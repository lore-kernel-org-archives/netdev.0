From: Peter Rusko <rusko.peter@prolan.hu>
Subject: FEC MAC with ethernet switch chip
Date: Thu, 22 Mar 2012 17:46:33 +0100
Message-ID: <4F6B5769.2090301@prolan.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------070200090801010708050003"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw2.prolan.hu ([193.68.50.107]:41730 "EHLO fw2.prolan.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474Ab2CWFl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 01:41:56 -0400
Received: from imss.prolan.hu (unknown [10.254.254.252])
	by fw2.prolan.hu (Postfix) with ESMTP id 76BF9E2C9
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 06:32:20 +0100 (CET)
Received: from imss.prolan.hu (localhost.localdomain [127.0.0.1])
	by localhost (Postfix) with ESMTP id 808CFCF9FD
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 06:33:35 +0100 (CET)
Received: from fw2.prolan.hu (unknown [10.254.254.253])
	by imss.prolan.hu (Postfix) with ESMTP id 683CBCF9EC
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 06:33:35 +0100 (CET)
Received: from saturn2.intranet.prolan.hu (saturn2.intranet.prolan.hu [193.91.83.237])
	by fw2.prolan.hu (Postfix) with ESMTP id B0D0BE468
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 06:31:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------070200090801010708050003
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit

Hi all,

I'm trying to get a Marvell ethernet switch (88E6065) working with the
FEC driver (on an i.mx28 cpu). The original driver doesn't support it
because of the multiple ports/phys. It probes the bus and assigns the hw
with the first address to fec0 and the second to fec1. This results the
loss of fec1 when I disconnect the cable from the first port (the phy
driver brings the connection down).

I have two solutions, but don't really know which one is better.

1. There is a DSA (Distributed Switch Architecture) interface used in
the kernel for these chips. These drivers don't need PHY's so I simply
disabled the PHY driver (and made it configurable through
platform_data). An attached patch shows this simple solution. It works
perfectly, but I still have to configure the chip. (btw, I had serious
problems adding the platform_dev because it needs a reference to a
struct ndev. Is there a good solution for this?)

2. A PHY driver would solve the problem, though it's not a PHY.

Which one should I use? Or is there a better one?

Regards,
-- 
Ruskó Péter
Fejlesztőmérnök

Prolan Zrt. / Prolan Co.
Hungary 2011 Budakalász, Szentendrei út 1-3.
Tel./Phone: +36 20 954 3118
Fax: +36 26 540 420
E-mail: rusko.peter@prolan.hu
Web: www.prolan.hu
Timezone:CET

--------------070200090801010708050003
Content-Type: text/x-patch; name="fecphy.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="fecphy.patch"

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a13eb30..293432f 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -239,6 +239,7 @@ struct fec_enet_private {
 	int	mii_timeout;
 	uint	phy_speed;
 	phy_interface_t	phy_interface;
+	unsigned phy_type;
 	int	link;
 	int	full_duplex;
 	struct	completion mdio_done;
@@ -978,6 +979,17 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 
 	fep->phy_dev = NULL;
 
+	if (fep->phy_type == FEC_PHY_SWITCH) {
+		fep->link = 1;
+		netif_carrier_on(ndev); // always up
+
+		fep->full_duplex = 1; // full duplex
+
+		fec_restart(ndev, fep->full_duplex);
+
+		return 0;
+	}
+
 	/* check for attached phy */
 	for (phy_id = 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
 		if ((fep->mii_bus->phy_mask & (1 << phy_id)))
@@ -1170,8 +1182,20 @@ static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 	if (!netif_running(ndev))
 		return -EINVAL;
 
-	if (!phydev)
-		return -ENODEV;
+	if (!phydev) {
+		// On i.mx28, this is not necessarily needed
+		// TODO: remove?
+		struct mii_ioctl_data *mii_data = if_mii(rq);
+
+		if (cmd == SIOCGMIIREG)
+			mdiobus_write(fep->mii_bus, mii_data->phy_id,
+					mii_data->reg_num, mii_data->val_in);
+		else if (cmd == SIOCSMIIREG)
+			mii_data->val_out = mdiobus_read(fep->mii_bus,
+					mii_data->phy_id, mii_data->reg_num);
+		else return -ENODEV;
+		return 0;
+	}
 
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
@@ -1274,7 +1298,8 @@ fec_enet_open(struct net_device *ndev)
 		fec_enet_free_buffers(ndev);
 		return ret;
 	}
-	phy_start(fep->phy_dev);
+	if (fep->phy_type == FEC_PHY_NORMAL)
+		phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
 	fep->opened = 1;
 	return 0;
@@ -1598,6 +1623,9 @@ fec_probe(struct platform_device *pdev)
 		fep->phy_interface = ret;
 	}
 
+	if (pdata)
+		fep->phy_type = pdata->phy_type;
+
 	fec_reset_phy(pdev);
 
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
diff --git a/include/linux/fec.h b/include/linux/fec.h
index bcff455..701fb2a 100644
--- a/include/linux/fec.h
+++ b/include/linux/fec.h
@@ -14,10 +14,15 @@
 #ifndef __LINUX_FEC_H__
 #define __LINUX_FEC_H__
 
+#define FEC_PHY_NORMAL 0
+#define FEC_PHY_SWITCH 1
+#define FEC_PHY_NONE 2
+
 #include <linux/phy.h>
 
 struct fec_platform_data {
 	phy_interface_t phy;
+	unsigned phy_type;
 	unsigned char mac[ETH_ALEN];
 };
 

--------------070200090801010708050003--
