From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/3] pcnet32: use ethtool for changing rx_copybreak
Date: Wed, 17 Sep 2014 02:21:26 +0530
Message-ID: <1410900687-9686-3-git-send-email-_govind@gmx.com>
References: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Don Fry <pcnet32@frontier.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:56513 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbaIPUwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 16:52:30 -0400
In-Reply-To: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the module parameter rx_copybreak. Add new ethtool
tunable support for setting/getting rx_copybreak.

Cc: Don Fry <pcnet32@frontier.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 49 ++++++++++++++++++++++++++++++++++----
 1 file changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e2e3aaf..20ef8d6 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -92,7 +92,7 @@ static int pcnet32vlb;		/* check for VLB cards ? */
 static struct net_device *pcnet32_dev;
 
 static int max_interrupt_work = 2;
-static int rx_copybreak = 200;
+#define PCNET_RX_COPYBREAK_DEFAULT 200
 
 #define PCNET32_PORT_AUI      0x00
 #define PCNET32_PORT_10BT     0x01
@@ -303,6 +303,7 @@ struct pcnet32_private {
 
 	/* saved registers during ethtool blink */
 	u16 			save_regs[4];
+	u32			rx_copybreak;
 };
 
 static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
@@ -1155,7 +1156,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		return;
 	}
 
-	if (pkt_len > rx_copybreak) {
+	if (pkt_len > lp->rx_copybreak) {
 		struct sk_buff *newskb;
 		dma_addr_t new_dma_addr;
 
@@ -1439,6 +1440,43 @@ static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
+static int pcnet32_get_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna, void *data)
+{
+	struct pcnet32_private *lp = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = lp->rx_copybreak;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int pcnet32_set_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna,
+			       const void *data)
+{
+	struct pcnet32_private *lp = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		lp->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops pcnet32_ethtool_ops = {
 	.get_settings		= pcnet32_get_settings,
 	.set_settings		= pcnet32_set_settings,
@@ -1455,6 +1493,8 @@ static const struct ethtool_ops pcnet32_ethtool_ops = {
 	.get_regs_len		= pcnet32_get_regs_len,
 	.get_regs		= pcnet32_get_regs,
 	.get_sset_count		= pcnet32_get_sset_count,
+	.get_tunable		= pcnet32_get_tunable,
+	.set_tunable		= pcnet32_set_tunable,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
@@ -1912,6 +1952,8 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	/* enable LED writes */
 	a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1000);
 
+	lp->rx_copybreak = PCNET_RX_COPYBREAK_DEFAULT;
+
 	return 0;
 
 err_free_ring:
@@ -2885,9 +2927,6 @@ MODULE_PARM_DESC(debug, DRV_NAME " debug level");
 module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(max_interrupt_work,
 		 DRV_NAME " maximum events handled per interrupt");
-module_param(rx_copybreak, int, 0);
-MODULE_PARM_DESC(rx_copybreak,
-		 DRV_NAME " copy breakpoint for copy-only-tiny-frames");
 module_param(tx_start_pt, int, 0);
 MODULE_PARM_DESC(tx_start_pt, DRV_NAME " transmit start point (0-3)");
 module_param(pcnet32vlb, int, 0);
-- 
2.1.0
