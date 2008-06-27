From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: don't do usb transfers of data on stack
Date: Fri, 27 Jun 2008 11:28:11 +0200
Message-ID: <1214558891-15971-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:54920 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYF0J2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 05:28:16 -0400
Received: by ug-out-1314.google.com with SMTP id h2so353553ugf.16
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 02:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm_{read,write}_shared_word() were doing USB transfers of data on stack,
which isn't allowed. Fix it by using the usbnet->data area like in
dm9601_set_multicast().

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index f7319d3..1a5e649 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -158,6 +158,10 @@ static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
 {
 	int ret, i;
+	/* USB transfers of data on stack is not allowed  - We use
+	   the 20 byte dev->data for value to avoid allocating memory.
+	   Notice that dm9601_set_multicast() uses the lower 8 bytes */
+	void *data = &dev->data[4];
 
 	mutex_lock(&dev->phy_mutex);
 
@@ -184,7 +188,8 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	}
 
 	dm_write_reg(dev, DM_SHARED_CTRL, 0x0);
-	ret = dm_read(dev, DM_SHARED_DATA, 2, value);
+	ret = dm_read(dev, DM_SHARED_DATA, 2, data);
+	memcpy(value, data, 2);
 
 	devdbg(dev, "read shared %d 0x%02x returned 0x%04x, %d",
 	       phy, reg, *value, ret);
@@ -197,10 +202,15 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
 {
 	int ret, i;
+	/* USB transfers of data on stack is not allowed  - We use
+	   the 20 byte dev->data for value to avoid allocating memory.
+	   Notice that dm9601_set_multicast() uses the lower 8 bytes */
+	void *data = &dev->data[4];
 
 	mutex_lock(&dev->phy_mutex);
 
-	ret = dm_write(dev, DM_SHARED_DATA, 2, &value);
+	memcpy(data, &value, sizeof(value));
+	ret = dm_write(dev, DM_SHARED_DATA, 2, data);
 	if (ret < 0)
 		goto out;
 
-- 
1.5.5.1

