From: robert.foss@collabora.com
Subject: [PATCH 2/3] net: asix: Avoid looping when the device is disconnected
Date: Mon, 25 Jul 2016 13:40:23 -0400
Message-ID: <1469468424-22685-2-git-send-email-robert.foss@collabora.com>
References: <1469468424-22685-1-git-send-email-robert.foss@collabora.com>
Cc: enric.balletbo@collabora.com, tomeu.vizoso@collabora.com
To: davem@davemloft.net, grundler@chromium.org, Mark_Craske@mentor.com,
	Dean_Jenkins@mentor.com, vpalatin@chromium.org, ivecera@redhat.com,
	linux@davidrobins.net, wk.tsai@nvidia.com, changchias@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469468424-22685-1-git-send-email-robert.foss@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Palatin <vpalatin@chromium.org>

Check the answers from the USB stack and avoid re-sending multiple times
the request if the device has disappeared.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 drivers/net/usb/asix_common.c  | 56 +++++++++++++++++++++++++++++++++---------
 drivers/net/usb/asix_devices.c |  2 ++
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index f0ccf76..0339560 100644
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
2.7.4
