From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 05/28] mISDN: Using FLG_ACTIVE flag to determine if layer 1 is active or not.
Date: Sat, 17 Mar 2012 10:41:22 +0100
Message-ID: <20120423170549.C3EDA9FB8D@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:62490 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <andreas@eversberg.eu>

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |   25 ++++++++++---------------
 1 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index c4e7fda..cc978e8 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -1619,10 +1619,16 @@ hfcmulti_leds(struct hfc_multi *hc)
 		 * 2 red steady:   TE mode deactivate
 		 * left green:     L1 active
 		 * left red:       frame sync, but no L1
-		 * right green:    L2 active
+		 * todo right green:    L2 active
 		 */
-		if (hc->chan[hc->dslot].sync != 2) { /* no frame sync */
-			if (hc->chan[hc->dslot].dch->dev.D.protocol
+		dch = hc->chan[hc->dslot].dch;
+		if (test_bit(FLG_ACTIVE, &dch->Flags)) {
+			led[0] = 0;
+			led[1] = 0;
+			led[2] = 0;
+			led[3] = 1;
+		} else {
+			if (dch->dev.D.protocol
 			    != ISDN_P_NT_E1) {
 				led[0] = 1;
 				led[1] = 1;
@@ -1635,12 +1641,6 @@ hfcmulti_leds(struct hfc_multi *hc)
 			}
 			led[2] = 0;
 			led[3] = 0;
-		} else { /* with frame sync */
-			/* TODO make it work */
-			led[0] = 0;
-			led[1] = 0;
-			led[2] = 0;
-			led[3] = 1;
 		}
 		leds = (led[0] | (led[1]<<2) | (led[2]<<1) | (led[3]<<3))^0xF;
 		/* leds are inverted */
@@ -4062,14 +4062,9 @@ open_dchannel(struct hfc_multi *hc, struct dchannel *dch,
 		hfcmulti_initmode(dch);
 		spin_unlock_irqrestore(&hc->lock, flags);
 	}
-
-	if (((rq->protocol == ISDN_P_NT_S0) && (dch->state == 3)) ||
-	    ((rq->protocol == ISDN_P_TE_S0) && (dch->state == 7)) ||
-	    ((rq->protocol == ISDN_P_NT_E1) && (dch->state == 1)) ||
-	    ((rq->protocol == ISDN_P_TE_E1) && (dch->state == 1))) {
+	if (test_bit(FLG_ACTIVE, &dch->Flags))
 		_queue_data(&dch->dev.D, PH_ACTIVATE_IND, MISDN_ID_ANY,
 			    0, NULL, GFP_KERNEL);
-	}
 	rq->ch = &dch->dev.D;
 	if (!try_module_get(THIS_MODULE))
 		printk(KERN_WARNING "%s:cannot get module\n", __func__);
-- 
1.7.3.4
