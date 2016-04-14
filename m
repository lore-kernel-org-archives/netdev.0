From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 5/5] ip6gre: Add support for GSO
Date: Thu, 14 Apr 2016 15:34:04 -0400
Message-ID: <20160414193404.12934.48572.stgit@ahduyck-xeon-server>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34169 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:34:11 -0400
Received: by mail-pf0-f178.google.com with SMTP id c20so48853305pfc.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:34:11 -0700 (PDT)
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code borrowed from bits and pieces of other protocols to
the IPv6 GRE path so that we can support GSO over IPv6 based GRE tunnels.
By adding this support we are able to significantly improve the throughput
for GRE tunnels as we are able to make use of GSO.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv6/ip6_gre.c |   56 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 33 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 1a5ad143be40..ca5a2c5675c5 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -621,7 +621,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	struct net *net = tunnel->net;
 	struct net_device *tdev;    /* Device to other host */
 	struct ipv6hdr  *ipv6h;     /* Our new IP header */
-	unsigned int max_headroom = 0; /* The extra header space needed */
+	unsigned int min_headroom = 0; /* The extra header space needed */
 	int    gre_hlen;
 	struct ipv6_tel_txoption opt;
 	int    mtu;
@@ -629,7 +629,6 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	struct net_device_stats *stats = &tunnel->dev->stats;
 	int err = -1;
 	u8 proto;
-	struct sk_buff *new_skb;
 	__be16 protocol;
 
 	if (dev->type == ARPHRD_ETHER)
@@ -672,14 +671,14 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 
 	mtu = dst_mtu(dst) - sizeof(*ipv6h);
 	if (encap_limit >= 0) {
-		max_headroom += 8;
+		min_headroom += 8;
 		mtu -= 8;
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		*pmtu = mtu;
 		err = -EMSGSIZE;
 		goto tx_err_dst_release;
@@ -697,20 +696,19 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
 
-	max_headroom += LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
+	min_headroom += LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
 
-	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
-	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
-		new_skb = skb_realloc_headroom(skb, max_headroom);
-		if (max_headroom > dev->needed_headroom)
-			dev->needed_headroom = max_headroom;
-		if (!new_skb)
-			goto tx_err_dst_release;
+	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
+		int head_delta = SKB_DATA_ALIGN(min_headroom -
+						skb_headroom(skb) +
+						16);
 
-		if (skb->sk)
-			skb_set_owner_w(new_skb, skb->sk);
-		consume_skb(skb);
-		skb = new_skb;
+		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
+				       0, GFP_ATOMIC);
+		if (min_headroom > dev->needed_headroom)
+			dev->needed_headroom = min_headroom;
+		if (unlikely(err))
+			goto tx_err_dst_release;
 	}
 
 	if (!fl6->flowi6_mark && ndst)
@@ -723,10 +721,11 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
 	}
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	err = iptunnel_handle_offloads(skb,
+				       (tunnel->parms.o_flags & GRE_CSUM) ?
+				       SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
+	if (err)
+		goto tx_err_dst_release;
 
 	skb_push(skb, gre_hlen);
 	skb_reset_network_header(skb);
@@ -760,7 +759,9 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 			*ptr = tunnel->parms.o_key;
 			ptr--;
 		}
-		if (tunnel->parms.o_flags&GRE_CSUM) {
+		if ((tunnel->parms.o_flags & GRE_CSUM) &&
+		    !(skb_shinfo(skb)->gso_type &
+		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
 			*ptr = 0;
 			*(__sum16 *)ptr = gre6_checksum(skb);
 		}
@@ -1559,9 +1560,18 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 	dev->features		|= GRE6_FEATURES;
 	dev->hw_features	|= GRE6_FEATURES;
 
-	/* Can use a lockless transmit, unless we generate output sequences */
-	if (!(nt->parms.o_flags & GRE_SEQ))
+	if (!(nt->parms.o_flags & GRE_SEQ)) {
+		/* TCP segmentation offload is not supported when we
+		 * generate output sequences.
+		 */
+		dev->features    |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+
+		/* Can use a lockless transmit, unless we generate
+		 * output sequences
+		 */
 		dev->features |= NETIF_F_LLTX;
+	}
 
 	err = register_netdevice(dev);
 	if (err)
