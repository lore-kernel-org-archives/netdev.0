From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 47/50] staging: btmtk_usb: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:10 +0800
Message-ID: <1373533573-12272-48-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/staging/btmtk_usb/btmtk_usb.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/btmtk_usb/btmtk_usb.c b/drivers/staging/btmtk_usb/btmtk_usb.c
index 0e783e8..ea10d4f 100644
--- a/drivers/staging/btmtk_usb/btmtk_usb.c
+++ b/drivers/staging/btmtk_usb/btmtk_usb.c
@@ -1218,6 +1218,7 @@ static void btmtk_usb_tx_complete(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct hci_dev *hdev = (struct hci_dev *)skb->dev;
 	struct btmtk_usb_data *data = hci_get_drvdata(hdev);
+	unsigned long flags;
 
 	BT_DBG("%s: %s urb %p status %d count %d\n", __func__, hdev->name,
 					urb, urb->status, urb->actual_length);
@@ -1231,9 +1232,9 @@ static void btmtk_usb_tx_complete(struct urb *urb)
 		hdev->stat.err_tx++;
 
 done:
-	spin_lock(&data->txlock);
+	spin_lock_irqsave(&data->txlock, flags);
 	data->tx_in_flight--;
-	spin_unlock(&data->txlock);
+	spin_unlock_irqrestore(&data->txlock, flags);
 
 	kfree(urb->setup_packet);
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
