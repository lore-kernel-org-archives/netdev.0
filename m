From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 5/8] mISDN: Make layer1 timer 3 value configurable
Date: Sat, 28 Apr 2012 13:43:21 +0200
Message-ID: <1335613404-10187-6-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:53795 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab2D1LrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:23 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

For certification test it is very useful to change the layer1
timer3 value on runtime.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/layer1.c |   16 ++++++++++++++--
 include/linux/mISDNhw.h     |    3 +++
 include/linux/mISDNif.h     |    3 ++-
 3 files changed, 19 insertions(+), 3 deletions(-)

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
index 74d5734..7075753 100644
--- a/include/linux/mISDNhw.h
+++ b/include/linux/mISDNhw.h
@@ -136,6 +136,9 @@ extern int	create_l1(struct dchannel *, dchannel_l1callback *);
 #define HW_TESTRX_RAW	0x9602
 #define HW_TESTRX_HDLC	0x9702
 #define HW_TESTRX_OFF	0x9802
+#define HW_TIMER3_IND	0x9902
+#define HW_TIMER3_VALUE	0x9a00
+#define HW_TIMER3_VMASK	0x00FF
 
 struct layer1;
 extern int	l1_event(struct layer1 *, u_int);
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index b7457e8..322d316 100644
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
@@ -374,6 +374,7 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_RX_OFF		0x0100
 #define MISDN_CTRL_FILL_EMPTY		0x0200
 #define MISDN_CTRL_GETPEER		0x0400
+#define MISDN_CTRL_L1_TIMER3		0x0800
 #define MISDN_CTRL_HW_FEATURES_OP	0x2000
 #define MISDN_CTRL_HW_FEATURES		0x2001
 #define MISDN_CTRL_HFC_OP		0x4000
-- 
1.7.3.4
