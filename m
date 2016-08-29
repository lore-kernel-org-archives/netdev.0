From: robert.foss@collabora.com
Subject: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Mon, 29 Aug 2016 09:32:22 -0400
Message-ID: <1472477566-32096-3-git-send-email-robert.foss@collabora.com>
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
Received: from bhuna.collabora.co.uk ([46.235.227.227]:52466 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933392AbcH2Ncz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:32:55 -0400
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Chou <allan@asix.com.tw>

The change fixes AX88772x resume failure by
- Restore incorrect AX88772A PHY registers when resetting
- Need to stop MAC operation when suspending
- Need to restart MII when restoring PHY

Signed-off-by: Allan Chou <allan@asix.com.tw>
Signed-off-by: Robert Foss <robert.foss@collabora.com>
Tested-by: Robert Foss <robert.foss@collabora.com>
---
 drivers/net/usb/asix_devices.c | 47 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 46 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index ebeb730..083dc2e 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -35,6 +35,15 @@
 
 #define	PHY_MODE_RTL8211CL	0x000C
 
+#define AX88772A_PHY14H		0x14
+#define AX88772A_PHY14H_DEFAULT 0x442C
+
+#define AX88772A_PHY15H		0x15
+#define AX88772A_PHY15H_DEFAULT 0x03C8
+
+#define AX88772A_PHY16H		0x16
+#define AX88772A_PHY16H_DEFAULT 0x4044
+
 struct ax88172_int_data {
 	__le16 res1;
 	u8 link;
@@ -424,7 +433,7 @@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
 {
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret, embd_phy;
-	u16 rx_ctl;
+	u16 rx_ctl, phy14h, phy15h, phy16h;
 	u8 chipcode = 0;
 
 	ret = asix_write_gpio(dev, AX_GPIO_RSE, 5, in_pm);
@@ -482,6 +491,32 @@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
 				   ret);
 			goto out;
 		}
+	} else if ((chipcode & AX_CHIPCODE_MASK) == AX_AX88772A_CHIPCODE) {
+		/* Check if the PHY registers have default settings */
+		phy14h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY14H);
+		phy15h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY15H);
+		phy16h = asix_mdio_read_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY16H);
+
+		netdev_dbg(dev->net,
+			   "772a_hw_reset: MR20=0x%x MR21=0x%x MR22=0x%x\n",
+			   phy14h, phy15h, phy16h);
+
+		/* Restore PHY registers default setting if not */
+		if (phy14h != AX88772A_PHY14H_DEFAULT)
+			asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY14H,
+					     AX88772A_PHY14H_DEFAULT);
+		if (phy15h != AX88772A_PHY15H_DEFAULT)
+			asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY15H,
+					     AX88772A_PHY15H_DEFAULT);
+		if (phy16h != AX88772A_PHY16H_DEFAULT)
+			asix_mdio_write_nopm(dev->net, dev->mii.phy_id,
+					     AX88772A_PHY16H,
+					     AX88772A_PHY16H_DEFAULT);
 	}
 
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
@@ -543,6 +578,15 @@ static const struct net_device_ops ax88772_netdev_ops = {
 static void ax88772_suspend(struct usbnet *dev)
 {
 	struct asix_common_private *priv = dev->driver_priv;
+	u16 medium;
+
+	/* Stop MAC operation */
+	medium = asix_read_medium_status(dev, 0);
+	medium &= ~AX_MEDIUM_RE;
+	asix_write_medium_mode(dev, medium, 0);
+
+	netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
+		   asix_read_medium_status(dev, 0));
 
 	/* Preserve BMCR for restoring */
 	priv->presvd_phy_bmcr =
@@ -577,6 +621,7 @@ static void ax88772_restore_phy(struct usbnet *dev)
 		asix_mdio_write_nopm(dev->net, dev->mii.phy_id, MII_BMCR,
 				     priv->presvd_phy_bmcr);
 
+		mii_nway_restart(&dev->mii);
 		priv->presvd_phy_advertise = 0;
 		priv->presvd_phy_bmcr = 0;
 	}
-- 
2.7.4
