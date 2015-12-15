From: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Subject: [PATCH] gianfar: Don't enable RX Filer if not supported
Date: Tue, 15 Dec 2015 14:14:50 +1300
Message-ID: <1450142090-10411-1-git-send-email-hamish.martin@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org,
	Hamish Martin <hamish.martin@alliedtelesis.co.nz>
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:52627 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbbLOBPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 20:15:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the
Parser"), 'TSEC' model controllers (for example as seen on MPC8541E)
always have 8 bytes stripped from the front of received frames.
Only 'eTSEC' gianfar controllers have the RX Filer capability (amongst
other enhancements). Previously this was treated as always enabled
for both 'TSEC' and 'eTSEC' controllers.
In commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the Parser")
a subtle change was made to the setting of 'uses_rxfcb' to effectively
always set it (since 'rx_filer_enable' was always true). This had the
side-effect of always stripping 8 bytes from the front of received frames
on 'TSEC' type controllers.

We now only enable the RX Filer capability on controller types that
support it, thereby avoiding the issue for 'TSEC' type controllers.

Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Reviewed-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Signed-off-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
---
 drivers/net/ethernet/freescale/gianfar.c | 8 +++++---
 drivers/net/ethernet/freescale/gianfar.h | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 7cf8984..3e233d9 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -894,7 +894,8 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 				     FSL_GIANFAR_DEV_HAS_VLAN |
 				     FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
 				     FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
-				     FSL_GIANFAR_DEV_HAS_TIMER;
+				     FSL_GIANFAR_DEV_HAS_TIMER |
+				     FSL_GIANFAR_DEV_HAS_RX_FILER;
 
 	err = of_property_read_string(np, "phy-connection-type", &ctype);
 
@@ -1396,8 +1397,9 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}
 
-	/* always enable rx filer */
-	priv->rx_filer_enable = 1;
+	/* Always enable rx filer if available */
+	priv->rx_filer_enable =
+	    (priv->device_flags & FSL_GIANFAR_DEV_HAS_RX_FILER) ? 1 : 0;
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
 	/* use pritority h/w tx queue scheduling for single queue devices */
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index f266b20..cb77667 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -923,6 +923,7 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
 #define FSL_GIANFAR_DEV_HAS_TIMER		0x00000800
 #define FSL_GIANFAR_DEV_HAS_WAKE_ON_FILER	0x00001000
+#define FSL_GIANFAR_DEV_HAS_RX_FILER		0x00002000
 
 #if (MAXGROUPS == 2)
 #define DEFAULT_MAPPING 	0xAA
-- 
2.6.4
