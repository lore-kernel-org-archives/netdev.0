From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/3] amd-xgbe: Allow rx-frames coalescing to be
 changed anytime
Date: Thu, 9 Apr 2015 12:11:51 -0500
Message-ID: <20150409171151.22188.39520.stgit@tlendack-t1.amdoffice.net>
References: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:1321
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755975AbbDIRL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 13:11:56 -0400
In-Reply-To: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the device must be down in order to update the rx-frames
coalescing setting because the interrupt indicator is set in the
descriptor data during initialization. Allow this setting to be changed
while the device is up by moving the interrupt decision into the
descriptor reset function and base the decision off of the supplied
descriptor index value.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   32 +++++++++++++++-----------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   10 --------
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    5 ++--
 4 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 80dd7a9..96c5e4b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1101,9 +1101,24 @@ static void xgbe_tx_desc_init(struct xgbe_channel *channel)
 	DBGPR("<--tx_desc_init\n");
 }
 
-static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
+static void xgbe_rx_desc_reset(struct xgbe_prv_data *pdata,
+			       struct xgbe_ring_data *rdata, unsigned int index)
 {
 	struct xgbe_ring_desc *rdesc = rdata->rdesc;
+	unsigned int rx_usecs = pdata->rx_usecs;
+	unsigned int rx_frames = pdata->rx_frames;
+	unsigned int inte;
+
+	if (!rx_usecs && !rx_frames) {
+		/* No coalescing, interrupt for every descriptor */
+		inte = 1;
+	} else {
+		/* Set interrupt based on Rx frame coalescing setting */
+		if (rx_frames && !((index + 1) % rx_frames))
+			inte = 1;
+		else
+			inte = 0;
+	}
 
 	/* Reset the Rx descriptor
 	 *   Set buffer 1 (lo) address to header dma address (lo)
@@ -1117,8 +1132,7 @@ static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
 	rdesc->desc2 = cpu_to_le32(lower_32_bits(rdata->rx.buf.dma));
 	rdesc->desc3 = cpu_to_le32(upper_32_bits(rdata->rx.buf.dma));
 
-	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE,
-			  rdata->interrupt ? 1 : 0);
+	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE, inte);
 
 	/* Since the Rx DMA engine is likely running, make sure everything
 	 * is written to the descriptor(s) before setting the OWN bit
@@ -1138,26 +1152,16 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
 	unsigned int start_index = ring->cur;
-	unsigned int rx_coalesce, rx_frames;
 	unsigned int i;
 
 	DBGPR("-->rx_desc_init\n");
 
-	rx_coalesce = (pdata->rx_riwt || pdata->rx_frames) ? 1 : 0;
-	rx_frames = pdata->rx_frames;
-
 	/* Initialize all descriptors */
 	for (i = 0; i < ring->rdesc_count; i++) {
 		rdata = XGBE_GET_DESC_DATA(ring, i);
 
-		/* Set interrupt on completion bit as appropriate */
-		if (rx_coalesce && (!rx_frames || ((i + 1) % rx_frames)))
-			rdata->interrupt = 0;
-		else
-			rdata->interrupt = 1;
-
 		/* Initialize Rx descriptor */
-		xgbe_rx_desc_reset(rdata);
+		xgbe_rx_desc_reset(pdata, rdata, i);
 	}
 
 	/* Update the total number of Rx descriptors */
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 347fe24..74b4698 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1806,7 +1806,7 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 		if (desc_if->map_rx_buffer(pdata, ring, rdata))
 			break;
 
-		hw_if->rx_desc_reset(rdata);
+		hw_if->rx_desc_reset(pdata, rdata, ring->dirty);
 
 		ring->dirty++;
 	}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index b4f6eaa..5f149e8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -424,16 +424,6 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	    (ec->rate_sample_interval))
 		return -EOPNOTSUPP;
 
-	/* Can only change rx-frames when interface is down (see
-	 * rx_descriptor_init in xgbe-dev.c)
-	 */
-	rx_frames = pdata->rx_frames;
-	if (rx_frames != ec->rx_max_coalesced_frames && netif_running(netdev)) {
-		netdev_alert(netdev,
-			     "interface must be down to change rx-frames\n");
-		return -EINVAL;
-	}
-
 	rx_riwt = hw_if->usec_to_riwt(pdata, ec->rx_coalesce_usecs);
 	rx_usecs = ec->rx_coalesce_usecs;
 	rx_frames = ec->rx_max_coalesced_frames;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index dd74242..a864eab 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -325,8 +325,6 @@ struct xgbe_ring_data {
 	struct xgbe_tx_ring_data tx;	/* Tx-related data */
 	struct xgbe_rx_ring_data rx;	/* Rx-related data */
 
-	unsigned int interrupt;		/* Interrupt indicator */
-
 	unsigned int mapped_as_page;
 
 	/* Incomplete receive save location.  If the budget is exhausted
@@ -536,8 +534,9 @@ struct xgbe_hw_if {
 	int (*dev_read)(struct xgbe_channel *);
 	void (*tx_desc_init)(struct xgbe_channel *);
 	void (*rx_desc_init)(struct xgbe_channel *);
-	void (*rx_desc_reset)(struct xgbe_ring_data *);
 	void (*tx_desc_reset)(struct xgbe_ring_data *);
+	void (*rx_desc_reset)(struct xgbe_prv_data *, struct xgbe_ring_data *,
+			      unsigned int);
 	int (*is_last_desc)(struct xgbe_ring_desc *);
 	int (*is_context_desc)(struct xgbe_ring_desc *);
 	void (*tx_start_xmit)(struct xgbe_channel *, struct xgbe_ring *);
