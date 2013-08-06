From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 1/4] USB: introduce usb_device_no_sg_constraint() helper
Date: Tue,  6 Aug 2013 08:52:46 +0800
Message-ID: <1375750370-18194-2-git-send-email-ming.lei@canonical.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:41585 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab3HFAxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 20:53:14 -0400
In-Reply-To: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some host controllers(such as xHCI) can support building
packet from discontinuous buffers, so introduce one flag
and helper for this kind of host controllers, then the
feature can help some applications(such as usbnet) by
supporting arbitrary length of sg buffers.

Acked-by: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/core/urb.c |    3 ++-
 include/linux/usb.h    |    8 +++++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/core/urb.c b/drivers/usb/core/urb.c
index e75115a..c77ec78 100644
--- a/drivers/usb/core/urb.c
+++ b/drivers/usb/core/urb.c
@@ -414,7 +414,8 @@ int usb_submit_urb(struct urb *urb, gfp_t mem_flags)
 			urb->iso_frame_desc[n].status = -EXDEV;
 			urb->iso_frame_desc[n].actual_length = 0;
 		}
-	} else if (dev->speed != USB_SPEED_WIRELESS && urb->num_sgs) {
+	} else if (urb->num_sgs && !urb->dev->bus->no_sg_constraint &&
+			dev->speed != USB_SPEED_WIRELESS) {
 		struct scatterlist *sg;
 		int i;
 
diff --git a/include/linux/usb.h b/include/linux/usb.h
index 84f14e2..bbd2c8d 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -337,6 +337,7 @@ struct usb_bus {
 					 * the ep queue on a short transfer
 					 * with the URB_SHORT_NOT_OK flag set.
 					 */
+	unsigned no_sg_constraint:1;	/* no sg constraint */
 	unsigned sg_tablesize;		/* 0 or largest number of sg list entries */
 
 	int devnum_next;		/* Next open device number in
@@ -684,6 +685,11 @@ static inline bool usb_device_supports_ltm(struct usb_device *udev)
 	return udev->bos->ss_cap->bmAttributes & USB_LTM_SUPPORT;
 }
 
+static inline bool usb_device_no_sg_constraint(struct usb_device *udev)
+{
+	return udev && udev->bus && udev->bus->no_sg_constraint;
+}
+
 
 /*-------------------------------------------------------------------------*/
 
@@ -1249,7 +1255,7 @@ typedef void (*usb_complete_t)(struct urb *);
  *	transfer_buffer.
  * @sg: scatter gather buffer list, the buffer size of each element in
  * 	the list (except the last) must be divisible by the endpoint's
- * 	max packet size
+ * 	max packet size if no_sg_constraint isn't set in 'struct usb_bus'
  * @num_mapped_sgs: (internal) number of mapped sg entries
  * @num_sgs: number of entries in the sg list
  * @transfer_buffer_length: How big is transfer_buffer.  The transfer may
-- 
1.7.9.5
