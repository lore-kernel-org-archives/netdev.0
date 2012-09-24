From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] [PATCH] qeth: cleanup channel path descriptor function
Date: Mon, 24 Sep 2012 16:24:23 +0200
Message-ID: <20120924142501.032039372@de.ibm.com>
References: <20120924142422.001953152@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:48528 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab2IXOZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:25:12 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Sep 2012 15:25:11 +0100
Content-Disposition: inline; filename=600-qeth-chp-desc-cleanup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

Cleanup the qeth_get_channel_path_desc function and rename it
to qeth_update_from_chp_desc. No functional change.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Acked-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |   74 +++++++++++++++++++++-----------------
 1 file changed, 41 insertions(+), 33 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1257,7 +1257,30 @@ static void qeth_clean_channel(struct qe
 		kfree(channel->iob[cnt].data);
 }
 
-static void qeth_get_channel_path_desc(struct qeth_card *card)
+static void qeth_set_single_write_queues(struct qeth_card *card)
+{
+	if ((atomic_read(&card->qdio.state) != QETH_QDIO_UNINITIALIZED) &&
+	    (card->qdio.no_out_queues == 4))
+		qeth_free_qdio_buffers(card);
+
+	card->qdio.no_out_queues = 1;
+	if (card->qdio.default_out_queue != 0)
+		dev_info(&card->gdev->dev, "Priority Queueing not supported\n");
+
+	card->qdio.default_out_queue = 0;
+}
+
+static void qeth_set_multiple_write_queues(struct qeth_card *card)
+{
+	if ((atomic_read(&card->qdio.state) != QETH_QDIO_UNINITIALIZED) &&
+	    (card->qdio.no_out_queues == 1)) {
+		qeth_free_qdio_buffers(card);
+		card->qdio.default_out_queue = 2;
+	}
+	card->qdio.no_out_queues = 4;
+}
+
+static void qeth_update_from_chp_desc(struct qeth_card *card)
 {
 	struct ccw_device *ccwdev;
 	struct channelPath_dsc {
@@ -1274,38 +1297,23 @@ static void qeth_get_channel_path_desc(s
 	QETH_DBF_TEXT(SETUP, 2, "chp_desc");
 
 	ccwdev = card->data.ccwdev;
-	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
-	if (chp_dsc != NULL) {
-		if (card->info.type != QETH_CARD_TYPE_IQD) {
-			/* CHPP field bit 6 == 1 -> single queue */
-			if ((chp_dsc->chpp & 0x02) == 0x02) {
-				if ((atomic_read(&card->qdio.state) !=
-					QETH_QDIO_UNINITIALIZED) &&
-				    (card->qdio.no_out_queues == 4))
-					/* change from 4 to 1 outbound queues */
-					qeth_free_qdio_buffers(card);
-				card->qdio.no_out_queues = 1;
-				if (card->qdio.default_out_queue != 0)
-					dev_info(&card->gdev->dev,
-					"Priority Queueing not supported\n");
-				card->qdio.default_out_queue = 0;
-			} else {
-				if ((atomic_read(&card->qdio.state) !=
-					QETH_QDIO_UNINITIALIZED) &&
-				    (card->qdio.no_out_queues == 1)) {
-					/* change from 1 to 4 outbound queues */
-					qeth_free_qdio_buffers(card);
-					card->qdio.default_out_queue = 2;
-				}
-				card->qdio.no_out_queues = 4;
-			}
-		}
-		card->info.func_level = 0x4100 + chp_dsc->desc;
-		kfree(chp_dsc);
-	}
+	chp_dsc = ccw_device_get_chp_desc(ccwdev, 0);
+	if (!chp_dsc)
+		goto out;
+
+	card->info.func_level = 0x4100 + chp_dsc->desc;
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		goto out;
+
+	/* CHPP field bit 6 == 1 -> single queue */
+	if ((chp_dsc->chpp & 0x02) == 0x02)
+		qeth_set_single_write_queues(card);
+	else
+		qeth_set_multiple_write_queues(card);
+out:
+	kfree(chp_dsc);
 	QETH_DBF_TEXT_(SETUP, 2, "nr:%x", card->qdio.no_out_queues);
 	QETH_DBF_TEXT_(SETUP, 2, "lvl:%02x", card->info.func_level);
-	return;
 }
 
 static void qeth_init_qdio_info(struct qeth_card *card)
@@ -1473,7 +1481,7 @@ static int qeth_determine_card_type(stru
 			card->qdio.no_in_queues = 1;
 			card->info.is_multicast_different =
 				known_devices[i][QETH_MULTICAST_IND];
-			qeth_get_channel_path_desc(card);
+			qeth_update_from_chp_desc(card);
 			return 0;
 		}
 		i++;
@@ -4742,7 +4750,7 @@ int qeth_core_hardsetup_card(struct qeth
 
 	QETH_DBF_TEXT(SETUP, 2, "hrdsetup");
 	atomic_set(&card->force_alloc_skb, 0);
-	qeth_get_channel_path_desc(card);
+	qeth_update_from_chp_desc(card);
 retry:
 	if (retries)
 		QETH_DBF_MESSAGE(2, "%s Retrying to do IDX activates.\n",
