From: "ASIX_Allan [Office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: [PATCH v4 3/5] net: asix: Fix AX88772x resume failures
Date: Wed, 30 Nov 2016 11:03:11 +0800
Message-ID: <00a601d24ab6$4e9274d0$ebb75e70$@asix.com.tw>
Reply-To: <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>, <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The change fixes AX88772x resume failure by
- Restore incorrect AX88772A PHY registers when resetting
- Need to stop MAC operation when suspending
- Need to restart MII when restoring PHY

Signed-off-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Tested-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>

---
drivers/net/usb/asix_devices.c | 47
+++++++++++++++++++++++++++++++++++++++++-
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
@@ -424,7 +433,7 @@ static int ax88772a_hw_reset(struct usbnet *dev, int
in_pm)  {
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret, embd_phy;
-	u16 rx_ctl;
+	u16 rx_ctl, phy14h, phy15h, phy16h;
 	u8 chipcode = 0;
 
 	ret = asix_write_gpio(dev, AX_GPIO_RSE, 5, in_pm); @@ -482,6 +491,32
@@ static int ax88772a_hw_reset(struct usbnet *dev, int in_pm)
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
 
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0, @@ -543,6 +578,15 @@
static const struct net_device_ops ax88772_netdev_ops = {  static void
ax88772_suspend(struct usbnet *dev)  {
 	struct asix_common_private *priv = dev->driver_priv;
+	u16 medium;
+
+	/* Stop MAC operation */
+	medium = asix_read_medium_status(dev, 1);
+	medium &= ~AX_MEDIUM_RE;
+	asix_write_medium_mode(dev, medium, 1);
+
+	netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
+		   asix_read_medium_status(dev, 1));
 
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


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
