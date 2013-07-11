From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 07/50] USB: ldusb: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:30 +0800
Message-ID: <1373533573-12272-8-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/usb/misc/ldusb.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/misc/ldusb.c b/drivers/usb/misc/ldusb.c
index ac76229..8bae18e 100644
--- a/drivers/usb/misc/ldusb.c
+++ b/drivers/usb/misc/ldusb.c
@@ -249,6 +249,7 @@ static void ld_usb_interrupt_in_callback(struct urb *urb)
 	unsigned int next_ring_head;
 	int status = urb->status;
 	int retval;
+	unsigned long flags;
 
 	if (status) {
 		if (status == -ENOENT ||
@@ -258,12 +259,12 @@ static void ld_usb_interrupt_in_callback(struct urb *urb)
 		} else {
 			dbg_info(&dev->intf->dev, "%s: nonzero status received: %d\n",
 				 __func__, status);
-			spin_lock(&dev->rbsl);
+			spin_lock_irqsave(&dev->rbsl, flags);
 			goto resubmit; /* maybe we can recover */
 		}
 	}
 
-	spin_lock(&dev->rbsl);
+	spin_lock_irqsave(&dev->rbsl, flags);
 	if (urb->actual_length > 0) {
 		next_ring_head = (dev->ring_head+1) % ring_buffer_size;
 		if (next_ring_head != dev->ring_tail) {
@@ -292,7 +293,7 @@ resubmit:
 			dev->buffer_overflow = 1;
 		}
 	}
-	spin_unlock(&dev->rbsl);
+	spin_unlock_irqrestore(&dev->rbsl, flags);
 exit:
 	dev->interrupt_in_done = 1;
 	wake_up_interruptible(&dev->read_wait);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
