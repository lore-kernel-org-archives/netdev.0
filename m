From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 2/2] ath9k: ar9003_mac: kill off ACCESS_ONCE()
Date: Tue, 27 Dec 2016 18:49:59 +0000
Message-ID: <1482864599-19995-3-git-send-email-mark.rutland@arm.com>
References: <1482864599-19995-1-git-send-email-mark.rutland@arm.com>
Cc: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
        netdev@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:54208 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753998AbcL0Sxv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 13:53:51 -0500
In-Reply-To: <1482864599-19995-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For several reasons, it is desirable to use {READ,WRITE}_ONCE() in
preference to ACCESS_ONCE(), and new code is expected to use one of the
former. So far, there's been no reason to change most existing uses of
ACCESS_ONCE(), as these aren't currently harmful.

However, for some new features (e.g. KTSAN / Kernel Thread Sanitizer),
it is necessary to instrument reads and writes separately, which is not
possible with ACCESS_ONCE(). This distinction is critical to correct
operation.

It's possible to transform the bulk of kernel code using the Coccinelle
script below. However, for some files (including the ath9k ar9003 mac
driver), this mangles the formatting. As a preparatory step, this patch
converts the driver to use {READ,WRITE}_ONCE() without said mangling.

----
virtual patch

@ depends on patch @
expression E1, E2;
@@

- ACCESS_ONCE(E1) = E2
+ WRITE_ONCE(E1, E2)

@ depends on patch @
expression E;
@@

- ACCESS_ONCE(E)
+ READ_ONCE(E)
----

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: ath9k-devel@qca.qualcomm.com
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: linux-wireless@vger.kernel.org
Cc: ath9k-devel@lists.ath9k.org
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/ath/ath9k/ar9003_mac.c | 92 ++++++++++++++---------------
 1 file changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index da84b70..cc5bb0a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -39,47 +39,47 @@ ar9003_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 	      (i->qcu << AR_TxQcuNum_S) | desc_len;
 
 	checksum += val;
-	ACCESS_ONCE(ads->info) = val;
+	WRITE_ONCE(ads->info, val);
 
 	checksum += i->link;
-	ACCESS_ONCE(ads->link) = i->link;
+	WRITE_ONCE(ads->link, i->link);
 
 	checksum += i->buf_addr[0];
-	ACCESS_ONCE(ads->data0) = i->buf_addr[0];
+	WRITE_ONCE(ads->data0, i->buf_addr[0]);
 	checksum += i->buf_addr[1];
-	ACCESS_ONCE(ads->data1) = i->buf_addr[1];
+	WRITE_ONCE(ads->data1, i->buf_addr[1]);
 	checksum += i->buf_addr[2];
-	ACCESS_ONCE(ads->data2) = i->buf_addr[2];
+	WRITE_ONCE(ads->data2, i->buf_addr[2]);
 	checksum += i->buf_addr[3];
-	ACCESS_ONCE(ads->data3) = i->buf_addr[3];
+	WRITE_ONCE(ads->data3, i->buf_addr[3]);
 
 	checksum += (val = (i->buf_len[0] << AR_BufLen_S) & AR_BufLen);
-	ACCESS_ONCE(ads->ctl3) = val;
+	WRITE_ONCE(ads->ctl3, val);
 	checksum += (val = (i->buf_len[1] << AR_BufLen_S) & AR_BufLen);
-	ACCESS_ONCE(ads->ctl5) = val;
+	WRITE_ONCE(ads->ctl5, val);
 	checksum += (val = (i->buf_len[2] << AR_BufLen_S) & AR_BufLen);
-	ACCESS_ONCE(ads->ctl7) = val;
+	WRITE_ONCE(ads->ctl7, val);
 	checksum += (val = (i->buf_len[3] << AR_BufLen_S) & AR_BufLen);
-	ACCESS_ONCE(ads->ctl9) = val;
+	WRITE_ONCE(ads->ctl9, val);
 
 	checksum = (u16) (((checksum & 0xffff) + (checksum >> 16)) & 0xffff);
-	ACCESS_ONCE(ads->ctl10) = checksum;
+	WRITE_ONCE(ads->ctl10, checksum);
 
 	if (i->is_first || i->is_last) {
-		ACCESS_ONCE(ads->ctl13) = set11nTries(i->rates, 0)
+		WRITE_ONCE(ads->ctl13, set11nTries(i->rates, 0)
 			| set11nTries(i->rates, 1)
 			| set11nTries(i->rates, 2)
 			| set11nTries(i->rates, 3)
 			| (i->dur_update ? AR_DurUpdateEna : 0)
-			| SM(0, AR_BurstDur);
+			| SM(0, AR_BurstDur));
 
-		ACCESS_ONCE(ads->ctl14) = set11nRate(i->rates, 0)
+		WRITE_ONCE(ads->ctl14, set11nRate(i->rates, 0)
 			| set11nRate(i->rates, 1)
 			| set11nRate(i->rates, 2)
-			| set11nRate(i->rates, 3);
+			| set11nRate(i->rates, 3));
 	} else {
-		ACCESS_ONCE(ads->ctl13) = 0;
-		ACCESS_ONCE(ads->ctl14) = 0;
+		WRITE_ONCE(ads->ctl13, 0);
+		WRITE_ONCE(ads->ctl14, 0);
 	}
 
 	ads->ctl20 = 0;
@@ -89,17 +89,17 @@ ar9003_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 
 	ctl17 = SM(i->keytype, AR_EncrType);
 	if (!i->is_first) {
-		ACCESS_ONCE(ads->ctl11) = 0;
-		ACCESS_ONCE(ads->ctl12) = i->is_last ? 0 : AR_TxMore;
-		ACCESS_ONCE(ads->ctl15) = 0;
-		ACCESS_ONCE(ads->ctl16) = 0;
-		ACCESS_ONCE(ads->ctl17) = ctl17;
-		ACCESS_ONCE(ads->ctl18) = 0;
-		ACCESS_ONCE(ads->ctl19) = 0;
+		WRITE_ONCE(ads->ctl11, 0);
+		WRITE_ONCE(ads->ctl12, i->is_last ? 0 : AR_TxMore);
+		WRITE_ONCE(ads->ctl15, 0);
+		WRITE_ONCE(ads->ctl16, 0);
+		WRITE_ONCE(ads->ctl17, ctl17);
+		WRITE_ONCE(ads->ctl18, 0);
+		WRITE_ONCE(ads->ctl19, 0);
 		return;
 	}
 
-	ACCESS_ONCE(ads->ctl11) = (i->pkt_len & AR_FrameLen)
+	WRITE_ONCE(ads->ctl11, (i->pkt_len & AR_FrameLen)
 		| (i->flags & ATH9K_TXDESC_VMF ? AR_VirtMoreFrag : 0)
 		| SM(i->txpower[0], AR_XmitPower0)
 		| (i->flags & ATH9K_TXDESC_VEOL ? AR_VEOL : 0)
@@ -107,7 +107,7 @@ ar9003_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 		| (i->flags & ATH9K_TXDESC_LOWRXCHAIN ? AR_LowRxChain : 0)
 		| (i->flags & ATH9K_TXDESC_CLRDMASK ? AR_ClrDestMask : 0)
 		| (i->flags & ATH9K_TXDESC_RTSENA ? AR_RTSEnable :
-		   (i->flags & ATH9K_TXDESC_CTSENA ? AR_CTSEnable : 0));
+		   (i->flags & ATH9K_TXDESC_CTSENA ? AR_CTSEnable : 0)));
 
 	ctl12 = (i->keyix != ATH9K_TXKEYIX_INVALID ?
 		 SM(i->keyix, AR_DestIdx) : 0)
@@ -135,26 +135,26 @@ ar9003_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 	val = (i->flags & ATH9K_TXDESC_PAPRD) >> ATH9K_TXDESC_PAPRD_S;
 	ctl12 |= SM(val, AR_PAPRDChainMask);
 
-	ACCESS_ONCE(ads->ctl12) = ctl12;
-	ACCESS_ONCE(ads->ctl17) = ctl17;
+	WRITE_ONCE(ads->ctl12, ctl12);
+	WRITE_ONCE(ads->ctl17, ctl17);
 
-	ACCESS_ONCE(ads->ctl15) = set11nPktDurRTSCTS(i->rates, 0)
-		| set11nPktDurRTSCTS(i->rates, 1);
+	WRITE_ONCE(ads->ctl15, set11nPktDurRTSCTS(i->rates, 0)
+		| set11nPktDurRTSCTS(i->rates, 1));
 
-	ACCESS_ONCE(ads->ctl16) = set11nPktDurRTSCTS(i->rates, 2)
-		| set11nPktDurRTSCTS(i->rates, 3);
+	WRITE_ONCE(ads->ctl16, set11nPktDurRTSCTS(i->rates, 2)
+		| set11nPktDurRTSCTS(i->rates, 3));
 
-	ACCESS_ONCE(ads->ctl18) = set11nRateFlags(i->rates, 0)
+	WRITE_ONCE(ads->ctl18, set11nRateFlags(i->rates, 0)
 		| set11nRateFlags(i->rates, 1)
 		| set11nRateFlags(i->rates, 2)
 		| set11nRateFlags(i->rates, 3)
-		| SM(i->rtscts_rate, AR_RTSCTSRate);
+		| SM(i->rtscts_rate, AR_RTSCTSRate));
 
-	ACCESS_ONCE(ads->ctl19) = AR_Not_Sounding;
+	WRITE_ONCE(ads->ctl19, AR_Not_Sounding);
 
-	ACCESS_ONCE(ads->ctl20) = SM(i->txpower[1], AR_XmitPower1);
-	ACCESS_ONCE(ads->ctl21) = SM(i->txpower[2], AR_XmitPower2);
-	ACCESS_ONCE(ads->ctl22) = SM(i->txpower[3], AR_XmitPower3);
+	WRITE_ONCE(ads->ctl20, SM(i->txpower[1], AR_XmitPower1));
+	WRITE_ONCE(ads->ctl21, SM(i->txpower[2], AR_XmitPower2));
+	WRITE_ONCE(ads->ctl22, SM(i->txpower[3], AR_XmitPower3));
 }
 
 static u16 ar9003_calc_ptr_chksum(struct ar9003_txc *ads)
@@ -359,7 +359,7 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 
 	ads = &ah->ts_ring[ah->ts_tail];
 
-	status = ACCESS_ONCE(ads->status8);
+	status = READ_ONCE(ads->status8);
 	if ((status & AR_TxDone) == 0)
 		return -EINPROGRESS;
 
@@ -385,7 +385,7 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 
 	if (status & AR_TxOpExceeded)
 		ts->ts_status |= ATH9K_TXERR_XTXOP;
-	status = ACCESS_ONCE(ads->status2);
+	status = READ_ONCE(ads->status2);
 	ts->ts_rssi_ctl0 = MS(status, AR_TxRSSIAnt00);
 	ts->ts_rssi_ctl1 = MS(status, AR_TxRSSIAnt01);
 	ts->ts_rssi_ctl2 = MS(status, AR_TxRSSIAnt02);
@@ -395,7 +395,7 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 		ts->ba_high = ads->status6;
 	}
 
-	status = ACCESS_ONCE(ads->status3);
+	status = READ_ONCE(ads->status3);
 	if (status & AR_ExcessiveRetries)
 		ts->ts_status |= ATH9K_TXERR_XRETRY;
 	if (status & AR_Filtered)
@@ -420,7 +420,7 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 	ts->ts_longretry = MS(status, AR_DataFailCnt);
 	ts->ts_virtcol = MS(status, AR_VirtRetryCnt);
 
-	status = ACCESS_ONCE(ads->status7);
+	status = READ_ONCE(ads->status7);
 	ts->ts_rssi = MS(status, AR_TxRSSICombined);
 	ts->ts_rssi_ext0 = MS(status, AR_TxRSSIAnt10);
 	ts->ts_rssi_ext1 = MS(status, AR_TxRSSIAnt11);
@@ -437,13 +437,13 @@ static int ar9003_hw_get_duration(struct ath_hw *ah, const void *ds, int index)
 
 	switch (index) {
 	case 0:
-		return MS(ACCESS_ONCE(adc->ctl15), AR_PacketDur0);
+		return MS(READ_ONCE(adc->ctl15), AR_PacketDur0);
 	case 1:
-		return MS(ACCESS_ONCE(adc->ctl15), AR_PacketDur1);
+		return MS(READ_ONCE(adc->ctl15), AR_PacketDur1);
 	case 2:
-		return MS(ACCESS_ONCE(adc->ctl16), AR_PacketDur2);
+		return MS(READ_ONCE(adc->ctl16), AR_PacketDur2);
 	case 3:
-		return MS(ACCESS_ONCE(adc->ctl16), AR_PacketDur3);
+		return MS(READ_ONCE(adc->ctl16), AR_PacketDur3);
 	default:
 		return 0;
 	}
-- 
2.7.4
