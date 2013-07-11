From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 02/50] USB: cdc-wdm: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:25 +0800
Message-ID: <1373533573-12272-3-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/usb/class/cdc-wdm.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/class/cdc-wdm.c b/drivers/usb/class/cdc-wdm.c
index 8a230f0..5f78d18 100644
--- a/drivers/usb/class/cdc-wdm.c
+++ b/drivers/usb/class/cdc-wdm.c
@@ -143,10 +143,12 @@ found:
 static void wdm_out_callback(struct urb *urb)
 {
 	struct wdm_device *desc;
+	unsigned long flags;
+
 	desc = urb->context;
-	spin_lock(&desc->iuspin);
+	spin_lock_irqsave(&desc->iuspin, flags);
 	desc->werr = urb->status;
-	spin_unlock(&desc->iuspin);
+	spin_unlock_irqrestore(&desc->iuspin, flags);
 	kfree(desc->outbuf);
 	desc->outbuf = NULL;
 	clear_bit(WDM_IN_USE, &desc->flags);
@@ -158,8 +160,9 @@ static void wdm_in_callback(struct urb *urb)
 	struct wdm_device *desc = urb->context;
 	int status = urb->status;
 	int length = urb->actual_length;
+	unsigned long flags;
 
-	spin_lock(&desc->iuspin);
+	spin_lock_irqsave(&desc->iuspin, flags);
 	clear_bit(WDM_RESPONDING, &desc->flags);
 
 	if (status) {
@@ -203,7 +206,7 @@ skip_error:
 	wake_up(&desc->wait);
 
 	set_bit(WDM_READ, &desc->flags);
-	spin_unlock(&desc->iuspin);
+	spin_unlock_irqrestore(&desc->iuspin, flags);
 }
 
 static void wdm_int_callback(struct urb *urb)
@@ -212,6 +215,7 @@ static void wdm_int_callback(struct urb *urb)
 	int status = urb->status;
 	struct wdm_device *desc;
 	struct usb_cdc_notification *dr;
+	unsigned long flags;
 
 	desc = urb->context;
 	dr = (struct usb_cdc_notification *)desc->sbuf;
@@ -260,7 +264,7 @@ static void wdm_int_callback(struct urb *urb)
 		goto exit;
 	}
 
-	spin_lock(&desc->iuspin);
+	spin_lock_irqsave(&desc->iuspin, flags);
 	clear_bit(WDM_READ, &desc->flags);
 	set_bit(WDM_RESPONDING, &desc->flags);
 	if (!test_bit(WDM_DISCONNECTING, &desc->flags)
@@ -269,7 +273,7 @@ static void wdm_int_callback(struct urb *urb)
 		dev_dbg(&desc->intf->dev, "%s: usb_submit_urb %d",
 			__func__, rv);
 	}
-	spin_unlock(&desc->iuspin);
+	spin_unlock_irqrestore(&desc->iuspin, flags);
 	if (rv < 0) {
 		clear_bit(WDM_RESPONDING, &desc->flags);
 		if (rv == -EPERM)
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
