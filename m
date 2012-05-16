From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH v2 8/8] mISDN: Implement MISDN_CTRL_RX_OFF for more drivers
Date: Wed, 16 May 2012 11:51:08 +0200
Message-ID: <1337161868-19399-9-git-send-email-kkeil@linux-pingi.de>
References: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:57498 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966866Ab2EPKA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 06:00:29 -0400
In-Reply-To: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MISDN_CTRL_RX_OFF is a meachanism to discard RX data in the driver if
the data is not needed by the application. It can be used when playing
mesages, but not recording or with unidirectional protocols.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   25 ++++++++++++++++---------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    9 ++++++---
 drivers/isdn/hardware/mISDN/hfcpci.c    |    5 +++++
 drivers/isdn/hardware/mISDN/hfcsusb.c   |    5 +++++
 drivers/isdn/hardware/mISDN/mISDNipac.c |    5 +++++
 drivers/isdn/hardware/mISDN/mISDNisar.c |    5 +++++
 drivers/isdn/hardware/mISDN/netjet.c    |    4 ++++
 drivers/isdn/hardware/mISDN/w6692.c     |    5 +++++
 drivers/isdn/mISDN/hwchannel.c          |   14 +++++++++++++-
 include/linux/mISDNhw.h                 |    3 +++
 10 files changed, 67 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index c6fa505..c08fc60 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -408,13 +408,18 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	struct fritzcard *fc = bch->hw;
 
 	pr_debug("%s: %s %d\n", fc->name, __func__, count);
-	cnt = bchannel_get_rxbuf(bch, count);
-	if (cnt < 0) {
-		pr_warning("%s.B%d: No bufferspace for %d bytes\n",
-			   fc->name, bch->nr, count);
-		return;
+	if (test_bit(FLG_RX_OFF, &bch->Flags)) {
+		p = NULL;
+		bch->dropcnt += count;
+	} else {
+		cnt = bchannel_get_rxbuf(bch, count);
+		if (cnt < 0) {
+			pr_warning("%s.B%d: No bufferspace for %d bytes\n",
+				   fc->name, bch->nr, count);
+			return;
+		}
+		p = skb_put(bch->rx_skb, count);
 	}
-	p = skb_put(bch->rx_skb, count);
 	ptr = (u32 *)p;
 	if (fc->type == AVM_FRITZ_PCIV2)
 		addr = fc->addr + (bch->nr == 2 ?
@@ -426,11 +431,13 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	cnt = 0;
 	while (cnt < count) {
 		val = le32_to_cpu(inl(addr));
-		put_unaligned(val, ptr);
-		ptr++;
+		if (p) {
+			put_unaligned(val, ptr);
+			ptr++;
+		}
 		cnt += 4;
 	}
-	if (debug & DEBUG_HW_BFIFO) {
+	if (p && (debug & DEBUG_HW_BFIFO)) {
 		snprintf(fc->log, LOG_SIZE, "B%1d-recv %s %d ",
 			 bch->nr, fc->name, count);
 		print_hex_dump_bytes(fc->log, DUMP_PREFIX_OFFSET, p, count);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 3b79a40..9e2a6da 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2224,8 +2224,11 @@ next_frame:
 	HFC_wait_nodebug(hc);
 
 	/* ignore if rx is off BUT change fifo (above) to start pending TX */
-	if (hc->chan[ch].rx_off)
+	if (hc->chan[ch].rx_off) {
+		if (bch)
+			bch->dropcnt += poll; /* not exact but fair enough */
 		return;
+	}
 
 	if (dch || test_bit(FLG_HDLC, &bch->Flags)) {
 		f1 = HFC_inb_nodebug(hc, A_F1);
@@ -3575,10 +3578,10 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
 		ret = mISDN_ctrl_bchannel(bch, cq);
-		cq->op |= MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP |
-			  MISDN_CTRL_RX_OFF;
+		cq->op |= MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP;
 		break;
 	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
+		ret = mISDN_ctrl_bchannel(bch, cq);
 		hc->chan[bch->slot].rx_off = !!cq->p1;
 		if (!hc->chan[bch->slot].rx_off) {
 			/* reset fifo on rx on */
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 1bd8bc7..81363ff 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -572,6 +572,11 @@ hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *rxbz,
 	fcnt_tx = B_FIFO_SIZE - fcnt_tx;
 	/* remaining bytes to send (bytes in tx-fifo) */
 
+	if (test_bit(FLG_RX_OFF, &bch->Flags)) {
+		bch->dropcnt += fcnt_rx;
+		*z2r = cpu_to_le16(new_z2);
+		return;
+	}
 	maxlen = bchannel_get_rxbuf(bch, fcnt_rx);
 	if (maxlen < 0) {
 		pr_warning("B%d: No bufferspace for %d bytes\n",
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index b539b10..83206e4 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -842,6 +842,11 @@ hfcsusb_rx_frame(struct usb_fifo *fifo, __u8 *data, unsigned int len,
 		hdlc = 1;
 	}
 	if (fifo->bch) {
+		if (test_bit(FLG_RX_OFF, &fifo->bch->Flags)) {
+			fifo->bch->dropcnt += len;
+			spin_unlock(&hw->lock);
+			return;
+		}
 		maxlen = bchannel_get_rxbuf(fifo->bch, len);
 		rx_skb = fifo->bch->rx_skb;
 		if (maxlen < 0) {
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 374a177..752e082 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -936,6 +936,11 @@ hscx_empty_fifo(struct hscx_hw *hscx, u8 count)
 	int maxlen;
 
 	pr_debug("%s: B%1d %d\n", hscx->ip->name, hscx->bch.nr, count);
+	if (test_bit(FLG_RX_OFF, &hscx->bch.Flags)) {
+		hscx->bch.dropcnt += count;
+		hscx_cmdr(hscx, 0x80); /* RMC */
+		return;
+	}
 	maxlen = bchannel_get_rxbuf(&hscx->bch, count);
 	if (maxlen < 0) {
 		hscx_cmdr(hscx, 0x80); /* RMC */
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 3f57fd9..5a256f0 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -429,6 +429,11 @@ isar_rcv_frame(struct isar_ch *ch)
 		ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
 		return;
 	}
+	if (test_bit(FLG_RX_OFF, &ch->bch.Flags)) {
+		ch->bch.dropcnt += ch->is->clsb;
+		ch->is->write_reg(ch->is->hw, ISAR_IIA, 0);
+		return;
+	}
 	switch (ch->bch.state) {
 	case ISDN_P_NONE:
 		pr_debug("%s: ISAR protocol 0 spurious IIS_RDATA %x/%x/%x\n",
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index aa95cc7..c3e3e76 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -386,6 +386,10 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 			bc->bch.nr, idx);
 	}
 	bc->lastrx = idx;
+	if (test_bit(FLG_RX_OFF, &bc->bch.Flags)) {
+		bc->bch.dropcnt += cnt;
+		return;
+	}
 	stat = bchannel_get_rxbuf(&bc->bch, cnt);
 	/* only transparent use the count here, HDLC overun is detected later */
 	if (stat == ENOMEM) {
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 183181f..26a86b8 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -475,6 +475,11 @@ W6692_empty_Bfifo(struct w6692_ch *wch, int count)
 			skb_trim(wch->bch.rx_skb, 0);
 		return;
 	}
+	if (test_bit(FLG_RX_OFF, &wch->bch.Flags)) {
+		wch->bch.dropcnt += count;
+		WriteW6692B(wch, W_B_CMDR, W_B_CMDR_RACK | W_B_CMDR_RACT);
+		return;
+	}
 	maxlen = bchannel_get_rxbuf(&wch->bch, count);
 	if (maxlen < 0) {
 		WriteW6692B(wch, W_B_CMDR, W_B_CMDR_RACK | W_B_CMDR_RACT);
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index e541b65..ef34fd4 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -142,6 +142,8 @@ mISDN_clear_bchannel(struct bchannel *ch)
 	test_and_clear_bit(FLG_ACTIVE, &ch->Flags);
 	test_and_clear_bit(FLG_FILLEMPTY, &ch->Flags);
 	test_and_clear_bit(FLG_TX_EMPTY, &ch->Flags);
+	test_and_clear_bit(FLG_RX_OFF, &ch->Flags);
+	ch->dropcnt = 0;
 	ch->minlen = ch->init_minlen;
 	ch->next_minlen = ch->init_minlen;
 	ch->maxlen = ch->init_maxlen;
@@ -167,7 +169,8 @@ mISDN_ctrl_bchannel(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_RX_BUFFER | MISDN_CTRL_FILL_EMPTY;
+		cq->op = MISDN_CTRL_RX_BUFFER | MISDN_CTRL_FILL_EMPTY |
+			 MISDN_CTRL_RX_OFF;
 		break;
 	case MISDN_CTRL_FILL_EMPTY:
 		if (cq->p1) {
@@ -177,6 +180,15 @@ mISDN_ctrl_bchannel(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 			test_and_clear_bit(FLG_FILLEMPTY, &bch->Flags);
 		}
 		break;
+	case MISDN_CTRL_RX_OFF:
+		/* read back dropped byte count */
+		cq->p2 = bch->dropcnt;
+		if (cq->p1)
+			test_and_set_bit(FLG_RX_OFF, &bch->Flags);
+		else
+			test_and_clear_bit(FLG_RX_OFF, &bch->Flags);
+		bch->dropcnt = 0;
+		break;
 	case MISDN_CTRL_RX_BUFFER:
 		if (cq->p2 > MISDN_CTRL_RX_SIZE_IGNORE)
 			bch->next_maxlen = cq->p2;
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 6211842..d0752ec 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -73,6 +73,8 @@
 #define FLG_LL_CONN		25
 #define FLG_DTMFSEND		26
 #define FLG_TX_EMPTY		27
+/* stop sending received data upstream */
+#define FLG_RX_OFF		28
 /* workq events */
 #define FLG_RECVQUEUE		30
 #define	FLG_PHCHANGE		31
@@ -173,6 +175,7 @@ struct bchannel {
 	int			err_crc;
 	int			err_tx;
 	int			err_rx;
+	int			dropcnt;
 };
 
 extern int	mISDN_initdchannel(struct dchannel *, int, void *);
-- 
1.7.3.4
