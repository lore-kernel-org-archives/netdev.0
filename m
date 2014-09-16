From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 1/3] typhoon: use ethtool for changing rx_copybreak
Date: Wed, 17 Sep 2014 02:21:25 +0530
Message-ID: <1410900687-9686-2-git-send-email-_govind@gmx.com>
References: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	David Dillow <dave@thedillows.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:50730 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062AbaIPUwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 16:52:20 -0400
In-Reply-To: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the module parameter rx_copybreak. Add new ethtool
tunable support for setting/getting rx_copybreak.

Cc: David Dillow <dave@thedillows.org>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/3com/typhoon.c | 49 ++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 48775b8..e1f4bf4 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -44,7 +44,7 @@
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
  * Setting to > 1518 effectively disables this feature.
  */
-static int rx_copybreak = 200;
+#define TYPHOON_RX_COPYBREAK_DEFAULT 200
 
 /* Should we use MMIO or Port IO?
  * 0: Port IO
@@ -131,12 +131,8 @@ MODULE_VERSION("1.0");
 MODULE_LICENSE("GPL");
 MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
-MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied and "
-			       "the buffer given back to the NIC. Default "
-			       "is 200.");
 MODULE_PARM_DESC(use_mmio, "Use MMIO (1) or PIO(0) to access the NIC. "
 			   "Default is to try MMIO and fallback to PIO.");
-module_param(rx_copybreak, int, 0);
 module_param(use_mmio, int, 0);
 
 #if defined(NETIF_F_TSO) && MAX_SKB_FRAGS > 32
@@ -294,6 +290,7 @@ struct typhoon {
 	/* unused stuff (future use) */
 	int			capabilities;
 	struct transmit_ring 	txHiRing;
+	u32			rx_copybreak;
 };
 
 enum completion_wait_values {
@@ -1144,6 +1141,43 @@ typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 	ering->tx_pending = TXLO_ENTRIES - 1;
 }
 
+static int typhoon_get_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna, void *data)
+{
+	struct typhoon *tp = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = tp->rx_copybreak;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int typhoon_set_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna,
+			       const void *data)
+{
+	struct typhoon *tp = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		tp->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops typhoon_ethtool_ops = {
 	.get_settings		= typhoon_get_settings,
 	.set_settings		= typhoon_set_settings,
@@ -1152,6 +1186,8 @@ static const struct ethtool_ops typhoon_ethtool_ops = {
 	.set_wol		= typhoon_set_wol,
 	.get_link		= ethtool_op_get_link,
 	.get_ringparam		= typhoon_get_ringparam,
+	.get_tunable		= typhoon_get_tunable,
+	.set_tunable		= typhoon_set_tunable,
 };
 
 static int
@@ -1659,7 +1695,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 
 		pkt_len = le16_to_cpu(rx->frameLen);
 
-		if(pkt_len < rx_copybreak &&
+		if(pkt_len < tp->rx_copybreak &&
 		   (new_skb = netdev_alloc_skb(tp->dev, pkt_len + 2)) != NULL) {
 			skb_reserve(new_skb, 2);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
@@ -2358,6 +2394,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->ioaddr = ioaddr;
 	tp->tx_ioaddr = ioaddr;
 	tp->dev = dev;
+	tp->rx_copybreak = TYPHOON_RX_COPYBREAK_DEFAULT;
 
 	/* Init sequence:
 	 * 1) Reset the adapter to clear any bad juju
-- 
2.1.0
