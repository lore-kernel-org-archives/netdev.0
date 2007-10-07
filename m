From: jamal <hadi@cyberus.ca>
Subject: [PATCH][E1000E] some cleanups
Date: Sun, 07 Oct 2007 12:15:23 -0400
Message-ID: <1191773723.4394.31.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <47028351.7090509@intel.com>  <1191417498.4357.23.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-rleDCwAkqyIileBQvpq0"
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:52672 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbXJGQP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 12:15:27 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1038965wxd
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2007 09:15:26 -0700 (PDT)
In-Reply-To: <1191417498.4357.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rleDCwAkqyIileBQvpq0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Ok, here you go; the explanation is below. This is from net-2.6.24 of
early this AM. I saw a patch you posted that is derived from Krishna;
although it hasnt showed up in the tree - i have considered those
changes and this patch adds a little more optimization in case of
errors.

I will send you a patch to kill LLTX the sooner this shows up somewhere.

cheers,
jamal

On Wed, 2007-03-10 at 09:18 -0400, jamal wrote:

> The cleanup is to break up the code so it is functionally more readable
> from a perspective of the 4 distinct parts in ->hard_start_xmit():
> 
> a) packet formatting (example: vlan, mss, descriptor counting, etc.)
> b) chip-specific formatting
> c) enqueueing the packet on a DMA ring
> d) IO operations to complete packet transmit, tell DMA engine to chew
> on, tx completion interrupts, set last tx time, etc.
> 
> Each of those steps sitting in different functions accumulates state
> that is used in the next steps. cb stores this state because it a
> scratchpad the driver owns. You could create some other structure and
> pass it around the iteration, but why waste more bytes.


--=-rleDCwAkqyIileBQvpq0
Content-Disposition: attachment; filename=e1000e-p1
Content-Type: text/x-patch; name=e1000e-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4a21d7d..26d35bb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3417,51 +3417,60 @@ static int e1000_maybe_stop_tx(struct net_device *netdev, int size)
 	return __e1000_maybe_stop_tx(netdev, size);
 }
 
+/* This structure cannot be larger than 40B given it uses skb->cb[8] */
+struct e1000_tx_cbdata {
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+	unsigned int tx_flags;
+};
+
+/* we avoid cb[0] because it is used by VLAN cookie
+ * struct vlan_skb_tx_cookie
+*/
+#define E1000_SKB_CB(__skb)       ((struct e1000_tx_cbdata *)&((__skb)->cb[8]))
+#define NETDEV_TX_DROPPED       -5
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+
+static int e1000_prep_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_ring *tx_ring = adapter->tx_ring;
-	unsigned int first;
-	unsigned int max_per_txd = E1000_MAX_PER_TXD;
-	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
-	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long irq_flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
-	int count = 0;
-	int tso;
+	unsigned int max_txd_pwr; 
+	struct e1000_tx_cbdata *cb;
 	unsigned int f;
-	len -= skb->data_len;
-
-	if (test_bit(__E1000_DOWN, &adapter->state)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
 
 	if (skb->len <= 0) {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
-	mss = skb_shinfo(skb)->gso_size;
+	max_txd_pwr = E1000_MAX_TXD_PWR;
+	cb = E1000_SKB_CB(skb);
+	cb->nr_frags = 0;
+	cb->mss = 0;
+	cb->count = 0;
+	cb->max_per_txd = E1000_MAX_PER_TXD;
+
+	len -= skb->data_len;
+	cb->mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
-	if (mss) {
+	if (cb->mss) {
 		u8 hdr_len;
-		max_per_txd = min(mss << 2, max_per_txd);
-		max_txd_pwr = fls(max_per_txd) - 1;
+		cb->max_per_txd = min(cb->mss << 2, cb->max_per_txd);
+		max_txd_pwr = fls(cb->max_per_txd) - 1;
 
 		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && (hdr_len == len )) {
 			unsigned int pull_size;
 
 			pull_size = min((unsigned int)4, skb->data_len);
@@ -3469,43 +3478,66 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				ndev_err(netdev,
 					 "__pskb_pull_tail failed.\n");
 				dev_kfree_skb_any(skb);
-				return NETDEV_TX_OK;
+				return NETDEV_TX_DROPPED;
 			}
 			len = skb->len - skb->data_len;
 		}
 	}
 
 	/* reserve a descriptor for the offload context */
-	if ((mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
-		count++;
-	count++;
+	if ((cb->mss) || (skb->ip_summed == CHECKSUM_PARTIAL))
+		cb->count++;
+	cb->count++;
 
-	count += TXD_USE_COUNT(len, max_txd_pwr);
+	cb->count += TXD_USE_COUNT(len, max_txd_pwr);
 
-	nr_frags = skb_shinfo(skb)->nr_frags;
-	for (f = 0; f < nr_frags; f++)
-		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
+	cb->nr_frags = skb_shinfo(skb)->nr_frags;
+	for (f = 0; f < cb->nr_frags; f++)
+		cb->count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size,
 				       max_txd_pwr);
 
 	if (adapter->hw.mac.tx_pkt_filtering)
 		e1000_transfer_dhcp_info(adapter, skb);
 
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		cb->tx_flags |= E1000_TX_FLAGS_VLAN;
+		cb->tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	int ret = NETDEV_TX_OK;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_ring *tx_ring = adapter->tx_ring;
+	unsigned int first;
+	unsigned long irq_flags;
+	int tso;
+	struct e1000_tx_cbdata *cb;
+
+	ret = e1000_prep_frame(skb, netdev);
+	if (unlikely(ret != NETDEV_TX_OK))
+		return NETDEV_TX_OK;
+
+	if (test_bit(__E1000_DOWN, &adapter->state)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	if (!spin_trylock_irqsave(&adapter->tx_queue_lock, irq_flags))
 		/* Collision - tell upper layer to requeue */
 		return NETDEV_TX_LOCKED;
 
+	cb = E1000_SKB_CB(skb);
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (e1000_maybe_stop_tx(netdev, count + 2)) {
+	if (e1000_maybe_stop_tx(netdev, cb->count + 2)) {
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
-		tx_flags |= E1000_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
-	}
-
 	first = tx_ring->next_to_use;
 
 	tso = e1000_tso(adapter, skb);
@@ -3516,25 +3548,25 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (tso)
-		tx_flags |= E1000_TX_FLAGS_TSO;
+		cb->tx_flags |= E1000_TX_FLAGS_TSO;
 	else if (e1000_tx_csum(adapter, skb))
-		tx_flags |= E1000_TX_FLAGS_CSUM;
+		cb->tx_flags |= E1000_TX_FLAGS_CSUM;
 
 	/* Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
 	 * no longer assume, we must. */
 	if (skb->protocol == htons(ETH_P_IP))
-		tx_flags |= E1000_TX_FLAGS_IPV4;
+		cb->tx_flags |= E1000_TX_FLAGS_IPV4;
 
-	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
-	if (count < 0) {
+	cb->count = e1000_tx_map(adapter, skb, first, cb->max_per_txd, cb->nr_frags, cb->mss);
+	if (cb->count < 0) {
 		/* handle pci_map_single() error in e1000_tx_map */
 		dev_kfree_skb_any(skb);
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_BUSY;
 	}
 
-	e1000_tx_queue(adapter, tx_flags, count);
+	e1000_tx_queue(adapter, cb->tx_flags, cb->count);
 
 	netdev->trans_start = jiffies;
 

--=-rleDCwAkqyIileBQvpq0--

