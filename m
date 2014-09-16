From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 3/3] sis190: use ethtool for changing rx_copybreak
Date: Wed, 17 Sep 2014 02:21:27 +0530
Message-ID: <1410900687-9686-4-git-send-email-_govind@gmx.com>
References: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:61784 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbaIPUwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 16:52:38 -0400
In-Reply-To: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the module parameter rx_copybreak. Add new ethtool
tunable support for setting/getting rx_copybreak.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/sis/sis190.c | 47 +++++++++++++++++++++++++++++++++++----
 1 file changed, 43 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 27be6c8..804d88d 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -290,6 +290,7 @@ struct sis190_private {
 		LNK_ON,
 		LNK_AUTONEG,
 	} link_status;
+	u32 rx_copybreak;
 };
 
 struct sis190_phy {
@@ -338,15 +339,13 @@ static const struct pci_device_id sis190_pci_tbl[] = {
 
 MODULE_DEVICE_TABLE(pci, sis190_pci_tbl);
 
-static int rx_copybreak = 200;
+#define SIS190_RX_COPYBREAK_DEFAULT 200
 
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
 
 MODULE_DESCRIPTION("SiS sis190/191 Gigabit Ethernet driver");
-module_param(rx_copybreak, int, 0);
-MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
 MODULE_AUTHOR("K.M. Liu <kmliu@sis.com>, Ueimor <romieu@fr.zoreil.com>");
@@ -535,7 +534,7 @@ static bool sis190_try_rx_copy(struct sis190_private *tp,
 	struct sk_buff *skb;
 	bool done = false;
 
-	if (pkt_size >= rx_copybreak)
+	if (pkt_size >= tp->rx_copybreak)
 		goto out;
 
 	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
@@ -1522,6 +1521,7 @@ static struct net_device *sis190_init_board(struct pci_dev *pdev)
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
 	tp->link_status = LNK_OFF;
+	tp->rx_copybreak = SIS190_RX_COPYBREAK_DEFAULT;
 
 	sis190_irq_mask_and_ack(ioaddr);
 
@@ -1796,6 +1796,43 @@ static void sis190_set_msglevel(struct net_device *dev, u32 value)
 	tp->msg_enable = value;
 }
 
+static int sis190_get_tunable(struct net_device *dev,
+			      const struct ethtool_tunable *tuna, void *data)
+{
+	struct sis190_private *tp = netdev_priv(dev);
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
+static int sis190_set_tunable(struct net_device *dev,
+			      const struct ethtool_tunable *tuna,
+			      const void *data)
+{
+	struct sis190_private *tp = netdev_priv(dev);
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
 static const struct ethtool_ops sis190_ethtool_ops = {
 	.get_settings	= sis190_get_settings,
 	.set_settings	= sis190_set_settings,
@@ -1806,6 +1843,8 @@ static const struct ethtool_ops sis190_ethtool_ops = {
 	.get_msglevel	= sis190_get_msglevel,
 	.set_msglevel	= sis190_set_msglevel,
 	.nway_reset	= sis190_nway_reset,
+	.get_tunable	= sis190_get_tunable,
+	.set_tunable	= sis190_set_tunable,
 };
 
 static int sis190_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
2.1.0
