From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 23/50] BT: bfusb: read_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:46 +0800
Message-ID: <1373533573-12272-24-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
read_lock_irqsave().

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: linux-bluetooth@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/bluetooth/bfusb.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/bluetooth/bfusb.c b/drivers/bluetooth/bfusb.c
index 995aee9..2e93501 100644
--- a/drivers/bluetooth/bfusb.c
+++ b/drivers/bluetooth/bfusb.c
@@ -186,6 +186,7 @@ static void bfusb_tx_complete(struct urb *urb)
 {
 	struct sk_buff *skb = (struct sk_buff *) urb->context;
 	struct bfusb_data *data = (struct bfusb_data *) skb->dev;
+	unsigned long flags;
 
 	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
 
@@ -199,14 +200,14 @@ static void bfusb_tx_complete(struct urb *urb)
 	else
 		data->hdev->stat.err_tx++;
 
-	read_lock(&data->lock);
+	read_lock_irqsave(&data->lock, flags);
 
 	skb_unlink(skb, &data->pending_q);
 	skb_queue_tail(&data->completed_q, skb);
 
 	bfusb_tx_wakeup(data);
 
-	read_unlock(&data->lock);
+	read_unlock_irqrestore(&data->lock, flags);
 }
 
 
@@ -347,10 +348,11 @@ static void bfusb_rx_complete(struct urb *urb)
 	unsigned char *buf = urb->transfer_buffer;
 	int count = urb->actual_length;
 	int err, hdr, len;
+	unsigned long flags;
 
 	BT_DBG("bfusb %p urb %p skb %p len %d", data, urb, skb, skb->len);
 
-	read_lock(&data->lock);
+	read_lock_irqsave(&data->lock, flags);
 
 	if (!test_bit(HCI_RUNNING, &data->hdev->flags))
 		goto unlock;
@@ -392,7 +394,7 @@ static void bfusb_rx_complete(struct urb *urb)
 
 	bfusb_rx_submit(data, urb);
 
-	read_unlock(&data->lock);
+	read_unlock_irqrestore(&data->lock, flags);
 
 	return;
 
@@ -406,7 +408,7 @@ resubmit:
 	}
 
 unlock:
-	read_unlock(&data->lock);
+	read_unlock_irqrestore(&data->lock, flags);
 }
 
 static int bfusb_open(struct hci_dev *hdev)
-- 
1.7.9.5

