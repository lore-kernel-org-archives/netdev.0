From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] udp: Add socket early demux support
Date: Tue, 26 Jun 2012 12:43:46 -0700
Message-ID: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, shemminger@vyatta.com, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:61305 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960Ab2FZTio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 15:38:44 -0400
Received: by dady13 with SMTP id y13so329079dad.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 12:38:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the recent TCP socket early demux code, this patch provides similar
support for UDP.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
This has been tested on x86 with UDP iperf flows and seemed to work. If this is
accepted, I plan to submit one more patch moving common code from TCP and UDP
early demux code into common helper functions.
Thanks in advance for feedback.

 include/net/udp.h  |    1 +
 net/ipv4/af_inet.c |    1 +
 net/ipv4/udp.c     |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 67 insertions(+), 2 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 065f379..e0ed11d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -175,6 +175,7 @@ extern int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			    unsigned int hash2_nulladdr);
 
 /* net/ipv4/udp.c */
+extern int udp_v4_early_demux(struct sk_buff *skb);
 extern int udp_get_port(struct sock *sk, unsigned short snum,
 			int (*saddr_cmp)(const struct sock *,
 					 const struct sock *));
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 07a02f6..c7d40db 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1531,6 +1531,7 @@ static const struct net_protocol tcp_protocol = {
 };
 
 static const struct net_protocol udp_protocol = {
+	.early_demux =	udp_v4_early_demux,
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.gso_send_check = udp4_ufo_send_check,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index db017ef..bd85cd8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -520,10 +520,10 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
 						 struct udp_table *udptable)
 {
-	struct sock *sk;
+	struct sock *sk = skb_steal_sock(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 
-	if (unlikely(sk = skb_steal_sock(skb)))
+	if (sk)
 		return sk;
 	else
 		return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
@@ -1403,6 +1403,19 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
+	if (sk->sk_rx_dst) {
+		struct dst_entry *dst = sk->sk_rx_dst;
+		if (unlikely(dst->obsolete)) {
+			if (dst->ops->check(dst, 0) == NULL) {
+				dst_release(dst);
+				sk->sk_rx_dst = NULL;
+			}
+		}
+	}
+
+	if (unlikely(sk->sk_rx_dst == NULL))
+		sk->sk_rx_dst = dst_clone(skb_dst(skb));
+
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
 	 */
@@ -1622,6 +1635,56 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 	return 0;
 }
 
+int udp_v4_early_demux(struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb->dev);
+	const struct iphdr *iph;
+	const struct udphdr *uh;
+	struct net_device *dev;
+	struct sock *sk;
+	unsigned short ulen;
+	int err;
+
+	err = -ENOENT;
+	if (skb->pkt_type != PACKET_HOST)
+		goto out_err;
+
+	if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct udphdr)))
+		goto out_err;
+
+	iph = ip_hdr(skb);
+	uh = (struct udphdr *)((char *)iph + ip_hdrlen(skb));
+	ulen = ntohs(uh->len);
+
+	if (ulen > skb->len)
+		goto out_err;
+
+	dev = skb->dev;
+
+	sk = udp4_lib_lookup(net, iph->saddr, uh->source, iph->daddr,
+			     uh->dest, dev->ifindex);
+
+	if (sk) {
+		struct dst_entry *dst = sk->sk_rx_dst;
+		skb->sk = sk;
+		skb->destructor = sock_edemux;
+
+		if (dst)
+			dst = dst_check(dst, 0);
+		if (dst) {
+			struct rtable *rt = (struct rtable *)dst;
+
+			if (rt->rt_iif == dev->ifindex) {
+				skb_dst_set_noref(skb, dst);
+				err = 0;
+			}
+		}
+	}
+
+out_err:
+	return err;
+}
+
 /*
  *	All we need to do is get the socket, and then do a checksum.
  */
-- 
1.7.0.4
