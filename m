From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [NET] gso: Add skb_is_gso
Date: Sat, 8 Jul 2006 13:53:02 +1000
Message-ID: <20060708035301.GA5351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:62219 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932430AbWGHDxK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 23:53:10 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

These two patches fix the netfilter/checksum/TSO problem where netfilter
destroys the partial checksum which breaks TSO.

[NET] gso: Add skb_is_gso

This patch adds the wrapper function skb_is_gso which can be used instead
of directly testing skb_shinfo(skb)->gso_size.  This makes things a little
nicer and allows us to change the primary key for indicating whether an skb
is GSO (if we ever want to do that).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1639,7 +1639,7 @@ bnx2_tx_int(struct bnx2 *bp)
 		skb = tx_buf->skb;
 #ifdef BCM_TSO 
 		/* partial BD completions possible with TSO packets */
-		if (skb_shinfo(skb)->gso_size) {
+		if (skb_is_gso(skb)) {
 			u16 last_idx, last_ring_idx;
 
 			last_idx = sw_cons +
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1417,7 +1417,7 @@ int t1_start_xmit(struct sk_buff *skb, s
 	struct cpl_tx_pkt *cpl;
 
 #ifdef NETIF_F_TSO
-	if (skb_shinfo(skb)->gso_size) {
+	if (skb_is_gso(skb)) {
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2394,7 +2394,7 @@ e1000_tso(struct e1000_adapter *adapter,
 	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
-	if (skb_shinfo(skb)->gso_size) {
+	if (skb_is_gso(skb)) {
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (err)
@@ -2519,7 +2519,7 @@ e1000_tx_map(struct e1000_adapter *adapt
 		 * tso gets written back prematurely before the data is fully
 		 * DMA'd to the controller */
 		if (!skb->data_len && tx_ring->last_tx_tso &&
-		    !skb_shinfo(skb)->gso_size) {
+		    !skb_is_gso(skb)) {
 			tx_ring->last_tx_tso = 0;
 			size -= 4;
 		}
@@ -2806,8 +2806,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 #ifdef NETIF_F_TSO
 	/* Controller Erratum workaround */
-	if (!skb->data_len && tx_ring->last_tx_tso &&
-	    !skb_shinfo(skb)->gso_size)
+	if (!skb->data_len && tx_ring->last_tx_tso && !skb_is_gso(skb))
 		count++;
 #endif
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1495,7 +1495,7 @@ static int nv_start_xmit(struct sk_buff 
 	np->tx_skbuff[nr] = skb;
 
 #ifdef NETIF_F_TSO
-	if (skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
 	else
 #endif
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1173,7 +1173,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 	uint16_t ipcse, tucse, mss;
 	int err;
 
-	if(likely(skb_shinfo(skb)->gso_size)) {
+	if (likely(skb_is_gso(skb))) {
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (err)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -139,7 +139,7 @@ static int loopback_xmit(struct sk_buff 
 #endif
 
 #ifdef LOOPBACK_TSO
-	if (skb_shinfo(skb)->gso_size) {
+	if (skb_is_gso(skb)) {
 		BUG_ON(skb->protocol != htons(ETH_P_IP));
 		BUG_ON(skb->nh.iph->protocol != IPPROTO_TCP);
 
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2116,7 +2116,7 @@ abort_linearize:
 		}
 		idx = (idx + 1) & tx->mask;
 	} while (idx != last_idx);
-	if (skb_shinfo(skb)->gso_size) {
+	if (skb_is_gso(skb)) {
 		printk(KERN_ERR
 		       "myri10ge: %s: TSO but wanted to linearize?!?!?\n",
 		       mgp->dev->name);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1159,7 +1159,7 @@ static unsigned tx_le_req(const struct s
 	count = sizeof(dma_addr_t) / sizeof(u32);
 	count += skb_shinfo(skb)->nr_frags * count;
 
-	if (skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		++count;
 
 	if (skb->ip_summed == CHECKSUM_HW)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -805,7 +805,7 @@ typhoon_start_tx(struct sk_buff *skb, st
 	 * If problems develop with TSO, check this first.
 	 */
 	numDesc = skb_shinfo(skb)->nr_frags + 1;
-	if(skb_tso_size(skb))
+	if (skb_is_gso(skb))
 		numDesc++;
 
 	/* When checking for free space in the ring, we need to also
@@ -845,7 +845,7 @@ typhoon_start_tx(struct sk_buff *skb, st
 				TYPHOON_TX_PF_VLAN_TAG_SHIFT);
 	}
 
-	if(skb_tso_size(skb)) {
+	if (skb_is_gso(skb)) {
 		first_txd->processFlags |= TYPHOON_TX_PF_TCP_SEGMENT;
 		first_txd->numDesc++;
 
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -4457,7 +4457,7 @@ qeth_send_packet(struct qeth_card *card,
 	queue = card->qdio.out_qs
 		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
 
-	if (skb_shinfo(skb)->gso_size)
+	if (skb_is_gso(skb))
 		large_send = card->options.large_send;
 
 	/*are we able to do TSO ? If so ,prepare and send it from here */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1001,7 +1001,7 @@ static inline int net_gso_ok(int feature
 
 static inline int skb_gso_ok(struct sk_buff *skb, int features)
 {
-	return net_gso_ok(features, skb_shinfo(skb)->gso_size ?
+	return net_gso_ok(features, skb_is_gso(skb) ?
 				    skb_shinfo(skb)->gso_type : 0);
 }
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1455,5 +1455,10 @@ static inline void skb_init_secmark(stru
 { }
 #endif
 
+static inline int skb_is_gso(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_size;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,7 +35,7 @@ static inline unsigned packet_length(con
 int br_dev_queue_push_xmit(struct sk_buff *skb)
 {
 	/* drop mtu oversized packets except gso */
-	if (packet_length(skb) > skb->dev->mtu && !skb_shinfo(skb)->gso_size)
+	if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 		kfree_skb(skb);
 	else {
 #ifdef CONFIG_BRIDGE_NETFILTER
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -761,7 +761,7 @@ static int br_nf_dev_queue_xmit(struct s
 {
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len > skb->dev->mtu &&
-	    !skb_shinfo(skb)->gso_size)
+	    !skb_is_gso(skb))
 		return ip_fragment(skb, br_dev_queue_push_xmit);
 	else
 		return br_dev_queue_push_xmit(skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -209,7 +209,7 @@ static inline int ip_finish_output(struc
 		return dst_output(skb);
 	}
 #endif
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->gso_size)
+	if (skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb))
 		return ip_fragment(skb, ip_finish_output2);
 	else
 		return ip_finish_output2(skb);
@@ -1095,7 +1095,7 @@ ssize_t	ip_append_page(struct sock *sk, 
 	while (size > 0) {
 		int i;
 
-		if (skb_shinfo(skb)->gso_size)
+		if (skb_is_gso(skb))
 			len = size;
 		else {
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -134,7 +134,7 @@ static int xfrm4_output_finish(struct sk
 	}
 #endif
 
-	if (!skb_shinfo(skb)->gso_size)
+	if (!skb_is_gso(skb))
 		return xfrm4_output_finish2(skb);
 
 	skb->protocol = htons(ETH_P_IP);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -147,7 +147,7 @@ static int ip6_output2(struct sk_buff *s
 
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->gso_size) ||
+	if ((skb->len > dst_mtu(skb->dst) && !skb_is_gso(skb)) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
@@ -229,7 +229,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	skb->priority = sk->sk_priority;
 
 	mtu = dst_mtu(dst);
-	if ((skb->len <= mtu) || ipfragok || skb_shinfo(skb)->gso_size) {
+	if ((skb->len <= mtu) || ipfragok || skb_is_gso(skb)) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -122,7 +122,7 @@ static int xfrm6_output_finish(struct sk
 {
 	struct sk_buff *segs;
 
-	if (!skb_shinfo(skb)->gso_size)
+	if (!skb_is_gso(skb))
 		return xfrm6_output_finish2(skb);
 
 	skb->protocol = htons(ETH_P_IP);
