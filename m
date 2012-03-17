From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 06/28] mISDN: Rework of LED status display for HFC-4S/8S/E1 cards.
Date: Sat, 17 Mar 2012 10:55:12 +0100
Message-ID: <20120423170549.AF4299FB80@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:55690 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>

LEDs will show RED if layer 1 is disabled or fails.
LEDs will show GREEN if layer 1 is active.
LEDs will blink if traffic on D-channel.

Signed-off-by: Andreas Eversberg <jolly@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |    9 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  157 ++++++++++++++++++-------------
 2 files changed, 95 insertions(+), 71 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index b0588ac..09e4e77 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -205,18 +205,19 @@ struct hfc_multi {
 
 	u_int		slots;	/* number of PCM slots */
 	u_int		leds;	/* type of leds */
-	u_int		ledcount; /* used to animate leds */
 	u_long		ledstate; /* save last state of leds */
 	int		opticalsupport; /* has the e1 board */
 					/* an optical Interface */
 	int		dslot;	/* channel # of d-channel (E1) default 16 */
+	u_int		activity_tx; /* if there is data TX / RX */
+	u_int		activity_rx; /* bitmask according to port number */
+				     /* (will be cleared after */
+				     /* showing led-states) */
+	u_int		flash[8]; /* counter for flashing 8 leds on activity */
 
 	u_long		wdcount;	/* every 500 ms we need to */
 					/* send the watchdog a signal */
 	u_char		wdbyte; /* watchdog toggle byte */
-	u_int		activity[8];	/* if there is any action on this */
-					/* port (will be cleared after */
-					/* showing led-states) */
 	int		e1_state; /* keep track of last state */
 	int		e1_getclock; /* if sync is retrieved from interface */
 	int		syncronized; /* keep track of existing sync interface */
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index cc978e8..876f7d0 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -1607,40 +1607,46 @@ hfcmulti_leds(struct hfc_multi *hc)
 	struct dchannel *dch;
 	int led[4];
 
-	hc->ledcount += poll;
-	if (hc->ledcount > 4096) {
-		hc->ledcount -= 4096;
-		hc->ledstate = 0xAFFEAFFE;
-	}
-
 	switch (hc->leds) {
 	case 1: /* HFC-E1 OEM */
-		/* 2 red blinking: NT mode deactivate
-		 * 2 red steady:   TE mode deactivate
-		 * left green:     L1 active
-		 * left red:       frame sync, but no L1
-		 * todo right green:    L2 active
+		/* 2 red steady:       LOS
+		 * 1 red steady:       L1 not active
+		 * 2 green steady:     L1 active
+		 * 1st green flashing: activity on TX
+		 * 2nd green flashing: activity on RX
 		 */
+		led[0] = 0;
+		led[1] = 0;
+		led[2] = 0;
+		led[3] = 0;
 		dch = hc->chan[hc->dslot].dch;
-		if (test_bit(FLG_ACTIVE, &dch->Flags)) {
-			led[0] = 0;
-			led[1] = 0;
-			led[2] = 0;
-			led[3] = 1;
-		} else {
-			if (dch->dev.D.protocol
-			    != ISDN_P_NT_E1) {
-				led[0] = 1;
+		if (dch) {
+			if (hc->chan[hc->dslot].los)
 				led[1] = 1;
-			} else if (hc->ledcount >> 11) {
+			if (hc->e1_state != 1) {
 				led[0] = 1;
-				led[1] = 1;
+				hc->flash[2] = 0;
+				hc->flash[3] = 0;
 			} else {
-				led[0] = 0;
-				led[1] = 0;
+				led[2] = 1;
+				led[3] = 1;
+				if (!hc->flash[2] && hc->activity_tx)
+					hc->flash[2] = poll;
+				if (!hc->flash[3] && hc->activity_rx)
+					hc->flash[3] = poll;
+				if (hc->flash[2] && hc->flash[2] < 1024)
+					led[2] = 0;
+				if (hc->flash[3] && hc->flash[3] < 1024)
+					led[3] = 0;
+				if (hc->flash[2] >= 2048)
+					hc->flash[2] = 0;
+				if (hc->flash[3] >= 2048)
+					hc->flash[3] = 0;
+				if (hc->flash[2])
+					hc->flash[2] += poll;
+				if (hc->flash[3])
+					hc->flash[3] += poll;
 			}
-			led[2] = 0;
-			led[3] = 0;
 		}
 		leds = (led[0] | (led[1]<<2) | (led[2]<<1) | (led[3]<<3))^0xF;
 		/* leds are inverted */
@@ -1651,9 +1657,9 @@ hfcmulti_leds(struct hfc_multi *hc)
 		break;
 
 	case 2: /* HFC-4S OEM */
-		/* red blinking = PH_DEACTIVATE NT Mode
-		 * red steady   = PH_DEACTIVATE TE Mode
-		 * green steady = PH_ACTIVATE
+		/* red steady:     PH_DEACTIVATE
+		 * green steady:   PH_ACTIVATE
+		 * green flashing: activity on TX
 		 */
 		for (i = 0; i < 4; i++) {
 			state = 0;
@@ -1669,17 +1675,20 @@ hfcmulti_leds(struct hfc_multi *hc)
 			if (state) {
 				if (state == active) {
 					led[i] = 1; /* led green */
-				} else
-					if (dch->dev.D.protocol == ISDN_P_TE_S0)
-						/* TE mode: led red */
-						led[i] = 2;
-					else
-						if (hc->ledcount >> 11)
-							/* led red */
-							led[i] = 2;
-						else
-							/* led off */
-							led[i] = 0;
+					hc->activity_tx |= hc->activity_rx;
+					if (!hc->flash[i] &&
+						(hc->activity_tx & (1 << i)))
+							hc->flash[i] = poll;
+					if (hc->flash[i] && hc->flash[i] < 1024)
+						led[i] = 0; /* led off */
+					if (hc->flash[i] >= 2048)
+						hc->flash[i] = 0;
+					if (hc->flash[i])
+						hc->flash[i] += poll;
+				} else {
+					led[i] = 2; /* led red */
+					hc->flash[i] = 0;
+				}
 			} else
 				led[i] = 0; /* led off */
 		}
@@ -1712,9 +1721,9 @@ hfcmulti_leds(struct hfc_multi *hc)
 		break;
 
 	case 3: /* HFC 1S/2S Beronet */
-		/* red blinking = PH_DEACTIVATE NT Mode
-		 * red steady   = PH_DEACTIVATE TE Mode
-		 * green steady = PH_ACTIVATE
+		/* red steady:     PH_DEACTIVATE
+		 * green steady:   PH_ACTIVATE
+		 * green flashing: activity on TX
 		 */
 		for (i = 0; i < 2; i++) {
 			state = 0;
@@ -1730,22 +1739,23 @@ hfcmulti_leds(struct hfc_multi *hc)
 			if (state) {
 				if (state == active) {
 					led[i] = 1; /* led green */
-				} else
-					if (dch->dev.D.protocol == ISDN_P_TE_S0)
-						/* TE mode: led red */
-						led[i] = 2;
-					else
-						if (hc->ledcount >> 11)
-							/* led red */
-							led[i] = 2;
-						else
-							/* led off */
-							led[i] = 0;
+					hc->activity_tx |= hc->activity_rx;
+					if (!hc->flash[i] &&
+						(hc->activity_tx & (1 << i)))
+							hc->flash[i] = poll;
+					if (hc->flash[i] < 1024)
+						led[i] = 0; /* led off */
+					if (hc->flash[i] >= 2048)
+						hc->flash[i] = 0;
+					if (hc->flash[i])
+						hc->flash[i] += poll;
+				} else {
+					led[i] = 2; /* led red */
+					hc->flash[i] = 0;
+				}
 			} else
 				led[i] = 0; /* led off */
 		}
-
-
 		leds = (led[0] > 0) | ((led[1] > 0) << 1) | ((led[0]&1) << 2)
 			| ((led[1]&1) << 3);
 		if (leds != (int)hc->ledstate) {
@@ -1757,8 +1767,11 @@ hfcmulti_leds(struct hfc_multi *hc)
 		}
 		break;
 	case 8: /* HFC 8S+ Beronet */
-		lled = 0;
-
+		/* off:      PH_DEACTIVATE
+		 * steady:   PH_ACTIVATE
+		 * flashing: activity on TX
+		 */
+		lled = 0xff; /* leds off */
 		for (i = 0; i < 8; i++) {
 			state = 0;
 			active = -1;
@@ -1772,14 +1785,20 @@ hfcmulti_leds(struct hfc_multi *hc)
 			}
 			if (state) {
 				if (state == active) {
-					lled |= 0 << i;
+					lled &= ~(1 << i); /* led on */
+					hc->activity_tx |= hc->activity_rx;
+					if (!hc->flash[i] &&
+						(hc->activity_tx & (1 << i)))
+							hc->flash[i] = poll;
+					if (hc->flash[i] < 1024)
+						lled |= 1 << i; /* led off */
+					if (hc->flash[i] >= 2048)
+						hc->flash[i] = 0;
+					if (hc->flash[i])
+						hc->flash[i] += poll;
 				} else
-					if (hc->ledcount >> 11)
-						lled |= 0 << i;
-					else
-						lled |= 1 << i;
-			} else
-				lled |= 1 << i;
+					hc->flash[i] = 0;
+			}
 		}
 		leddw = lled << 24 | lled << 16 | lled << 8 | lled;
 		if (leddw != hc->ledstate) {
@@ -1794,6 +1813,8 @@ hfcmulti_leds(struct hfc_multi *hc)
 		}
 		break;
 	}
+	hc->activity_tx = 0;
+	hc->activity_rx = 0;
 }
 /*
  * read dtmf coefficients
@@ -2093,7 +2114,8 @@ next_frame:
 	*txpending = 1;
 
 	/* show activity */
-	hc->activity[hc->chan[ch].port] = 1;
+	if (dch)
+		hc->activity_tx |= 1 << hc->chan[ch].port;
 
 	/* fill fifo to what we have left */
 	ii = len;
@@ -2236,7 +2258,8 @@ next_frame:
 		}
 	}
 	/* show activity */
-	hc->activity[hc->chan[ch].port] = 1;
+	if (dch)
+		hc->activity_rx |= 1 << hc->chan[ch].port;
 
 	/* empty fifo with what we have */
 	if (dch || test_bit(FLG_HDLC, &bch->Flags)) {
-- 
1.7.3.4
