From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v4 2/5] net/usb/r815x: avoid to call mdio functions for runtime-suspended device
Date: Wed, 31 Jul 2013 17:21:23 +0800
Message-ID: <1375262486-5373-2-git-send-email-hayeswang@realtek.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't replace the usb_control_msg() with usbnet_{read,write}_cmd()
which couldn't be called inside suspend/resume callback. Keep the
basic functions unlimited. Instead, using usb_autopm_get_interface()
and usb_autopm_put_interface() in r815x_mdio_{read,write}().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r815x.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
index e9b99ba..1a80e76 100644
--- a/drivers/net/usb/r815x.c
+++ b/drivers/net/usb/r815x.c
@@ -126,11 +126,18 @@ out1:
 static int r815x_mdio_read(struct net_device *netdev, int phy_id, int reg)
 {
 	struct usbnet *dev = netdev_priv(netdev);
+	int ret;
 
 	if (phy_id != R815x_PHY_ID)
 		return -EINVAL;
 
-	return ocp_reg_read(dev, BASE_MII + reg * 2);
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		return -ENODEV;
+
+	ret = ocp_reg_read(dev, BASE_MII + reg * 2);
+
+	usb_autopm_put_interface(dev->intf);
+	return ret;
 }
 
 static
@@ -141,7 +148,12 @@ void r815x_mdio_write(struct net_device *netdev, int phy_id, int reg, int val)
 	if (phy_id != R815x_PHY_ID)
 		return;
 
+	if (usb_autopm_get_interface(dev->intf) < 0)
+		return;
+
 	ocp_reg_write(dev, BASE_MII + reg * 2, val);
+
+	usb_autopm_put_interface(dev->intf);
 }
 
 static int r8153_bind(struct usbnet *dev, struct usb_interface *intf)
-- 
1.8.3.1
