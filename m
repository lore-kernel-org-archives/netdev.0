From: frank.blaschka@de.ibm.com
Subject: [patch 07/11] [PATCH] qeth: Fold qeth_qerr debug area
Date: Tue, 22 Jun 2010 10:57:08 +0200
Message-ID: <20100622085807.794527000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:59134 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758956Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=607-qeth-qerr-debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch removes the qerr debug area. Most info that goes in here is logged
to the card's local debug area already, those duplicates are removed. All other
elements are moved to the card's local debug area.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 -
 drivers/s390/net/qeth_core_main.c |   14 ++++----------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:55:00.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:55:00.000000000 +0200
@@ -40,7 +40,6 @@
  */
 enum qeth_dbf_names {
 	QETH_DBF_SETUP,
-	QETH_DBF_QERR,
 	QETH_DBF_MSG,
 	QETH_DBF_CTRL,
 	QETH_DBF_INFOS	/* must be last element */
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:00.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:00.000000000 +0200
@@ -32,8 +32,6 @@ struct qeth_dbf_info qeth_dbf[QETH_DBF_I
 	/*                   N  P  A    M  L  V                      H  */
 	[QETH_DBF_SETUP] = {"qeth_setup",
 				8, 1,   8, 5, &debug_hex_ascii_view, NULL},
-	[QETH_DBF_QERR]  = {"qeth_qerr",
-				2, 1,   8, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_MSG]   = {"qeth_msg",
 				8, 1, 128, 3, &debug_sprintf_view,   NULL},
 	[QETH_DBF_CTRL]  = {"qeth_control",
@@ -2641,12 +2639,11 @@ int qeth_check_qdio_errors(struct qeth_c
 {
 	if (qdio_error) {
 		QETH_CARD_TEXT(card, 2, dbftext);
-		QETH_DBF_TEXT(QERR, 2, dbftext);
-		QETH_DBF_TEXT_(QERR, 2, " F15=%02X",
+		QETH_CARD_TEXT_(card, 2, " F15=%02X",
 			       buf->element[15].flags & 0xff);
-		QETH_DBF_TEXT_(QERR, 2, " F14=%02X",
+		QETH_CARD_TEXT_(card, 2, " F14=%02X",
 			       buf->element[14].flags & 0xff);
-		QETH_DBF_TEXT_(QERR, 2, " qerr=%X", qdio_error);
+		QETH_CARD_TEXT_(card, 2, " qerr=%X", qdio_error);
 		if ((buf->element[15].flags & 0xff) == 0x12) {
 			card->stats.rx_dropped++;
 			return 0;
@@ -3201,7 +3198,7 @@ int qeth_do_send_packet_fast(struct qeth
 			rc = dev_queue_xmit(skb);
 		} else {
 			dev_kfree_skb_any(skb);
-			QETH_DBF_TEXT(QERR, 2, "qrdrop");
+			QETH_CARD_TEXT(card, 2, "qrdrop");
 		}
 	}
 	return 0;
@@ -4112,9 +4109,6 @@ struct sk_buff *qeth_core_get_next_skb(s
 		if (skb_len) {
 			if (qeth_is_last_sbale(element)) {
 				QETH_CARD_TEXT(card, 4, "unexeob");
-				QETH_DBF_TEXT(QERR, 2, "unexeob");
-				QETH_DBF_TEXT_(QERR, 2, "%s",
-					CARD_BUS_ID(card));
 				QETH_CARD_HEX(card, 2, buffer, sizeof(void *));
 				dev_kfree_skb_any(skb);
 				card->stats.rx_errors++;

