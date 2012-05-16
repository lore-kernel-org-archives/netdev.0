From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 6/8] mISDN: Allow to set a minimum length for transparent data
Date: Wed, 16 May 2012 06:22:52 +0200
Message-ID: <1337142174-8304-7-git-send-email-kkeil@linux-pingi.de>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:50864 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab2EPEcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 00:32:12 -0400
In-Reply-To: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the FIFO of the card is small, many short messages are queued up to
the upper layers and the userspace. This change allows the applications
to set a minimum datalen they want from the drivers.
Create a common control function to avoid code duplication in each
driver.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   35 ++++++----------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |   17 ++++----
 drivers/isdn/hardware/mISDN/hfcpci.c    |   12 +++---
 drivers/isdn/hardware/mISDN/hfcsusb.c   |   14 +++---
 drivers/isdn/hardware/mISDN/mISDNipac.c |   27 +++----------
 drivers/isdn/hardware/mISDN/mISDNisar.c |   25 +++---------
 drivers/isdn/hardware/mISDN/netjet.c    |   23 ++--------
 drivers/isdn/hardware/mISDN/w6692.c     |   25 +++---------
 drivers/isdn/mISDN/hwchannel.c          |   65 ++++++++++++++++++++++++++++---
 drivers/isdn/mISDN/l1oip_core.c         |    2 +-
 include/linux/mISDNhw.h                 |   13 +++++-
 include/linux/mISDNif.h                 |    9 ++++-
 12 files changed, 135 insertions(+), 132 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 0e56580..57b9855 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -536,12 +536,12 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 			hdlc_empty_fifo(bch, len);
 			if (!bch->rx_skb)
 				goto handle_tx;
-			if (test_bit(FLG_TRANSPARENT, &bch->Flags) ||
-			    (stat & HDLC_STAT_RME)) {
-				if (((stat & HDLC_STAT_CRCVFRRAB) ==
-				     HDLC_STAT_CRCVFR) ||
-				    test_bit(FLG_TRANSPARENT, &bch->Flags)) {
-					recv_Bchannel(bch, 0);
+			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
+				recv_Bchannel(bch, 0, 0);
+			} else if (stat & HDLC_STAT_RME) {
+				if ((stat & HDLC_STAT_CRCVFRRAB) ==
+				    HDLC_STAT_CRCVFR) {
+					recv_Bchannel(bch, 0, 0);
 				} else {
 					pr_warning("%s: got invalid frame\n",
 						   fc->name);
@@ -809,21 +809,7 @@ init_card(struct fritzcard *fc)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int ret = 0;
-	struct fritzcard *fc = bch->hw;
-
-	switch (cq->op) {
-	case MISDN_CTRL_GETOP:
-		cq->op = 0;
-		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
-	default:
-		pr_info("%s: %s unknown Op %x\n", fc->name, __func__, cq->op);
-		ret = -EINVAL;
-		break;
-	}
-	return ret;
+	return mISDN_ctrl_bchannel(bch, cq);
 }
 
 static int
@@ -1019,6 +1005,7 @@ static int __devinit
 setup_instance(struct fritzcard *card)
 {
 	int i, err;
+	unsigned short minsize;
 	u_long flags;
 
 	snprintf(card->name, MISDN_MAX_IDLEN - 1, "AVM.%d", AVM_cnt + 1);
@@ -1038,7 +1025,11 @@ setup_instance(struct fritzcard *card)
 	for (i = 0; i < 2; i++) {
 		card->bch[i].nr = i + 1;
 		set_channelmap(i + 1, card->isac.dch.dev.channelmap);
-		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM);
+		if (AVM_FRITZ_PCIV2 == card->type)
+			minsize = HDLC_FIFO_SIZE_V2;
+		else
+			minsize = HDLC_FIFO_SIZE_V1;
+		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM, minsize);
 		card->bch[i].hw = card;
 		card->bch[i].ch.send = avm_l2l1B;
 		card->bch[i].ch.ctrl = avm_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 16bef01..22eee18 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2352,7 +2352,7 @@ next_frame:
 			if (dch)
 				recv_Dchannel(dch);
 			else
-				recv_Bchannel(bch, MISDN_ID_ANY);
+				recv_Bchannel(bch, MISDN_ID_ANY, 0);
 			*sp = skb;
 			again++;
 			goto next_frame;
@@ -2367,7 +2367,7 @@ next_frame:
 			       "(z1=%04x, z2=%04x) TRANS\n",
 			       __func__, hc->id + 1, ch, Zsize, z1, z2);
 		/* only bch is transparent */
-		recv_Bchannel(bch, hc->chan[ch].Zfill);
+		recv_Bchannel(bch, hc->chan[ch].Zfill, 0);
 	}
 }
 
@@ -3574,8 +3574,9 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP
-			| MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY;
+		ret = mISDN_ctrl_bchannel(bch, cq);
+		cq->op |= MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP |
+			  MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY;
 		break;
 	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
 		hc->chan[bch->slot].rx_off = !!cq->p1;
@@ -3683,9 +3684,7 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 			ret = -EINVAL;
 		break;
 	default:
-		printk(KERN_WARNING "%s: unknown Op %x\n",
-		       __func__, cq->op);
-		ret = -EINVAL;
+		ret = mISDN_ctrl_bchannel(bch, cq);
 		break;
 	}
 	return ret;
@@ -4855,7 +4854,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m, int pt)
 		bch->nr = ch;
 		bch->slot = ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, poll >> 1);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = hfcm_bctrl;
@@ -4928,7 +4927,7 @@ init_multi_port(struct hfc_multi *hc, int pt)
 		bch->nr = ch + 1;
 		bch->slot = i + ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, poll >> 1);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = hfcm_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 0622e05..5e074a8 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -453,7 +453,7 @@ hfcpci_empty_bfifo(struct bchannel *bch, struct bzfifo *bz,
 		}
 		bz->za[new_f2].z2 = cpu_to_le16(new_z2);
 		bz->f2 = new_f2;	/* next buffer */
-		recv_Bchannel(bch, MISDN_ID_ANY);
+		recv_Bchannel(bch, MISDN_ID_ANY, 0);
 	}
 }
 
@@ -599,7 +599,7 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
 			ptr1 = bdata;	/* start of buffer */
 			memcpy(ptr, ptr1, fcnt_rx);	/* rest */
 		}
-		recv_Bchannel(bch, fcnt_tx); /* bch, id */
+		recv_Bchannel(bch, fcnt_tx, 0); /* bch, id, !force */
 	}
 	*z2r = cpu_to_le16(new_z2);		/* new position */
 }
@@ -1535,7 +1535,8 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_FILL_EMPTY;
+		ret = mISDN_ctrl_bchannel(bch, cq);
+		cq->op |= MISDN_CTRL_FILL_EMPTY;
 		break;
 	case MISDN_CTRL_FILL_EMPTY: /* fill fifo, if empty */
 		test_and_set_bit(FLG_FILLEMPTY, &bch->Flags);
@@ -1544,8 +1545,7 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 			       "off=%d)\n", __func__, bch->nr, !!cq->p1);
 		break;
 	default:
-		printk(KERN_WARNING "%s: unknown Op %x\n", __func__, cq->op);
-		ret = -EINVAL;
+		ret = mISDN_ctrl_bchannel(bch, cq);
 		break;
 	}
 	return ret;
@@ -2116,7 +2116,7 @@ setup_card(struct hfc_pci *card)
 		card->bch[i].nr = i + 1;
 		set_channelmap(i + 1, card->dch.dev.channelmap);
 		card->bch[i].debug = debug;
-		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM, poll >> 1);
 		card->bch[i].hw = card;
 		card->bch[i].ch.send = hfcpci_l2l1B;
 		card->bch[i].ch.ctrl = hfc_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 6bb689b..f65f799 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -810,7 +810,8 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_FILL_EMPTY;
+		ret = mISDN_ctrl_bchannel(bch, cq);
+		cq->op |= MISDN_CTRL_FILL_EMPTY;
 		break;
 	case MISDN_CTRL_FILL_EMPTY: /* fill fifo, if empty */
 		test_and_set_bit(FLG_FILLEMPTY, &bch->Flags);
@@ -819,8 +820,7 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 			       "off=%d)\n", __func__, bch->nr, !!cq->p1);
 		break;
 	default:
-		printk(KERN_WARNING "%s: unknown Op %x\n", __func__, cq->op);
-		ret = -EINVAL;
+		ret = mISDN_ctrl_bchannel(bch, cq);
 		break;
 	}
 	return ret;
@@ -931,7 +931,8 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 				if (fifo->dch)
 					recv_Dchannel(fifo->dch);
 				if (fifo->bch)
-					recv_Bchannel(fifo->bch, MISDN_ID_ANY);
+					recv_Bchannel(fifo->bch, MISDN_ID_ANY,
+						      0);
 				if (fifo->ech)
 					recv_Echannel(fifo->ech,
 						      &hw->dch);
@@ -952,8 +953,7 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		}
 	} else {
 		/* deliver transparent data to layer2 */
-		if (rx_skb->len >= poll)
-			recv_Bchannel(fifo->bch, MISDN_ID_ANY);
+		recv_Bchannel(fifo->bch, MISDN_ID_ANY, 0);
 	}
 	spin_unlock(&hw->lock);
 }
@@ -1861,7 +1861,7 @@ setup_instance(struct hfcsusb *hw, struct device *parent)
 		hw->bch[i].nr = i + 1;
 		set_channelmap(i + 1, hw->dch.dev.channelmap);
 		hw->bch[i].debug = debug;
-		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM);
+		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM, poll >> 1);
 		hw->bch[i].hw = hw;
 		hw->bch[i].ch.send = hfcusb_l2l1B;
 		hw->bch[i].ch.ctrl = hfc_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 7d109ed..cd372de 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1063,7 +1063,7 @@ ipac_rme(struct hscx_hw *hx)
 		skb_trim(hx->bch.rx_skb, 0);
 	} else {
 		skb_trim(hx->bch.rx_skb, hx->bch.rx_skb->len - 1);
-		recv_Bchannel(&hx->bch, 0);
+		recv_Bchannel(&hx->bch, 0, 0);
 	}
 }
 
@@ -1114,11 +1114,8 @@ ipac_irq(struct hscx_hw *hx, u8 ista)
 
 	if (istab & IPACX_B_RPF) {
 		hscx_empty_fifo(hx, hx->fifo_size);
-		if (test_bit(FLG_TRANSPARENT, &hx->bch.Flags)) {
-			/* receive transparent audio data */
-			if (hx->bch.rx_skb)
-				recv_Bchannel(&hx->bch, 0);
-		}
+		if (test_bit(FLG_TRANSPARENT, &hx->bch.Flags))
+			recv_Bchannel(&hx->bch, 0, 0);
 	}
 
 	if (istab & IPACX_B_RFO) {
@@ -1377,20 +1374,7 @@ hscx_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int	ret = 0;
-
-	switch (cq->op) {
-	case MISDN_CTRL_GETOP:
-		cq->op = 0;
-		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
-	default:
-		pr_info("%s: unknown Op %x\n", __func__, cq->op);
-		ret = -EINVAL;
-		break;
-	}
-	return ret;
+	return mISDN_ctrl_bchannel(bch, cq);
 }
 
 static int
@@ -1608,7 +1592,8 @@ mISDNipac_init(struct ipac_hw *ipac, void *hw)
 		set_channelmap(i + 1, ipac->isac.dch.dev.channelmap);
 		list_add(&ipac->hscx[i].bch.ch.list,
 			 &ipac->isac.dch.dev.bchannels);
-		mISDN_initbchannel(&ipac->hscx[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&ipac->hscx[i].bch, MAX_DATA_MEM,
+				   ipac->hscx[i].fifo_size);
 		ipac->hscx[i].bch.ch.nr = i + 1;
 		ipac->hscx[i].bch.ch.send = &hscx_l2l1;
 		ipac->hscx[i].bch.ch.ctrl = hscx_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 4169bb2..a58f629 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -446,7 +446,7 @@ isar_rcv_frame(struct isar_ch *ch)
 			break;
 		}
 		rcv_mbox(ch->is, skb_put(ch->bch.rx_skb, ch->is->clsb));
-		recv_Bchannel(&ch->bch, 0);
+		recv_Bchannel(&ch->bch, 0, 0);
 		break;
 	case ISDN_P_B_HDLC:
 		maxlen = bchannel_get_rxbuf(&ch->bch, ch->is->clsb);
@@ -481,7 +481,7 @@ isar_rcv_frame(struct isar_ch *ch)
 				break;
 			}
 			skb_trim(ch->bch.rx_skb, ch->bch.rx_skb->len - 2);
-			recv_Bchannel(&ch->bch, 0);
+			recv_Bchannel(&ch->bch, 0, 0);
 		}
 		break;
 	case ISDN_P_B_T30_FAX:
@@ -517,7 +517,7 @@ isar_rcv_frame(struct isar_ch *ch)
 				ch->state = STFAX_ESCAPE;
 				/* set_skb_flag(skb, DF_NOMOREDATA); */
 			}
-			recv_Bchannel(&ch->bch, 0);
+			recv_Bchannel(&ch->bch, 0, 0);
 			if (ch->is->cmsb & SART_NMD)
 				deliver_status(ch, HW_MOD_NOCARR);
 			break;
@@ -557,7 +557,7 @@ isar_rcv_frame(struct isar_ch *ch)
 				break;
 			}
 			skb_trim(ch->bch.rx_skb, ch->bch.rx_skb->len - 2);
-			recv_Bchannel(&ch->bch, 0);
+			recv_Bchannel(&ch->bch, 0, 0);
 		}
 		if (ch->is->cmsb & SART_NMD) { /* ABORT */
 			pr_debug("%s: isar_rcv_frame: no more data\n",
@@ -1554,20 +1554,7 @@ isar_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int	ret = 0;
-
-	switch (cq->op) {
-	case MISDN_CTRL_GETOP:
-		cq->op = 0;
-		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
-	default:
-		pr_info("%s: unknown Op %x\n", __func__, cq->op);
-		ret = -EINVAL;
-		break;
-	}
-	return ret;
+	return mISDN_ctrl_bchannel(bch, cq);
 }
 
 static int
@@ -1665,7 +1652,7 @@ mISDNisar_init(struct isar_hw *isar, void *hw)
 	isar->hw = hw;
 	for (i = 0; i < 2; i++) {
 		isar->ch[i].bch.nr = i + 1;
-		mISDN_initbchannel(&isar->ch[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&isar->ch[i].bch, MAX_DATA_MEM, 32);
 		isar->ch[i].bch.ch.nr = i + 1;
 		isar->ch[i].bch.ch.send = &isar_l2l1;
 		isar->ch[i].bch.ch.ctrl = isar_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 3f28057..68ac05f 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -408,7 +408,7 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 	}
 
 	if (test_bit(FLG_TRANSPARENT, &bc->bch.Flags)) {
-		recv_Bchannel(&bc->bch, 0);
+		recv_Bchannel(&bc->bch, 0, 0);
 		return;
 	}
 
@@ -426,7 +426,7 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 						     DUMP_PREFIX_OFFSET, p,
 						     stat);
 			}
-			recv_Bchannel(&bc->bch, 0);
+			recv_Bchannel(&bc->bch, 0, 0);
 			stat = bchannel_get_rxbuf(&bc->bch, bc->bch.maxlen);
 			if (stat < 0) {
 				pr_warning("%s.B%d: No memory for %d bytes\n",
@@ -758,21 +758,7 @@ nj_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 static int
 channel_bctrl(struct tiger_ch *bc, struct mISDN_ctrl_req *cq)
 {
-	int ret = 0;
-	struct tiger_hw *card  = bc->bch.hw;
-
-	switch (cq->op) {
-	case MISDN_CTRL_GETOP:
-		cq->op = 0;
-		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
-	default:
-		pr_info("%s: %s unknown Op %x\n", card->name, __func__, cq->op);
-		ret = -EINVAL;
-		break;
-	}
-	return ret;
+	return mISDN_ctrl_bchannel(&bc->bch, cq);
 }
 
 static int
@@ -1006,7 +992,8 @@ setup_instance(struct tiger_hw *card)
 	for (i = 0; i < 2; i++) {
 		card->bc[i].bch.nr = i + 1;
 		set_channelmap(i + 1, card->isac.dch.dev.channelmap);
-		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM,
+				   NJ_DMA_RXSIZE >> 1);
 		card->bc[i].bch.hw = card;
 		card->bc[i].bch.ch.send = nj_l2l1B;
 		card->bc[i].bch.ch.ctrl = nj_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 8324b20..a513baf 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -688,7 +688,7 @@ W6692B_interrupt(struct w6692_hw *card, int ch)
 			if (count == 0)
 				count = W_B_FIFO_THRESH;
 			W6692_empty_Bfifo(wch, count);
-			recv_Bchannel(&wch->bch, 0);
+			recv_Bchannel(&wch->bch, 0, 0);
 		}
 	}
 	if (stat & W_B_EXI_RMR) {
@@ -704,9 +704,8 @@ W6692B_interrupt(struct w6692_hw *card, int ch)
 				    W_B_CMDR_RRST | W_B_CMDR_RACT);
 		} else {
 			W6692_empty_Bfifo(wch, W_B_FIFO_THRESH);
-			if (test_bit(FLG_TRANSPARENT, &wch->bch.Flags) &&
-			    wch->bch.rx_skb && (wch->bch.rx_skb->len > 0))
-				recv_Bchannel(&wch->bch, 0);
+			if (test_bit(FLG_TRANSPARENT, &wch->bch.Flags))
+				recv_Bchannel(&wch->bch, 0, 0);
 		}
 	}
 	if (stat & W_B_EXI_RDOV) {
@@ -979,20 +978,7 @@ w6692_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int	ret = 0;
-
-	switch (cq->op) {
-	case MISDN_CTRL_GETOP:
-		cq->op = 0;
-		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
-	default:
-		pr_info("%s: unknown Op %x\n", __func__, cq->op);
-		ret = -EINVAL;
-		break;
-	}
-	return ret;
+	return mISDN_ctrl_bchannel(bch, cq);
 }
 
 static int
@@ -1303,7 +1289,8 @@ setup_instance(struct w6692_hw *card)
 	card->dch.hw = card;
 	card->dch.dev.nrbchan = 2;
 	for (i = 0; i < 2; i++) {
-		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM,
+				   W_B_FIFO_THRESH);
 		card->bc[i].bch.hw = card;
 		card->bc[i].bch.nr = i + 1;
 		card->bc[i].bch.ch.nr = i + 1;
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index fba8f73..f0a861c 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -81,10 +81,16 @@ mISDN_initdchannel(struct dchannel *ch, int maxlen, void *phf)
 EXPORT_SYMBOL(mISDN_initdchannel);
 
 int
-mISDN_initbchannel(struct bchannel *ch, int maxlen)
+mISDN_initbchannel(struct bchannel *ch, unsigned short maxlen,
+		   unsigned short minlen)
 {
 	ch->Flags = 0;
+	ch->minlen = minlen;
+	ch->next_minlen = minlen;
+	ch->init_minlen = minlen;
 	ch->maxlen = maxlen;
+	ch->next_maxlen = maxlen;
+	ch->init_maxlen = maxlen;
 	ch->hw = NULL;
 	ch->rx_skb = NULL;
 	ch->tx_skb = NULL;
@@ -134,6 +140,10 @@ mISDN_clear_bchannel(struct bchannel *ch)
 	test_and_clear_bit(FLG_TX_BUSY, &ch->Flags);
 	test_and_clear_bit(FLG_TX_NEXT, &ch->Flags);
 	test_and_clear_bit(FLG_ACTIVE, &ch->Flags);
+	ch->minlen = ch->init_minlen;
+	ch->next_minlen = ch->init_minlen;
+	ch->maxlen = ch->init_maxlen;
+	ch->next_maxlen = ch->init_maxlen;
 }
 EXPORT_SYMBOL(mISDN_clear_bchannel);
 
@@ -148,6 +158,33 @@ mISDN_freebchannel(struct bchannel *ch)
 }
 EXPORT_SYMBOL(mISDN_freebchannel);
 
+int
+mISDN_ctrl_bchannel(struct bchannel *bch, struct mISDN_ctrl_req *cq)
+{
+	int ret = 0;
+
+	switch (cq->op) {
+	case MISDN_CTRL_GETOP:
+		cq->op = MISDN_CTRL_RX_BUFFER;
+		break;
+	case MISDN_CTRL_RX_BUFFER:
+		if (cq->p2 > MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->next_maxlen = cq->p2;
+		if (cq->p1 > MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->next_minlen = cq->p1;
+		/* we return the old values */
+		cq->p1 = bch->minlen;
+		cq->p2 = bch->maxlen;
+		break;
+	default:
+		pr_info("mISDN unhandled control %x operation\n", cq->op);
+		ret = -EINVAL;
+		break;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(mISDN_ctrl_bchannel);
+
 static inline u_int
 get_sapi_tei(u_char *p)
 {
@@ -197,7 +234,7 @@ recv_Echannel(struct dchannel *ech, struct dchannel *dch)
 EXPORT_SYMBOL(recv_Echannel);
 
 void
-recv_Bchannel(struct bchannel *bch, unsigned int id)
+recv_Bchannel(struct bchannel *bch, unsigned int id, unsigned int force)
 {
 	struct mISDNhead *hh;
 
@@ -211,6 +248,9 @@ recv_Bchannel(struct bchannel *bch, unsigned int id)
 		dev_kfree_skb(bch->rx_skb);
 		bch->rx_skb = NULL;
 	} else {
+		if (test_bit(FLG_TRANSPARENT, &bch->Flags) &&
+		    (bch->rx_skb->len < bch->minlen) && !force)
+				return;
 		hh = mISDN_HEAD_P(bch->rx_skb);
 		hh->prim = PH_DATA_IND;
 		hh->id = id;
@@ -427,7 +467,7 @@ bchannel_get_rxbuf(struct bchannel *bch, int reqlen)
 				   bch->nr, reqlen, len);
 			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
 				/* send what we have now and try a new buffer */
-				recv_Bchannel(bch, 0);
+				recv_Bchannel(bch, 0, 1);
 			} else {
 				/* on HDLC we have to drop too big frames */
 				return -EMSGSIZE;
@@ -436,12 +476,25 @@ bchannel_get_rxbuf(struct bchannel *bch, int reqlen)
 			return len;
 		}
 	}
+	/* update current min/max length first */
+	if (unlikely(bch->maxlen != bch->next_maxlen))
+		bch->maxlen = bch->next_maxlen;
+	if (unlikely(bch->minlen != bch->next_minlen))
+		bch->minlen = bch->next_minlen;
 	if (unlikely(reqlen > bch->maxlen))
 		return -EMSGSIZE;
-	if (test_bit(FLG_TRANSPARENT, &bch->Flags))
-		len = reqlen;
-	else /* with HDLC we do not know the length yet */
+	if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
+		if (reqlen >= bch->minlen) {
+			len = reqlen;
+		} else {
+			len = 2 * bch->minlen;
+			if (len > bch->maxlen)
+				len = bch->maxlen;
+		}
+	} else {
+		/* with HDLC we do not know the length yet */
 		len = bch->maxlen;
+	}
 	bch->rx_skb = mI_alloc_skb(len, GFP_ATOMIC);
 	if (!bch->rx_skb) {
 		pr_warning("B%d receive no memory for %d bytes\n",
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 0f88acf..db50f78 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -1420,7 +1420,7 @@ init_card(struct l1oip *hc, int pri, int bundle)
 		bch->nr = i + ch;
 		bch->slot = i + ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, 0);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = l1oip_bctrl;
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index a86d86b..04db4fc 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -154,7 +154,12 @@ struct bchannel {
 	struct timer_list	timer;
 	/* receive data */
 	struct sk_buff		*rx_skb;
-	int			maxlen;
+	unsigned short		maxlen;
+	unsigned short		init_maxlen; /* initial value */
+	unsigned short		next_maxlen; /* pending value */
+	unsigned short		minlen; /* for transparent data */
+	unsigned short		init_minlen; /* initial value */
+	unsigned short		next_minlen; /* pending value */
 	/* send data */
 	struct sk_buff		*next_skb;
 	struct sk_buff		*tx_skb;
@@ -169,10 +174,12 @@ struct bchannel {
 };
 
 extern int	mISDN_initdchannel(struct dchannel *, int, void *);
-extern int	mISDN_initbchannel(struct bchannel *, int);
+extern int	mISDN_initbchannel(struct bchannel *, unsigned short,
+				   unsigned short);
 extern int	mISDN_freedchannel(struct dchannel *);
 extern void	mISDN_clear_bchannel(struct bchannel *);
 extern int	mISDN_freebchannel(struct bchannel *);
+extern int	mISDN_ctrl_bchannel(struct bchannel *, struct mISDN_ctrl_req *);
 extern void	queue_ch_frame(struct mISDNchannel *, u_int,
 			int, struct sk_buff *);
 extern int	dchannel_senddata(struct dchannel *, struct sk_buff *);
@@ -180,7 +187,7 @@ extern int	bchannel_senddata(struct bchannel *, struct sk_buff *);
 extern int      bchannel_get_rxbuf(struct bchannel *, int);
 extern void	recv_Dchannel(struct dchannel *);
 extern void	recv_Echannel(struct dchannel *, struct dchannel *);
-extern void	recv_Bchannel(struct bchannel *, unsigned int id);
+extern void	recv_Bchannel(struct bchannel *, unsigned int, unsigned int);
 extern void	recv_Dchannel_skb(struct dchannel *, struct sk_buff *);
 extern void	recv_Bchannel_skb(struct bchannel *, struct sk_buff *);
 extern int	get_next_bframe(struct bchannel *);
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index ce6e613..246a352 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		28
+#define MISDN_RELEASE		29
 
 /* primitives for information exchange
  * generell format
@@ -365,6 +365,7 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_LOOP			0x0001
 #define MISDN_CTRL_CONNECT		0x0002
 #define MISDN_CTRL_DISCONNECT		0x0004
+#define MISDN_CTRL_RX_BUFFER		0x0008
 #define MISDN_CTRL_PCMCONNECT		0x0010
 #define MISDN_CTRL_PCMDISCONNECT	0x0020
 #define MISDN_CTRL_SETPEER		0x0040
@@ -387,6 +388,12 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_HFC_WD_INIT		0x4009
 #define MISDN_CTRL_HFC_WD_RESET		0x400A
 
+/* special RX buffer value for MISDN_CTRL_RX_BUFFER request.p1 is the minimum
+ * buffer size request.p2 the maximum. Using  MISDN_CTRL_RX_SIZE_IGNORE will
+ * not change the value, but still read back the actual stetting.
+ */
+#define MISDN_CTRL_RX_SIZE_IGNORE	-1
+
 /* socket options */
 #define MISDN_TIME_STAMP		0x0001
 
-- 
1.7.3.4
