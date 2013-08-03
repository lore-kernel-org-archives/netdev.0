From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 1/4] USB: introduce usb_device_no_sg_limit() helper
Date: Sat,  3 Aug 2013 10:46:34 +0800
Message-ID: <1375497998-7424-2-git-send-email-ming.lei@canonical.com>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Alan Stern <stern@rowland.harvard.edu>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62910 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab3HCCrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 22:47:43 -0400
In-Reply-To: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some host controllers(such as xHCI) can support building
packet from discontinuous buffers, so introduce one flag
and helper for this kind of host controllers, then the
feature can help some applications(such as, usbnet) by
supporting arbitrary length of sg buffers.

Cc: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/core/urb.c |    3 ++-
 include/linux/usb.h    |   11 ++++++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/core/urb.c b/drivers/usb/core/urb.c
index e75115a..7a88ae8 100644
--- a/drivers/usb/core/urb.c
+++ b/drivers/usb/core/urb.c
@@ -414,7 +414,8 @@ int usb_submit_urb(struct urb *urb, gfp_t mem_flags)
 			urb->iso_frame_desc[n].status = -EXDEV;
 			urb->iso_frame_desc[n].actual_length = 0;
 		}
-	} else if (dev->speed != USB_SPEED_WIRELESS && urb->num_sgs) {
+	} else if (urb->num_sgs && !urb->dev->bus->no_sg_limit &&
+			dev->speed != USB_SPEED_WIRELESS) {
 		struct scatterlist *sg;
 		int i;
 
diff --git a/include/linux/usb.h b/include/linux/usb.h
index 84f14e2..5d03074 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -337,6 +337,7 @@ struct usb_bus {
 					 * the ep queue on a short transfer
 					 * with the URB_SHORT_NOT_OK flag set.
 					 */
+	unsigned no_sg_limit:1;		/* no sg list limit */
 	unsigned sg_tablesize;		/* 0 or largest number of sg list entries */
 
 	int devnum_next;		/* Next open device number in
@@ -684,6 +685,14 @@ static inline bool usb_device_supports_ltm(struct usb_device *udev)
 	return udev->bos->ss_cap->bmAttributes & USB_LTM_SUPPORT;
 }
 
+static inline bool usb_device_no_sg_limit(struct usb_device *udev)
+{
+	if (udev && udev->bus && udev->bus->no_sg_limit)
+		return true;
+	else
+		return false;
+}
+
 
 /*-------------------------------------------------------------------------*/
 
@@ -1249,7 +1258,7 @@ typedef void (*usb_complete_t)(struct urb *);
  *	transfer_buffer.
  * @sg: scatter gather buffer list, the buffer size of each element in
  * 	the list (except the last) must be divisible by the endpoint's
- * 	max packet size
+ * 	max packet size if no_sg_limit isn't set in 'struct usb_bus'
  * @num_mapped_sgs: (internal) number of mapped sg entries
  * @num_sgs: number of entries in the sg list
  * @transfer_buffer_length: How big is transfer_buffer.  The transfer may
-- 
1.7.9.5
