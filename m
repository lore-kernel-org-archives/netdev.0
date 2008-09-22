From: akpm@linux-foundation.org
Subject: [patch 4/8] drivers/atm: Use DIV_ROUND_UP
Date: Mon, 22 Sep 2008 14:50:39 -0700
Message-ID: <200809222150.m8MLod61031866@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34492 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753920AbYIVV5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The kernel.h macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /
(d)) but is perhaps more readable.

In the case of the file drivers/atm/eni.c, I am a little bit suspicious of
the -1 at the end of the affected expression.  Please check that that is
what is wanted.

An extract of the semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@haskernel@
@@

#include <linux/kernel.h>

@depends on haskernel@
expression n,d;
@@

(
- (n + d - 1) / d
+ DIV_ROUND_UP(n,d)
|
- (n + (d - 1)) / d
+ DIV_ROUND_UP(n,d)
)

@depends on haskernel@
expression n,d;
@@

- DIV_ROUND_UP((n),d)
+ DIV_ROUND_UP(n,d)

@depends on haskernel@
expression n,d;
@@

- DIV_ROUND_UP(n,(d))
+ DIV_ROUND_UP(n,d)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/eni.c     |    2 +-
 drivers/atm/horizon.c |    8 ++++----
 drivers/atm/zatm.c    |    6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff -puN drivers/atm/eni.c~drivers-atm-use-div_round_up drivers/atm/eni.c
--- a/drivers/atm/eni.c~drivers-atm-use-div_round_up
+++ a/drivers/atm/eni.c
@@ -1270,7 +1270,7 @@ static int comp_tx(struct eni_dev *eni_d
 			if (*pre < 3) (*pre)++; /* else fail later */
 			div = pre_div[*pre]*-*pcr;
 			DPRINTK("max div %d\n",div);
-			*res = (TS_CLOCK+div-1)/div-1;
+			*res = DIV_ROUND_UP(TS_CLOCK, div)-1;
 		}
 		if (*res < 0) *res = 0;
 		if (*res > MID_SEG_MAX_RATE) *res = MID_SEG_MAX_RATE;
diff -puN drivers/atm/horizon.c~drivers-atm-use-div_round_up drivers/atm/horizon.c
--- a/drivers/atm/horizon.c~drivers-atm-use-div_round_up
+++ a/drivers/atm/horizon.c
@@ -635,7 +635,7 @@ static int make_rate (const hrz_dev * de
 		// take care of rounding
 		switch (r) {
 			case round_down:
-				pre = (br+(c<<div)-1)/(c<<div);
+				pre = DIV_ROUND_UP(br, c<<div);
 				// but p must be non-zero
 				if (!pre)
 					pre = 1;
@@ -668,7 +668,7 @@ static int make_rate (const hrz_dev * de
 			// take care of rounding
 			switch (r) {
 				case round_down:
-					pre = (br+(c<<div)-1)/(c<<div);
+					pre = DIV_ROUND_UP(br, c<<div);
 					break;
 				case round_nearest:
 					pre = (br+(c<<div)/2)/(c<<div);
@@ -698,7 +698,7 @@ got_it:
 		if (bits)
 			*bits = (div<<CLOCK_SELECT_SHIFT) | (pre-1);
 		if (actual) {
-			*actual = (br + (pre<<div) - 1) / (pre<<div);
+			*actual = DIV_ROUND_UP(br, pre<<div);
 			PRINTD (DBG_QOS, "actual rate: %u", *actual);
 		}
 		return 0;
@@ -1967,7 +1967,7 @@ static int __devinit hrz_init (hrz_dev *
   // Set the max AAL5 cell count to be just enough to contain the
   // largest AAL5 frame that the user wants to receive
   wr_regw (dev, MAX_AAL5_CELL_COUNT_OFF,
-	   (max_rx_size + ATM_AAL5_TRAILER + ATM_CELL_PAYLOAD - 1) / ATM_CELL_PAYLOAD);
+	   DIV_ROUND_UP(max_rx_size + ATM_AAL5_TRAILER, ATM_CELL_PAYLOAD));
   
   // Enable receive
   wr_regw (dev, RX_CONFIG_OFF, rd_regw (dev, RX_CONFIG_OFF) | RX_ENABLE);
diff -puN drivers/atm/zatm.c~drivers-atm-use-div_round_up drivers/atm/zatm.c
--- a/drivers/atm/zatm.c~drivers-atm-use-div_round_up
+++ a/drivers/atm/zatm.c
@@ -496,8 +496,8 @@ static int open_rx_first(struct atm_vcc 
 			vcc->qos.rxtp.max_sdu = 65464;
 			/* fix this - we may want to receive 64kB SDUs
 			   later */
-		cells = (vcc->qos.rxtp.max_sdu+ATM_AAL5_TRAILER+
-		    ATM_CELL_PAYLOAD-1)/ATM_CELL_PAYLOAD;
+		cells = DIV_ROUND_UP(vcc->qos.rxtp.max_sdu + ATM_AAL5_TRAILER,
+				ATM_CELL_PAYLOAD);
 		zatm_vcc->pool = pool_index(cells*ATM_CELL_PAYLOAD);
 	}
 	else {
@@ -820,7 +820,7 @@ static int alloc_shaper(struct atm_dev *
 			}
 			else {
 				i = 255;
-				m = (ATM_OC3_PCR*255+max-1)/max;
+				m = DIV_ROUND_UP(ATM_OC3_PCR*255, max);
 			}
 		}
 		if (i > m) {
_
