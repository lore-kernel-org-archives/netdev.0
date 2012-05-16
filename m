From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH v2 5/8] mISDN: Reduce RX buffer allocation for transparent data
Date: Wed, 16 May 2012 11:51:05 +0200
Message-ID: <1337161868-19399-6-git-send-email-kkeil@linux-pingi.de>
References: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:59298 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966865Ab2EPKA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 06:00:29 -0400
In-Reply-To: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We did allways allocate maxsize buffers, but for transparent data we know
the actual size.
Use a common function to calculate size and detect overflows.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   18 ++-----
 drivers/isdn/hardware/mISDN/hfcmulti.c  |   61 ++++++++++--------------
 drivers/isdn/hardware/mISDN/hfcpci.c    |   11 ++--
 drivers/isdn/hardware/mISDN/hfcsusb.c   |   52 +++++++++-----------
 drivers/isdn/hardware/mISDN/mISDNipac.c |   20 +++-----
 drivers/isdn/hardware/mISDN/mISDNisar.c |   37 +++++----------
 drivers/isdn/hardware/mISDN/netjet.c    |   79 +++++++++++++-----------------
 drivers/isdn/hardware/mISDN/w6692.c     |   20 +++-----
 drivers/isdn/mISDN/hwchannel.c          |   75 ++++++++++++++++++++++++-----
 include/linux/mISDNhw.h                 |    1 +
 10 files changed, 186 insertions(+), 188 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index cc78264..8081367 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -404,21 +404,14 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	u32 *ptr;
 	u8 *p;
 	u32  val, addr;
-	int cnt = 0;
+	int cnt;
 	struct fritzcard *fc = bch->hw;
 
 	pr_debug("%s: %s %d\n", fc->name, __func__, count);
-	if (!bch->rx_skb) {
-		bch->rx_skb = mI_alloc_skb(bch->maxlen, GFP_ATOMIC);
-		if (!bch->rx_skb) {
-			pr_info("%s: B receive out of memory\n",
-				fc->name);
-			return;
-		}
-	}
-	if ((bch->rx_skb->len + count) > bch->maxlen) {
-		pr_debug("%s: overrun %d\n", fc->name,
-			 bch->rx_skb->len + count);
+	cnt = bchannel_get_rxbuf(bch, count);
+	if (cnt < 0) {
+		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+			   fc->name, bch->nr, count);
 		return;
 	}
 	p = skb_put(bch->rx_skb, count);
@@ -430,6 +423,7 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 		addr = fc->addr + CHIP_WINDOW;
 		outl(bch->nr == 2 ? AVM_HDLC_2 : AVM_HDLC_1, fc->addr);
 	}
+	cnt = 0;
 	while (cnt < count) {
 		val = le32_to_cpu(inl(addr));
 		put_unaligned(val, ptr);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index bcb2b8e..16bef01 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2196,24 +2196,20 @@ hfcmulti_rx(struct hfc_multi *hc, int ch)
 	int f1 = 0, f2 = 0; /* = 0, to make GCC happy */
 	int again = 0;
 	struct	bchannel *bch;
-	struct  dchannel *dch;
+	struct  dchannel *dch = NULL;
 	struct sk_buff	*skb, **sp = NULL;
 	int	maxlen;
 
 	bch = hc->chan[ch].bch;
-	dch = hc->chan[ch].dch;
-	if ((!dch) && (!bch))
-		return;
-	if (dch) {
+	if (bch) {
+		if (!test_bit(FLG_ACTIVE, &bch->Flags))
+			return;
+	} else if (hc->chan[ch].dch) {
+		dch = hc->chan[ch].dch;
 		if (!test_bit(FLG_ACTIVE, &dch->Flags))
 			return;
-		sp = &dch->rx_skb;
-		maxlen = dch->maxlen;
 	} else {
-		if (!test_bit(FLG_ACTIVE, &bch->Flags))
-			return;
-		sp = &bch->rx_skb;
-		maxlen = bch->maxlen;
+		return;
 	}
 next_frame:
 	/* on first AND before getting next valid frame, R_FIFO must be written
@@ -2260,13 +2256,26 @@ next_frame:
 	if (Zsize <= 0)
 		return;
 
-	if (*sp == NULL) {
-		*sp = mI_alloc_skb(maxlen + 3, GFP_ATOMIC);
-		if (*sp == NULL) {
-			printk(KERN_DEBUG "%s: No mem for rx_skb\n",
-			       __func__);
+	if (bch) {
+		maxlen = bchannel_get_rxbuf(bch, Zsize);
+		if (maxlen < 0) {
+			pr_warning("card%d.B%d: No bufferspace for %d bytes\n",
+				   hc->id + 1, bch->nr, Zsize);
 			return;
 		}
+		sp = &bch->rx_skb;
+		maxlen = bch->maxlen;
+	} else { /* Dchannel */
+		sp = &dch->rx_skb;
+		maxlen = dch->maxlen + 3;
+		if (*sp == NULL) {
+			*sp = mI_alloc_skb(maxlen, GFP_ATOMIC);
+			if (*sp == NULL) {
+				pr_warning("card%d: No mem for dch rx_skb\n",
+					   hc->id + 1);
+				return;
+			}
+		}
 	}
 	/* show activity */
 	if (dch)
@@ -2281,7 +2290,7 @@ next_frame:
 			       Zsize, z1, z2, (f1 == f2) ? "fragment" : "COMPLETE",
 			       f1, f2, Zsize + (*sp)->len, again);
 		/* HDLC */
-		if ((Zsize + (*sp)->len) > (maxlen + 3)) {
+		if ((Zsize + (*sp)->len) > maxlen) {
 			if (debug & DEBUG_HFCMULTI_FIFO)
 				printk(KERN_DEBUG
 				       "%s(card %d): hdlc-frame too large.\n",
@@ -2351,24 +2360,7 @@ next_frame:
 		/* there is an incomplete frame */
 	} else {
 		/* transparent */
-		if (Zsize > skb_tailroom(*sp))
-			Zsize = skb_tailroom(*sp);
 		hc->read_fifo(hc, skb_put(*sp, Zsize), Zsize);
-		if (((*sp)->len) < MISDN_COPY_SIZE) {
-			skb = *sp;
-			*sp = mI_alloc_skb(skb->len, GFP_ATOMIC);
-			if (*sp) {
-				memcpy(skb_put(*sp, skb->len),
-				       skb->data, skb->len);
-				skb_trim(skb, 0);
-			} else {
-				printk(KERN_DEBUG "%s: No mem\n", __func__);
-				*sp = skb;
-				skb = NULL;
-			}
-		} else {
-			skb = NULL;
-		}
 		if (debug & DEBUG_HFCMULTI_FIFO)
 			printk(KERN_DEBUG
 			       "%s(card %d): fifo(%d) reading %d bytes "
@@ -2376,7 +2368,6 @@ next_frame:
 			       __func__, hc->id + 1, ch, Zsize, z1, z2);
 		/* only bch is transparent */
 		recv_Bchannel(bch, hc->chan[ch].Zfill);
-		*sp = skb;
 	}
 }
 
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 123e8e5..0622e05 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -577,8 +577,11 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
 	fcnt_tx = B_FIFO_SIZE - fcnt_tx;
 	/* remaining bytes to send (bytes in tx-fifo) */
 
-	bch->rx_skb = mI_alloc_skb(fcnt_rx, GFP_ATOMIC);
-	if (bch->rx_skb) {
+	maxlen = bchannel_get_rxbuf(bch, fcnt_rx);
+	if (maxlen < 0) {
+		pr_warning("B%d: No bufferspace for %d bytes\n",
+			   bch->nr, fcnt_rx);
+	} else {
 		ptr = skb_put(bch->rx_skb, fcnt_rx);
 		if (le16_to_cpu(*z2r) + fcnt_rx <= B_FIFO_SIZE + B_SUB_VAL)
 			maxlen = fcnt_rx;	/* complete transfer */
@@ -597,9 +600,7 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
 			memcpy(ptr, ptr1, fcnt_rx);	/* rest */
 		}
 		recv_Bchannel(bch, fcnt_tx); /* bch, id */
-	} else
-		printk(KERN_WARNING "HFCPCI: receive out of memory\n");
-
+	}
 	*z2r = cpu_to_le16(new_z2);		/* new position */
 }
 
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 919eccc..6bb689b 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -860,7 +860,16 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		hdlc = 1;
 	}
 	if (fifo->bch) {
+		maxlen = bchannel_get_rxbuf(fifo->bch, len);
 		rx_skb = fifo->bch->rx_skb;
+		if (maxlen < 0) {
+			if (rx_skb)
+				skb_trim(rx_skb, 0);
+			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+				   hw->name, fifo->bch->nr, len);
+			spin_unlock(&hw->lock);
+			return;
+		}
 		maxlen = fifo->bch->maxlen;
 		hdlc = test_bit(FLG_HDLC, &fifo->bch->Flags);
 	}
@@ -870,25 +879,22 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		hdlc = 1;
 	}
 
-	if (!rx_skb) {
-		rx_skb = mI_alloc_skb(maxlen, GFP_ATOMIC);
-		if (rx_skb) {
-			if (fifo->dch)
-				fifo->dch->rx_skb = rx_skb;
-			if (fifo->bch)
-				fifo->bch->rx_skb = rx_skb;
-			if (fifo->ech)
-				fifo->ech->rx_skb = rx_skb;
-			skb_trim(rx_skb, 0);
-		} else {
-			printk(KERN_DEBUG "%s: %s: No mem for rx_skb\n",
-			       hw->name, __func__);
-			spin_unlock(&hw->lock);
-			return;
-		}
-	}
-
 	if (fifo->dch || fifo->ech) {
+		if (!rx_skb) {
+			rx_skb = mI_alloc_skb(maxlen, GFP_ATOMIC);
+			if (rx_skb) {
+				if (fifo->dch)
+					fifo->dch->rx_skb = rx_skb;
+				if (fifo->ech)
+					fifo->ech->rx_skb = rx_skb;
+				skb_trim(rx_skb, 0);
+			} else {
+				printk(KERN_DEBUG "%s: %s: No mem for rx_skb\n",
+				       hw->name, __func__);
+				spin_unlock(&hw->lock);
+				return;
+			}
+		}
 		/* D/E-Channel SKB range check */
 		if ((rx_skb->len + len) >= MAX_DFRAME_LEN_L1) {
 			printk(KERN_DEBUG "%s: %s: sbk mem exceeded "
@@ -898,16 +904,6 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 			spin_unlock(&hw->lock);
 			return;
 		}
-	} else if (fifo->bch) {
-		/* B-Channel SKB range check */
-		if ((rx_skb->len + len) >= (MAX_BCH_SIZE + 3)) {
-			printk(KERN_DEBUG "%s: %s: sbk mem exceeded "
-			       "for fifo(%d) HFCUSB_B_RX\n",
-			       hw->name, __func__, fifon);
-			skb_trim(rx_skb, 0);
-			spin_unlock(&hw->lock);
-			return;
-		}
 	}
 
 	memcpy(skb_put(rx_skb, len), data, len);
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index e4b6d8d..7d109ed 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -933,22 +933,16 @@ static void
 hscx_empty_fifo(struct hscx_hw *hscx, u8 count)
 {
 	u8 *p;
+	int maxlen;
 
 	pr_debug("%s: B%1d %d\n", hscx->ip->name, hscx->bch.nr, count);
-	if (!hscx->bch.rx_skb) {
-		hscx->bch.rx_skb = mI_alloc_skb(hscx->bch.maxlen, GFP_ATOMIC);
-		if (!hscx->bch.rx_skb) {
-			pr_info("%s: B receive out of memory\n",
-				hscx->ip->name);
-			hscx_cmdr(hscx, 0x80); /* RMC */
-			return;
-		}
-	}
-	if ((hscx->bch.rx_skb->len + count) > hscx->bch.maxlen) {
-		pr_debug("%s: overrun %d\n", hscx->ip->name,
-			 hscx->bch.rx_skb->len + count);
-		skb_trim(hscx->bch.rx_skb, 0);
+	maxlen = bchannel_get_rxbuf(&hscx->bch, count);
+	if (maxlen < 0) {
 		hscx_cmdr(hscx, 0x80); /* RMC */
+		if (hscx->bch.rx_skb)
+			skb_trim(hscx->bch.rx_skb, 0);
+		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+			   hscx->ip->name, hscx->bch.nr, count);
 		return;
 	}
 	p = skb_put(hscx->bch.rx_skb, count);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 9deea88..4169bb2 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -421,7 +421,8 @@ deliver_status(struct isar_ch *ch, int status)
 static inline void
 isar_rcv_frame(struct isar_ch *ch)
 {
-	u8		*ptr;
+	u8	*ptr;
+	int	maxlen;
 
 	if (!ch->is->clsb) {
 		pr_debug("%s; ISAR zero len frame\n", ch->is->name);
@@ -437,36 +438,22 @@ isar_rcv_frame(struct isar_ch *ch)
 	case ISDN_P_B_RAW:
 	case ISDN_P_B_L2DTMF:
 	case ISDN_P_B_MODEM_ASYNC:
-		if (!ch->bch.rx_skb) {
-			ch->bch.rx_skb = mI_alloc_skb(ch->bch.maxlen,
-						      GFP_ATOMIC);
-			if (unlikely(!ch->bch.rx_skb)) {
-				pr_info("%s: B receive out of memory\n",
-					ch->is->name);
-				ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
-				break;
-			}
+		maxlen = bchannel_get_rxbuf(&ch->bch, ch->is->clsb);
+		if (maxlen < 0) {
+			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+				   ch->is->name, ch->bch.nr, ch->is->clsb);
+			ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
+			break;
 		}
 		rcv_mbox(ch->is, skb_put(ch->bch.rx_skb, ch->is->clsb));
 		recv_Bchannel(&ch->bch, 0);
 		break;
 	case ISDN_P_B_HDLC:
-		if (!ch->bch.rx_skb) {
-			ch->bch.rx_skb = mI_alloc_skb(ch->bch.maxlen,
-						      GFP_ATOMIC);
-			if (unlikely(!ch->bch.rx_skb)) {
-				pr_info("%s: B receive out of memory\n",
-					ch->is->name);
-				ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
-				break;
-			}
-		}
-		if ((ch->bch.rx_skb->len + ch->is->clsb) >
-		    (ch->bch.maxlen + 2)) {
-			pr_debug("%s: incoming packet too large\n",
-				 ch->is->name);
+		maxlen = bchannel_get_rxbuf(&ch->bch, ch->is->clsb);
+		if (maxlen < 0) {
+			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+				   ch->is->name, ch->bch.nr, ch->is->clsb);
 			ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
-			skb_trim(ch->bch.rx_skb, 0);
 			break;
 		}
 		if (ch->is->cmsb & HDLC_ERROR) {
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index da13b07..3f28057 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -386,24 +386,16 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 			bc->bch.nr, idx);
 	}
 	bc->lastrx = idx;
-	if (!bc->bch.rx_skb) {
-		bc->bch.rx_skb = mI_alloc_skb(bc->bch.maxlen, GFP_ATOMIC);
-		if (!bc->bch.rx_skb) {
-			pr_info("%s: B%1d receive out of memory\n",
-				card->name, bc->bch.nr);
-			return;
-		}
+	stat = bchannel_get_rxbuf(&bc->bch, cnt);
+	/* only transparent use the count here, HDLC overun is detected later */
+	if (stat == ENOMEM) {
+		pr_warning("%s.B%d: No memory for %d bytes\n",
+			   card->name, bc->bch.nr, cnt);
+		return;
 	}
-
-	if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags)) {
-		if ((bc->bch.rx_skb->len + cnt) > bc->bch.maxlen) {
-			pr_debug("%s: B%1d overrun %d\n", card->name,
-				 bc->bch.nr, bc->bch.rx_skb->len + cnt);
-			skb_trim(bc->bch.rx_skb, 0);
-			return;
-		}
+	if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags))
 		p = skb_put(bc->bch.rx_skb, cnt);
-	} else
+	else
 		p = bc->hrbuf;
 
 	for (i = 0; i < cnt; i++) {
@@ -414,48 +406,45 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 			idx = 0;
 		p[i] = val & 0xff;
 	}
+
+	if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags)) {
+		recv_Bchannel(&bc->bch, 0);
+		return;
+	}
+
 	pn = bc->hrbuf;
-next_frame:
-	if (test_bit(FLG_HDLC, &bc->bch.Flags)) {
+	while (cnt > 0) {
 		stat = isdnhdlc_decode(&bc->hrecv, pn, cnt, &i,
 				       bc->bch.rx_skb->data, bc->bch.maxlen);
-		if (stat > 0) /* valid frame received */
+		if (stat > 0) { /* valid frame received */
 			p = skb_put(bc->bch.rx_skb, stat);
-		else if (stat == -HDLC_CRC_ERROR)
+			if (debug & DEBUG_HW_BFIFO) {
+				snprintf(card->log, LOG_SIZE,
+					 "B%1d-recv %s %d ", bc->bch.nr,
+					 card->name, stat);
+				print_hex_dump_bytes(card->log,
+						     DUMP_PREFIX_OFFSET, p,
+						     stat);
+			}
+			recv_Bchannel(&bc->bch, 0);
+			stat = bchannel_get_rxbuf(&bc->bch, bc->bch.maxlen);
+			if (stat < 0) {
+				pr_warning("%s.B%d: No memory for %d bytes\n",
+					   card->name, bc->bch.nr, cnt);
+				return;
+			}
+		} else if (stat == -HDLC_CRC_ERROR) {
 			pr_info("%s: B%1d receive frame CRC error\n",
 				card->name, bc->bch.nr);
-		else if (stat == -HDLC_FRAMING_ERROR)
+		} else if (stat == -HDLC_FRAMING_ERROR) {
 			pr_info("%s: B%1d receive framing error\n",
 				card->name, bc->bch.nr);
-		else if (stat == -HDLC_LENGTH_ERROR)
+		} else if (stat == -HDLC_LENGTH_ERROR) {
 			pr_info("%s: B%1d receive frame too long (> %d)\n",
 				card->name, bc->bch.nr, bc->bch.maxlen);
-	} else
-		stat = cnt;
-
-	if (stat > 0) {
-		if (debug & DEBUG_HW_BFIFO) {
-			snprintf(card->log, LOG_SIZE, "B%1d-recv %s %d ",
-				 bc->bch.nr, card->name, stat);
-			print_hex_dump_bytes(card->log, DUMP_PREFIX_OFFSET,
-					     p, stat);
 		}
-		recv_Bchannel(&bc->bch, 0);
-	}
-	if (test_bit(FLG_HDLC, &bc->bch.Flags)) {
 		pn += i;
 		cnt -= i;
-		if (!bc->bch.rx_skb) {
-			bc->bch.rx_skb = mI_alloc_skb(bc->bch.maxlen,
-						      GFP_ATOMIC);
-			if (!bc->bch.rx_skb) {
-				pr_info("%s: B%1d receive out of memory\n",
-					card->name, bc->bch.nr);
-				return;
-			}
-		}
-		if (cnt > 0)
-			goto next_frame;
 	}
 }
 
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index f1c0bf1..8324b20 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -465,6 +465,7 @@ W6692_empty_Bfifo(struct w6692_ch *wch, int count)
 {
 	struct w6692_hw *card = wch->bch.hw;
 	u8 *ptr;
+	int maxlen;
 
 	pr_debug("%s: empty_Bfifo %d\n", card->name, count);
 	if (unlikely(wch->bch.state == ISDN_P_NONE)) {
@@ -474,20 +475,13 @@ W6692_empty_Bfifo(struct w6692_ch *wch, int count)
 			skb_trim(wch->bch.rx_skb, 0);
 		return;
 	}
-	if (!wch->bch.rx_skb) {
-		wch->bch.rx_skb = mI_alloc_skb(wch->bch.maxlen, GFP_ATOMIC);
-		if (unlikely(!wch->bch.rx_skb)) {
-			pr_info("%s: B receive out of memory\n", card->name);
-			WriteW6692B(wch, W_B_CMDR, W_B_CMDR_RACK |
-				    W_B_CMDR_RACT);
-			return;
-		}
-	}
-	if (wch->bch.rx_skb->len + count > wch->bch.maxlen) {
-		pr_debug("%s: empty_Bfifo incoming packet too large\n",
-			 card->name);
+	maxlen = bchannel_get_rxbuf(&wch->bch, count);
+	if (maxlen < 0) {
 		WriteW6692B(wch, W_B_CMDR, W_B_CMDR_RACK | W_B_CMDR_RACT);
-		skb_trim(wch->bch.rx_skb, 0);
+		if (wch->bch.rx_skb)
+			skb_trim(wch->bch.rx_skb, 0);
+		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+			   card->name, wch->bch.nr, count);
 		return;
 	}
 	ptr = skb_put(wch->bch.rx_skb, count);
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index 5c5ab47..3c2145d 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -201,20 +201,30 @@ recv_Bchannel(struct bchannel *bch, unsigned int id)
 {
 	struct mISDNhead *hh;
 
-	hh = mISDN_HEAD_P(bch->rx_skb);
-	hh->prim = PH_DATA_IND;
-	hh->id = id;
-	if (bch->rcount >= 64) {
-		printk(KERN_WARNING "B-channel %p receive queue overflow, "
-		       "flushing!\n", bch);
-		skb_queue_purge(&bch->rqueue);
-		bch->rcount = 0;
+	/* if allocation did fail upper functions still may call us */
+	if (unlikely(!bch->rx_skb))
 		return;
+	if (unlikely(!bch->rx_skb->len)) {
+		/* we have no data to send - this may happen after recovery
+		 * from overflow or too small allocation.
+		 * We need to free the buffer here */
+		dev_kfree_skb(bch->rx_skb);
+		bch->rx_skb = NULL;
+	} else {
+		hh = mISDN_HEAD_P(bch->rx_skb);
+		hh->prim = PH_DATA_IND;
+		hh->id = id;
+		if (bch->rcount >= 64) {
+			printk(KERN_WARNING
+			       "B%d receive queue overflow - flushing!\n",
+			       bch->nr);
+			skb_queue_purge(&bch->rqueue);
+		}
+		bch->rcount++;
+		skb_queue_tail(&bch->rqueue, bch->rx_skb);
+		bch->rx_skb = NULL;
+		schedule_event(bch, FLG_RECVQUEUE);
 	}
-	bch->rcount++;
-	skb_queue_tail(&bch->rqueue, bch->rx_skb);
-	bch->rx_skb = NULL;
-	schedule_event(bch, FLG_RECVQUEUE);
 }
 EXPORT_SYMBOL(recv_Bchannel);
 
@@ -399,3 +409,44 @@ bchannel_senddata(struct bchannel *ch, struct sk_buff *skb)
 	}
 }
 EXPORT_SYMBOL(bchannel_senddata);
+
+/* The function allocates a new receive skb on demand with a size for the
+ * requirements of the current protocol. It returns the tailroom of the
+ * receive skb or an error.
+ */
+int
+bchannel_get_rxbuf(struct bchannel *bch, int reqlen)
+{
+	int len;
+
+	if (bch->rx_skb) {
+		len = skb_tailroom(bch->rx_skb);
+		if (len < reqlen) {
+			pr_warning("B%d no space for %d (only %d) bytes\n",
+				   bch->nr, reqlen, len);
+			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
+				/* send what we have now and try a new buffer */
+				recv_Bchannel(bch, 0);
+			} else {
+				/* on HDLC we have to drop too big frames */
+				return -EMSGSIZE;
+			}
+		} else {
+			return len;
+		}
+	}
+	if (unlikely(reqlen > bch->maxlen))
+		return -EMSGSIZE;
+	if (test_bit(FLG_TRANSPARENT, &bch->Flags))
+		len = reqlen;
+	else /* with HDLC we do not know the length yet */
+		len = bch->maxlen;
+	bch->rx_skb = mI_alloc_skb(len, GFP_ATOMIC);
+	if (!bch->rx_skb) {
+		pr_warning("B%d receive no memory for %d bytes\n",
+			   bch->nr, len);
+		len = -ENOMEM;
+	}
+	return len;
+}
+EXPORT_SYMBOL(bchannel_get_rxbuf);
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 491afd6..a86d86b 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -177,6 +177,7 @@ extern void	queue_ch_frame(struct mISDNchannel *, u_int,
 			int, struct sk_buff *);
 extern int	dchannel_senddata(struct dchannel *, struct sk_buff *);
 extern int	bchannel_senddata(struct bchannel *, struct sk_buff *);
+extern int      bchannel_get_rxbuf(struct bchannel *, int);
 extern void	recv_Dchannel(struct dchannel *);
 extern void	recv_Echannel(struct dchannel *, struct dchannel *);
 extern void	recv_Bchannel(struct bchannel *, unsigned int id);
-- 
1.7.3.4
