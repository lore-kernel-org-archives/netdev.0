From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 6/8] mISDN: Layer1 statemachine fix
Date: Sat, 28 Apr 2012 13:43:22 +0200
Message-ID: <1335613404-10187-7-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:62360 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab2D1Lr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:29 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

The timer3 and the activation delay timer need to be
independent.
Now layer1 pass TBR3 again.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/layer1.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
index ff05153..ee16e03 100644
--- a/drivers/isdn/mISDN/layer1.c
+++ b/drivers/isdn/mISDN/layer1.c
@@ -28,7 +28,8 @@ static u_int *debug;
 struct layer1 {
 	u_long Flags;
 	struct FsmInst l1m;
-	struct FsmTimer timer;
+	struct FsmTimer timer3;
+	struct FsmTimer timerX;
 	int delay;
 	int t3_value;
 	struct dchannel *dch;
@@ -135,7 +136,7 @@ l1_deact_req_s(struct FsmInst *fi, int event, void *arg)
 	struct layer1 *l1 = fi->userdata;
 
 	mISDN_FsmChangeState(fi, ST_L1_F3);
-	mISDN_FsmRestartTimer(&l1->timer, 550, EV_TIMER_DEACT, NULL, 2);
+	mISDN_FsmRestartTimer(&l1->timerX, 550, EV_TIMER_DEACT, NULL, 2);
 	test_and_set_bit(FLG_L1_DEACTTIMER, &l1->Flags);
 }
 
@@ -180,11 +181,11 @@ l1_info4_ind(struct FsmInst *fi, int event, void *arg)
 	mISDN_FsmChangeState(fi, ST_L1_F7);
 	l1->dcb(l1->dch, INFO3_P8);
 	if (test_and_clear_bit(FLG_L1_DEACTTIMER, &l1->Flags))
-		mISDN_FsmDelTimer(&l1->timer, 4);
+		mISDN_FsmDelTimer(&l1->timerX, 4);
 	if (!test_bit(FLG_L1_ACTIVATED, &l1->Flags)) {
 		if (test_and_clear_bit(FLG_L1_T3RUN, &l1->Flags))
-			mISDN_FsmDelTimer(&l1->timer, 3);
-		mISDN_FsmRestartTimer(&l1->timer, 110, EV_TIMER_ACT, NULL, 2);
+			mISDN_FsmDelTimer(&l1->timer3, 3);
+		mISDN_FsmRestartTimer(&l1->timerX, 110, EV_TIMER_ACT, NULL, 2);
 		test_and_set_bit(FLG_L1_ACTTIMER, &l1->Flags);
 	}
 }
@@ -201,8 +202,9 @@ l1_timer3(struct FsmInst *fi, int event, void *arg)
 		l1->dcb(l1->dch, PH_DEACTIVATE_IND);
 	}
 	if (l1->l1m.state != ST_L1_F6) {
+		/* keep in F6 */
 		mISDN_FsmChangeState(fi, ST_L1_F3);
-		l1->dcb(l1->dch, HW_POWERUP_REQ);
+		/* do not force anything here, we need send INFO 0 */
 	}
 }
 
@@ -234,8 +236,9 @@ l1_activate_s(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer1 *l1 = fi->userdata;
 
-	mISDN_FsmRestartTimer(&l1->timer, l1->t3_value, EV_TIMER3, NULL, 2);
+	mISDN_FsmRestartTimer(&l1->timer3, l1->t3_value, EV_TIMER3, NULL, 2);
 	test_and_set_bit(FLG_L1_T3RUN, &l1->Flags);
+	/* Tell HW to send INFO 1 */
 	l1->dcb(l1->dch, HW_RESET_REQ);
 }
 
@@ -303,7 +306,8 @@ static struct FsmNode L1SFnList[] =
 
 static void
 release_l1(struct layer1 *l1) {
-	mISDN_FsmDelTimer(&l1->timer, 0);
+	mISDN_FsmDelTimer(&l1->timerX, 0);
+	mISDN_FsmDelTimer(&l1->timer3, 0);
 	if (l1->dch)
 		l1->dch->l1 = NULL;
 	module_put(THIS_MODULE);
@@ -395,7 +399,8 @@ create_l1(struct dchannel *dch, dchannel_l1callback *dcb) {
 	nl1->l1m.printdebug = l1m_debug;
 	nl1->dch = dch;
 	nl1->dcb = dcb;
-	mISDN_FsmInitTimer(&nl1->l1m, &nl1->timer);
+	mISDN_FsmInitTimer(&nl1->l1m, &nl1->timer3);
+	mISDN_FsmInitTimer(&nl1->l1m, &nl1->timerX);
 	__module_get(THIS_MODULE);
 	dch->l1 = nl1;
 	return 0;
-- 
1.7.3.4
