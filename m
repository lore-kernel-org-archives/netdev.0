From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 4/4] UDP memory usage accounting (take 4): memory limitation
Date: Sat, 06 Oct 2007 00:02:47 +0900
Message-ID: <47065217.5050004@hitachi.com>
References: <47065139.5030402@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:38836 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbXJEPCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:02:52 -0400
Received: from mlsv9.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id B9B9133CCA
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 00:02:51 +0900 (JST)
In-Reply-To: <47065139.5030402@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces memory limitation for UDP.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-rc9-udp_limit/include/net/udp.h
===================================================================
--- 2.6.23-rc9-udp_limit.orig/include/net/udp.h
+++ 2.6.23-rc9-udp_limit/include/net/udp.h
@@ -65,7 +65,10 @@ extern rwlock_t udp_hash_lock;
 
 extern struct proto udp_prot;
 
+/* Used by memory accounting and capping */
+#define UDP_MIN_SKB_PAGES	4096
 extern atomic_t udp_memory_allocated;
+extern int sysctl_udp_mem;
 
 struct sk_buff;
 
Index: 2.6.23-rc9-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-rc9-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-rc9-udp_limit/net/ipv4/udp.c
@@ -114,8 +114,10 @@ struct hlist_head udp_hash[UDP_HTABLE_SI
 DEFINE_RWLOCK(udp_hash_lock);
 
 atomic_t udp_memory_allocated;
+int sysctl_udp_mem = 0;
 
 EXPORT_SYMBOL(udp_memory_allocated);
+EXPORT_SYMBOL(sysctl_udp_mem);
 
 static int udp_port_rover;
 
@@ -1018,6 +1020,16 @@ int udp_queue_rcv_skb(struct sock * sk, 
 			goto drop;
 	}
 
+	if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES) {
+		if ((atomic_read(sk->sk_prot->memory_allocated)
+			       + sk_datagram_pages(skb->truesize))
+			>= sk->sk_prot->sysctl_mem[0]) {
+			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS,
+				up->pcflag);
+			goto drop;
+		}
+	}
+
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
@@ -1453,6 +1465,7 @@ struct proto udp_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = &sysctl_udp_mem,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
Index: 2.6.23-rc9-udp_limit/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.23-rc9-udp_limit.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.23-rc9-udp_limit/net/ipv4/sysctl_net_ipv4.c
@@ -17,6 +17,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/cipso_ipv4.h>
 
 /* From af_inet.c */
@@ -599,6 +600,14 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= NET_UDP_MEM,
+		.procname	= "udp_mem",
+		.data		= &sysctl_udp_mem,
+		.maxlen		= sizeof(sysctl_udp_mem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{
 		.ctl_name	= NET_TCP_APP_WIN,
 		.procname	= "tcp_app_win",
 		.data		= &sysctl_tcp_app_win,
Index: 2.6.23-rc9-udp_limit/include/linux/sysctl.h
===================================================================
--- 2.6.23-rc9-udp_limit.orig/include/linux/sysctl.h
+++ 2.6.23-rc9-udp_limit/include/linux/sysctl.h
@@ -441,6 +441,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_UDP_MEM=126,
 };
 
 enum {
Index: 2.6.23-rc9-udp_limit/net/ipv4/ip_output.c
===================================================================
--- 2.6.23-rc9-udp_limit.orig/net/ipv4/ip_output.c
+++ 2.6.23-rc9-udp_limit/net/ipv4/ip_output.c
@@ -75,6 +75,7 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
+#include <net/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -910,6 +911,17 @@ alloc_new_skb:
 			if (datalen == length + fraggap)
 				alloclen += rt->u.dst.trailer_len;
 
+			if (sk->sk_prot->sysctl_mem)
+				if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
+					if ((atomic_read(sk->sk_prot->memory_allocated)
+						       + sk_datagram_pages(
+							   SKB_DATA_ALIGN(alloclen + hh_len + 15)
+							 + sizeof(struct sk_buff)))
+					     >= sk->sk_prot->sysctl_mem[0]) {
+						err = -ENOBUFS;
+						goto error;
+					}
+
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,
@@ -1009,6 +1021,15 @@ alloc_new_skb:
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
+				if (sk->sk_prot->sysctl_mem)
+					if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
+						if ((atomic_read(sk->sk_prot->memory_allocated)
+							       + sk_datagram_pages(PAGE_SIZE))
+						     >= sk->sk_prot->sysctl_mem[0]) {
+							err = -ENOBUFS;
+							goto error;
+						}
+
 				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
 				    > 2 * sk->sk_sndbuf) {
 					err = -ENOBUFS;
@@ -1126,6 +1147,17 @@ ssize_t	ip_append_page(struct sock *sk, 
 			fraggap = skb_prev->len - maxfraglen;
 
 			alloclen = fragheaderlen + hh_len + fraggap + 15;
+
+			if (sk->sk_prot->sysctl_mem)
+				if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
+					if((atomic_read(sk->sk_prot->memory_allocated)
+						      + sk_datagram_pages(alloclen
+									+ sizeof(struct sk_buff)))
+					    >= sk->sk_prot->sysctl_mem[0]) {
+						err = -ENOBUFS;
+						goto error;
+					}
+
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
 			if (unlikely(!skb)) {
 				err = -ENOBUFS;

