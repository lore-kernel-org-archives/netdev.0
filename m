From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 4/5] memory limitation by using udp_mem
Date: Mon, 29 Oct 2007 17:23:33 -0400
Message-ID: <47264F55.40301@redhat.com>
References: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000805020309040908030602"
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbXJ2V2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:28:52 -0400
In-Reply-To: <47264E2D.4080109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000805020309040908030602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces memory limitation for UDP.

--
Hideo Aoki
Hitachi Computer Products (America) Inc.

--------------000805020309040908030602
Content-Type: text/x-patch;
 name="udp_memory_limit_ipv4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_memory_limit_ipv4.patch"


Signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Signed-off-by: Hideo Aoki <haoki@redhat.com>

 Documentation/networking/ip-sysctl.txt |    6 ++++
 include/net/udp.h                      |    3 ++
 net/ipv4/af_inet.c                     |    3 ++
 net/ipv4/ip_output.c                   |   47 ++++++++++++++++++++++++++++++---
 net/ipv4/sysctl_net_ipv4.c             |   11 +++++++
 net/ipv4/udp.c                         |   24 ++++++++++++++++
 6 files changed, 91 insertions(+), 3 deletions(-)

diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/Documentation/networking/ip-sysctl.txt linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/Documentation/networking/ip-sysctl.txt	2007-10-24 11:33:58.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/Documentation/networking/ip-sysctl.txt	2007-10-26 20:35:52.000000000 -0400
@@ -446,6 +446,12 @@ tcp_dma_copybreak - INTEGER
 	and CONFIG_NET_DMA is enabled.
 	Default: 4096
 
+UDP variables:
+
+udp_mem - INTEGER
+	Number of pages allowed for queueing by all UDP sockets.
+	Default is calculated at boot time from amount of available memory.
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/include/net/udp.h linux-2.6.24-rc1-mem003-ipv4-dev-p4/include/net/udp.h
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/include/net/udp.h	2007-10-24 11:47:51.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/include/net/udp.h	2007-10-26 20:35:52.000000000 -0400
@@ -66,6 +66,7 @@ extern rwlock_t udp_hash_lock;
 extern struct proto udp_prot;
 
 extern atomic_t udp_memory_allocated;
+extern int sysctl_udp_mem;
 
 struct sk_buff;
 
@@ -175,4 +176,6 @@ extern void udp_proc_unregister(struct u
 extern int  udp4_proc_init(void);
 extern void udp4_proc_exit(void);
 #endif
+
+extern void udp_init(void);
 #endif	/* _UDP_H */
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/af_inet.c linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/af_inet.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/af_inet.c	2007-10-24 19:10:27.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/af_inet.c	2007-10-26 20:35:52.000000000 -0400
@@ -1446,6 +1446,9 @@ static int __init inet_init(void)
 	/* Setup TCP slab cache for open requests. */
 	tcp_init();
 
+	/* Setup UDP memory threshold */
+	udp_init();
+
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();
 
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/ip_output.c linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/ip_output.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/ip_output.c	2007-10-24 12:31:47.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/ip_output.c	2007-10-29 09:36:32.000000000 -0400
@@ -75,6 +75,7 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
+#include <net/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -699,6 +700,20 @@ csum_page(struct page *page, int offset,
 	return csum;
 }
 
+static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
+{
+	switch(sk->sk_protocol) {
+	case IPPROTO_UDP:
+		if (atomic_read(sk->sk_prot->memory_allocated) + size
+		    > sk->sk_prot->sysctl_mem[0])
+			return -ENOBUFS;
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
@@ -707,16 +722,20 @@ static inline int ip_ufo_append_data(str
 {
 	struct sk_buff *skb;
 	int err;
+	int size = 0;
 
 	/* There is support for UDP fragmentation offload by network
 	 * device, so create one single skb packet containing complete
 	 * udp datagram
 	 */
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
-		skb = sock_alloc_send_skb(sk,
-			hh_len + fragheaderlen + transhdrlen + 20,
-			(flags & MSG_DONTWAIT), &err);
+		size = hh_len + fragheaderlen + transhdrlen + 20;
+		err = __ip_check_max_skb_pages(sk, sk_datagram_pages(size));
+		if (err)
+			return err;
 
+		skb = sock_alloc_send_skb(sk, size, (flags & MSG_DONTWAIT),
+					  &err);
 		if (skb == NULL)
 			return err;
 
@@ -737,6 +756,10 @@ static inline int ip_ufo_append_data(str
 		sk->sk_sndmsg_off = 0;
 	}
 
+	err = __ip_check_max_skb_pages(sk, sk_datagram_pages(size + length - 
+							     transhdrlen));
+	if (err)
+		goto fail;
 	err = skb_append_datato_frags(sk,skb, getfrag, from,
 			       (length - transhdrlen));
 	if (!err) {
@@ -752,6 +775,7 @@ static inline int ip_ufo_append_data(str
 	/* There is not enough support do UFO ,
 	 * so follow normal path
 	 */
+fail:
 	kfree_skb(skb);
 	return err;
 }
@@ -910,6 +934,12 @@ alloc_new_skb:
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
@@ -1009,6 +1039,11 @@ alloc_new_skb:
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
@@ -1126,6 +1161,12 @@ ssize_t	ip_append_page(struct sock *sk, 
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
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/sysctl_net_ipv4.c linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/sysctl_net_ipv4.c	2007-10-24 11:34:34.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/sysctl_net_ipv4.c	2007-10-26 20:35:52.000000000 -0400
@@ -18,6 +18,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
 
@@ -885,6 +886,16 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "udp_mem",
+		.data		= &sysctl_udp_mem,
+		.maxlen		= sizeof(sysctl_udp_mem),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero
+	},
 	{ .ctl_name = 0 }
 };
 
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/udp.c linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/udp.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/udp.c	2007-10-26 19:43:20.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p4/net/ipv4/udp.c	2007-10-26 20:35:52.000000000 -0400
@@ -82,6 +82,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <linux/bootmem.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/module.h>
@@ -115,6 +116,7 @@ struct hlist_head udp_hash[UDP_HTABLE_SI
 DEFINE_RWLOCK(udp_hash_lock);
 
 atomic_t udp_memory_allocated;
+int sysctl_udp_mem __read_mostly;
 
 static inline int __udp_lib_lport_inuse(__u16 num,
 					const struct hlist_head udptable[])
@@ -1023,6 +1025,13 @@ int udp_queue_rcv_skb(struct sock * sk, 
 			goto drop;
 	}
 
+	if ((atomic_read(sk->sk_prot->memory_allocated)
+		       + sk_datagram_pages(skb->truesize))
+		> sk->sk_prot->sysctl_mem[0]) {
+		UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
+	}
+
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
@@ -1458,6 +1467,7 @@ struct proto udp_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.memory_allocated  = &udp_memory_allocated,
+	.sysctl_mem	   = &sysctl_udp_mem,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
@@ -1652,6 +1662,20 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+void __init udp_init(void)
+{
+	unsigned long limit;
+
+	/* Set the pressure threshold up by the same strategy of TCP. It is a
+	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
+	 * toward zero with the amount of memory, with a floor of 128 pages.
+	 */
+	limit = min(nr_all_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (nr_all_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = max(limit, 128UL);
+	sysctl_udp_mem = limit / 2 * 3;
+}
+
 EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_hash);
 EXPORT_SYMBOL(udp_hash_lock);

--------------000805020309040908030602--
