From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCHv2 5/7] Add L1 timer3 config control to lowlevel drivers
Date: Thu,  3 May 2012 17:47:30 +0200
Message-ID: <1336060052-27119-6-git-send-email-kkeil@linux-pingi.de>
References: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52498 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab2ECPxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 11:53:05 -0400
In-Reply-To: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |    5 ++++-
 drivers/isdn/hardware/mISDN/hfcmulti.c |    5 ++++-
 drivers/isdn/hardware/mISDN/hfcpci.c   |    5 ++++-
 drivers/isdn/hardware/mISDN/hfcsusb.c  |    6 ++++--
 drivers/isdn/hardware/mISDN/netjet.c   |    5 ++++-
 drivers/isdn/hardware/mISDN/speedfax.c |    5 ++++-
 drivers/isdn/hardware/mISDN/w6692.c    |    5 ++++-
 7 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index c0b8c96..6bf2c58 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -868,7 +868,7 @@ channel_ctrl(struct fritzcard  *fc, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_LOOP;
+		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_LOOP:
 		/* cq->channel: 0 disable, 1 B1 loop 2 B2 loop, 3 both */
@@ -878,6 +878,9 @@ channel_ctrl(struct fritzcard  *fc, struct mISDN_ctrl_req *cq)
 		}
 		ret = fc->isac.ctrl(&fc->isac, HW_TESTLOOP, cq->channel);
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = fc->isac.ctrl(&fc->isac, HW_TIMER3_VALUE, cq->p1);
+		break;
 	default:
 		pr_info("%s: %s unknown Op %x\n", fc->name, __func__, cq->op);
 		ret = -EINVAL;
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 4301331..4c128e4 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -4161,7 +4161,7 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_HFC_OP;
+		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_HFC_WD_INIT: /* init the watchdog */
 		wd_cnt = cq->p1 & 0xf;
@@ -4191,6 +4191,9 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 			       __func__);
 		HFC_outb(hc, R_BERT_WD_MD, hc->hw.r_bert_wd_md | V_WD_RES);
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = l1_event(dch->l1, HW_TIMER3_VALUE | (cq->p1 & 0xff));
+		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
 		       __func__, cq->op);
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index e2c83a2..5fe993e 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1819,7 +1819,7 @@ channel_ctrl(struct hfc_pci *hc, struct mISDN_ctrl_req *cq)
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
 		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_CONNECT |
-			MISDN_CTRL_DISCONNECT;
+			 MISDN_CTRL_DISCONNECT | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_LOOP:
 		/* channel 0 disabled loop */
@@ -1896,6 +1896,9 @@ channel_ctrl(struct hfc_pci *hc, struct mISDN_ctrl_req *cq)
 		Write_hfc(hc, HFCPCI_CONNECT, hc->hw.conn);
 		hc->hw.trm &= 0x7f;	/* disable IOM-loop */
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = l1_event(hc->dch.l1, HW_TIMER3_VALUE | (cq->p1 & 0xff));
+		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
 		       __func__, cq->op);
diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 8cde2a0..100784e 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -525,8 +525,10 @@ channel_ctrl(struct hfcsusb *hw, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_CONNECT |
-			MISDN_CTRL_DISCONNECT;
+		cq->op = MISDN_CTRL_L1_TIMER3;
+		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = l1_event(hw->dch.l1, HW_TIMER3_VALUE | (cq->p1 & 0xff));
 		break;
 	default:
 		printk(KERN_WARNING "%s: %s: unknown Op %x\n",
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index c726e09..27998d7 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -837,7 +837,7 @@ channel_ctrl(struct tiger_hw *card, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_LOOP;
+		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_LOOP:
 		/* cq->channel: 0 disable, 1 B1 loop 2 B2 loop, 3 both */
@@ -847,6 +847,9 @@ channel_ctrl(struct tiger_hw *card, struct mISDN_ctrl_req *cq)
 		}
 		ret = card->isac.ctrl(&card->isac, HW_TESTLOOP, cq->channel);
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = card->isac.ctrl(&card->isac, HW_TIMER3_VALUE, cq->p1);
+		break;
 	default:
 		pr_info("%s: %s unknown Op %x\n", card->name, __func__, cq->op);
 		ret = -EINVAL;
diff --git a/drivers/isdn/hardware/mISDN/speedfax.c b/drivers/isdn/hardware/mISDN/speedfax.c
index 0468993..93f344d 100644
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -224,7 +224,7 @@ channel_ctrl(struct sfax_hw  *sf, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_LOOP;
+		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_LOOP:
 		/* cq->channel: 0 disable, 1 B1 loop 2 B2 loop, 3 both */
@@ -234,6 +234,9 @@ channel_ctrl(struct sfax_hw  *sf, struct mISDN_ctrl_req *cq)
 		}
 		ret = sf->isac.ctrl(&sf->isac, HW_TESTLOOP, cq->channel);
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = sf->isac.ctrl(&sf->isac, HW_TIMER3_VALUE, cq->p1);
+		break;
 	default:
 		pr_info("%s: unknown Op %x\n", sf->name, cq->op);
 		ret = -EINVAL;
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 2183357..1d04467 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1035,7 +1035,10 @@ channel_ctrl(struct w6692_hw *card, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = 0;
+		cq->op = MISDN_CTRL_L1_TIMER3;
+		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = l1_event(card->dch.l1, HW_TIMER3_VALUE | (cq->p1 & 0xff));
 		break;
 	default:
 		pr_info("%s: unknown CTRL OP %x\n", card->name, cq->op);
-- 
1.7.3.4
