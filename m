From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 35/49] wireless: libertas: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:25:00 +0800
Message-ID: <1376756714-25479-36-git-send-email-ming.lei@canonical.com>
References: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1376756714-25479-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/libertas/if_usb.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 2798077..f6a8396 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -626,6 +626,7 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 				      struct lbs_private *priv)
 {
 	u8 i;
+	unsigned long flags;
 
 	if (recvlength > LBS_CMD_BUFFER_SIZE) {
 		lbs_deb_usbd(&cardp->udev->dev,
@@ -636,7 +637,7 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 
 	BUG_ON(!in_interrupt());
 
-	spin_lock(&priv->driver_lock);
+	spin_lock_irqsave(&priv->driver_lock, flags);
 
 	i = (priv->resp_idx == 0) ? 1 : 0;
 	BUG_ON(priv->resp_len[i]);
@@ -646,7 +647,7 @@ static inline void process_cmdrequest(int recvlength, uint8_t *recvbuff,
 	kfree_skb(skb);
 	lbs_notify_command_response(priv, i);
 
-	spin_unlock(&priv->driver_lock);
+	spin_unlock_irqrestore(&priv->driver_lock, flags);
 
 	lbs_deb_usbd(&cardp->udev->dev,
 		    "Wake up main thread to handle cmd response\n");
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
