From: frank.blaschka@de.ibm.com
Subject: [patch 2/7] [PATCH] qeth: add more strict MTU checking
Date: Tue, 01 Feb 2011 09:16:49 +0100
Message-ID: <20110201081723.409578321@de.ibm.com>
References: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:51901 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab1BAIRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:17:44 -0500
Content-Disposition: inline; filename=605-qeth-mtu-checking.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

HiperSockets and OSA hardware report a maximum MTU size. Add checking
to reject larger MTUs than allowed by hardware.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core_main.c |   35 ++++-------------------------------
 1 file changed, 4 insertions(+), 31 deletions(-)
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1832,33 +1832,6 @@ static inline int qeth_get_initial_mtu_f
 	}
 }
 
-static inline int qeth_get_max_mtu_for_card(int cardtype)
-{
-	switch (cardtype) {
-
-	case QETH_CARD_TYPE_UNKNOWN:
-	case QETH_CARD_TYPE_OSD:
-	case QETH_CARD_TYPE_OSN:
-	case QETH_CARD_TYPE_OSM:
-	case QETH_CARD_TYPE_OSX:
-		return 61440;
-	case QETH_CARD_TYPE_IQD:
-		return 57344;
-	default:
-		return 1500;
-	}
-}
-
-static inline int qeth_get_mtu_out_of_mpc(int cardtype)
-{
-	switch (cardtype) {
-	case QETH_CARD_TYPE_IQD:
-		return 1;
-	default:
-		return 0;
-	}
-}
-
 static inline int qeth_get_mtu_outof_framesize(int framesize)
 {
 	switch (framesize) {
@@ -1881,10 +1854,9 @@ static inline int qeth_mtu_is_valid(stru
 	case QETH_CARD_TYPE_OSD:
 	case QETH_CARD_TYPE_OSM:
 	case QETH_CARD_TYPE_OSX:
-		return ((mtu >= 576) && (mtu <= 61440));
 	case QETH_CARD_TYPE_IQD:
 		return ((mtu >= 576) &&
-			(mtu <= card->info.max_mtu + 4096 - 32));
+			(mtu <= card->info.max_mtu));
 	case QETH_CARD_TYPE_OSN:
 	case QETH_CARD_TYPE_UNKNOWN:
 	default:
@@ -1907,7 +1879,7 @@ static int qeth_ulp_enable_cb(struct qet
 	memcpy(&card->token.ulp_filter_r,
 	       QETH_ULP_ENABLE_RESP_FILTER_TOKEN(iob->data),
 	       QETH_MPC_TOKEN_LENGTH);
-	if (qeth_get_mtu_out_of_mpc(card->info.type)) {
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
 		memcpy(&framesize, QETH_ULP_ENABLE_RESP_MAX_MTU(iob->data), 2);
 		mtu = qeth_get_mtu_outof_framesize(framesize);
 		if (!mtu) {
@@ -1920,7 +1892,8 @@ static int qeth_ulp_enable_cb(struct qet
 		card->qdio.in_buf_size = mtu + 2 * PAGE_SIZE;
 	} else {
 		card->info.initial_mtu = qeth_get_initial_mtu_for_card(card);
-		card->info.max_mtu = qeth_get_max_mtu_for_card(card->info.type);
+		card->info.max_mtu = *(__u16 *)QETH_ULP_ENABLE_RESP_MAX_MTU(
+			iob->data);
 		card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
 	}
 

