From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 29/50] USBNET: rtl8150: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:52 +0800
Message-ID: <1373533573-12272-30-git-send-email-ming.lei@canonical.com>
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

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/rtl8150.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6cbdac6..199e0fb 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -372,6 +372,7 @@ static void read_bulk_callback(struct urb *urb)
 	u16 rx_stat;
 	int status = urb->status;
 	int result;
+	unsigned long flags;
 
 	dev = urb->context;
 	if (!dev)
@@ -413,9 +414,9 @@ static void read_bulk_callback(struct urb *urb)
 	netdev->stats.rx_packets++;
 	netdev->stats.rx_bytes += pkt_len;
 
-	spin_lock(&dev->rx_pool_lock);
+	spin_lock_irqsave(&dev->rx_pool_lock, flags);
 	skb = pull_skb(dev);
-	spin_unlock(&dev->rx_pool_lock);
+	spin_unlock_irqrestore(&dev->rx_pool_lock, flags);
 	if (!skb)
 		goto resched;
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
