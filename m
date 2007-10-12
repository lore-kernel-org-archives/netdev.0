From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [PATCH 4/4] UDP memory accounting and limitation(take 5): memory
 limitation
Date: Fri, 12 Oct 2007 21:11:27 +0900
Message-ID: <470F646F.2030003@hitachi.com>
References: <470F61D4.6040808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBETFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:58499 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbXJLMLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:11:32 -0400
Received: from mlsv15.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 320C637AEC
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 21:11:31 +0900 (JST)
In-Reply-To: <470F61D4.6040808@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces memory limitation for UDP.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-udp_limit/include/net/udp.h
===================================================================
--- 2.6.23-udp_limit.orig/include/net/udp.h
+++ 2.6.23-udp_limit/include/net/udp.h
@@ -65,7 +65,10 @@ extern rwlock_t udp_hash_lock;
 
 extern struct proto udp_prot;
 
+/* Used by memory accounting and capping */
+#define UDP_MIN_SKB_PAGES	4096
 extern atomic_t udp_memory_allocated;
+extern int sysctl_udp_mem;
 
 struct sk_buff;
 
Index: 2.6.23-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-udp_limit/net/ipv4/udp.c
@@ -114,6 +114,7 @@ struct hlist_head udp_hash[UDP_HTABLE_SI
 DEFINE_RWLOCK(udp_hash_lock);
 
 atomic_t udp_memory_allocated;
+int sysctl_udp_mem = UDP_MIN_SKB_PAGES;
 
 static int udp_port_rover;
 
@@ -1016,6 +1017,16 @@ int udp_queue_rcv_skb(struct sock * sk, 
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
@@ -1451,6 +1462,7 @@ struct proto udp_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = &sysctl_udp_mem,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
Index: 2.6.23-udp_limit/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.23-udp_limit/net/ipv4/sysctl_net_ipv4.c
@@ -17,6 +17,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/cipso_ipv4.h>
 
 /* From af_inet.c */
@@ -25,6 +26,7 @@ extern int sysctl_ip_nonlocal_bind;
 #ifdef CONFIG_SYSCTL
 static int zero;
 static int tcp_retr1_max = 255;
+static int udp_mem_min = UDP_MIN_SKB_PAGES;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 #endif
@@ -599,6 +601,16 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_mem",
+		.data		= &sysctl_udp_mem,
+		.maxlen		= sizeof(sysctl_udp_mem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &udp_mem_min
+	},
+	{
 		.ctl_name	= NET_TCP_APP_WIN,
 		.procname	= "tcp_app_win",
 		.data		= &sysctl_tcp_app_win,
Index: 2.6.23-udp_limit/net/ipv4/ip_output.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/ip_output.c
+++ 2.6.23-udp_limit/net/ipv4/ip_output.c
@@ -75,6 +75,7 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
+#include <net/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -699,6 +700,21 @@ csum_page(struct page *page, int offset,
 	return csum;
 }
 
+static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
+{
+	switch(sk->sk_protocol) {
+	case IPPROTO_UDP:
+		if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
+			if (atomic_read(sk->sk_prot->memory_allocated)+size
+			    >= sk->sk_prot->sysctl_mem[0])
+				return -ENOBUFS;
+		/* Fall through */	
+	default:
+		break;
+	}
+	return 0;
+}
+
 static inline int ip_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			       int odd, struct sk_buff *skb),
@@ -910,6 +926,12 @@ alloc_new_skb:
 			if (datalen == length + fraggap)
 				alloclen += rt->u.dst.trailer_len;
 
+			err = __ip_check_max_skb_pages(sk,
+				sk_datagram_pages(SKB_DATA_ALIGN(alloclen + hh_len + 15)
+				+ sizeof(struct sk_buff)));
+			if (err)
+				goto error;
+
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,
@@ -1009,6 +1031,11 @@ alloc_new_skb:
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
+				err = __ip_check_max_skb_pages(sk,
+					sk_datagram_pages(PAGE_SIZE));
+				if (err)
+					goto error;
+
 				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
 				    > 2 * sk->sk_sndbuf) {
 					err = -ENOBUFS;
@@ -1126,6 +1153,12 @@ ssize_t	ip_append_page(struct sock *sk, 
 			fraggap = skb_prev->len - maxfraglen;
 
 			alloclen = fragheaderlen + hh_len + fraggap + 15;
+
+			err = __ip_check_max_skb_pages(sk,
+				sk_datagram_pages(alloclen + sizeof(struct sk_buff)));
+			if (err)
+				goto error;
+
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
 			if (unlikely(!skb)) {
 				err = -ENOBUFS;
Index: 2.6.23-udp_limit/Documentation/networking/ip-sysctl.txt
===================================================================
--- 2.6.23-udp_limit.orig/Documentation/networking/ip-sysctl.txt
+++ 2.6.23-udp_limit/Documentation/networking/ip-sysctl.txt
@@ -439,6 +439,14 @@ tcp_dma_copybreak - INTEGER
 	and CONFIG_NET_DMA is enabled.
 	Default: 4096
 
+UDP variables:
+
+udp_mem - INTERGER
+	Number of pages allowed for queueing by all UDP sockets.
+	Minimal value is 4096. If 4096 is set, UDP memory will not
+	be limited.
+	Default: 4096
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN

