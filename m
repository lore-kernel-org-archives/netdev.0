From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 2/2] smsc95xx: fix async register writes on big endian platforms
Date: Mon, 10 Dec 2012 11:03:08 +0000
Message-ID: <1355137388-2938-2-git-send-email-steve.glendinning@shawell.net>
References: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:48306 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab2LJLDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 06:03:12 -0500
In-Reply-To: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a missing endian conversion which results in the
interface failing to come up on BE platforms.

It also removes an unnecessary pointer dereference from this
function.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index a00dcc4..9b73670 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -421,15 +421,19 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 }
 
 static int __must_check smsc95xx_write_reg_async(struct usbnet *dev, u16 index,
-						 u32 *data)
+						 u32 data)
 {
 	const u16 size = 4;
+	u32 buf;
 	int ret;
 
+	buf = data;
+	cpu_to_le32s(&buf);
+
 	ret = usbnet_write_cmd_async(dev, USB_VENDOR_REQUEST_WRITE_REGISTER,
 				     USB_DIR_OUT | USB_TYPE_VENDOR |
 				     USB_RECIP_DEVICE,
-				     0, index, data, size);
+				     0, index, &buf, size);
 	if (ret < 0)
 		netdev_warn(dev->net, "Error write async cmd, sts=%d\n",
 			    ret);
@@ -490,15 +494,15 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
 
 	/* Initiate async writes, as we can't wait for completion here */
-	ret = smsc95xx_write_reg_async(dev, HASHH, &pdata->hash_hi);
+	ret = smsc95xx_write_reg_async(dev, HASHH, pdata->hash_hi);
 	if (ret < 0)
 		netdev_warn(dev->net, "failed to initiate async write to HASHH\n");
 
-	ret = smsc95xx_write_reg_async(dev, HASHL, &pdata->hash_lo);
+	ret = smsc95xx_write_reg_async(dev, HASHL, pdata->hash_lo);
 	if (ret < 0)
 		netdev_warn(dev->net, "failed to initiate async write to HASHL\n");
 
-	ret = smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
+	ret = smsc95xx_write_reg_async(dev, MAC_CR, pdata->mac_cr);
 	if (ret < 0)
 		netdev_warn(dev->net, "failed to initiate async write to MAC_CR\n");
 }
-- 
1.7.10.4
