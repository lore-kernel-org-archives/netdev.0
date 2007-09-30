From: jamal <hadi@cyberus.ca>
Subject: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 13:41:17 -0400
Message-ID: <1191174077.6165.11.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-opxgvb4E3+vYcZmdnLk3"
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:51502 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757368AbXI3Rl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 13:41:26 -0400
Received: by wr-out-0506.google.com with SMTP id 36so1652566wra
        for <netdev@vger.kernel.org>; Sun, 30 Sep 2007 10:41:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-opxgvb4E3+vYcZmdnLk3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Auke,

heres part of something i promised. 
I couldnt do any packet testing on because 82571EB is disabled in the
driver. I uncommented the code out in the table, but the best i could
get was the module loading, some probing and some sysfs renaming
failures (probably a debianism); the machine access is intermittent, so
thats as far as i could go. In any case, you probably have a good reason
for disabling that chip. So, heres the patch, the burden of testing now
falls on you ;->
Once you have 82571EB on and kicking, my next steps are to kill LLTX
then add batching on top.
BTW, since this driver is just for PCIE, would you take a similar patch
for non-PCIE e1000?

comment:
There used to be an "mmiowb()" call right after the dma wake which is
gone now; is this unneeded with pcie? I have restored it, look for the
"XXX".

cheers,
jamal

--=-opxgvb4E3+vYcZmdnLk3
Content-Disposition: attachment; filename=e1000e-p1
Content-Type: text/plain; name=e1000e-p1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[E1000E] some cleanups
This patch makes the xmit path code a lot more readable and reusable.
preps for removing LLTX.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit ad63c288ce980907f68d94d5faac08625c0b1782
tree 296a6da371b98c6488c544a8910941ea6d8c18a8
parent 7f5d0afdff875b2c4957031f8934741aefe257cc
author Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 13:26:00 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Sun, 30 Sep 2007 13:26:00 -0400

 drivers/net/e1000e/netdev.c |  187 +++++++++++++++++++++++++++----------------
 1 files changed, 119 insertions(+), 68 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4a21d7d..5043504 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3076,6 +3076,18 @@ link_up:
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
+struct e1000_tx_cbdata {
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+	unsigned int tx_flags;
+};
+
+#define E1000_SKB_CB(__skb) ((struct e1000_tx_cbdata *)&((__skb)->cb[8]))
+#define NETDEV_TX_DROPPED -5
+#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1)
+
 static int e1000_tso(struct e1000_adapter *adapter,
 		     struct sk_buff *skb)
 {
@@ -3194,8 +3206,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 
 static int e1000_tx_map(struct e1000_adapter *adapter,
 			struct sk_buff *skb, unsigned int first,
-			unsigned int max_per_txd, unsigned int nr_frags,
-			unsigned int mss)
+			struct e1000_tx_cbdata *cb)
 {
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	struct e1000_buffer *buffer_info;
@@ -3207,11 +3218,11 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
-		size = min(len, max_per_txd);
+		size = min(len, cb->max_per_txd);
 
 		/* Workaround for premature desc write-backs
 		 * in TSO mode.  Append 4-byte sentinel desc */
-		if (mss && !nr_frags && size == len && size > 8)
+		if (cb->mss && !cb->nr_frags && size == len && size > 8)
 			size -= 4;
 
 		buffer_info->length = size;
@@ -3237,7 +3248,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			i = 0;
 	}
 
-	for (f = 0; f < nr_frags; f++) {
+	for (f = 0; f < cb->nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
@@ -3246,10 +3257,11 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
-			size = min(len, max_per_txd);
+			size = min(len, cb->max_per_txd);
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if (mss && f == (nr_frags-1) && size == len && size > 8)
+			if (cb->mss && f == (cb->nr_frags-1) &&
+			    size == len && size > 8)
 				size -= 4;
 
 			buffer_info->length = size;
@@ -3334,18 +3346,7 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 	}
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
-
-	/* Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64). */
-	wmb();
-
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tail);
-	/* we need this if more than one processor can write to our tail
-	 * at a time, it synchronizes IO on IA64/Altix systems */
-	mmiowb();
 }
 
 #define MINIMUM_DHCP_PACKET_SIZE 282
@@ -3417,45 +3418,54 @@ static int e1000_maybe_stop_tx(struct net_device *netdev, int size)
 	return __e1000_maybe_stop_tx(netdev, size);
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static void
+e1000_complete_tx(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_ring *tx_ring = adapter->tx_ring;
-	unsigned int first;
-	unsigned int max_per_txd = E1000_MAX_PER_TXD;
+	/* Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64). */
+	wmb();
+	writel(tx_ring->next_to_use, adapter->hw.hw_addr + tx_ring->tail);
+	/* XXX: we need this if more than one processor can write to
+	 * our tail at a time, it syncronizes IO on IA64/Altix systems */
+	mmiowb();
+	netdev->trans_start = jiffies;
+}
+
+static int e1000_prep_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
-	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long irq_flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
-	int count = 0;
-	int tso;
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
 	unsigned int f;
-	len -= skb->data_len;
 
-	if (test_bit(__E1000_DOWN, &adapter->state)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
+	cb->nr_frags = 0;
+	cb->mss = 0;
+	cb->count = 0;
+	cb->max_per_txd = E1000_MAX_PER_TXD;
+
+	len -= skb->data_len;
 
 	if (skb->len <= 0) {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
 	}
 
-	mss = skb_shinfo(skb)->gso_size;
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
@@ -3469,80 +3479,121 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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
 
-	if (!spin_trylock_irqsave(&adapter->tx_queue_lock, irq_flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		cb->tx_flags |= E1000_TX_FLAGS_VLAN;
+		cb->tx_flags |= (vlan_tx_tag_get(skb) <<
+				E1000_TX_FLAGS_VLAN_SHIFT);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static int e1000_queue_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_ring *tx_ring = adapter->tx_ring;
+	unsigned int first;
+	int tso;
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
+
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (e1000_maybe_stop_tx(netdev, count + 2)) {
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
+	if (e1000_maybe_stop_tx(netdev, cb->count + 2))
 		return NETDEV_TX_BUSY;
-	}
-
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
-		tx_flags |= E1000_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
-	}
 
 	first = tx_ring->next_to_use;
 
 	tso = e1000_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
-		return NETDEV_TX_OK;
+		return NETDEV_TX_DROPPED;
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
+	cb->count = e1000_tx_map(adapter, skb, first, cb);
+	if (cb->count < 0) {
 		/* handle pci_map_single() error in e1000_tx_map */
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
+		return NETDEV_TX_DROPPED;
+	}
+
+	e1000_tx_queue(adapter, cb->tx_flags, cb->count);
+
+	return NETDEV_TX_OK;
+}
+
+static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	int ret = NETDEV_TX_OK;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	unsigned long irq_flags;
+	struct e1000_tx_cbdata *cb = E1000_SKB_CB(skb);
+
+	ret = e1000_prep_frame(skb, netdev);
+	if (unlikely(ret != NETDEV_TX_OK))
+		return NETDEV_TX_OK;
+
+	if (test_bit(__E1000_DOWN, &adapter->state)) {
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-	e1000_tx_queue(adapter, tx_flags, count);
+	if (!spin_trylock_irqsave(&adapter->tx_queue_lock, irq_flags))
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
 
-	netdev->trans_start = jiffies;
+	/* need: count + 2 desc gap to keep tail from touching
+	 * head, otherwise try next time */
+	if (e1000_maybe_stop_tx(netdev, cb->count + 2)) {
+		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	ret = e1000_queue_frame(skb, netdev);
+
+	if (ret == NETDEV_TX_OK)
+		e1000_complete_tx(netdev);
+
+	if (ret == NETDEV_TX_DROPPED)
+		ret = NETDEV_TX_OK;
 
 	/* Make sure there is space in the ring for the next send. */
 	e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
 
 	spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 /**

--=-opxgvb4E3+vYcZmdnLk3--

