From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCHv3 4/6] mISDN: Make layer1 timer 3 value configurable
Date: Fri,  4 May 2012 16:15:33 +0200
Message-ID: <1336140935-25830-5-git-send-email-kkeil@linux-pingi.de>
References: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:65037 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477Ab2EDOVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:21:25 -0400
In-Reply-To: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

For certification test it is very useful to change the layer1
timer3 value on runtime.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |    5 ++++-
 drivers/isdn/hardware/mISDN/hfcmulti.c  |    5 ++++-
 drivers/isdn/hardware/mISDN/hfcpci.c    |    5 ++++-
 drivers/isdn/hardware/mISDN/mISDNipac.c |   17 ++++++++++++-----
 drivers/isdn/hardware/mISDN/netjet.c    |    5 ++++-
 drivers/isdn/hardware/mISDN/speedfax.c  |    5 ++++-
 drivers/isdn/hardware/mISDN/w6692.c     |    5 ++++-
 drivers/isdn/mISDN/layer1.c             |   16 ++++++++++++++--
 include/linux/mISDNhw.h                 |    3 +++
 include/linux/mISDNif.h                 |    3 ++-
 10 files changed, 55 insertions(+), 14 deletions(-)

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
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 884369f..92d4a78 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -603,10 +603,11 @@ isac_l1hw(struct mISDNchannel *ch, struct sk_buff *skb)
 }
 
 static int
-isac_ctrl(struct isac_hw *isac, u32 cmd, u_long para)
+isac_ctrl(struct isac_hw *isac, u32 cmd, unsigned long para)
 {
 	u8 tl = 0;
-	u_long flags;
+	unsigned long flags;
+	int ret = 0;
 
 	switch (cmd) {
 	case HW_TESTLOOP:
@@ -626,12 +627,15 @@ isac_ctrl(struct isac_hw *isac, u32 cmd, u_long para)
 		}
 		spin_unlock_irqrestore(isac->hwlock, flags);
 		break;
+	case HW_TIMER3_VALUE:
+		ret = l1_event(isac->dch.l1, HW_TIMER3_VALUE | (para & 0xff));
+		break;
 	default:
 		pr_debug("%s: %s unknown command %x %lx\n", isac->name,
 			 __func__, cmd, para);
-		return -1;
+		ret = -1;
 	}
-	return 0;
+	return ret;
 }
 
 static int
@@ -1526,7 +1530,7 @@ channel_ctrl(struct ipac_hw *ipac, struct mISDN_ctrl_req *cq)
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_LOOP;
+		cq->op = MISDN_CTRL_LOOP | MISDN_CTRL_L1_TIMER3;
 		break;
 	case MISDN_CTRL_LOOP:
 		/* cq->channel: 0 disable, 1 B1 loop 2 B2 loop, 3 both */
@@ -1536,6 +1540,9 @@ channel_ctrl(struct ipac_hw *ipac, struct mISDN_ctrl_req *cq)
 		}
 		ret = ipac->ctrl(ipac, HW_TESTLOOP, cq->channel);
 		break;
+	case MISDN_CTRL_L1_TIMER3:
+		ret = ipac->isac.ctrl(&ipac->isac, HW_TIMER3_VALUE, cq->p1);
+		break;
 	default:
 		pr_info("%s: unknown CTRL OP %x\n", ipac->name, cq->op);
 		ret = -EINVAL;
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
diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
index 0fc49b3..ff05153 100644
--- a/drivers/isdn/mISDN/layer1.c
+++ b/drivers/isdn/mISDN/layer1.c
@@ -30,11 +30,12 @@ struct layer1 {
 	struct FsmInst l1m;
 	struct FsmTimer timer;
 	int delay;
+	int t3_value;
 	struct dchannel *dch;
 	dchannel_l1callback *dcb;
 };
 
-#define TIMER3_VALUE 7000
+#define TIMER3_DEFAULT_VALUE	7000
 
 static
 struct Fsm l1fsm_s = {NULL, 0, 0, NULL, NULL};
@@ -233,7 +234,7 @@ l1_activate_s(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer1 *l1 = fi->userdata;
 
-	mISDN_FsmRestartTimer(&l1->timer, TIMER3_VALUE, EV_TIMER3, NULL, 2);
+	mISDN_FsmRestartTimer(&l1->timer, l1->t3_value, EV_TIMER3, NULL, 2);
 	test_and_set_bit(FLG_L1_T3RUN, &l1->Flags);
 	l1->dcb(l1->dch, HW_RESET_REQ);
 }
@@ -356,6 +357,16 @@ l1_event(struct layer1 *l1, u_int event)
 		release_l1(l1);
 		break;
 	default:
+		if ((event & ~HW_TIMER3_VMASK) == HW_TIMER3_VALUE) {
+			int val = event & HW_TIMER3_VMASK;
+
+			if (val < 5)
+				val = 5;
+			if (val > 30)
+				val = 30;
+			l1->t3_value = val;
+			break;
+		}
 		if (*debug & DEBUG_L1)
 			printk(KERN_DEBUG "%s %x unhandled\n",
 			       __func__, event);
@@ -377,6 +388,7 @@ create_l1(struct dchannel *dch, dchannel_l1callback *dcb) {
 	nl1->l1m.fsm = &l1fsm_s;
 	nl1->l1m.state = ST_L1_F3;
 	nl1->Flags = 0;
+	nl1->t3_value = TIMER3_DEFAULT_VALUE;
 	nl1->l1m.debug = *debug & DEBUG_L1_FSM;
 	nl1->l1m.userdata = nl1;
 	nl1->l1m.userint = 0;
diff --git a/include/linux/mISDNhw.h b/include/linux/mISDNhw.h
index 4af8414..de165b5 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -135,6 +135,9 @@ extern int	create_l1(struct dchannel *, dchannel_l1callback *);
 #define HW_TESTRX_RAW	0x9602
 #define HW_TESTRX_HDLC	0x9702
 #define HW_TESTRX_OFF	0x9802
+#define HW_TIMER3_IND	0x9902
+#define HW_TIMER3_VALUE	0x9a00
+#define HW_TIMER3_VMASK	0x00FF
 
 struct layer1;
 extern int	l1_event(struct layer1 *, u_int);
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index b80f764..9cc8ce5 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		26
+#define MISDN_RELEASE		27
 
 /* primitives for information exchange
  * generell format
@@ -372,6 +372,7 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_RX_OFF		0x0100
 #define MISDN_CTRL_FILL_EMPTY		0x0200
 #define MISDN_CTRL_GETPEER		0x0400
+#define MISDN_CTRL_L1_TIMER3		0x0800
 #define MISDN_CTRL_HW_FEATURES_OP	0x2000
 #define MISDN_CTRL_HW_FEATURES		0x2001
 #define MISDN_CTRL_HFC_OP		0x4000
-- 
1.7.3.4
