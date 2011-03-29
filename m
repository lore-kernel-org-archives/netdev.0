From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] phylib: phy_attach_direct: phy_init_hw can fail, add cleanup
Date: Tue, 29 Mar 2011 02:54:08 +0200
Message-ID: <1301360048-14095-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, "David S. Miller" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37949 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257Ab1C2AyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 20:54:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function phy_attach_direct attaches the phy and calls phy_init_hw.
phy_init_hw can fail, but the phy is still marked as attached. Successive
calls to phy_attach_direct will fail because the phy is busy.

[    1.020000] eth0: Freescale FEC PHY driver [Generic PHY] (mii_bus:phy_addr=1:00, irq=-1)
[    1.030000] eth1: Freescale FEC PHY driver [Generic PHY] (mii_bus:phy_addr=1:01, irq=-1)
[    2.050000] Sending DHCP requests .
[    3.020000] PHY: 1:00 - Link is Up - 100/Full
[    5.110000] ..... timed out!
[   87.660000] IP-Config: Reopening network devices...
[   88.190000] FEC: MDIO read timeout
[   88.190000] eth0: could not attach to PHY
[   88.190000] IP-Config: Failed to open eth0
[   88.210000] FEC: MDIO read timeout
[   88.210000] eth1: could not attach to PHY
[   88.210000] IP-Config: Failed to open eth1
[   88.220000] IP-Config: No network devices available.
[   88.220000] Freeing init memory: 6968K

[...]

starting network interfaces...
ip: RTNETLINK answers: File exists
[   94.000000] net eth0: PHY already attached
[   94.010000] eth0: could not attach to PHY
ip: SIOCSIFFLAGS: Device or resource busy

This patch adds phy_detach to clean up if phy_init_hw fails.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/phy/phy_device.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 993c52c..e870c06 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -442,11 +442,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			     u32 flags, phy_interface_t interface)
 {
 	struct device *d = &phydev->dev;
+	int err;
 
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver. */
 	if (NULL == d->driver) {
-		int err;
 		d->driver = &genphy_driver.driver;
 
 		err = d->driver->probe(d);
@@ -474,7 +474,11 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface) */
-	return phy_init_hw(phydev);
+	err = phy_init_hw(phydev);
+	if (err)
+		phy_detach(phydev);
+
+	return err;
 }
 
 /**
-- 
1.7.2.3

