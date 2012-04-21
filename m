From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 20/28] mISDN: Allow the driver to set a minimum length for transparent data
Date: Sat, 21 Apr 2012 17:19:36 +0200
Message-ID: <20120423170551.4F5379FB98@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:64513 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab2DWRIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is usefull for better flow control and will
avoid very short messages to upper layer.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   88 +++++++++++++++++++++----------
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    4 +-
 drivers/isdn/hardware/mISDN/hfcpci.c    |    2 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c   |    2 +-
 drivers/isdn/hardware/mISDN/mISDNipac.c |   25 ++++++---
 drivers/isdn/hardware/mISDN/mISDNisar.c |    2 +-
 drivers/isdn/hardware/mISDN/netjet.c    |    2 +-
 drivers/isdn/hardware/mISDN/w6692.c     |    2 +-
 drivers/isdn/mISDN/hwchannel.c          |    3 +-
 drivers/isdn/mISDN/l1oip_core.c         |    2 +-
 include/linux/mISDNhw.h                 |    3 +-
 11 files changed, 90 insertions(+), 45 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index c773a7f..4b1c86e 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -30,7 +30,7 @@
 #include "ipac.h"
 
 
-#define AVMFRITZ_REV	"2.1"
+#define AVMFRITZ_REV	"2.2"
 
 static int AVM_cnt;
 static int debug;
@@ -69,7 +69,8 @@ enum {
 #define HDLC_MODE_TRANS		0x02
 #define HDLC_MODE_CCR_7		0x04
 #define HDLC_MODE_CCR_16	0x08
-#define HDLC_MODE_TESTLOOP	0x80
+#define HDLC_FIFO_SIZE_128	0x20
+#define HDLC_MODE_TESTLOOP_V1	0x80
 
 #define HDLC_INT_XPR		0x80
 #define HDLC_INT_XDU		0x40
@@ -80,13 +81,16 @@ enum {
 #define HDLC_STAT_RDO		0x10
 #define HDLC_STAT_CRCVFRRAB	0x0E
 #define HDLC_STAT_CRCVFR	0x06
-#define HDLC_STAT_RML_MASK	0x3f00
+#define HDLC_STAT_RML_MASK_V1	0x3f00
+#define HDLC_STAT_RML_MASK_V2	0x7f00
 
 #define HDLC_CMD_XRS		0x80
 #define HDLC_CMD_XME		0x01
 #define HDLC_CMD_RRS		0x20
 #define HDLC_CMD_XML_MASK	0x3f00
-#define HDLC_FIFO_SIZE		32
+
+#define HDLC_FIFO_SIZE_V1	32
+#define HDLC_FIFO_SIZE_V2	128
 
 /* Fritz PCI v2.0 */
 
@@ -346,11 +350,14 @@ modehdlc(struct bchannel *bch, int protocol)
 {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
+	u8 mode;
 
 	hdlc = &fc->hdlc[(bch->nr - 1) & 1];
 	pr_debug("%s: hdlc %c protocol %x-->%x ch %d\n", fc->name,
 		 '@' + bch->nr, bch->state, protocol, bch->nr);
 	hdlc->ctrl.ctrl = 0;
+	mode = (AVM_FRITZ_PCIV2 == fc->type) ? HDLC_FIFO_SIZE_128 : 0;
+
 	switch (protocol) {
 	case -1: /* used for init */
 		bch->state = -1;
@@ -358,7 +365,7 @@ modehdlc(struct bchannel *bch, int protocol)
 		if (bch->state == ISDN_P_NONE)
 			break;
 		hdlc->ctrl.sr.cmd  = HDLC_CMD_XRS | HDLC_CMD_RRS;
-		hdlc->ctrl.sr.mode = HDLC_MODE_TRANS;
+		hdlc->ctrl.sr.mode = mode | HDLC_MODE_TRANS;
 		write_ctrl(bch, 5);
 		bch->state = ISDN_P_NONE;
 		test_and_clear_bit(FLG_HDLC, &bch->Flags);
@@ -367,7 +374,7 @@ modehdlc(struct bchannel *bch, int protocol)
 	case ISDN_P_B_RAW:
 		bch->state = protocol;
 		hdlc->ctrl.sr.cmd  = HDLC_CMD_XRS | HDLC_CMD_RRS;
-		hdlc->ctrl.sr.mode = HDLC_MODE_TRANS;
+		hdlc->ctrl.sr.mode = mode | HDLC_MODE_TRANS;
 		write_ctrl(bch, 5);
 		hdlc->ctrl.sr.cmd = HDLC_CMD_XRS;
 		write_ctrl(bch, 1);
@@ -377,7 +384,7 @@ modehdlc(struct bchannel *bch, int protocol)
 	case ISDN_P_B_HDLC:
 		bch->state = protocol;
 		hdlc->ctrl.sr.cmd  = HDLC_CMD_XRS | HDLC_CMD_RRS;
-		hdlc->ctrl.sr.mode = HDLC_MODE_ITF_FLG;
+		hdlc->ctrl.sr.mode = mode | HDLC_MODE_ITF_FLG;
 		write_ctrl(bch, 5);
 		hdlc->ctrl.sr.cmd = HDLC_CMD_XRS;
 		write_ctrl(bch, 1);
@@ -397,21 +404,29 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	u32 *ptr;
 	u8 *p;
 	u32  val, addr;
-	int cnt = 0;
+	int cnt;
 	struct fritzcard *fc = bch->hw;
 
 	pr_debug("%s: %s %d\n", fc->name, __func__, count);
 	if (!bch->rx_skb) {
-		bch->rx_skb = mI_alloc_skb(bch->maxlen, GFP_ATOMIC);
+		if (test_bit(FLG_TRANSPARENT, &bch->Flags)) {
+			if (count >= bch->minlen)
+				cnt = count;
+			else
+				cnt = 2 * bch->minlen;
+		} else
+			cnt = bch->maxlen;
+		bch->rx_skb = mI_alloc_skb(cnt, GFP_ATOMIC);
 		if (!bch->rx_skb) {
 			pr_info("%s: B receive out of memory\n",
 				fc->name);
 			return;
 		}
-	}
-	if ((bch->rx_skb->len + count) > bch->maxlen) {
-		pr_debug("%s: overrun %d\n", fc->name,
-			 bch->rx_skb->len + count);
+	} else
+		cnt = skb_tailroom(bch->rx_skb);
+	if (count > cnt) {
+		pr_debug("%s: overrun %d + %d free %d\n", fc->name,
+			bch->rx_skb->len, count, cnt);
 		return;
 	}
 	p = skb_put(bch->rx_skb, count);
@@ -423,6 +438,7 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 		addr = fc->addr + CHIP_WINDOW;
 		outl(bch->nr == 2 ? AVM_HDLC_2 : AVM_HDLC_1, fc->addr);
 	}
+	cnt = 0;
 	while (cnt < count) {
 		val = le32_to_cpu(inl(addr));
 		put_unaligned(val, ptr);
@@ -441,7 +457,7 @@ hdlc_fill_fifo(struct bchannel *bch)
 {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
-	int count, cnt = 0;
+	int count, fs, cnt = 0;
 	u8 *p;
 	u32 *ptr, val, addr;
 
@@ -451,10 +467,12 @@ hdlc_fill_fifo(struct bchannel *bch)
 	count = bch->tx_skb->len - bch->tx_idx;
 	if (count <= 0)
 		return;
+	fs = (fc->type == AVM_FRITZ_PCIV2) ?
+		HDLC_FIFO_SIZE_V2 : HDLC_FIFO_SIZE_V1;
 	p = bch->tx_skb->data + bch->tx_idx;
 	hdlc->ctrl.sr.cmd &= ~HDLC_CMD_XME;
-	if (count > HDLC_FIFO_SIZE) {
-		count = HDLC_FIFO_SIZE;
+	if (count > fs) {
+		count = fs;
 	} else {
 		if (test_bit(FLG_HDLC, &bch->Flags))
 			hdlc->ctrl.sr.cmd |= HDLC_CMD_XME;
@@ -463,7 +481,7 @@ hdlc_fill_fifo(struct bchannel *bch)
 		 bch->tx_idx, bch->tx_skb->len);
 	ptr = (u32 *)p;
 	bch->tx_idx += count;
-	hdlc->ctrl.sr.xml = ((count == HDLC_FIFO_SIZE) ? 0 : count);
+	hdlc->ctrl.sr.xml = ((count == fs) ? 0 : count);
 	if (AVM_FRITZ_PCIV2 == fc->type) {
 		__write_ctrl_pciv2(fc, hdlc, bch->nr);
 		addr = fc->addr + (bch->nr == 2 ?
@@ -493,8 +511,6 @@ HDLC_irq_xpr(struct bchannel *bch)
 	else {
 		if (bch->tx_skb) {
 			/* send confirm, on trans, free on hdlc. */
-			if (test_bit(FLG_TRANSPARENT, &bch->Flags))
-				confirm_Bsend(bch);
 			dev_kfree_skb(bch->tx_skb);
 		}
 		if (get_next_bframe(bch))
@@ -506,13 +522,23 @@ static void
 HDLC_irq(struct bchannel *bch, u32 stat)
 {
 	struct fritzcard *fc = bch->hw;
-	int		len;
+	int		len, fs;
+	u32		rmlMask;
 	struct hdlc_hw	*hdlc;
 
 	hdlc = &fc->hdlc[(bch->nr - 1) & 1];
 	pr_debug("%s: ch%d stat %#x\n", fc->name, bch->nr, stat);
+	if (fc->type == AVM_FRITZ_PCIV2) {
+		rmlMask = HDLC_STAT_RML_MASK_V2;
+		fs = HDLC_FIFO_SIZE_V2;
+	} else {
+		rmlMask = HDLC_STAT_RML_MASK_V1;
+		fs = HDLC_FIFO_SIZE_V1;
+	}
 	if (stat & HDLC_INT_RPR) {
 		if (stat & HDLC_STAT_RDO) {
+			pr_warning("%s: ch%d stat %x RDO\n",
+				   fc->name, bch->nr, stat);
 			hdlc->ctrl.sr.xml = 0;
 			hdlc->ctrl.sr.cmd |= HDLC_CMD_RRS;
 			write_ctrl(bch, 1);
@@ -521,20 +547,20 @@ HDLC_irq(struct bchannel *bch, u32 stat)
 			if (bch->rx_skb)
 				skb_trim(bch->rx_skb, 0);
 		} else {
-			len = (stat & HDLC_STAT_RML_MASK) >> 8;
+			len = (stat & rmlMask) >> 8;
 			if (!len)
-				len = 32;
+				len = fs;
 			hdlc_empty_fifo(bch, len);
 			if (!bch->rx_skb)
 				goto handle_tx;
-			if ((stat & HDLC_STAT_RME) || test_bit(FLG_TRANSPARENT,
-							       &bch->Flags)) {
+			if ((stat & HDLC_STAT_RME) || (test_bit(FLG_TRANSPARENT,
+			    &bch->Flags) && bch->rx_skb->len >= bch->minlen)) {
 				if (((stat & HDLC_STAT_CRCVFRRAB) ==
 				     HDLC_STAT_CRCVFR) ||
 				    test_bit(FLG_TRANSPARENT, &bch->Flags)) {
 					recv_Bchannel(bch, 0);
 				} else {
-					pr_debug("%s: got invalid frame\n",
+					pr_warning("%s: got invalid frame\n",
 						 fc->name);
 					skb_trim(bch->rx_skb, 0);
 				}
@@ -547,6 +573,8 @@ handle_tx:
 		 * restart transmitting the whole frame on HDLC
 		 * in transparent mode we send the next data
 		 */
+		pr_warning("%s: ch%d stat %x XDU %s\n", fc->name, bch->nr,
+			stat, bch->tx_skb ? "tx_skb" : "no tx_skb");
 		if (bch->tx_skb)
 			pr_debug("%s: ch%d XDU len(%d) idx(%d) Flags(%lx)\n",
 				 fc->name, bch->nr, bch->tx_skb->len,
@@ -643,7 +671,7 @@ avm_fritzv2_interrupt(int intno, void *dev_id)
 		mISDNisac_irq(&fc->isac, val);
 	}
 	if (sval & AVM_STATUS0_IRQ_TIMER) {
-		pr_debug("%s: timer irq\n", fc->name);
+		pr_debug("%s: sval(%x) - timer irq\n", fc->name, sval);
 		outb(fc->ctrlreg | AVM_STATUS0_RES_TIMER, fc->addr + 2);
 		udelay(1);
 		outb(fc->ctrlreg, fc->addr + 2);
@@ -1013,7 +1041,7 @@ release_card(struct fritzcard *card)
 static int __devinit
 setup_instance(struct fritzcard *card)
 {
-	int i, err;
+	int i, err, minsize;
 	u_long flags;
 
 	snprintf(card->name, MISDN_MAX_IDLEN - 1, "AVM.%d", AVM_cnt + 1);
@@ -1033,7 +1061,11 @@ setup_instance(struct fritzcard *card)
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
index d826586..884c090 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5175,7 +5175,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m, int pt)
 		bch->nr = ch;
 		bch->slot = ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, -1);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = hfcm_bctrl;
@@ -5248,7 +5248,7 @@ init_multi_port(struct hfc_multi *hc, int pt)
 		bch->nr = ch + 1;
 		bch->slot = i + ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, -1);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = hfcm_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 6a0d964..76bb800 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2117,7 +2117,7 @@ setup_card(struct hfc_pci *card)
 		card->bch[i].nr = i + 1;
 		set_channelmap(i + 1, card->dch.dev.channelmap);
 		card->bch[i].debug = debug;
-		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bch[i], MAX_DATA_MEM, -1);
 		card->bch[i].hw = card;
 		card->bch[i].ch.send = hfcpci_l2l1B;
 		card->bch[i].ch.ctrl = hfc_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 404184a..3c20b4f 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -1876,7 +1876,7 @@ setup_instance(struct hfcsusb *hw, struct device *parent)
 		hw->bch[i].nr = i + 1;
 		set_channelmap(i + 1, hw->dch.dev.channelmap);
 		hw->bch[i].debug = debug;
-		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM);
+		mISDN_initbchannel(&hw->bch[i], MAX_DATA_MEM, -1);
 		hw->bch[i].hw = hw;
 		hw->bch[i].ch.send = hfcusb_l2l1B;
 		hw->bch[i].ch.ctrl = hfc_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index d301d8c..1bc75ae 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -929,20 +929,29 @@ static void
 hscx_empty_fifo(struct hscx_hw *hscx, u8 count)
 {
 	u8 *p;
+	int len;
 
 	pr_debug("%s: B%1d %d\n", hscx->ip->name, hscx->bch.nr, count);
 	if (!hscx->bch.rx_skb) {
-		hscx->bch.rx_skb = mI_alloc_skb(hscx->bch.maxlen, GFP_ATOMIC);
+		if (test_bit(FLG_TRANSPARENT, &hscx->bch.Flags)) {
+			if (count >= hscx->bch.minlen)
+				len = count;
+			else
+				len = 2 * hscx->bch.minlen;
+		} else
+			len = hscx->bch.maxlen;
+		hscx->bch.rx_skb = mI_alloc_skb(len, GFP_ATOMIC);
 		if (!hscx->bch.rx_skb) {
 			pr_info("%s: B receive out of memory\n",
 				hscx->ip->name);
 			hscx_cmdr(hscx, 0x80); /* RMC */
 			return;
 		}
-	}
-	if ((hscx->bch.rx_skb->len + count) > hscx->bch.maxlen) {
-		pr_debug("%s: overrun %d\n", hscx->ip->name,
-			 hscx->bch.rx_skb->len + count);
+	} else
+		len = skb_tailroom(hscx->bch.rx_skb);
+	if (count > len) {
+		pr_debug("%s: overrun  %d + %d free %d\n", hscx->ip->name,
+			hscx->bch.rx_skb->len, count, len);
 		skb_trim(hscx->bch.rx_skb, 0);
 		hscx_cmdr(hscx, 0x80); /* RMC */
 		return;
@@ -1122,7 +1131,8 @@ ipac_irq(struct hscx_hw *hx, u8 ista)
 		hscx_empty_fifo(hx, hx->fifo_size);
 		if (test_bit(FLG_TRANSPARENT, &hx->bch.Flags)) {
 			/* receive transparent audio data */
-			if (hx->bch.rx_skb)
+			if (hx->bch.rx_skb &&
+			    (hx->bch.rx_skb->len >= hx->bch.minlen))
 				recv_Bchannel(&hx->bch, 0);
 		}
 	}
@@ -1613,7 +1623,8 @@ mISDNipac_init(struct ipac_hw *ipac, void *hw)
 		set_channelmap(i + 1, ipac->isac.dch.dev.channelmap);
 		list_add(&ipac->hscx[i].bch.ch.list,
 			 &ipac->isac.dch.dev.bchannels);
-		mISDN_initbchannel(&ipac->hscx[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&ipac->hscx[i].bch, MAX_DATA_MEM,
+			ipac->hscx[i].fifo_size);
 		ipac->hscx[i].bch.ch.nr = i + 1;
 		ipac->hscx[i].bch.ch.send = &hscx_l2l1;
 		ipac->hscx[i].bch.ch.ctrl = hscx_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 8db914a..202bd92 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1683,7 +1683,7 @@ mISDNisar_init(struct isar_hw *isar, void *hw)
 	isar->hw = hw;
 	for (i = 0; i < 2; i++) {
 		isar->ch[i].bch.nr = i + 1;
-		mISDN_initbchannel(&isar->ch[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&isar->ch[i].bch, MAX_DATA_MEM, -1);
 		isar->ch[i].bch.ch.nr = i + 1;
 		isar->ch[i].bch.ch.send = &isar_l2l1;
 		isar->ch[i].bch.ch.ctrl = isar_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index fd421e7..3c5d704 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1020,7 +1020,7 @@ setup_instance(struct tiger_hw *card)
 	for (i = 0; i < 2; i++) {
 		card->bc[i].bch.nr = i + 1;
 		set_channelmap(i + 1, card->isac.dch.dev.channelmap);
-		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM, -1);
 		card->bc[i].bch.hw = card;
 		card->bc[i].bch.ch.send = nj_l2l1B;
 		card->bc[i].bch.ch.ctrl = nj_bctrl;
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 0424652..a506018 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1312,7 +1312,7 @@ setup_instance(struct w6692_hw *card)
 	card->dch.hw = card;
 	card->dch.dev.nrbchan = 2;
 	for (i = 0; i < 2; i++) {
-		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM);
+		mISDN_initbchannel(&card->bc[i].bch, MAX_DATA_MEM, -1);
 		card->bc[i].bch.hw = card;
 		card->bc[i].bch.nr = i + 1;
 		card->bc[i].bch.ch.nr = i + 1;
diff --git a/drivers/isdn/mISDN/hwchannel.c b/drivers/isdn/mISDN/hwchannel.c
index a250244..467518c 100644
--- a/drivers/isdn/mISDN/hwchannel.c
+++ b/drivers/isdn/mISDN/hwchannel.c
@@ -81,7 +81,7 @@ mISDN_initdchannel(struct dchannel *ch, int maxlen, void *phf)
 EXPORT_SYMBOL(mISDN_initdchannel);
 
 int
-mISDN_initbchannel(struct bchannel *ch, int maxlen)
+mISDN_initbchannel(struct bchannel *ch, int maxlen, int minlen)
 {
 	ch->Flags = 0;
 	ch->maxlen = maxlen;
@@ -89,6 +89,7 @@ mISDN_initbchannel(struct bchannel *ch, int maxlen)
 	ch->rx_skb = NULL;
 	ch->tx_skb = NULL;
 	ch->tx_idx = 0;
+	ch->minlen = minlen;
 	skb_queue_head_init(&ch->rqueue);
 	ch->rcount = 0;
 	ch->next_skb = NULL;
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 0f88acf..f68abe8 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -1420,7 +1420,7 @@ init_card(struct l1oip *hc, int pri, int bundle)
 		bch->nr = i + ch;
 		bch->slot = i + ch;
 		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		mISDN_initbchannel(bch, MAX_DATA_MEM, -1);
 		bch->hw = hc;
 		bch->ch.send = handle_bmsg;
 		bch->ch.ctrl = l1oip_bctrl;
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 7075753..4f97bd3 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -158,6 +158,7 @@ struct bchannel {
 	/* receive data */
 	struct sk_buff		*rx_skb;
 	int			maxlen;
+	int			minlen; /* for transparent data -1 no check */
 	/* send data */
 	struct sk_buff		*next_skb;
 	struct sk_buff		*tx_skb;
@@ -172,7 +173,7 @@ struct bchannel {
 };
 
 extern int	mISDN_initdchannel(struct dchannel *, int, void *);
-extern int	mISDN_initbchannel(struct bchannel *, int);
+extern int	mISDN_initbchannel(struct bchannel *, int, int);
 extern int	mISDN_freedchannel(struct dchannel *);
 extern void	mISDN_clear_bchannel(struct bchannel *);
 extern int	mISDN_freebchannel(struct bchannel *);
-- 
1.7.3.4
