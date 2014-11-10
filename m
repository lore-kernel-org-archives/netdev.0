From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Subject: [PATCH] smsc911x: power-up phydev before doing a software reset.
Date: Mon, 10 Nov 2014 19:23:09 +0100
Message-ID: <1415643789-5367-1-git-send-email-eballetbo@iseebcn.com>
Cc: javier@dowhile0.org, ebutera@gmail.com,
	Enric Balletbo i Serra <eballetbo@iseebcn.com>
To: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:55860 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaKJSXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:23:30 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so10934058wiv.1
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 10:23:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
to HALTED"), the PHY device will be put in a low-power mode using
BMCR_PDOWN if the the interface is set down. The smsc911x driver does
a software_reset opening the device driver (ndo_open). In such case,
the PHY must be powered-up before access to any register and before
calling the software_reset function. Otherwise, as the PHY is powered
down the software reset fails and the interface can not be enabled
again.

This patch fixes this scenario that is easy to reproduce setting down
the network interface and setting up again.

    $ ifconfig eth0 down
    $ ifconfig eth0 up
    ifconfig: SIOCSIFFLAGS: Input/output error

Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 46 ++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index affb29d..d8bfe94 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1342,6 +1342,42 @@ static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
 	spin_unlock(&pdata->mac_lock);
 }
 
+static int smsc911x_phy_general_power_up(struct smsc911x_data *pdata)
+{
+	int rc = 0;
+
+	if (!pdata->phy_dev)
+		return rc;
+
+	/* If the internal PHY is in General Power-Down mode, all, except the
+	 * management interface, is powered-down and stays in that condition as
+	 * long as Phy register bit 0.11 is HIGH.
+	 *
+	 * In that case, clear the bit 0.11, so the PHY powers up and we can
+	 * access to the phy registers.
+	 */
+	rc = phy_read(pdata->phy_dev, MII_BMCR);
+	if (rc < 0) {
+		SMSC_WARN(pdata, drv, "Failed reading PHY control reg");
+		return rc;
+	}
+
+	/* If the PHY general power-down bit is not set is not necessary to
+	 * disable the general power down-mode.
+	 */
+	if (rc & BMCR_PDOWN) {
+		rc = phy_write(pdata->phy_dev, MII_BMCR, rc & ~BMCR_PDOWN);
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
 static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 {
 	int rc = 0;
@@ -1415,6 +1451,16 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 	int ret;
 
 	/*
+	 * Make sure to power-up the PHY chip before doing a reset, otherwise
+	 * the reset fails.
+	 */
+	ret = smsc911x_phy_general_power_up(pdata);
+	if (ret) {
+		SMSC_WARN(pdata, drv, "Failed to power-up the PHY chip");
+		return ret;
+	}
+
+	/*
 	 * LAN9210/LAN9211/LAN9220/LAN9221 chips have an internal PHY that
 	 * are initialized in a Energy Detect Power-Down mode that prevents
 	 * the MAC chip to be software reseted. So we have to wakeup the PHY
-- 
1.9.1
