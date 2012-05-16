From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH v2 3/8] mISDN: avmfritz use the bigger fifo of chip version 2
Date: Wed, 16 May 2012 11:51:03 +0200
Message-ID: <1337161868-19399-4-git-send-email-kkeil@linux-pingi.de>
References: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:62633 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966825Ab2EPKA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 06:00:27 -0400
In-Reply-To: <1337161868-19399-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we detect the latest hardware revision we should use the bigger fifo
to avoid TX underruns and have less interrupts.
TX underruns should be logged as warning.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |   68 +++++++++++++++++++-------------
 1 files changed, 41 insertions(+), 27 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 788b9a7..cc78264 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -30,7 +30,7 @@
 #include "ipac.h"
 
 
-#define AVMFRITZ_REV	"2.1"
+#define AVMFRITZ_REV	"2.2"
 
 static int AVM_cnt;
 static int debug;
@@ -69,6 +69,7 @@ enum {
 #define HDLC_MODE_TRANS		0x02
 #define HDLC_MODE_CCR_7		0x04
 #define HDLC_MODE_CCR_16	0x08
+#define HDLC_FIFO_SIZE_128	0x20
 #define HDLC_MODE_TESTLOOP	0x80
 
 #define HDLC_INT_XPR		0x80
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
+	mode = (fc->type == AVM_FRITZ_PCIV2) ? HDLC_FIFO_SIZE_128 : 0;
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
@@ -416,7 +423,7 @@ hdlc_empty_fifo(struct bchannel *bch, int count)
 	}
 	p = skb_put(bch->rx_skb, count);
 	ptr = (u32 *)p;
-	if (AVM_FRITZ_PCIV2 == fc->type)
+	if (fc->type == AVM_FRITZ_PCIV2)
 		addr = fc->addr + (bch->nr == 2 ?
 				   AVM_HDLC_FIFO_2 : AVM_HDLC_FIFO_1);
 	else {
@@ -441,7 +448,7 @@ hdlc_fill_fifo(struct bchannel *bch)
 {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
-	int count, cnt = 0;
+	int count, fs, cnt = 0;
 	u8 *p;
 	u32 *ptr, val, addr;
 
@@ -451,10 +458,12 @@ hdlc_fill_fifo(struct bchannel *bch)
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
@@ -463,8 +472,8 @@ hdlc_fill_fifo(struct bchannel *bch)
 		 bch->tx_idx, bch->tx_skb->len);
 	ptr = (u32 *)p;
 	bch->tx_idx += count;
-	hdlc->ctrl.sr.xml = ((count == HDLC_FIFO_SIZE) ? 0 : count);
-	if (AVM_FRITZ_PCIV2 == fc->type) {
+	hdlc->ctrl.sr.xml = ((count == fs) ? 0 : count);
+	if (fc->type == AVM_FRITZ_PCIV2) {
 		__write_ctrl_pciv2(fc, hdlc, bch->nr);
 		addr = fc->addr + (bch->nr == 2 ?
 				   AVM_HDLC_FIFO_2 : AVM_HDLC_FIFO_1);
@@ -502,13 +511,23 @@ static void
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
@@ -517,21 +536,21 @@ HDLC_irq(struct bchannel *bch, u32 stat)
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
+			if (test_bit(FLG_TRANSPARENT, &bch->Flags) ||
+			    (stat & HDLC_STAT_RME)) {
 				if (((stat & HDLC_STAT_CRCVFRRAB) ==
 				     HDLC_STAT_CRCVFR) ||
 				    test_bit(FLG_TRANSPARENT, &bch->Flags)) {
 					recv_Bchannel(bch, 0);
 				} else {
-					pr_debug("%s: got invalid frame\n",
-						 fc->name);
+					pr_warning("%s: got invalid frame\n",
+						   fc->name);
 					skb_trim(bch->rx_skb, 0);
 				}
 			}
@@ -543,13 +562,8 @@ handle_tx:
 		 * restart transmitting the whole frame on HDLC
 		 * in transparent mode we send the next data
 		 */
-		if (bch->tx_skb)
-			pr_debug("%s: ch%d XDU len(%d) idx(%d) Flags(%lx)\n",
-				 fc->name, bch->nr, bch->tx_skb->len,
-				 bch->tx_idx, bch->Flags);
-		else
-			pr_debug("%s: ch%d XDU no tx_skb Flags(%lx)\n",
-				 fc->name, bch->nr, bch->Flags);
+		pr_warning("%s: ch%d stat %x XDU %s\n", fc->name, bch->nr,
+			   stat, bch->tx_skb ? "tx_skb" : "no tx_skb");
 		if (bch->tx_skb && bch->tx_skb->len) {
 			if (!test_bit(FLG_TRANSPARENT, &bch->Flags))
 				bch->tx_idx = 0;
@@ -774,7 +788,7 @@ init_card(struct fritzcard *fc)
 		inithdlc(fc);
 		enable_hwirq(fc);
 		/* RESET Receiver and Transmitter */
-		if (AVM_FRITZ_PCIV2 == fc->type) {
+		if (fc->type == AVM_FRITZ_PCIV2) {
 			WriteISAC_V2(fc, ISACX_MASK, 0);
 			WriteISAC_V2(fc, ISACX_CMDRD, 0x41);
 		} else {
-- 
1.7.3.4
