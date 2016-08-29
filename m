From: robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Subject: [PATCH v3 4/5] net: asix: see 802.3 spec for phy reset
Date: Mon, 29 Aug 2016 09:32:18 -0400
Message-ID: <1f15c0fdc3c484a5cf8f6b140059834411dc78f2.1472155176.git-series.robert.foss__2630.11765569008$1472477734$gmane$org@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
To: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
        Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>

From: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

https://lkml.org/lkml/2014/11/11/947

Ben Hutchings is correct. IEEE 802.3 spec section "22.2.4.1.1 Reset" requires
up to 500ms delay. Mitigate the "max" delay by polling the phy until BCM_RESET
bit is clear.

Signed-off-by: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/net/usb/asix_devices.c | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 083dc2e..dbcdda2 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -212,6 +212,28 @@ static const struct net_device_ops ax88172_netdev_ops = {
 	.ndo_set_rx_mode	= ax88172_set_multicast,
 };
 
+static void asix_phy_reset(struct usbnet *dev, unsigned int reset_bits)
+{
+	unsigned int timeout = 5000;
+
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, reset_bits);
+
+	/* give phy_id a chance to process reset */
+	udelay(500);
+
+	/* See IEEE 802.3 "22.2.4.1.1 Reset": 500ms max */
+	while (timeout--) {
+		if (asix_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR)
+							& BMCR_RESET)
+			udelay(100);
+		else
+			return;
+	}
+
+	netdev_err(dev->net, "BMCR_RESET timeout on phy_id %d\n",
+		   dev->mii.phy_id);
+}
+
 static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret = 0;
@@ -258,7 +280,7 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
 	dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	asix_phy_reset(dev, BMCR_RESET);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	mii_nway_restart(&dev->mii);
@@ -900,8 +922,7 @@ static int ax88178_reset(struct usbnet *dev)
 	} else if (data->phymode == PHY_MODE_RTL8211CL)
 		rtl8211cl_phy_init(dev);
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
-			BMCR_RESET | BMCR_ANENABLE);
+	asix_phy_reset(dev, BMCR_RESET | BMCR_ANENABLE);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
-- 
git-series 0.8.10
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
