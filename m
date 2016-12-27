From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: [PATCH 1/2] ath9k: ar9002_mac: kill off ACCESS_ONCE()
Date: Tue, 27 Dec 2016 18:49:58 +0000
Message-ID: <1482864599-19995-2-git-send-email-mark.rutland@arm.com>
References: <1482864599-19995-1-git-send-email-mark.rutland@arm.com>
Cc: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482864599-19995-1-git-send-email-mark.rutland-5wv7dgnIgG8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For several reasons, it is desirable to use {READ,WRITE}_ONCE() in
preference to ACCESS_ONCE(), and new code is expected to use one of the
former. So far, there's been no reason to change most existing uses of
ACCESS_ONCE(), as these aren't currently harmful.

However, for some new features (e.g. KTSAN / Kernel Thread Sanitizer),
it is necessary to instrument reads and writes separately, which is not
possible with ACCESS_ONCE(). This distinction is critical to correct
operation.

It's possible to transform the bulk of kernel code using the Coccinelle
script below. However, for some files (including the ath9k ar9002 mac
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

Signed-off-by: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/ath/ath9k/ar9002_mac.c | 64 ++++++++++++++---------------
 1 file changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9002_mac.c b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
index f816909..4b3c9b1 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
@@ -220,8 +220,8 @@ ar9002_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 	ads->ds_txstatus6 = ads->ds_txstatus7 = 0;
 	ads->ds_txstatus8 = ads->ds_txstatus9 = 0;
 
-	ACCESS_ONCE(ads->ds_link) = i->link;
-	ACCESS_ONCE(ads->ds_data) = i->buf_addr[0];
+	WRITE_ONCE(ads->ds_link, i->link);
+	WRITE_ONCE(ads->ds_data, i->buf_addr[0]);
 
 	ctl1 = i->buf_len[0] | (i->is_last ? 0 : AR_TxMore);
 	ctl6 = SM(i->keytype, AR_EncrType);
@@ -235,26 +235,26 @@ ar9002_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 
 	if ((i->is_first || i->is_last) &&
 	    i->aggr != AGGR_BUF_MIDDLE && i->aggr != AGGR_BUF_LAST) {
-		ACCESS_ONCE(ads->ds_ctl2) = set11nTries(i->rates, 0)
+		WRITE_ONCE(ads->ds_ctl2, set11nTries(i->rates, 0)
 			| set11nTries(i->rates, 1)
 			| set11nTries(i->rates, 2)
 			| set11nTries(i->rates, 3)
 			| (i->dur_update ? AR_DurUpdateEna : 0)
-			| SM(0, AR_BurstDur);
+			| SM(0, AR_BurstDur));
 
-		ACCESS_ONCE(ads->ds_ctl3) = set11nRate(i->rates, 0)
+		WRITE_ONCE(ads->ds_ctl3, set11nRate(i->rates, 0)
 			| set11nRate(i->rates, 1)
 			| set11nRate(i->rates, 2)
-			| set11nRate(i->rates, 3);
+			| set11nRate(i->rates, 3));
 	} else {
-		ACCESS_ONCE(ads->ds_ctl2) = 0;
-		ACCESS_ONCE(ads->ds_ctl3) = 0;
+		WRITE_ONCE(ads->ds_ctl2, 0);
+		WRITE_ONCE(ads->ds_ctl3, 0);
 	}
 
 	if (!i->is_first) {
-		ACCESS_ONCE(ads->ds_ctl0) = 0;
-		ACCESS_ONCE(ads->ds_ctl1) = ctl1;
-		ACCESS_ONCE(ads->ds_ctl6) = ctl6;
+		WRITE_ONCE(ads->ds_ctl0, 0);
+		WRITE_ONCE(ads->ds_ctl1, ctl1);
+		WRITE_ONCE(ads->ds_ctl6, ctl6);
 		return;
 	}
 
@@ -279,7 +279,7 @@ ar9002_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 		break;
 	}
 
-	ACCESS_ONCE(ads->ds_ctl0) = (i->pkt_len & AR_FrameLen)
+	WRITE_ONCE(ads->ds_ctl0, (i->pkt_len & AR_FrameLen)
 		| (i->flags & ATH9K_TXDESC_VMF ? AR_VirtMoreFrag : 0)
 		| SM(i->txpower[0], AR_XmitPower0)
 		| (i->flags & ATH9K_TXDESC_VEOL ? AR_VEOL : 0)
@@ -287,29 +287,29 @@ ar9002_set_txdesc(struct ath_hw *ah, void *ds, struct ath_tx_info *i)
 		| (i->keyix != ATH9K_TXKEYIX_INVALID ? AR_DestIdxValid : 0)
 		| (i->flags & ATH9K_TXDESC_CLRDMASK ? AR_ClrDestMask : 0)
 		| (i->flags & ATH9K_TXDESC_RTSENA ? AR_RTSEnable :
-		   (i->flags & ATH9K_TXDESC_CTSENA ? AR_CTSEnable : 0));
+		   (i->flags & ATH9K_TXDESC_CTSENA ? AR_CTSEnable : 0)));
 
-	ACCESS_ONCE(ads->ds_ctl1) = ctl1;
-	ACCESS_ONCE(ads->ds_ctl6) = ctl6;
+	WRITE_ONCE(ads->ds_ctl1, ctl1);
+	WRITE_ONCE(ads->ds_ctl6, ctl6);
 
 	if (i->aggr == AGGR_BUF_MIDDLE || i->aggr == AGGR_BUF_LAST)
 		return;
 
-	ACCESS_ONCE(ads->ds_ctl4) = set11nPktDurRTSCTS(i->rates, 0)
-		| set11nPktDurRTSCTS(i->rates, 1);
+	WRITE_ONCE(ads->ds_ctl4, set11nPktDurRTSCTS(i->rates, 0)
+		| set11nPktDurRTSCTS(i->rates, 1));
 
-	ACCESS_ONCE(ads->ds_ctl5) = set11nPktDurRTSCTS(i->rates, 2)
-		| set11nPktDurRTSCTS(i->rates, 3);
+	WRITE_ONCE(ads->ds_ctl5, set11nPktDurRTSCTS(i->rates, 2)
+		| set11nPktDurRTSCTS(i->rates, 3));
 
-	ACCESS_ONCE(ads->ds_ctl7) = set11nRateFlags(i->rates, 0)
+	WRITE_ONCE(ads->ds_ctl7, set11nRateFlags(i->rates, 0)
 		| set11nRateFlags(i->rates, 1)
 		| set11nRateFlags(i->rates, 2)
 		| set11nRateFlags(i->rates, 3)
-		| SM(i->rtscts_rate, AR_RTSCTSRate);
+		| SM(i->rtscts_rate, AR_RTSCTSRate));
 
-	ACCESS_ONCE(ads->ds_ctl9) = SM(i->txpower[1], AR_XmitPower1);
-	ACCESS_ONCE(ads->ds_ctl10) = SM(i->txpower[2], AR_XmitPower2);
-	ACCESS_ONCE(ads->ds_ctl11) = SM(i->txpower[3], AR_XmitPower3);
+	WRITE_ONCE(ads->ds_ctl9, SM(i->txpower[1], AR_XmitPower1));
+	WRITE_ONCE(ads->ds_ctl10, SM(i->txpower[2], AR_XmitPower2));
+	WRITE_ONCE(ads->ds_ctl11, SM(i->txpower[3], AR_XmitPower3));
 }
 
 static int ar9002_hw_proc_txdesc(struct ath_hw *ah, void *ds,
@@ -318,7 +318,7 @@ static int ar9002_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 	struct ar5416_desc *ads = AR5416DESC(ds);
 	u32 status;
 
-	status = ACCESS_ONCE(ads->ds_txstatus9);
+	status = READ_ONCE(ads->ds_txstatus9);
 	if ((status & AR_TxDone) == 0)
 		return -EINPROGRESS;
 
@@ -332,7 +332,7 @@ static int ar9002_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 	ts->ts_rateindex = MS(status, AR_FinalTxIdx);
 	ts->ts_seqnum = MS(status, AR_SeqNum);
 
-	status = ACCESS_ONCE(ads->ds_txstatus0);
+	status = READ_ONCE(ads->ds_txstatus0);
 	ts->ts_rssi_ctl0 = MS(status, AR_TxRSSIAnt00);
 	ts->ts_rssi_ctl1 = MS(status, AR_TxRSSIAnt01);
 	ts->ts_rssi_ctl2 = MS(status, AR_TxRSSIAnt02);
@@ -342,7 +342,7 @@ static int ar9002_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 		ts->ba_high = ads->AR_BaBitmapHigh;
 	}
 
-	status = ACCESS_ONCE(ads->ds_txstatus1);
+	status = READ_ONCE(ads->ds_txstatus1);
 	if (status & AR_FrmXmitOK)
 		ts->ts_status |= ATH9K_TX_ACKED;
 	else {
@@ -371,7 +371,7 @@ static int ar9002_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 	ts->ts_longretry = MS(status, AR_DataFailCnt);
 	ts->ts_virtcol = MS(status, AR_VirtRetryCnt);
 
-	status = ACCESS_ONCE(ads->ds_txstatus5);
+	status = READ_ONCE(ads->ds_txstatus5);
 	ts->ts_rssi = MS(status, AR_TxRSSICombined);
 	ts->ts_rssi_ext0 = MS(status, AR_TxRSSIAnt10);
 	ts->ts_rssi_ext1 = MS(status, AR_TxRSSIAnt11);
@@ -390,13 +390,13 @@ static int ar9002_hw_get_duration(struct ath_hw *ah, const void *ds, int index)
 
 	switch (index) {
 	case 0:
-		return MS(ACCESS_ONCE(ads->ds_ctl4), AR_PacketDur0);
+		return MS(READ_ONCE(ads->ds_ctl4), AR_PacketDur0);
 	case 1:
-		return MS(ACCESS_ONCE(ads->ds_ctl4), AR_PacketDur1);
+		return MS(READ_ONCE(ads->ds_ctl4), AR_PacketDur1);
 	case 2:
-		return MS(ACCESS_ONCE(ads->ds_ctl5), AR_PacketDur2);
+		return MS(READ_ONCE(ads->ds_ctl5), AR_PacketDur2);
 	case 3:
-		return MS(ACCESS_ONCE(ads->ds_ctl5), AR_PacketDur3);
+		return MS(READ_ONCE(ads->ds_ctl5), AR_PacketDur3);
 	default:
 		return -1;
 	}
-- 
2.7.4
