From: Jon Mason <jon.mason@broadcom.com>
Subject: [RFC 2/7] net: ethernet: bgmac: add dma_dev pointer
Date: Tue, 28 Jun 2016 15:34:39 -0400
Message-ID: <1467142484-11161-3-git-send-email-jon.mason@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dma buffer allocation, etc references a dma_dev device pointer from
the bcma core.  In anticipation of removing the bcma requirement for
this driver, these must be changed to not reference that struct.  Add a
dma_dev device pointer to the bgmac stuct and reference that instead.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 17 +++++++++--------
 drivers/net/ethernet/broadcom/bgmac.h |  1 +
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 2ab0887..b5c35bc 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -152,7 +152,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 				    struct bgmac_dma_ring *ring,
 				    struct sk_buff *skb)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	struct net_device *net_dev = bgmac->net_dev;
 	int index = ring->end % BGMAC_TX_RING_SLOTS;
 	struct bgmac_slot_info *slot = &ring->slots[index];
@@ -254,7 +254,7 @@ err_drop:
 /* Free transmitted packets */
 static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	int empty_slot;
 	bool freed = false;
 	unsigned bytes_compl = 0, pkts_compl = 0;
@@ -351,7 +351,7 @@ static void bgmac_dma_rx_enable(struct bgmac *bgmac,
 static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 				     struct bgmac_slot_info *slot)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	dma_addr_t dma_addr;
 	struct bgmac_rx_header *rx;
 	void *buf;
@@ -440,7 +440,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	end_slot /= sizeof(struct bgmac_dma_desc);
 
 	while (ring->start != end_slot) {
-		struct device *dma_dev = bgmac->core->dma_dev;
+		struct device *dma_dev = bgmac->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
 		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
 		struct sk_buff *skb;
@@ -543,7 +543,7 @@ static bool bgmac_dma_unaligned(struct bgmac *bgmac,
 static void bgmac_dma_tx_ring_free(struct bgmac *bgmac,
 				   struct bgmac_dma_ring *ring)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	struct bgmac_dma_desc *dma_desc = ring->cpu_base;
 	struct bgmac_slot_info *slot;
 	int i;
@@ -569,7 +569,7 @@ static void bgmac_dma_tx_ring_free(struct bgmac *bgmac,
 static void bgmac_dma_rx_ring_free(struct bgmac *bgmac,
 				   struct bgmac_dma_ring *ring)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	struct bgmac_slot_info *slot;
 	int i;
 
@@ -590,7 +590,7 @@ static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
 				     struct bgmac_dma_ring *ring,
 				     int num_slots)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	int size;
 
 	if (!ring->cpu_base)
@@ -628,7 +628,7 @@ static void bgmac_dma_free(struct bgmac *bgmac)
 
 static int bgmac_dma_alloc(struct bgmac *bgmac)
 {
-	struct device *dma_dev = bgmac->core->dma_dev;
+	struct device *dma_dev = bgmac->dma_dev;
 	struct bgmac_dma_ring *ring;
 	static const u16 ring_base[] = { BGMAC_DMA_BASE0, BGMAC_DMA_BASE1,
 					 BGMAC_DMA_BASE2, BGMAC_DMA_BASE3, };
@@ -1701,6 +1701,7 @@ static int bgmac_probe(struct bcma_device *core)
 	net_dev->ethtool_ops = &bgmac_ethtool_ops;
 	bgmac = netdev_priv(net_dev);
 	bgmac->dev = &core->dev;
+	bgmac->dma_dev = core->dma_dev;
 	bgmac->net_dev = net_dev;
 	bgmac->core = core;
 	bcma_set_drvdata(core, bgmac);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index abb9dd8..fd20018 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -429,6 +429,7 @@ struct bgmac {
 	struct bcma_device *cmn; /* Reference to CMN core for BCM4706 */
 
 	struct device *dev;
+	struct device *dma_dev;
 	struct net_device *net_dev;
 	struct napi_struct napi;
 	struct mii_bus *mii_bus;
-- 
1.9.1
