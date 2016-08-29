From: robert.foss@collabora.com
Subject: [PATCH v3 2/5] net: asix: Avoid looping when the device is disconnected
Date: Mon, 29 Aug 2016 09:32:16 -0400
Message-ID: <00080a3858eea85e87951162adf8841a60632581.1472155176.git-series.robert.foss__19589.5306337208$1472477682$gmane$org@collabora.com>
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
Received: from bhuna.collabora.co.uk ([46.235.227.227]:52395 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933393AbcH2Nco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:32:44 -0400
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Foss <robert.foss@collabora.com>

From: Vincent Palatin <vpalatin@chromium.org>

Check the answers from the USB stack and avoid re-sending multiple times
the request if the device has disappeared.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
Signed-off-by: Robert Foss <robert.foss@collabora.com>
Tested-by: Robert Foss <robert.foss@collabora.com>
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
