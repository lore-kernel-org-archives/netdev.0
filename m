From: Stefani Seibold <stefani@seibold.net>
Subject: [PATCH] fix PHY polling system blocking
Date: Sat, 13 Mar 2010 13:53:10 +0100
Message-ID: <1268484790.6339.37.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
To: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the PHY poller, which can block the whole system. PHY
access are normaly not very fast, since there are serial attached.

For PHY chips without interrupts, the status of the ethernet will be
polled every 2 sec. The poll function will read some register of the MII
PHY. The time between the sending the MII_READ_COMMAND and receiving the
result could be very long (>100us).

For example:

On a Freescale PPC 834x this result in a delay of 450 us due the slow
communication with the PHY chip. The time between the sending the
MII_READ_COMMAND and receiving the result is more the 100 us on this
controller.
   
The patch modifies the poller a lit bit. Only a link status state change
will result in a successive detection of the connection type. The poll
cycle on the other hand will be increased to one every seconds.

All in all this patch will prevent a blocking of f.e nearly 400 us every
two seconds of the whole system on a PPC 834x.

There is not real drawback, only the detection of a connection type
change without unplugging the cable will not work. But this is more an
esoteric use case.

The patch is against kernel 2.6.33. Please merge it.

Signed-off-by: Stefani Seibold <stefani@seibold.net>
---
 phy.c        |    5 ++---
 phy_device.c |   11 ++++++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff -u -N -r -p linux-2.6.33.orig/drivers/net/phy/phy.c linux-2.6.33/drivers/net/phy/phy.c
--- linux-2.6.33.orig/drivers/net/phy/phy.c	2010-02-24 19:52:17.000000000 +0100
+++ linux-2.6.33/drivers/net/phy/phy.c	2010-02-28 22:53:14.725464101 +0100
@@ -871,9 +871,8 @@ void phy_state_machine(struct work_struc
 		case PHY_RUNNING:
 			/* Only register a CHANGE if we are
 			 * polling */
-			if (PHY_POLL == phydev->irq)
-				phydev->state = PHY_CHANGELINK;
-			break;
+			if (PHY_POLL != phydev->irq)
+				break;
 		case PHY_CHANGELINK:
 			err = phy_read_status(phydev);
 
diff -u -N -r -p linux-2.6.33.orig/drivers/net/phy/phy_device.c linux-2.6.33/drivers/net/phy/phy_device.c
--- linux-2.6.33.orig/drivers/net/phy/phy_device.c	2010-02-24 19:52:17.000000000 +0100
+++ linux-2.6.33/drivers/net/phy/phy_device.c	2010-02-28 22:53:14.726464145 +0100
@@ -161,7 +161,7 @@ struct phy_device* phy_device_create(str
 	dev->speed = 0;
 	dev->duplex = -1;
 	dev->pause = dev->asym_pause = 0;
-	dev->link = 1;
+	dev->link = 0;
 	dev->interface = PHY_INTERFACE_MODE_GMII;
 
 	dev->autoneg = AUTONEG_ENABLE;
@@ -694,10 +694,15 @@ int genphy_update_link(struct phy_device
 	if (status < 0)
 		return status;
 
-	if ((status & BMSR_LSTATUS) == 0)
+	if ((status & BMSR_LSTATUS) == 0) {
+		if (phydev->link == 0)
+			return 1;
 		phydev->link = 0;
-	else
+	} else {
+		if (phydev->link == 1)
+			return 1;
 		phydev->link = 1;
+	}
 
 	return 0;
 }
