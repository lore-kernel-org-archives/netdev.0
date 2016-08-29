From: robert.foss@collabora.com
Subject: [PATCH v3 4/5] net: asix: see 802.3 spec for phy reset
Date: Mon, 29 Aug 2016 09:32:18 -0400
Message-ID: <1f15c0fdc3c484a5cf8f6b140059834411dc78f2.1472155176.git-series.robert.foss__4858.91200737587$1472477726$gmane$org@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
To: freddy@asix.com.tw, Dean_Jenkins@mentor.com,
        Mark_Craske@mentor.com, davem@davemloft.net,
        robert.foss@collabora.com, ivecera@redhat.com,
        john.stultz@linaro.org, vpalatin@chromium.org,
        stephen@networkplumber.org, grundler@chromium.org,
        changchias@gmail.com, allan@asix.com.tw, andrew@lunn.ch,
        tremyfr@gmail.com, colin.king@canonical.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vpalatin@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:52421 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933345AbcH2Nco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:32:44 -0400
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Foss <robert.foss@collabora.com>

From: Grant Grundler <grundler@chromium.org>

https://lkml.org/lkml/2014/11/11/947

Ben Hutchings is correct. IEEE 802.3 spec section "22.2.4.1.1 Reset" requires
up to 500ms delay. Mitigate the "max" delay by polling the phy until BCM_RESET
bit is clear.

Signed-off-by: Grant Grundler <grundler@chromium.org>
Signed-off-by: Robert Foss <robert.foss@collabora.com>
Tested-by: Robert Foss <robert.foss@collabora.com>
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
