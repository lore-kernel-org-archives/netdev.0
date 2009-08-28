From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/17] tg3: Break out mini producer ring handling
Date: Fri, 28 Aug 2009 16:57:12 -0700
Message-ID: <1251585280.29672@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2511 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbZH2Wer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch separates the code that sets up the mini producer ring from
the code that sets up the jumbo producer rings.  The 5717 asic rev
devices do not have a mini ring, but do have a jumbo frame
implementation similar to the 5704 and previous devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4c4d164..606703c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6967,19 +6967,16 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 	     NIC_SRAM_RX_BUFFER_DESC);
 
-	/* Don't even try to program the JUMBO/MINI buffer descriptor
-	 * configs on 5705.
-	 */
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
-		tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS,
-		     RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT);
-	} else {
-		tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS,
-		     RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT);
-
+	/* Disable the mini ring */
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		tw32(RCVDBDI_MINI_BD + TG3_BDINFO_MAXLEN_FLAGS,
 		     BDINFO_FLAGS_DISABLED);
 
+	/* Program the jumbo buffer descriptor ring control
+	 * blocks on those devices that have them.
+	 */
+	if ((tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 		/* Setup replenish threshold. */
 		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
 
@@ -6997,7 +6994,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     BDINFO_FLAGS_DISABLED);
 		}
 
-	}
+		val = RX_STD_MAX_SIZE << BDINFO_FLAGS_MAXLEN_SHIFT;
+	} else
+		val = RX_STD_MAX_SIZE_5705 << BDINFO_FLAGS_MAXLEN_SHIFT;
+
+	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS, val);
 
 	/* There is only one send ring on 5705/5750, no need to explicitly
 	 * disable the others.
-- 
1.6.3.3


