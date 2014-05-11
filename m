From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH 1/2] arc_emac: implement promiscuous mode and multicast filtering
Date: Sun, 11 May 2014 18:11:47 +0200
Message-ID: <1399824708-2497-2-git-send-email-b.galvani@gmail.com>
References: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:40199 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbaEKQM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 12:12:26 -0400
In-Reply-To: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the set_rx_mode function to enable/disable
promiscuous or all-multicast modes and to update the multicast
filtering list of the device.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |   37 ++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9f45782..12fc810 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -13,6 +13,7 @@
  *		Vineet Gupta
  */
 
+#include <linux/crc32.h>
 #include <linux/etherdevice.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
@@ -451,6 +452,41 @@ static int arc_emac_open(struct net_device *ndev)
 }
 
 /**
+ * arc_emac_set_rx_mode - Change the receive filtering mode.
+ * @ndev:	Pointer to the network device.
+ *
+ * This function enables/disables promiscuous or all-multicast mode
+ * and updates the multicast filtering list of the network device.
+ */
+static void arc_emac_set_rx_mode(struct net_device *ndev)
+{
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	if (ndev->flags & IFF_PROMISC) {
+		arc_reg_or(priv, R_CTRL, PROM_MASK);
+	} else {
+		arc_reg_clr(priv, R_CTRL, PROM_MASK);
+
+		if (ndev->flags & IFF_ALLMULTI) {
+			arc_reg_set(priv, R_LAFL, ~0);
+			arc_reg_set(priv, R_LAFH, ~0);
+		} else {
+			struct netdev_hw_addr *ha;
+			unsigned int filter[2] = { 0, 0 };
+			int bit;
+
+			netdev_for_each_mc_addr(ha, ndev) {
+				bit = ether_crc_le(ETH_ALEN, ha->addr) >> 26;
+				filter[bit >> 5] |= 1 << (bit & 31);
+			}
+
+			arc_reg_set(priv, R_LAFL, filter[0]);
+			arc_reg_set(priv, R_LAFH, filter[1]);
+		}
+	}
+}
+
+/**
  * arc_emac_stop - Close the network device.
  * @ndev:	Pointer to the network device.
  *
@@ -620,6 +656,7 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 	.ndo_start_xmit		= arc_emac_tx,
 	.ndo_set_mac_address	= arc_emac_set_address,
 	.ndo_get_stats		= arc_emac_stats,
+	.ndo_set_rx_mode	= arc_emac_set_rx_mode,
 };
 
 static int arc_emac_probe(struct platform_device *pdev)
-- 
1.7.10.4
