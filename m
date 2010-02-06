From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 1/2] sky2: Factor out code to calculate packet sizes
Date: Sat, 06 Feb 2010 10:22:44 +0900
Message-ID: <4B6CC464.6030701@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f187.google.com ([209.85.222.187]:51242 "EHLO
	mail-pz0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933128Ab0BFBc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 20:32:56 -0500
Received: by pzk17 with SMTP id 17so313869pzk.4
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2010 17:32:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move code to calculate receive threshold and packet size out of
sky2_rx_start() so that is can be called from elsewhere easily.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   57 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 0b47c7f..2061eb8 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1064,6 +1064,40 @@ static inline struct sky2_rx_le *sky2_next_rx(struct sky2_port *sky2)
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
@@ -1337,7 +1371,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	struct sky2_hw *hw = sky2->hw;
 	struct rx_ring_info *re;
 	unsigned rxq = rxqaddr[sky2->port];
-	unsigned i, size, thresh;
+	unsigned i, thresh;
 
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
@@ -1358,25 +1392,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
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
@@ -1401,6 +1417,7 @@ static int sky2_rx_start(struct sky2_port *sky2)
 	 * the register is limited to 9 bits, so if you do frames > 2052
 	 * you better get the MTU right!
 	 */
+	thresh = sky2_get_rx_threshold(sky2);
 	if (thresh > 0x1ff)
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_OFF);
 	else {
-- 
1.5.6.5


