From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v3 3/5] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
Date: Tue,  6 Nov 2012 09:45:39 +0800
Message-ID: <1352166341-27616-4-git-send-email-ming.lei@canonical.com>
References: <1352166341-27616-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352166341-27616-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes memory leak in smsc95xx_suspend.

Also, it isn't necessary to bother mm to allocate 8bytes/16byte,
and we can use stack variable safely.

Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/smsc95xx.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 34f2e78..8260c50 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1070,11 +1070,15 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 
 	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
 		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
-		u32 *command = kzalloc(2, GFP_KERNEL);
-		u32 *offset = kzalloc(2, GFP_KERNEL);
-		u32 *crc = kzalloc(4, GFP_KERNEL);
+		u32 command[2];
+		u32 offset[2];
+		u32 crc[4];
 		int i, filter = 0;
 
+		memset(command, 0, sizeof(command));
+		memset(offset, 0, sizeof(offset));
+		memset(crc, 0, sizeof(crc));
+
 		if (pdata->wolopts & WAKE_BCAST) {
 			const u8 bcast[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
 			netdev_info(dev->net, "enabling broadcast detection");
@@ -1131,6 +1135,8 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
 			check_warn_return(ret, "Error writing WUFF");
 		}
 
+		kfree(filter_mask);
+
 		for (i = 0; i < (pdata->wuff_filter_count / 4); i++) {
 			ret = smsc95xx_write_reg(dev, WUFF, command[i]);
 			check_warn_return(ret, "Error writing WUFF");
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
