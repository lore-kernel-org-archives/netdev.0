From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 25/50] ISDN: hfcsusb: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:48 +0800
Message-ID: <1373533573-12272-26-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:55666 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab3GKJJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:09:59 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |   36 ++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 114f3bc..082f9e0 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -819,6 +819,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 	int		fifon = fifo->fifonum;
 	int		i;
 	int		hdlc = 0;
+	unsigned long	flags;
 
 	if (debug & DBG_HFC_CALL_TRACE)
 		printk(KERN_DEBUG "%s: %s: fifo(%i) len(%i) "
@@ -835,7 +836,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		return;
 	}
 
-	spin_lock(&hw->lock);
+	spin_lock_irqsave(&hw->lock, flags);
 	if (fifo->dch) {
 		rx_skb = fifo->dch->rx_skb;
 		maxlen = fifo->dch->maxlen;
@@ -844,7 +845,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 	if (fifo->bch) {
 		if (test_bit(FLG_RX_OFF, &fifo->bch->Flags)) {
 			fifo->bch->dropcnt += len;
-			spin_unlock(&hw->lock);
+			spin_unlock_irqrestore(&hw->lock, flags);
 			return;
 		}
 		maxlen = bchannel_get_rxbuf(fifo->bch, len);
@@ -854,7 +855,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 				skb_trim(rx_skb, 0);
 			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
 				   hw->name, fifo->bch->nr, len);
-			spin_unlock(&hw->lock);
+			spin_unlock_irqrestore(&hw->lock, flags);
 			return;
 		}
 		maxlen = fifo->bch->maxlen;
@@ -878,7 +879,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 			} else {
 				printk(KERN_DEBUG "%s: %s: No mem for rx_skb\n",
 				       hw->name, __func__);
-				spin_unlock(&hw->lock);
+				spin_unlock_irqrestore(&hw->lock, flags);
 				return;
 			}
 		}
@@ -888,7 +889,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 			       "for fifo(%d) HFCUSB_D_RX\n",
 			       hw->name, __func__, fifon);
 			skb_trim(rx_skb, 0);
-			spin_unlock(&hw->lock);
+			spin_unlock_irqrestore(&hw->lock, flags);
 			return;
 		}
 	}
@@ -942,7 +943,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		/* deliver transparent data to layer2 */
 		recv_Bchannel(fifo->bch, MISDN_ID_ANY, false);
 	}
-	spin_unlock(&hw->lock);
+	spin_unlock_irqrestore(&hw->lock, flags);
 }
 
 static void
@@ -979,18 +980,19 @@ rx_iso_complete(struct urb *urb)
 	__u8 *buf;
 	static __u8 eof[8];
 	__u8 s0_state;
+	unsigned long flags;
 
 	fifon = fifo->fifonum;
 	status = urb->status;
 
-	spin_lock(&hw->lock);
+	spin_lock_irqsave(&hw->lock, flags);
 	if (fifo->stop_gracefull) {
 		fifo->stop_gracefull = 0;
 		fifo->active = 0;
-		spin_unlock(&hw->lock);
+		spin_unlock_irqrestore(&hw->lock, flags);
 		return;
 	}
-	spin_unlock(&hw->lock);
+	spin_unlock_irqrestore(&hw->lock, flags);
 
 	/*
 	 * ISO transfer only partially completed,
@@ -1096,15 +1098,16 @@ rx_int_complete(struct urb *urb)
 	struct usb_fifo *fifo = (struct usb_fifo *) urb->context;
 	struct hfcsusb *hw = fifo->hw;
 	static __u8 eof[8];
+	unsigned long flags;
 
-	spin_lock(&hw->lock);
+	spin_lock_irqsave(&hw->lock, flags);
 	if (fifo->stop_gracefull) {
 		fifo->stop_gracefull = 0;
 		fifo->active = 0;
-		spin_unlock(&hw->lock);
+		spin_unlock_irqrestore(&hw->lock, flags);
 		return;
 	}
-	spin_unlock(&hw->lock);
+	spin_unlock_irqrestore(&hw->lock, flags);
 
 	fifon = fifo->fifonum;
 	if ((!fifo->active) || (urb->status)) {
@@ -1172,12 +1175,13 @@ tx_iso_complete(struct urb *urb)
 	int *tx_idx;
 	int frame_complete, fifon, status, fillempty = 0;
 	__u8 threshbit, *p;
+	unsigned long flags;
 
-	spin_lock(&hw->lock);
+	spin_lock_irqsave(&hw->lock, flags);
 	if (fifo->stop_gracefull) {
 		fifo->stop_gracefull = 0;
 		fifo->active = 0;
-		spin_unlock(&hw->lock);
+		spin_unlock_irqrestore(&hw->lock, flags);
 		return;
 	}
 
@@ -1195,7 +1199,7 @@ tx_iso_complete(struct urb *urb)
 	} else {
 		printk(KERN_DEBUG "%s: %s: neither BCH nor DCH\n",
 		       hw->name, __func__);
-		spin_unlock(&hw->lock);
+		spin_unlock_irqrestore(&hw->lock, flags);
 		return;
 	}
 
@@ -1375,7 +1379,7 @@ tx_iso_complete(struct urb *urb)
 			       hw->name, __func__,
 			       symbolic(urb_errlist, status), status, fifon);
 	}
-	spin_unlock(&hw->lock);
+	spin_unlock_irqrestore(&hw->lock, flags);
 }
 
 /*
-- 
1.7.9.5
