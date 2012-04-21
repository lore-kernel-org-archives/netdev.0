From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 26/28] mISDN: Enhance hfcsusb driver
Date: Sat, 21 Apr 2012 18:16:58 +0200
Message-ID: <20120423170551.A50999FB8D@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:63769 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431Ab2DWRI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add support for MISDN_CTRL_RX_OFF and MISDN_CTRL_FILL_EMPTY
- Add MISDN_CTRL_RX_BUFFER  handling
- Use a extra buffer pointer for the current transmitted frame, this allows
  upper layers to send next data earlier and should avoid TX underuns

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |  205 ++++++++++++++++++++++-----------
 drivers/isdn/hardware/mISDN/hfcsusb.h |   10 +-
 2 files changed, 143 insertions(+), 72 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index cd0f2f6..02b9fe9 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -27,7 +27,7 @@
  *   poll=<n>, default 128
  *     n : burst size of PH_DATA_IND at transparent rx data
  *
- * Revision: 0.3.3 (socket), 2008-11-05
+ * Revision: 0.3.5 (socket), 2012-01-16
  */
 
 #include <linux/module.h>
@@ -294,13 +294,12 @@ hfcusb_l2l1D(struct mISDNchannel *ch, struct sk_buff *skb)
 
 	switch (hh->prim) {
 	case PH_DATA_REQ:
-		if (debug & DBG_HFC_CALL_TRACE)
-			printk(KERN_DEBUG "%s: %s: PH_DATA_REQ\n",
-			       hw->name, __func__);
-
 		spin_lock_irqsave(&hw->lock, flags);
 		ret = dchannel_senddata(dch, skb);
 		spin_unlock_irqrestore(&hw->lock, flags);
+		if (debug & DBG_HFC_CALL_TRACE)
+			printk(KERN_DEBUG "%s: %s: PH_DATA_REQ ret %d\n",
+			       hw->name, __func__, ret);
 		if (ret > 0) {
 			ret = 0;
 			queue_ch_frame(ch, PH_DATA_CNF, hh->id, NULL);
@@ -807,17 +806,49 @@ hfcsusb_ph_command(struct hfcsusb *hw, u_char command)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int	ret = 0;
+	struct hfcsusb *hw = bch->hw;
+	int idx, o1, o2, ret = 0;
 
+	idx = (bch->nr - 1) & 1;
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_FILL_EMPTY;
+		cq->op = MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY |
+			 MISDN_CTRL_RX_BUFFER;
+		break;
+	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
+		o1 = hw->dropcnt[idx];
+		if (cq->p1) {
+			test_and_set_bit(FLG_RX_OFF, &bch->Flags);
+			hw->dropcnt[idx] = 0;
+		} else
+			test_and_clear_bit(FLG_RX_OFF, &bch->Flags);
+		cq->p2 = o1;
+		if (debug & DEBUG_HW_BCHANNEL)
+			printk(KERN_DEBUG "Bch%d RX %s dropped %d\n",
+			       bch->nr, cq->p1 ? "off" : "on", o1);
 		break;
 	case MISDN_CTRL_FILL_EMPTY: /* fill fifo, if empty */
-		test_and_set_bit(FLG_FILLEMPTY, &bch->Flags);
-		if (debug & DEBUG_HW_OPEN)
-			printk(KERN_DEBUG "%s: FILL_EMPTY request (nr=%d "
-			       "off=%d)\n", __func__, bch->nr, !!cq->p1);
+		if (cq->p1) {
+			test_and_set_bit(FLG_FILLEMPTY, &bch->Flags);
+			if (cq->p2 > -1)
+				hw->fillbyte[idx] = cq->p2 & 0xff;
+		} else
+			test_and_clear_bit(FLG_FILLEMPTY, &bch->Flags);
+		if (debug & DEBUG_HW_BCHANNEL)
+			printk(KERN_DEBUG "FILL_EMPTY Bch%d %s val %02x\n",
+			       bch->nr, cq->p1 ? "on" : "off",
+			       hw->fillbyte[idx]);
+		break;
+	case MISDN_CTRL_RX_BUFFER:
+		/* We return the old values */
+		o1 = bch->minlen;
+		o2 =  bch->maxlen;
+		if (cq->p1 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p1;
+		if (cq->p2 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p2;
+		cq->p1 = o1;
+		cq->p2 = o2;
 		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n", __func__, cq->op);
@@ -861,9 +892,21 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		hdlc = 1;
 	}
 	if (fifo->bch) {
+		if (test_bit(FLG_RX_OFF, &fifo->bch->Flags)) {
+			i = (fifo->bch->nr - 1) & 1;
+			hw->dropcnt[i]++;
+			spin_unlock(&hw->lock);
+			return;
+		}
 		rx_skb = fifo->bch->rx_skb;
 		maxlen = fifo->bch->maxlen;
 		hdlc = test_bit(FLG_HDLC, &fifo->bch->Flags);
+		if (!hdlc) {
+			if (len >= fifo->bch->minlen)
+				maxlen = len;
+			else
+				maxlen = 2 * fifo->bch->minlen;
+		}
 	}
 	if (fifo->ech) {
 		rx_skb = fifo->ech->rx_skb;
@@ -938,8 +981,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 				if (fifo->bch)
 					recv_Bchannel(fifo->bch, MISDN_ID_ANY);
 				if (fifo->ech)
-					recv_Echannel(fifo->ech,
-						      &hw->dch);
+					recv_Echannel(fifo->ech, &hw->dch);
 			} else {
 				if (debug & DBG_HFC_FIFO_VERBOSE) {
 					printk(KERN_DEBUG
@@ -957,7 +999,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		}
 	} else {
 		/* deliver transparent data to layer2 */
-		if (rx_skb->len >= poll)
+		if (rx_skb->len >= fifo->bch->minlen)
 			recv_Bchannel(fifo->bch, MISDN_ID_ANY);
 	}
 	spin_unlock(&hw->lock);
@@ -1184,36 +1226,48 @@ tx_iso_complete(struct urb *urb)
 	struct iso_urb *context_iso_urb = (struct iso_urb *) urb->context;
 	struct usb_fifo *fifo = context_iso_urb->owner_fifo;
 	struct hfcsusb *hw = fifo->hw;
-	struct sk_buff *tx_skb;
 	int k, tx_offset, num_isoc_packets, sink, remain, current_len,
-		errcode, hdlc, i;
-	int *tx_idx;
+		errcode, hdlc = 1, i;
 	int frame_complete, fifon, status;
-	__u8 threshbit;
+	__u8 threshbit, fill = 0;
 
 	spin_lock(&hw->lock);
+	if (!fifo->ctx) {
+		if (fifo->dch) {
+			fifo->ctx = fifo->dch->tx_skb;
+			fifo->ctxi = 0;
+			if (fifo->ctx)
+				i = get_next_dframe(fifo->dch);
+		} else if (fifo->bch) {
+			fifo->ctx = fifo->bch->tx_skb;
+			fifo->ctxi = 0;
+			if (fifo->ctx)
+				get_next_bframe(fifo->bch);
+			hdlc = test_bit(FLG_HDLC, &fifo->bch->Flags);
+			if (!hdlc)
+				fill = hw->fillbyte[(fifo->bch->nr - 1) & 1];
+		} else {
+			printk(KERN_DEBUG "%s: %s: neither BCH nor DCH\n",
+			       hw->name, __func__);
+			spin_unlock(&hw->lock);
+			return;
+		}
+	} else {
+		if (fifo->bch) {
+			hdlc = test_bit(FLG_HDLC, &fifo->bch->Flags);
+			if (!hdlc)
+				fill = hw->fillbyte[(fifo->bch->nr - 1) & 1];
+		}
+	}
 	if (fifo->stop_gracefull) {
 		fifo->stop_gracefull = 0;
 		fifo->active = 0;
+		if (fifo->ctx)
+			dev_kfree_skb(fifo->ctx);
+		fifo->ctx = NULL;
 		spin_unlock(&hw->lock);
 		return;
 	}
-
-	if (fifo->dch) {
-		tx_skb = fifo->dch->tx_skb;
-		tx_idx = &fifo->dch->tx_idx;
-		hdlc = 1;
-	} else if (fifo->bch) {
-		tx_skb = fifo->bch->tx_skb;
-		tx_idx = &fifo->bch->tx_idx;
-		hdlc = test_bit(FLG_HDLC, &fifo->bch->Flags);
-	} else {
-		printk(KERN_DEBUG "%s: %s: neither BCH nor DCH\n",
-		       hw->name, __func__);
-		spin_unlock(&hw->lock);
-		return;
-	}
-
 	fifon = fifo->fifonum;
 	status = urb->status;
 
@@ -1248,7 +1302,7 @@ tx_iso_complete(struct urb *urb)
 			      fifo->usb_packet_maxlen, fifo->intervall,
 			      (usb_complete_t)tx_iso_complete, urb->context);
 		memset(context_iso_urb->buffer, 0,
-		       sizeof(context_iso_urb->buffer));
+			sizeof(context_iso_urb->buffer));
 		frame_complete = 0;
 
 		for (k = 0; k < num_isoc_packets; ++k) {
@@ -1263,10 +1317,14 @@ tx_iso_complete(struct urb *urb)
 			}
 
 			/* Generate next ISO Packets */
-			if (tx_skb)
-				remain = tx_skb->len - *tx_idx;
-			else
+			if (fifo->ctx)
+				remain = fifo->ctx->len - fifo->ctxi;
+			else {
 				remain = 0;
+				if ((!hdlc) &&
+				    test_bit(FLG_FILLEMPTY, &fifo->bch->Flags))
+					remain = 14;
+			}
 
 			if (remain > 0) {
 				fifo->bit_line -= sink;
@@ -1295,10 +1353,17 @@ tx_iso_complete(struct urb *urb)
 				}
 
 				/* copy tx data to iso-urb buffer */
-				memcpy(context_iso_urb->buffer + tx_offset + 1,
-				       (tx_skb->data + *tx_idx), current_len);
-				*tx_idx += current_len;
-
+				i = tx_offset + 1;
+				if (fifo->ctx) {
+					memcpy(context_iso_urb->buffer + i,
+						(fifo->ctx->data + fifo->ctxi),
+						current_len);
+					fifo->ctxi += current_len;
+				} else {
+					memset(context_iso_urb->buffer + i,
+						fill, current_len);
+					frame_complete = 1;
+				}
 				urb->iso_frame_desc[k].offset = tx_offset;
 				urb->iso_frame_desc[k].length = current_len + 1;
 
@@ -1313,14 +1378,14 @@ tx_iso_complete(struct urb *urb)
 					       urb->iso_frame_desc[k].length);
 
 					for (i = urb->iso_frame_desc[k].offset;
-					     i < (urb->iso_frame_desc[k].offset
-						  + urb->iso_frame_desc[k].length);
-					     i++)
+					    i < (urb->iso_frame_desc[k].offset +
+					    urb->iso_frame_desc[k].length);
+					    i++)
 						printk("%x ",
 						       context_iso_urb->buffer[i]);
 
 					printk(" skb->len(%i) tx-idx(%d)\n",
-					       tx_skb->len, *tx_idx);
+					       fifo->ctx->len, fifo->ctxi);
 				}
 
 				tx_offset += (current_len + 1);
@@ -1335,29 +1400,34 @@ tx_iso_complete(struct urb *urb)
 
 			if (frame_complete) {
 				frame_complete = 0;
-
 				if (debug & DBG_HFC_FIFO_VERBOSE) {
 					printk(KERN_DEBUG  "%s: %s: "
 					       "fifon(%i) new TX len(%i): ",
 					       hw->name, __func__,
-					       fifon, tx_skb->len);
+					       fifon, fifo->ctx->len);
 					i = 0;
-					while (i < tx_skb->len)
+					while (i < fifo->ctx->len)
 						printk("%02x ",
-						       tx_skb->data[i++]);
+						       fifo->ctx->data[i++]);
 					printk("\n");
 				}
-
-				dev_kfree_skb(tx_skb);
-				tx_skb = NULL;
-				if (fifo->dch && get_next_dframe(fifo->dch))
-					tx_skb = fifo->dch->tx_skb;
-				else if (fifo->bch &&
-					 get_next_bframe(fifo->bch)) {
-					if (test_bit(FLG_TRANSPARENT,
-						     &fifo->bch->Flags))
-						confirm_Bsend(fifo->bch);
-					tx_skb = fifo->bch->tx_skb;
+				dev_kfree_skb(fifo->ctx);
+				fifo->ctx = NULL;
+				fifo->ctxi = 0;
+				if (fifo->dch) {
+					if (fifo->dch->tx_skb) {
+						fifo->ctx = fifo->dch->tx_skb;
+						get_next_dframe(fifo->dch);
+					} else
+						test_and_clear_bit(FLG_TX_BUSY,
+							&fifo->dch->Flags);
+				} else if (fifo->bch) {
+					if (fifo->bch->tx_skb) {
+						fifo->ctx = fifo->bch->tx_skb;
+						get_next_bframe(fifo->bch);
+					} else
+						test_and_clear_bit(FLG_TX_BUSY,
+							&fifo->bch->Flags);
 				}
 			}
 		}
@@ -1417,11 +1487,10 @@ start_isoc_chain(struct usb_fifo *fifo, int num_packets_per_urb,
 			}
 			fifo->iso[i].owner_fifo = (struct usb_fifo *) fifo;
 			fifo->iso[i].indx = i;
-
 			/* Init the first iso */
 			if (ISO_BUFFER_SIZE >=
 			    (fifo->usb_packet_maxlen *
-			     num_packets_per_urb)) {
+			    num_packets_per_urb)) {
 				fill_isoc_urb(fifo->iso[i].urb,
 					      fifo->hw->dev, fifo->pipe,
 					      fifo->iso[i].buffer,
@@ -1430,7 +1499,7 @@ start_isoc_chain(struct usb_fifo *fifo, int num_packets_per_urb,
 					      fifo->intervall, complete,
 					      &fifo->iso[i]);
 				memset(fifo->iso[i].buffer, 0,
-				       sizeof(fifo->iso[i].buffer));
+				     sizeof(fifo->iso[i].buffer));
 
 				for (k = 0; k < num_packets_per_urb; k++) {
 					fifo->iso[i].urb->
@@ -1471,7 +1540,7 @@ stop_iso_gracefull(struct usb_fifo *fifo)
 		spin_lock_irqsave(&hw->lock, flags);
 		if (debug)
 			printk(KERN_DEBUG "%s: %s for fifo %i.%i\n",
-			       hw->name, __func__, fifo->fifonum, i);
+			     hw->name, __func__, fifo->fifonum, i);
 		fifo->stop_gracefull = 1;
 		spin_unlock_irqrestore(&hw->lock, flags);
 	}
@@ -1496,7 +1565,7 @@ stop_int_gracefull(struct usb_fifo *fifo)
 	spin_lock_irqsave(&hw->lock, flags);
 	if (debug)
 		printk(KERN_DEBUG "%s: %s for fifo %i\n",
-		       hw->name, __func__, fifo->fifonum);
+		     hw->name, __func__, fifo->fifonum);
 	fifo->stop_gracefull = 1;
 	spin_unlock_irqrestore(&hw->lock, flags);
 
@@ -1505,7 +1574,7 @@ stop_int_gracefull(struct usb_fifo *fifo)
 		schedule_timeout_interruptible((HZ / 1000) * 3);
 	if (debug && fifo->stop_gracefull)
 		printk(KERN_DEBUG "%s: ERROR %s for fifo %i\n",
-		       hw->name, __func__, fifo->fifonum);
+		     hw->name, __func__, fifo->fifonum);
 }
 
 /* start the interrupt transfer for the given fifo */
@@ -1870,7 +1939,7 @@ setup_instance(struct hfcsusb *hw, struct device *parent)
 		hw->bch[i].nr = i + 1;
 		set_channelmap(i + 1, hw->dch.dev.channelmap);
 		hw->bch[i].debug = debug;
-		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM, -1);
+		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM, poll);
 		hw->bch[i].hw = hw;
 		hw->bch[i].ch.send = hfcusb_l2l1B;
 		hw->bch[i].ch.ctrl = hfc_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.h b/drivers/isdn/hardware/mISDN/hfcsusb.h
index cb1231b..7d48b86 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.h
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.h
@@ -263,6 +263,8 @@ struct usb_fifo {
 	struct dchannel *dch;	/* link to hfcsusb_t->dch */
 	struct bchannel *bch;	/* link to hfcsusb_t->bch */
 	struct dchannel *ech;	/* link to hfcsusb_t->ech, TODO: E-CHANNEL */
+	struct sk_buff	*ctx;	/* current TX skb */
+	int		ctxi;	/* next byte to write from current TX skb */
 	int last_urblen;	/* remember length of last packet */
 	__u8 stop_gracefull;	/* stops URB retransmission */
 };
@@ -282,7 +284,6 @@ struct hfcsusb {
 	int			packet_size;
 	int			iso_packet_size;
 	struct usb_fifo		fifos[HFCUSB_NUM_FIFOS];
-
 	/* control pipe background handling */
 	struct ctrl_buf		ctrl_buff[HFC_CTRL_BUFSIZE];
 	int			ctrl_in_idx, ctrl_out_idx, ctrl_cnt;
@@ -293,15 +294,16 @@ struct hfcsusb {
 	int			ctrl_in_pipe, ctrl_out_pipe;
 	spinlock_t		ctrl_lock; /* lock for ctrl */
 	spinlock_t              lock;
+	int			nt_timer;
+	int			open;
+	int			dropcnt[2];
 
 	__u8			threshold_mask;
 	__u8			led_state;
-
 	__u8			protocol;
-	int			nt_timer;
-	int			open;
 	__u8			timers;
 	__u8			initdone;
+	__u8			fillbyte[2];
 	char			name[MISDN_MAX_IDLEN];
 };
 
-- 
1.7.3.4
