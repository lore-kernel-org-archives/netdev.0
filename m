From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/10] sky2: Factor out code to calculate packet sizes
Date: Fri, 12 Feb 2010 08:58:02 -0800
Message-ID: <20100212165937.863986102@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49498 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab0BLRIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:13 -0500
Content-Disposition: inline; filename=sky2-mike1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Move code to calculate receive threshold and packet size out of
sky2_rx_start() so that is can be called from elsewhere easily.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |   57 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 37 insertions(+), 20 deletions(-)

--- a/drivers/net/sky2.c	2010-02-11 09:55:57.641435835 -0800
+++ b/drivers/net/sky2.c	2010-02-11 09:58:16.522894061 -0800
@@ -1049,6 +1049,40 @@ static inline struct sky2_rx_le *sky2_ne
 	return le;
 }
 
+static unsigned sky2_get_rx_threshold(struct sky2_port* sky2)
+{
+	unsigned size;
+
+	/* Space needed for frame data + headers rounded up */
+	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
+
+	/* Stopping point for hardware truncation */
+	return (size - 8) / sizeof(u32);
+}
+
+static unsigned sky2_get_rx_data_size(struct sky2_port* sky2)
+{
+	struct rx_ring_info *re;
+	unsigned size;
+
+	/* Space needed for frame data + headers rounded up */
+	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
+
+	sky2->rx_nfrags = size >> PAGE_SHIFT;
+	BUG_ON(sky2->rx_nfrags > ARRAY_SIZE(re->frag_addr));
+
+	/* Compute residue after pages */
+	size -= sky2->rx_nfrags << PAGE_SHIFT;
+
+	/* Optimize to handle small packets and headers */
+	if (size < copybreak)
+		size = copybreak;
+	if (size < ETH_HLEN)
+		size = ETH_HLEN;
+
+	return size;
+}
+
 /* Build description to hardware for one receive segment */
 static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
 			dma_addr_t map, unsigned len)
@@ -1343,7 +1377,7 @@ static int sky2_rx_start(struct sky2_por
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
 	unsigned rxq = rxqaddr[sky2->port];
-	unsigned i, size, thresh;
+	unsigned i, thresh;
 
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
@@ -1364,25 +1398,7 @@ static int sky2_rx_start(struct sky2_por
 	if (!(hw->flags & SKY2_HW_NEW_LE))
 		rx_set_checksum(sky2);
 
-	/* Space needed for frame data + headers rounded up */
-	size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
-
-	/* Stopping point for hardware truncation */
-	thresh = (size - 8) / sizeof(u32);
-
-	sky2->rx_nfrags = size >> PAGE_SHIFT;
-	BUG_ON(sky2->rx_nfrags > ARRAY_SIZE(re->frag_addr));
-
-	/* Compute residue after pages */
-	size -= sky2->rx_nfrags << PAGE_SHIFT;
-
-	/* Optimize to handle small packets and headers */
-	if (size < copybreak)
-		size = copybreak;
-	if (size < ETH_HLEN)
-		size = ETH_HLEN;
-
-	sky2->rx_data_size = size;
+	sky2->rx_data_size = sky2_get_rx_data_size(sky2);
 
 	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
@@ -1407,6 +1423,7 @@ static int sky2_rx_start(struct sky2_por
 	 * the register is limited to 9 bits, so if you do frames > 2052
 	 * you better get the MTU right!
 	 */
+	thresh = sky2_get_rx_threshold(sky2);
 	if (thresh > 0x1ff)
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_OFF);
 	else {

-- 

