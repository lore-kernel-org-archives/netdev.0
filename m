From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/4] USB: introduce no_sg_limit field into usb_bus
Date: Wed, 31 Jul 2013 18:51:46 +0800
Message-ID: <1375267909-30373-2-git-send-email-ming.lei@canonical.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:40788 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144Ab3GaKwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 06:52:17 -0400
In-Reply-To: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some host controllers(such as xHCI) can support building
packet from discontinuous buffers, so introduce the flag
for this kind of host controllers, then the feature can
help for some applications(such as, usbnet)

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/core/urb.c |    3 ++-
 include/linux/usb.h    |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

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
index 84f14e2..981fe52 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -337,6 +337,7 @@ struct usb_bus {
 					 * the ep queue on a short transfer
 					 * with the URB_SHORT_NOT_OK flag set.
 					 */
+	unsigned no_sg_limit:1;		/* no sg list limit */
 	unsigned sg_tablesize;		/* 0 or largest number of sg list entries */
 
 	int devnum_next;		/* Next open device number in
@@ -1249,7 +1250,7 @@ typedef void (*usb_complete_t)(struct urb *);
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
