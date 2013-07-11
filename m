From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 28/50] USBNET: kaweth: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:51 +0800
Message-ID: <1373533573-12272-29-git-send-email-ming.lei@canonical.com>
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

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/kaweth.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index afb117c..4addbbf 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -598,6 +598,7 @@ static void kaweth_usb_receive(struct urb *urb)
 	struct kaweth_device *kaweth = urb->context;
 	struct net_device *net = kaweth->net;
 	int status = urb->status;
+	unsigned long flags;
 
 	int count = urb->actual_length;
 	int count2 = urb->transfer_buffer_length;
@@ -630,12 +631,12 @@ static void kaweth_usb_receive(struct urb *urb)
 		kaweth->stats.rx_errors++;
 		dev_dbg(dev, "Status was -EOVERFLOW.\n");
 	}
-	spin_lock(&kaweth->device_lock);
+	spin_lock_irqsave(&kaweth->device_lock, flags);
 	if (IS_BLOCKED(kaweth->status)) {
-		spin_unlock(&kaweth->device_lock);
+		spin_unlock_irqrestore(&kaweth->device_lock, flags);
 		return;
 	}
-	spin_unlock(&kaweth->device_lock);
+	spin_unlock_irqrestore(&kaweth->device_lock, flags);
 
 	if(status && status != -EREMOTEIO && count != 1) {
 		dev_err(&kaweth->intf->dev,
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
