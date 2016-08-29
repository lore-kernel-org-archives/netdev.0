From: robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Subject: [PATCH v3 2/5] net: asix: Avoid looping when the device is disconnected
Date: Mon, 29 Aug 2016 09:32:16 -0400
Message-ID: <00080a3858eea85e87951162adf8841a60632581.1472155176.git-series.robert.foss__20591.0462224439$1472477680$gmane$org@collabora.com>
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

From: Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

Check the answers from the USB stack and avoid re-sending multiple times
the request if the device has disappeared.

Signed-off-by: Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/net/usb/asix_common.c  | 56 +++++++++++++++++++++++++++--------
 drivers/net/usb/asix_devices.c |  2 +-
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 25609ee..f79eb12 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -428,13 +428,21 @@ int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	__le16 res;
 	u8 smsr;
 	int i = 0;
+	int ret;
 
 	mutex_lock(&dev->phy_mutex);
 	do {
-		asix_set_sw_mii(dev, 0);
+		ret = asix_set_sw_mii(dev, 0);
+		if (ret == -ENODEV)
+			break;
 		usleep_range(1000, 1100);
-		asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
-	} while (!(smsr & AX_HOST_EN) && (i++ < 30));
+		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
+				    0, 0, 1, &smsr, 0);
+	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
+	if (ret == -ENODEV) {
+		mutex_unlock(&dev->phy_mutex);
+		return ret;
+	}
 
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
 				(__u16)loc, 2, &res, 0);
@@ -453,16 +461,24 @@ void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 	__le16 res = cpu_to_le16(val);
 	u8 smsr;
 	int i = 0;
+	int ret;
 
 	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
 			phy_id, loc, val);
 
 	mutex_lock(&dev->phy_mutex);
 	do {
-		asix_set_sw_mii(dev, 0);
+		ret = asix_set_sw_mii(dev, 0);
+		if (ret == -ENODEV)
+			break;
 		usleep_range(1000, 1100);
-		asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 0);
-	} while (!(smsr & AX_HOST_EN) && (i++ < 30));
+		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
+				    0, 0, 1, &smsr, 0);
+	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
+	if (ret == -ENODEV) {
+		mutex_unlock(&dev->phy_mutex);
+		return;
+	}
 
 	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
 		       (__u16)loc, 2, &res, 0);
@@ -476,13 +492,21 @@ int asix_mdio_read_nopm(struct net_device *netdev, int phy_id, int loc)
 	__le16 res;
 	u8 smsr;
 	int i = 0;
+	int ret;
 
 	mutex_lock(&dev->phy_mutex);
 	do {
-		asix_set_sw_mii(dev, 1);
+		ret = asix_set_sw_mii(dev, 1);
+		if (ret == -ENODEV)
+			break;
 		usleep_range(1000, 1100);
-		asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
-	} while (!(smsr & AX_HOST_EN) && (i++ < 30));
+		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
+				    0, 0, 1, &smsr, 1);
+	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
+	if (ret == -ENODEV) {
+		mutex_unlock(&dev->phy_mutex);
+		return ret;
+	}
 
 	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
 		      (__u16)loc, 2, &res, 1);
@@ -502,16 +526,24 @@ asix_mdio_write_nopm(struct net_device *netdev, int phy_id, int loc, int val)
 	__le16 res = cpu_to_le16(val);
 	u8 smsr;
 	int i = 0;
+	int ret;
 
 	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
 			phy_id, loc, val);
 
 	mutex_lock(&dev->phy_mutex);
 	do {
-		asix_set_sw_mii(dev, 1);
+		ret = asix_set_sw_mii(dev, 1);
+		if (ret == -ENODEV)
+			break;
 		usleep_range(1000, 1100);
-		asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG, 0, 0, 1, &smsr, 1);
-	} while (!(smsr & AX_HOST_EN) && (i++ < 30));
+		ret = asix_read_cmd(dev, AX_CMD_STATMNGSTS_REG,
+				    0, 0, 1, &smsr, 1);
+	} while (!(smsr & AX_HOST_EN) && (i++ < 30) && (ret != -ENODEV));
+	if (ret == -ENODEV) {
+		mutex_unlock(&dev->phy_mutex);
+		return;
+	}
 
 	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
 		       (__u16)loc, 2, &res, 1);
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index aaa4290..ebeb730 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -79,6 +79,8 @@ static u32 asix_get_phyid(struct usbnet *dev)
 	/* Poll for the rare case the FW or phy isn't ready yet.  */
 	for (i = 0; i < 100; i++) {
 		phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
+		if (phy_reg < 0)
+			return 0;
 		if (phy_reg != 0 && phy_reg != 0xFFFF)
 			break;
 		mdelay(1);
-- 
git-series 0.8.10
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
