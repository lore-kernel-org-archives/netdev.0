From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 2/2] net/smsc911x: Check if PHY is in operational mode before software reset
Date: Mon,  2 Jan 2012 18:08:51 +0100
Message-ID: <1325524131-14585-2-git-send-email-martinez.javier@gmail.com>
References: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>,
	netdev@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46990 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab2ABRII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 12:08:08 -0500
Received: by wibhm6 with SMTP id hm6so8519588wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 09:08:07 -0800 (PST)
In-Reply-To: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMSC LAN generation 4 chips integrate an IEEE 802.3 ethernet physical layer.
The PHY driver for this integrated chip enable an energy detect power-down mode.
When the PHY is in a power-down mode, it prevents the MAC portion chip to be
software reseted.

That means that if we compile the kernel with the configuration option SMSC_PHY
enabled and try to bring the network interface up without an cable plug-ed the
PHY will be in a low power mode and the software reset will fail returning -EIO
to user-space:

root@igep00x0:~# ifconfig eth0 up
ifconfig: SIOCSIFFLAGS: Input/output error

This patch disable the energy detect power-down mode before trying to software
reset the LAN chip and re-enables after it was reseted successfully.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   88 ++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8843071..2a63e11 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1243,10 +1243,88 @@ static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
 	spin_unlock(&pdata->mac_lock);
 }
 
+static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
+{
+	int rc = 0;
+
+	if (!pdata->phy_dev)
+		return rc;
+
+	rc = phy_read(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS);
+
+	if (rc < 0) {
+		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
+		return rc;
+	}
+
+	/* If energy is detected the PHY is already awake so is not necessary
+	 * to disable the energy detect power-down mode. */
+	if ((rc & MII_LAN83C185_EDPWRDOWN) &&
+	    !(rc & MII_LAN83C185_ENERGYON)) {
+		/* Disable energy detect mode for this SMSC Transceivers */
+		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
+			       rc & (~MII_LAN83C185_EDPWRDOWN));
+
+		if (rc < 0) {
+			SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
+			return rc;
+		}
+
+		mdelay(1);
+	}
+
+	return 0;
+}
+
+static int smsc911x_phy_enable_energy_detect(struct smsc911x_data *pdata)
+{
+	int rc = 0;
+
+	if (!pdata->phy_dev)
+		return rc;
+
+	rc = phy_read(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS);
+
+	if (rc < 0) {
+		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
+		return rc;
+	}
+
+	/* Only enable if energy detect mode is already disabled */
+	if (!(rc & MII_LAN83C185_EDPWRDOWN)) {
+		mdelay(100);
+		/* Enable energy detect mode for this SMSC Transceivers */
+		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
+			       rc | MII_LAN83C185_EDPWRDOWN);
+
+		if (rc < 0) {
+			SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
+			return rc;
+		}
+
+		mdelay(1);
+	}
+	return 0;
+}
+
 static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 {
 	unsigned int timeout;
 	unsigned int temp;
+	int ret;
+
+	/* LAN9210/LAN9211/LAN9220/LAN9221 chips have an internal PHY that
+	 * are initialized in a Energy Detect Power-Down mode that prevents
+	 * the MAC chip to be software reseted. So we have to wakeup the PHY
+	 * before */
+	if (pdata->generation == 4) {
+		ret = smsc911x_phy_disable_energy_detect(pdata);
+
+		if (ret) {
+			SMSC_WARN(pdata, drv, "Failed to wakeup the PHY chip");
+			return ret;
+		}
+	}
 
 	/* Reset the LAN911x */
 	smsc911x_reg_write(pdata, HW_CFG, HW_CFG_SRST_);
@@ -1260,6 +1338,16 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 		SMSC_WARN(pdata, drv, "Failed to complete reset");
 		return -EIO;
 	}
+
+	if (pdata->generation == 4) {
+		ret = smsc911x_phy_enable_energy_detect(pdata);
+
+		if (ret) {
+			SMSC_WARN(pdata, drv, "Failed to wakeup the PHY chip");
+			return ret;
+		}
+	}
+
 	return 0;
 }
 
-- 
1.7.4.1
