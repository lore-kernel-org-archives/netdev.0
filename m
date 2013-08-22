From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH net-next 2/2] fs_enet: cleanup clock API use
Date: Thu, 22 Aug 2013 21:55:13 +0200
Message-ID: <1377201313-10420-2-git-send-email-agust@denx.de>
References: <1377201313-10420-1-git-send-email-agust@denx.de>
Cc: davem@davemloft.net, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, Gerhard Sittig <gsi@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:53522 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715Ab3HVTzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:55:17 -0400
In-Reply-To: <1377201313-10420-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Sittig <gsi@denx.de>

make the Freescale ethernet driver get, prepare and enable the FEC clock
during probe(); disable and unprepare the clock upon remove(), put is
done by the devm approach; hold a reference to the clock over the period
of use.

clock lookup is non-fatal as not all platforms provide clock specs in
their device tree; failure to enable specified clocks is fatal.

Signed-off-by: Gerhard Sittig <gsi@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   20 ++++++++++++++++++++
 include/linux/fs_enet_pd.h                         |    3 +++
 2 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index c04eb3a..6b60582 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -999,6 +999,8 @@ static int fs_enet_probe(struct platform_device *ofdev)
 	struct fs_enet_private *fep;
 	struct fs_platform_info *fpi;
 	const u32 *data;
+	struct clk *clk;
+	int err;
 	const u8 *mac_addr;
 	const char *phy_connection_type;
 	int privsize, len, ret = -ENODEV;
@@ -1036,6 +1038,20 @@ static int fs_enet_probe(struct platform_device *ofdev)
 			fpi->use_rmii = 1;
 	}
 
+	/* make clock lookup non-fatal (the driver is shared among platforms),
+	 * but require enable to succeed when a clock was specified/found,
+	 * keep a reference to the clock upon successful acquisition
+	 */
+	clk = devm_clk_get(&ofdev->dev, "per");
+	if (!IS_ERR(clk)) {
+		err = clk_prepare_enable(clk);
+		if (err) {
+			ret = err;
+			goto out_free_fpi;
+		}
+		fpi->clk_per = clk;
+	}
+
 	privsize = sizeof(*fep) +
 	           sizeof(struct sk_buff **) *
 	           (fpi->rx_ring + fpi->tx_ring);
@@ -1107,6 +1123,8 @@ out_free_dev:
 	free_netdev(ndev);
 out_put:
 	of_node_put(fpi->phy_node);
+	if (fpi->clk_per)
+		clk_disable_unprepare(fpi->clk_per);
 out_free_fpi:
 	kfree(fpi);
 	return ret;
@@ -1123,6 +1141,8 @@ static int fs_enet_remove(struct platform_device *ofdev)
 	fep->ops->cleanup_data(ndev);
 	dev_set_drvdata(fep->dev, NULL);
 	of_node_put(fep->fpi->phy_node);
+	if (fep->fpi->clk_per)
+		clk_disable_unprepare(fep->fpi->clk_per);
 	free_netdev(ndev);
 	return 0;
 }
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 343d82a..efb0596 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -16,6 +16,7 @@
 #ifndef FS_ENET_PD_H
 #define FS_ENET_PD_H
 
+#include <linux/clk.h>
 #include <linux/string.h>
 #include <linux/of_mdio.h>
 #include <linux/if_ether.h>
@@ -143,6 +144,8 @@ struct fs_platform_info {
 
 	int use_rmii;		/* use RMII mode 	       */
 	int has_phy;            /* if the network is phy container as well...*/
+
+	struct clk *clk_per;	/* 'per' clock for register access */
 };
 struct fs_mii_fec_platform_info {
 	u32 irq[32];
-- 
1.7.9.5
