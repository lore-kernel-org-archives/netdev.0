From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 3/9] ftgmac100: Add ndo_set_rx_mode() and support for multicast & promisc
Date: Thu, 13 Apr 2017 14:39:10 +1000
Message-ID: <20170413043916.7793-4-benh@kernel.crashing.org>
References: <20170413043916.7793-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57845 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751867AbdDMEkF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 00:40:05 -0400
In-Reply-To: <20170413043916.7793-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ndo_set_rx_mode() callback to configure the
multicast filters, promisc and allmulti options.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 52 ++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 4be8bf9..551ab3e 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -30,6 +30,7 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/crc32.h>
 #include <net/ip.h>
 #include <net/ncsi.h>
 
@@ -97,6 +98,10 @@ struct ftgmac100 {
 	int cur_duplex;
 	bool use_ncsi;
 
+	/* Multicast filter settings */
+	u32 maht0;
+	u32 maht1;
+
 	/* Flow control settings */
 	bool tx_pause;
 	bool rx_pause;
@@ -264,6 +269,10 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 	/* Write MAC address */
 	ftgmac100_write_mac_addr(priv, priv->netdev->dev_addr);
 
+	/* Write multicast filter */
+	iowrite32(priv->maht0, priv->base + FTGMAC100_OFFSET_MAHT0);
+	iowrite32(priv->maht1, priv->base + FTGMAC100_OFFSET_MAHT1);
+
 	/* Configure descriptor sizes and increase burst sizes according
 	 * to values in Aspeed SDK. The FIFO arbitration is enabled and
 	 * the thresholds set based on the recommended values in the
@@ -317,6 +326,12 @@ static void ftgmac100_start_hw(struct ftgmac100 *priv)
 	/* Add other bits as needed */
 	if (priv->cur_duplex == DUPLEX_FULL)
 		maccr |= FTGMAC100_MACCR_FULLDUP;
+	if (priv->netdev->flags & IFF_PROMISC)
+		maccr |= FTGMAC100_MACCR_RX_ALL;
+	if (priv->netdev->flags & IFF_ALLMULTI)
+		maccr |= FTGMAC100_MACCR_RX_MULTIPKT;
+	else if (netdev_mc_count(priv->netdev))
+		maccr |= FTGMAC100_MACCR_HT_MULTI_EN;
 
 	/* Hit the HW */
 	iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
@@ -327,6 +342,42 @@ static void ftgmac100_stop_hw(struct ftgmac100 *priv)
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
+static void ftgmac100_calc_mc_hash(struct ftgmac100 *priv)
+{
+	struct netdev_hw_addr *ha;
+
+	priv->maht1 = 0;
+	priv->maht0 = 0;
+	netdev_for_each_mc_addr(ha, priv->netdev) {
+		u32 crc_val = ether_crc_le(ETH_ALEN, ha->addr);
+
+		crc_val = (~(crc_val >> 2)) & 0x3f;
+		if (crc_val >= 32)
+			priv->maht1 |= 1ul << (crc_val - 32);
+		else
+			priv->maht0 |= 1ul << (crc_val);
+	}
+}
+
+static void ftgmac100_set_rx_mode(struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
+
+	/* Setup the hash filter */
+	ftgmac100_calc_mc_hash(priv);
+
+	/* Interface down ? that's all there is to do */
+	if (!netif_running(netdev))
+		return;
+
+	/* Update the HW */
+	iowrite32(priv->maht0, priv->base + FTGMAC100_OFFSET_MAHT0);
+	iowrite32(priv->maht1, priv->base + FTGMAC100_OFFSET_MAHT1);
+
+	/* Reconfigure MACCR */
+	ftgmac100_start_hw(priv);
+}
+
 static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 				  struct ftgmac100_rxdes *rxdes, gfp_t gfp)
 {
@@ -1501,6 +1552,7 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= ftgmac100_do_ioctl,
 	.ndo_tx_timeout		= ftgmac100_tx_timeout,
+	.ndo_set_rx_mode	= ftgmac100_set_rx_mode,
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
-- 
2.9.3
