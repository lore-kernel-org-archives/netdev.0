From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH net-next] fs_enet: Add MPC5125 FEC support and PHY interface selection
Date: Sun, 18 Mar 2012 00:10:50 +0100
Message-ID: <1332025850-829-1-git-send-email-agust@denx.de>
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Vladimir Ermakov <vooon341@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54181 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab2CQXKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 19:10:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Ermakov <vooon341@gmail.com>

Add compatible string for MPC5125 FEC. The FEC on MPC5125 additionally
supports RMII PHY interface. Configure controller/PHY interface type
according to the optional phy-connection-type property in the ethernet
node. This property should be either "rmii" or "mii".

Signed-off-by: Vladimir Ermakov <vooon341@gmail.com>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/ethernet/freescale/fs_enet/fec.h       |    6 ++++--
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   20 ++++++++++++++++++--
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |    9 ++++++---
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fec.h b/drivers/net/ethernet/freescale/fs_enet/fec.h
index e980527..b9fe5bd 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fec.h
+++ b/drivers/net/ethernet/freescale/fs_enet/fec.h
@@ -23,6 +23,10 @@
 #define FEC_ECNTRL_ETHER_EN	0x00000002
 #define FEC_ECNTRL_RESET	0x00000001
 
+/* RMII mode enabled only when MII_MODE bit is set too. */
+#define FEC_RCNTRL_RMII_MODE	(0x00000100 | \
+				 FEC_RCNTRL_MII_MODE | FEC_RCNTRL_FCE)
+#define FEC_RCNTRL_FCE		0x00000020
 #define FEC_RCNTRL_BC_REJ	0x00000010
 #define FEC_RCNTRL_PROM		0x00000008
 #define FEC_RCNTRL_MII_MODE	0x00000004
@@ -33,8 +37,6 @@
 #define FEC_TCNTRL_HBC		0x00000002
 #define FEC_TCNTRL_GTS		0x00000001
 
-
-
 /*
  * Delay to wait for FEC reset command to complete (in us)
  */
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 910a8e1..3fc103f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -790,16 +790,20 @@ static int fs_init_phy(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct phy_device *phydev;
+	phy_interface_t iface;
 
 	fep->oldlink = 0;
 	fep->oldspeed = 0;
 	fep->oldduplex = -1;
 
+	iface = fep->fpi->use_rmii ?
+		PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII;
+
 	phydev = of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link, 0,
-				PHY_INTERFACE_MODE_MII);
+				iface);
 	if (!phydev) {
 		phydev = of_phy_connect_fixed_link(dev, &fs_adjust_link,
-						   PHY_INTERFACE_MODE_MII);
+						   iface);
 	}
 	if (!phydev) {
 		dev_err(&dev->dev, "Could not attach to PHY\n");
@@ -1007,6 +1011,7 @@ static int __devinit fs_enet_probe(struct platform_device *ofdev)
 	struct fs_platform_info *fpi;
 	const u32 *data;
 	const u8 *mac_addr;
+	const char *phy_connection_type;
 	int privsize, len, ret = -ENODEV;
 
 	match = of_match_device(fs_enet_match, &ofdev->dev);
@@ -1035,6 +1040,13 @@ static int __devinit fs_enet_probe(struct platform_device *ofdev)
 						  NULL)))
 		goto out_free_fpi;
 
+	if (of_device_is_compatible(ofdev->dev.of_node, "fsl,mpc5125-fec")) {
+		phy_connection_type = of_get_property(ofdev->dev.of_node,
+						"phy-connection-type", NULL);
+		if (phy_connection_type && !strcmp("rmii", phy_connection_type))
+			fpi->use_rmii = 1;
+	}
+
 	privsize = sizeof(*fep) +
 	           sizeof(struct sk_buff **) *
 	           (fpi->rx_ring + fpi->tx_ring);
@@ -1150,6 +1162,10 @@ static struct of_device_id fs_enet_match[] = {
 		.compatible = "fsl,mpc5121-fec",
 		.data = (void *)&fs_fec_ops,
 	},
+	{
+		.compatible = "fsl,mpc5125-fec",
+		.data = (void *)&fs_fec_ops,
+	},
 #else
 	{
 		.compatible = "fsl,pq1-fec-enet",
diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index b9fbc83..9ae6cdb 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -322,10 +322,11 @@ static void restart(struct net_device *dev)
 	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
 #else
 	/*
-	 * Only set MII mode - do not touch maximum frame length
+	 * Only set MII/RMII mode - do not touch maximum frame length
 	 * configured before.
 	 */
-	FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+	FS(fecp, r_cntrl, fpi->use_rmii ?
+			FEC_RCNTRL_RMII_MODE : FEC_RCNTRL_MII_MODE);
 #endif
 	/*
 	 * adjust to duplex mode
@@ -381,7 +382,9 @@ static void stop(struct net_device *dev)
 
 	/* shut down FEC1? that's where the mii bus is */
 	if (fpi->has_phy) {
-		FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
+		FS(fecp, r_cntrl, fpi->use_rmii ?
+				FEC_RCNTRL_RMII_MODE :
+				FEC_RCNTRL_MII_MODE);	/* MII/RMII enable */
 		FS(fecp, ecntrl, FEC_ECNTRL_PINMUX | FEC_ECNTRL_ETHER_EN);
 		FW(fecp, ievent, FEC_ENET_MII);
 		FW(fecp, mii_speed, feci->mii_speed);
-- 
1.7.7.6
