From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 22/28] mISDN: More support for MISDN_CTRL_FILL_EMPTY and MISDN_CTRL_RX_OFF
Date: Sat, 21 Apr 2012 17:39:50 +0200
Message-ID: <20120423170551.30CA59FB80@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:59923 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab2DWRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a common HW flag to support RX_OFF.
Implement MISDN_CTRL_FILL_EMPTY and MISDN_CTRL_RX_OFF for the avmfritz
driver.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |  169 ++++++++++++++++++++++++--------
 drivers/isdn/mISDN/hwchannel.c         |    1 +
 include/linux/mISDNhw.h                |    4 +-
 include/linux/mISDNif.h                |   10 ++-
 4 files changed, 139 insertions(+), 45 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 9cee744..3781446 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -141,6 +141,8 @@ struct fritzcard {
 	struct isac_hw		isac;
 	struct hdlc_hw		hdlc[2];
 	struct bchannel		bch[2];
+	int			dropcnt[2];
+	u8			fill[2 * HDLC_FIFO_SIZE_V2];
 	char			log[LOG_SIZE + 1];
 };
 
@@ -402,35 +404,45 @@ static void
 hdlc_empty_fifo(struct bchannel *bch, int count)
 {
 	u32 *ptr;
-	u8 *p;
+	u8 *p, copy;
 	u32  val, addr;
 	int cnt;
 	struct fritzcard *fc = bch->hw;
 
 	pr_debug("%s: %s %d\n", fc->name, __func__, count);
-	if (!bch->rx_skb) {
-		if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
-			if (count >= bch->minlen)
-				cnt = count;
-			else
-				cnt = 2 * bch->minlen;
-		} else
-			cnt = bch->maxlen;
-		bch->rx_skb = mI_alloc_skb(cnt, GFP_ATOMIC);
+	if (test_bit(FLG_RX_OFF, &bch->Flags)) {
+		/* We drop the content, but need to read all bytes from FIFO */
+		copy = 0;
+		if (debug & DEBUG_HW_BFIFO)
+			printk(KERN_DEBUG "Dropped %d bytes - RX off\n", count);
+		val = (bch->nr - 1) & 1;
+		fc->dropcnt[val] += count;
+	} else {
+		copy = 1;
 		if (!bch->rx_skb) {
-			pr_info("%s: B receive out of memory\n",
-				fc->name);
+			if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
+				if (count >= bch->minlen)
+					cnt = count;
+				else
+					cnt = 2 * bch->minlen;
+			} else
+				cnt = bch->maxlen;
+			bch->rx_skb = mI_alloc_skb(cnt, GFP_ATOMIC);
+			if (!bch->rx_skb) {
+				pr_info("%s: B receive out of memory\n",
+					fc->name);
+				return;
+			}
+		} else
+			cnt = skb_tailroom(bch->rx_skb);
+		if (count > cnt) {
+			pr_debug("%s: overrun %d + %d free %d\n", fc->name,
+				bch->rx_skb->len, count, cnt);
 			return;
 		}
-	} else
-		cnt = skb_tailroom(bch->rx_skb);
-	if (count > cnt) {
-		pr_debug("%s: overrun %d + %d free %d\n", fc->name,
-			bch->rx_skb->len, count, cnt);
-		return;
+		p = skb_put(bch->rx_skb, count);
+		ptr = (u32 *)p;
 	}
-	p = skb_put(bch->rx_skb, count);
-	ptr = (u32 *)p;
 	if (AVM_FRITZ_PCIV2 == fc->type)
 		addr = fc->addr + (bch->nr == 2 ?
 				   AVM_HDLC_FIFO_2 : AVM_HDLC_FIFO_1);
@@ -441,11 +453,13 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	cnt = 0;
 	while (cnt < count) {
 		val = le32_to_cpu(inl(addr));
-		put_unaligned(val, ptr);
-		ptr++;
+		if (copy) {
+			put_unaligned(val, ptr);
+			ptr++;
+		}
 		cnt += 4;
 	}
-	if (debug & DEBUG_HW_BFIFO) {
+	if (copy && (debug & DEBUG_HW_BFIFO)) {
 		snprintf(fc->log, LOG_SIZE, "B%1d-recv %s %d ",
 			 bch->nr, fc->name, count);
 		print_hex_dump_bytes(fc->log, DUMP_PREFIX_OFFSET, p, count);
@@ -457,19 +471,25 @@ hdlc_fill_fifo(struct bchannel *bch)
 {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
-	int count, fs, cnt = 0;
+	int count, fs, cnt = 0, idx;
 	u8 *p;
 	u32 *ptr, val, addr;
 
-	hdlc = &fc->hdlc[(bch->nr - 1) & 1];
-	if (!bch->tx_skb)
-		return;
-	count = bch->tx_skb->len - bch->tx_idx;
-	if (count <= 0)
-		return;
+	idx = (bch->nr - 1) & 1;
+	hdlc = &fc->hdlc[idx];
 	fs = (fc->type == AVM_FRITZ_PCIV2) ?
 		HDLC_FIFO_SIZE_V2 : HDLC_FIFO_SIZE_V1;
-	p = bch->tx_skb->data + bch->tx_idx;
+	if (!bch->tx_skb) {
+		if (!test_bit(FLG_FILLEMPTY, &bch->Flags))
+			return;
+		count = fs;
+		p = fc->fill + (idx * HDLC_FIFO_SIZE_V2);
+	} else {
+		count = bch->tx_skb->len - bch->tx_idx;
+		if (count <= 0)
+			return;
+		p = bch->tx_skb->data + bch->tx_idx;
+	}
 	hdlc->ctrl.sr.cmd &= ~HDLC_CMD_XME;
 	if (count > fs) {
 		count = fs;
@@ -477,10 +497,13 @@ hdlc_fill_fifo(struct bchannel *bch)
 		if (test_bit(FLG_HDLC, &bch->Flags))
 			hdlc->ctrl.sr.cmd |= HDLC_CMD_XME;
 	}
-	pr_debug("%s: %s %d/%d/%d", fc->name, __func__, count,
-		 bch->tx_idx, bch->tx_skb->len);
 	ptr = (u32 *)p;
-	bch->tx_idx += count;
+	if (bch->tx_skb) {
+		pr_debug("%s: %s %d/%d/%d", fc->name, __func__, count,
+			bch->tx_idx, bch->tx_skb->len);
+		bch->tx_idx += count;
+	} else
+		 pr_debug("%s: %s fillempty %d\n", fc->name, __func__, count);
 	hdlc->ctrl.sr.xml = ((count == fs) ? 0 : count);
 	if (AVM_FRITZ_PCIV2 == fc->type) {
 		__write_ctrl_pciv2(fc, hdlc, bch->nr);
@@ -509,11 +532,10 @@ HDLC_irq_xpr(struct bchannel *bch)
 	if (bch->tx_skb && bch->tx_idx < bch->tx_skb->len)
 		hdlc_fill_fifo(bch);
 	else {
-		if (bch->tx_skb) {
-			/* send confirm, on trans, free on hdlc. */
+		if (bch->tx_skb)
 			dev_kfree_skb(bch->tx_skb);
-		}
-		if (get_next_bframe(bch))
+		if (get_next_bframe(bch) ||
+		    test_bit(FLG_FILLEMPTY, &bch->Flags))
 			hdlc_fill_fifo(bch);
 	}
 }
@@ -523,8 +545,9 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 {
 	struct fritzcard *fc = bch->hw;
 	int		len, fs;
-	u32		rmlMask;
+	u32		rmlMask, err;
 	struct hdlc_hw	*hdlc;
+	struct sk_buff	*skb;
 
 	hdlc = &fc->hdlc[(bch->nr - 1) & 1];
 	pr_debug("%s: ch%d stat %#x\n", fc->name, bch->nr, stat);
@@ -546,6 +569,12 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 			write_ctrl(bch, 1);
 			if (bch->rx_skb)
 				skb_trim(bch->rx_skb, 0);
+			if (test_bit(FLG_FIFO_STATUS, &bch->Flags)) {
+				skb = _alloc_mISDN_skb(PH_CONTROL_IND,
+					HW_FIFO_RDO, 0, NULL, GFP_KERNEL);
+				if (skb)
+					recv_Bchannel_skb(bch, skb);
+			}
 		} else {
 			len = (stat & rmlMask) >> 8;
 			if (!len)
@@ -575,13 +604,22 @@ handle_tx:
 		 */
 		pr_warning("%s: ch%d stat %x XDU %s\n", fc->name, bch->nr,
 			stat, bch->tx_skb ? "tx_skb" : "no tx_skb");
-		if (bch->tx_skb)
+		if (bch->tx_skb) {
 			pr_debug("%s: ch%d XDU len(%d) idx(%d) Flags(%lx)\n",
 				 fc->name, bch->nr, bch->tx_skb->len,
 				 bch->tx_idx, bch->Flags);
-		else
+			err = HW_FIFO_XDU_DATA;
+		} else {
 			pr_debug("%s: ch%d XDU no tx_skb Flags(%lx)\n",
 				 fc->name, bch->nr, bch->Flags);
+			err = HW_FIFO_XDU_NODATA;
+		}
+		if (test_bit(FLG_FIFO_STATUS, &bch->Flags)) {
+			skb = _alloc_mISDN_skb(PH_CONTROL_IND, err,
+				0, NULL, GFP_KERNEL);
+			if (skb)
+				recv_Bchannel_skb(bch, skb);
+		}
 		if (bch->tx_skb && bch->tx_skb->len) {
 			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
 				bch->tx_idx = 0;
@@ -721,6 +759,24 @@ avm_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 			    NULL, GFP_KERNEL);
 		ret = 0;
 		break;
+	case PH_CONTROL_REQ:
+		switch (hh->id) {
+		case HW_FIFO_STATUS_ON:
+			test_and_set_bit(FLG_FIFO_STATUS, &bch->Flags);
+			id = 0;
+			break;
+		case HW_FIFO_STATUS_OFF:
+			test_and_clear_bit(FLG_FIFO_STATUS, &bch->Flags);
+			id = 0;
+			break;
+		default:
+			pr_info("PH_CONTROL_REQ %x not supported\n", hh->id);
+			id = -EINVAL;
+			break;
+		}
+		_queue_data(ch, PH_CONTROL_CNF, id, 0, NULL, GFP_KERNEL);
+		ret = 0;
+		break;
 	}
 	if (!ret)
 		dev_kfree_skb(skb);
@@ -835,12 +891,39 @@ init_card(struct fritzcard *fc)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int ret = 0, o1, o2;
+	int ret = 0, o1, o2, idx;
+	u8 *p;
 	struct fritzcard *fc = bch->hw;
 
+	idx = (bch->nr - 1) & 1;
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_RX_BUFFER;
+		cq->op = MISDN_CTRL_RX_BUFFER |
+			MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY;
+		break;
+	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
+		o1 = fc->dropcnt[idx];
+		if (cq->p1) {
+			test_and_set_bit(FLG_RX_OFF, &bch->Flags);
+			fc->dropcnt[idx] = 0;
+		} else
+			test_and_clear_bit(FLG_RX_OFF, &bch->Flags);
+		cq->p2 = o1;
+		if (debug & DEBUG_HW_BCHANNEL)
+			printk(KERN_DEBUG "Bch%d RX %s\n",
+			    bch->nr, cq->p1 ? "off" : "on");
+		break;
+	case MISDN_CTRL_FILL_EMPTY: /* fill fifo, if empty */
+		p = fc->fill + (idx * HDLC_FIFO_SIZE_V2);
+		if (cq->p1) {
+			test_and_set_bit(FLG_FILLEMPTY, &bch->Flags);
+			if (cq->p2 > -1)
+				memset(p, cq->p2 & 0xff, HDLC_FIFO_SIZE_V2);
+		} else
+			test_and_clear_bit(FLG_FILLEMPTY, &bch->Flags);
+		if (debug & DEBUG_HW_BCHANNEL)
+			printk(KERN_DEBUG "FILL_EMPTY Bch%d %s val %02x\n",
+				bch->nr, cq->p1 ? "on" : "off", *p);
 		break;
 	case MISDN_CTRL_RX_BUFFER:
 		/* We return the old values */
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index 467518c..84fbcf1 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -135,6 +135,7 @@ mISDN_clear_bchannel(struct bchannel *ch)
 	test_and_clear_bit(FLG_TX_BUSY, &ch->Flags);
 	test_and_clear_bit(FLG_TX_NEXT, &ch->Flags);
 	test_and_clear_bit(FLG_ACTIVE, &ch->Flags);
+	test_and_clear_bit(FLG_RX_OFF, &ch->Flags);
 }
 EXPORT_SYMBOL(mISDN_clear_bchannel);
 
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 4f97bd3..9776edd 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -73,7 +73,9 @@
 #define FLG_LL_OK		24
 #define FLG_LL_CONN		25
 #define FLG_DTMFSEND		26
-
+/* stop sending received data upstream */
+#define FLG_RX_OFF		27
+#define FLG_FIFO_STATUS		28
 /* workq events */
 #define FLG_RECVQUEUE		30
 #define	FLG_PHCHANGE		31
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index b26de1a..89ce4ec 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		30
+#define MISDN_RELEASE		31
 
 /* primitives for information exchange
  * generell format
@@ -158,6 +158,7 @@
 #define HFC_VOL_CHANGE_RX	0x2602
 #define HFC_SPL_LOOP_ON		0x2603
 #define HFC_SPL_LOOP_OFF	0x2604
+
 /* for T30 FAX and analog modem */
 #define HW_MOD_FRM		0x4000
 #define HW_MOD_FRH		0x4001
@@ -171,6 +172,13 @@
 #define HW_MOD_READY		0x4014
 #define HW_MOD_LASTDATA		0x4015
 
+/* Debug and status via PH_CONTROL */
+#define HW_FIFO_STATUS_OFF	0x8000
+#define HW_FIFO_STATUS_ON	0x8001
+#define HW_FIFO_RDO		0x8002
+#define HW_FIFO_XDU_DATA	0x8003
+#define HW_FIFO_XDU_NODATA	0x8004
+
 /* DSP_TONE_PATT_ON parameter */
 #define TONE_OFF			0x0000
 #define TONE_GERMAN_DIALTONE		0x0001
-- 
1.7.3.4
