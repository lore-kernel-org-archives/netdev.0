From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: [PATCH RESEND] dm9601: don't do usb transfers of data on stack
Date: Fri, 11 Jul 2008 13:37:39 +0200
Message-ID: <87mykoircs.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

dm_{read,write}_shared_word() were doing USB transfers of data on stack,
which isn't allowed. Fix it by using the usbnet->data area like in
dm9601_set_multicast().

Signed-off-by: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
---
 Resending since no feedback (27/06).

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


-- 
Bye, Peter Korsgaard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
