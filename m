From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] USB2NET : SR9700 : One Chip USB 1.1 USB2NET SR9700
 Device Driver Support
Date: Fri, 30 Aug 2013 01:06:53 +0200
Message-ID: <20130829230653.GB12124@electric-eye.fr.zoreil.com>
References: <1377746832-6201-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, horms@verge.net.au, joe@perches.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60925 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757154Ab3H2XHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 19:07:11 -0400
Content-Disposition: inline
In-Reply-To: <1377746832-6201-1-git-send-email-liujunliang_ljl@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep it small though literate.

---
 drivers/net/usb/sr9700.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index f7f46e6..3f05b35 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -71,31 +71,25 @@ static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 
 static int wait_phy_eeprom_ready(struct usbnet *dev, int phy)
 {
-	int i, ret;
+	int i;
 
-	ret = 0;
 	for (i = 0; i < SR_SHARE_TIMEOUT; i++) {
 		u8 tmp = 0;
+		int ret;
 
 		udelay(1);
 		ret = sr_read_reg(dev, EPCR, &tmp);
 		if (ret < 0)
-			goto out;
+			return ret;
 
 		/* ready */
-		if ((tmp & EPCR_ERRE) == 0)
-			break;
+		if (!(tmp & EPCR_ERRE))
+			return 0;
 	}
 
-	if (i >= SR_SHARE_TIMEOUT) {
-		netdev_err(dev->net, "%s write timed out!\n",
-			   phy ? "phy" : "eeprom");
-		ret = -EIO;
-		goto out;
-	}
+	netdev_err(dev->net, "%s write timed out!\n", phy ? "phy" : "eeprom");
 
-out:
-	return ret;
+	return -EIO;
 }
 
 static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg,
@@ -110,7 +104,7 @@ static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg,
 
 	ret = wait_phy_eeprom_ready(dev, phy);
 	if (ret < 0)
-		goto out;
+		goto out_unlock;
 
 	sr_write_reg(dev, EPCR, 0x0);
 	ret = sr_read(dev, EPDR, 2, value);
@@ -118,7 +112,7 @@ static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg,
 	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
 		   phy, reg, *value, ret);
 
-out:
+out_unlock:
 	mutex_unlock(&dev->phy_mutex);
 	return ret;
 }
@@ -132,18 +126,18 @@ static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg,
 
 	ret = sr_write(dev, EPDR, 2, &value);
 	if (ret < 0)
-		goto out;
+		goto out_unlock;
 
 	sr_write_reg(dev, EPAR, phy ? (reg | 0x40) : reg);
 	sr_write_reg(dev, EPCR, phy ? 0x1a : 0x12);
 
 	ret = wait_phy_eeprom_ready(dev, phy);
 	if (ret < 0)
-		goto out;
+		goto out_unlock;
 
 	sr_write_reg(dev, EPCR, 0x0);
 
-out:
+out_unlock:
 	mutex_unlock(&dev->phy_mutex);
 	return ret;
 }
-- 
1.8.3.1
