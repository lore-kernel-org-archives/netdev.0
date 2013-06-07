From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: tcp: move GRO/GSO functions to tcp_offload
Date: Fri,  7 Jun 2013 17:11:46 +0200
Message-ID: <1370617906-4849-2-git-send-email-dborkman@redhat.com>
References: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab3FGPLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 11:11:54 -0400
In-Reply-To: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would be good to make things explicit and move those functions to
a new file called tcp_offload.c, thus make this similar to tcpv6_offload.c.
While moving all related functions into tcp_offload.c, we can also
make some of them static, since they are only used there. Also, add
an explicit registration function.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 I'll also follow-up with a udp_offload.c very soon after we agreed on this one.

 include/net/tcp.h      |   9 +-
 net/ipv4/Makefile      |   2 +-
 net/ipv4/af_inet.c     |  13 +-
 net/ipv4/tcp.c         | 241 -----------------------------------
 net/ipv4/tcp_ipv4.c    |  66 +---------
 net/ipv4/tcp_offload.c | 332 +++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 341 insertions(+), 322 deletions(-)
 create mode 100644 net/ipv4/tcp_offload.c

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bf1cc3d..0d637e9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1541,15 +1541,14 @@ extern struct request_sock_ops tcp6_request_sock_ops;
 
 extern void tcp_v4_destroy_sock(struct sock *sk);
 
-extern int tcp_v4_gso_send_check(struct sk_buff *skb);
 extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 				       netdev_features_t features);
 extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb);
-extern struct sk_buff **tcp4_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb);
 extern int tcp_gro_complete(struct sk_buff *skb);
-extern int tcp4_gro_complete(struct sk_buff *skb);
+
+extern void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr,
+				__be32 daddr);
 
 #ifdef CONFIG_PROC_FS
 extern int tcp4_proc_init(void);
@@ -1584,6 +1583,8 @@ struct tcp_request_sock_ops {
 #endif
 };
 
+extern int tcpv4_offload_init(void);
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 089cb9f..4d3e138 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -8,7 +8,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
-	     datagram.o raw.o udp.o udplite.o \
+	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ping.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9c090c7..7b51429 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1559,15 +1559,6 @@ static const struct net_protocol tcp_protocol = {
 	.netns_ok	=	1,
 };
 
-static const struct net_offload tcp_offload = {
-	.callbacks = {
-		.gso_send_check	=	tcp_v4_gso_send_check,
-		.gso_segment	=	tcp_tso_segment,
-		.gro_receive	=	tcp4_gro_receive,
-		.gro_complete	=	tcp4_gro_complete,
-	},
-};
-
 static const struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
@@ -1683,8 +1674,8 @@ static int __init ipv4_offload_init(void)
 	 */
 	if (inet_add_offload(&udp_offload, IPPROTO_UDP) < 0)
 		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
-	if (inet_add_offload(&tcp_offload, IPPROTO_TCP) < 0)
-		pr_crit("%s: Cannot add TCP protocol offlaod\n", __func__);
+	if (tcpv4_offload_init() < 0)
+		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
 
 	dev_add_offload(&ip_packet_offload);
 	return 0;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6a1cf95..bc42469 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2877,247 +2877,6 @@ int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
-	netdev_features_t features)
-{
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	struct tcphdr *th;
-	unsigned int thlen;
-	unsigned int seq;
-	__be32 delta;
-	unsigned int oldlen;
-	unsigned int mss;
-	struct sk_buff *gso_skb = skb;
-	__sum16 newcheck;
-	bool ooo_okay, copy_destructor;
-
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		goto out;
-
-	th = tcp_hdr(skb);
-	thlen = th->doff * 4;
-	if (thlen < sizeof(*th))
-		goto out;
-
-	if (!pskb_may_pull(skb, thlen))
-		goto out;
-
-	oldlen = (u16)~skb->len;
-	__skb_pull(skb, thlen);
-
-	mss = tcp_skb_mss(skb);
-	if (unlikely(skb->len <= mss))
-		goto out;
-
-	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
-		/* Packet is from an untrusted source, reset gso_segs. */
-		int type = skb_shinfo(skb)->gso_type;
-
-		if (unlikely(type &
-			     ~(SKB_GSO_TCPV4 |
-			       SKB_GSO_DODGY |
-			       SKB_GSO_TCP_ECN |
-			       SKB_GSO_TCPV6 |
-			       SKB_GSO_GRE |
-			       SKB_GSO_MPLS |
-			       SKB_GSO_UDP_TUNNEL |
-			       0) ||
-			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
-			goto out;
-
-		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
-
-		segs = NULL;
-		goto out;
-	}
-
-	copy_destructor = gso_skb->destructor == tcp_wfree;
-	ooo_okay = gso_skb->ooo_okay;
-	/* All segments but the first should have ooo_okay cleared */
-	skb->ooo_okay = 0;
-
-	segs = skb_segment(skb, features);
-	if (IS_ERR(segs))
-		goto out;
-
-	/* Only first segment might have ooo_okay set */
-	segs->ooo_okay = ooo_okay;
-
-	delta = htonl(oldlen + (thlen + mss));
-
-	skb = segs;
-	th = tcp_hdr(skb);
-	seq = ntohl(th->seq);
-
-	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
-					       (__force u32)delta));
-
-	do {
-		th->fin = th->psh = 0;
-		th->check = newcheck;
-
-		if (skb->ip_summed != CHECKSUM_PARTIAL)
-			th->check =
-			     csum_fold(csum_partial(skb_transport_header(skb),
-						    thlen, skb->csum));
-
-		seq += mss;
-		if (copy_destructor) {
-			skb->destructor = gso_skb->destructor;
-			skb->sk = gso_skb->sk;
-			/* {tcp|sock}_wfree() use exact truesize accounting :
-			 * sum(skb->truesize) MUST be exactly be gso_skb->truesize
-			 * So we account mss bytes of 'true size' for each segment.
-			 * The last segment will contain the remaining.
-			 */
-			skb->truesize = mss;
-			gso_skb->truesize -= mss;
-		}
-		skb = skb->next;
-		th = tcp_hdr(skb);
-
-		th->seq = htonl(seq);
-		th->cwr = 0;
-	} while (skb->next);
-
-	/* Following permits TCP Small Queues to work well with GSO :
-	 * The callback to TCP stack will be called at the time last frag
-	 * is freed at TX completion, and not right now when gso_skb
-	 * is freed by GSO engine
-	 */
-	if (copy_destructor) {
-		swap(gso_skb->sk, skb->sk);
-		swap(gso_skb->destructor, skb->destructor);
-		swap(gso_skb->truesize, skb->truesize);
-	}
-
-	delta = htonl(oldlen + (skb_tail_pointer(skb) -
-				skb_transport_header(skb)) +
-		      skb->data_len);
-	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
-				(__force u32)delta));
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		th->check = csum_fold(csum_partial(skb_transport_header(skb),
-						   thlen, skb->csum));
-
-out:
-	return segs;
-}
-EXPORT_SYMBOL(tcp_tso_segment);
-
-struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
-{
-	struct sk_buff **pp = NULL;
-	struct sk_buff *p;
-	struct tcphdr *th;
-	struct tcphdr *th2;
-	unsigned int len;
-	unsigned int thlen;
-	__be32 flags;
-	unsigned int mss = 1;
-	unsigned int hlen;
-	unsigned int off;
-	int flush = 1;
-	int i;
-
-	off = skb_gro_offset(skb);
-	hlen = off + sizeof(*th);
-	th = skb_gro_header_fast(skb, off);
-	if (skb_gro_header_hard(skb, hlen)) {
-		th = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!th))
-			goto out;
-	}
-
-	thlen = th->doff * 4;
-	if (thlen < sizeof(*th))
-		goto out;
-
-	hlen = off + thlen;
-	if (skb_gro_header_hard(skb, hlen)) {
-		th = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!th))
-			goto out;
-	}
-
-	skb_gro_pull(skb, thlen);
-
-	len = skb_gro_len(skb);
-	flags = tcp_flag_word(th);
-
-	for (; (p = *head); head = &p->next) {
-		if (!NAPI_GRO_CB(p)->same_flow)
-			continue;
-
-		th2 = tcp_hdr(p);
-
-		if (*(u32 *)&th->source ^ *(u32 *)&th2->source) {
-			NAPI_GRO_CB(p)->same_flow = 0;
-			continue;
-		}
-
-		goto found;
-	}
-
-	goto out_check_final;
-
-found:
-	flush = NAPI_GRO_CB(p)->flush;
-	flush |= (__force int)(flags & TCP_FLAG_CWR);
-	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
-		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
-	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
-	for (i = sizeof(*th); i < thlen; i += 4)
-		flush |= *(u32 *)((u8 *)th + i) ^
-			 *(u32 *)((u8 *)th2 + i);
-
-	mss = tcp_skb_mss(p);
-
-	flush |= (len - 1) >= mss;
-	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
-
-	if (flush || skb_gro_receive(head, skb)) {
-		mss = 1;
-		goto out_check_final;
-	}
-
-	p = *head;
-	th2 = tcp_hdr(p);
-	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
-
-out_check_final:
-	flush = len < mss;
-	flush |= (__force int)(flags & (TCP_FLAG_URG | TCP_FLAG_PSH |
-					TCP_FLAG_RST | TCP_FLAG_SYN |
-					TCP_FLAG_FIN));
-
-	if (p && (!NAPI_GRO_CB(skb)->same_flow || flush))
-		pp = head;
-
-out:
-	NAPI_GRO_CB(skb)->flush |= flush;
-
-	return pp;
-}
-EXPORT_SYMBOL(tcp_gro_receive);
-
-int tcp_gro_complete(struct sk_buff *skb)
-{
-	struct tcphdr *th = tcp_hdr(skb);
-
-	skb->csum_start = skb_transport_header(skb) - skb->head;
-	skb->csum_offset = offsetof(struct tcphdr, check);
-	skb->ip_summed = CHECKSUM_PARTIAL;
-
-	skb_shinfo(skb)->gso_segs = NAPI_GRO_CB(skb)->count;
-
-	if (th->cwr)
-		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
-
-	return 0;
-}
-EXPORT_SYMBOL(tcp_gro_complete);
-
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
 static DEFINE_MUTEX(tcp_md5sig_mutex);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d20ede0..289039b4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -545,8 +545,7 @@ out:
 	sock_put(sk);
 }
 
-static void __tcp_v4_send_check(struct sk_buff *skb,
-				__be32 saddr, __be32 daddr)
+void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 
@@ -571,23 +570,6 @@ void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(tcp_v4_send_check);
 
-int tcp_v4_gso_send_check(struct sk_buff *skb)
-{
-	const struct iphdr *iph;
-	struct tcphdr *th;
-
-	if (!pskb_may_pull(skb, sizeof(*th)))
-		return -EINVAL;
-
-	iph = ip_hdr(skb);
-	th = tcp_hdr(skb);
-
-	th->check = 0;
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	__tcp_v4_send_check(skb, iph->saddr, iph->daddr);
-	return 0;
-}
-
 /*
  *	This routine will send an RST to the other tcp.
  *
@@ -2795,52 +2777,6 @@ void tcp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
-struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
-{
-	const struct iphdr *iph = skb_gro_network_header(skb);
-	__wsum wsum;
-	__sum16 sum;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
-				  skb->csum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			break;
-		}
-flush:
-		NAPI_GRO_CB(skb)->flush = 1;
-		return NULL;
-
-	case CHECKSUM_NONE:
-		wsum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
-					  skb_gro_len(skb), IPPROTO_TCP, 0);
-		sum = csum_fold(skb_checksum(skb,
-					     skb_gro_offset(skb),
-					     skb_gro_len(skb),
-					     wsum));
-		if (sum)
-			goto flush;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		break;
-	}
-
-	return tcp_gro_receive(head, skb);
-}
-
-int tcp4_gro_complete(struct sk_buff *skb)
-{
-	const struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
-
-	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
-				  iph->saddr, iph->daddr, 0);
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
-
-	return tcp_gro_complete(skb);
-}
-
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
new file mode 100644
index 0000000..3a7525e
--- /dev/null
+++ b/net/ipv4/tcp_offload.c
@@ -0,0 +1,332 @@
+/*
+ *	IPV4 GSO/GRO offload support
+ *	Linux INET implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	TCPv4 GSO/GRO support
+ */
+
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+#include <net/protocol.h>
+
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+				netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct tcphdr *th;
+	unsigned int thlen;
+	unsigned int seq;
+	__be32 delta;
+	unsigned int oldlen;
+	unsigned int mss;
+	struct sk_buff *gso_skb = skb;
+	__sum16 newcheck;
+	bool ooo_okay, copy_destructor;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		goto out;
+
+	th = tcp_hdr(skb);
+	thlen = th->doff * 4;
+	if (thlen < sizeof(*th))
+		goto out;
+
+	if (!pskb_may_pull(skb, thlen))
+		goto out;
+
+	oldlen = (u16)~skb->len;
+	__skb_pull(skb, thlen);
+
+	mss = tcp_skb_mss(skb);
+	if (unlikely(skb->len <= mss))
+		goto out;
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type &
+			     ~(SKB_GSO_TCPV4 |
+			       SKB_GSO_DODGY |
+			       SKB_GSO_TCP_ECN |
+			       SKB_GSO_TCPV6 |
+			       SKB_GSO_GRE |
+			       SKB_GSO_MPLS |
+			       SKB_GSO_UDP_TUNNEL |
+			       0) ||
+			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
+			goto out;
+
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
+
+		segs = NULL;
+		goto out;
+	}
+
+	copy_destructor = gso_skb->destructor == tcp_wfree;
+	ooo_okay = gso_skb->ooo_okay;
+	/* All segments but the first should have ooo_okay cleared */
+	skb->ooo_okay = 0;
+
+	segs = skb_segment(skb, features);
+	if (IS_ERR(segs))
+		goto out;
+
+	/* Only first segment might have ooo_okay set */
+	segs->ooo_okay = ooo_okay;
+
+	delta = htonl(oldlen + (thlen + mss));
+
+	skb = segs;
+	th = tcp_hdr(skb);
+	seq = ntohl(th->seq);
+
+	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
+					       (__force u32)delta));
+
+	do {
+		th->fin = th->psh = 0;
+		th->check = newcheck;
+
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
+			th->check =
+			     csum_fold(csum_partial(skb_transport_header(skb),
+						    thlen, skb->csum));
+
+		seq += mss;
+		if (copy_destructor) {
+			skb->destructor = gso_skb->destructor;
+			skb->sk = gso_skb->sk;
+			/* {tcp|sock}_wfree() use exact truesize accounting :
+			 * sum(skb->truesize) MUST be exactly be gso_skb->truesize
+			 * So we account mss bytes of 'true size' for each segment.
+			 * The last segment will contain the remaining.
+			 */
+			skb->truesize = mss;
+			gso_skb->truesize -= mss;
+		}
+		skb = skb->next;
+		th = tcp_hdr(skb);
+
+		th->seq = htonl(seq);
+		th->cwr = 0;
+	} while (skb->next);
+
+	/* Following permits TCP Small Queues to work well with GSO :
+	 * The callback to TCP stack will be called at the time last frag
+	 * is freed at TX completion, and not right now when gso_skb
+	 * is freed by GSO engine
+	 */
+	if (copy_destructor) {
+		swap(gso_skb->sk, skb->sk);
+		swap(gso_skb->destructor, skb->destructor);
+		swap(gso_skb->truesize, skb->truesize);
+	}
+
+	delta = htonl(oldlen + (skb_tail_pointer(skb) -
+				skb_transport_header(skb)) +
+		      skb->data_len);
+	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
+				(__force u32)delta));
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		th->check = csum_fold(csum_partial(skb_transport_header(skb),
+						   thlen, skb->csum));
+out:
+	return segs;
+}
+EXPORT_SYMBOL(tcp_tso_segment);
+
+struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	struct tcphdr *th;
+	struct tcphdr *th2;
+	unsigned int len;
+	unsigned int thlen;
+	__be32 flags;
+	unsigned int mss = 1;
+	unsigned int hlen;
+	unsigned int off;
+	int flush = 1;
+	int i;
+
+	off = skb_gro_offset(skb);
+	hlen = off + sizeof(*th);
+	th = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		th = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!th))
+			goto out;
+	}
+
+	thlen = th->doff * 4;
+	if (thlen < sizeof(*th))
+		goto out;
+
+	hlen = off + thlen;
+	if (skb_gro_header_hard(skb, hlen)) {
+		th = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!th))
+			goto out;
+	}
+
+	skb_gro_pull(skb, thlen);
+
+	len = skb_gro_len(skb);
+	flags = tcp_flag_word(th);
+
+	for (; (p = *head); head = &p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		th2 = tcp_hdr(p);
+
+		if (*(u32 *)&th->source ^ *(u32 *)&th2->source) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		goto found;
+	}
+
+	goto out_check_final;
+
+found:
+	flush = NAPI_GRO_CB(p)->flush;
+	flush |= (__force int)(flags & TCP_FLAG_CWR);
+	flush |= (__force int)((flags ^ tcp_flag_word(th2)) &
+		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH));
+	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
+	for (i = sizeof(*th); i < thlen; i += 4)
+		flush |= *(u32 *)((u8 *)th + i) ^
+			 *(u32 *)((u8 *)th2 + i);
+
+	mss = tcp_skb_mss(p);
+
+	flush |= (len - 1) >= mss;
+	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
+
+	if (flush || skb_gro_receive(head, skb)) {
+		mss = 1;
+		goto out_check_final;
+	}
+
+	p = *head;
+	th2 = tcp_hdr(p);
+	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
+
+out_check_final:
+	flush = len < mss;
+	flush |= (__force int)(flags & (TCP_FLAG_URG | TCP_FLAG_PSH |
+					TCP_FLAG_RST | TCP_FLAG_SYN |
+					TCP_FLAG_FIN));
+
+	if (p && (!NAPI_GRO_CB(skb)->same_flow || flush))
+		pp = head;
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+EXPORT_SYMBOL(tcp_gro_receive);
+
+int tcp_gro_complete(struct sk_buff *skb)
+{
+	struct tcphdr *th = tcp_hdr(skb);
+
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct tcphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+
+	skb_shinfo(skb)->gso_segs = NAPI_GRO_CB(skb)->count;
+
+	if (th->cwr)
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_gro_complete);
+
+static int tcp_v4_gso_send_check(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	struct tcphdr *th;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		return -EINVAL;
+
+	iph = ip_hdr(skb);
+	th = tcp_hdr(skb);
+
+	th->check = 0;
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	__tcp_v4_send_check(skb, iph->saddr, iph->daddr);
+	return 0;
+}
+
+static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	const struct iphdr *iph = skb_gro_network_header(skb);
+	__wsum wsum;
+	__sum16 sum;
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
+				  skb->csum)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+flush:
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+
+	case CHECKSUM_NONE:
+		wsum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
+					  skb_gro_len(skb), IPPROTO_TCP, 0);
+		sum = csum_fold(skb_checksum(skb,
+					     skb_gro_offset(skb),
+					     skb_gro_len(skb),
+					     wsum));
+		if (sum)
+			goto flush;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
+	}
+
+	return tcp_gro_receive(head, skb);
+}
+
+static int tcp4_gro_complete(struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
+
+	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
+				  iph->saddr, iph->daddr, 0);
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+
+	return tcp_gro_complete(skb);
+}
+
+static const struct net_offload tcpv4_offload = {
+	.callbacks = {
+		.gso_send_check	=	tcp_v4_gso_send_check,
+		.gso_segment	=	tcp_tso_segment,
+		.gro_receive	=	tcp4_gro_receive,
+		.gro_complete	=	tcp4_gro_complete,
+	},
+};
+
+int __init tcpv4_offload_init(void)
+{
+	return inet_add_offload(&tcpv4_offload, IPPROTO_TCP);
+}
-- 
1.7.11.7
