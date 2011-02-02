From: frank.blaschka@de.ibm.com
Subject: [patch 4/6] [PATCH] qeth: allow OSA CHPARM change in suspend state
Date: Wed, 02 Feb 2011 17:04:34 +0100
Message-ID: <20110202160530.539261177@de.ibm.com>
References: <20110202160430.554090958@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:35095 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab1BBQFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:05:33 -0500
Content-Disposition: inline; filename=608-qeth-osa-chparm-change.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For OSA the CHPARM-definition determines the number of available
outbound queues.
A CHPARM-change may occur while a Linux system with probed
OSA device is in suspend state. This patch enables proper
resuming of an OSA device in this case.

Signed-off-by: Ursula braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core_main.c |  104 +++++++++++++++++++++++---------------
 1 file changed, 63 insertions(+), 41 deletions(-)
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -988,16 +988,30 @@ static void qeth_get_channel_path_desc(s
 	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
 	if (chp_dsc != NULL) {
 		/* CHPP field bit 6 == 1 -> single queue */
-		if ((chp_dsc->chpp & 0x02) == 0x02)
+		if ((chp_dsc->chpp & 0x02) == 0x02) {
+			if ((atomic_read(&card->qdio.state) !=
+				QETH_QDIO_UNINITIALIZED) &&
+			    (card->qdio.no_out_queues == 4))
+				/* change from 4 to 1 outbound queues */
+				qeth_free_qdio_buffers(card);
 			card->qdio.no_out_queues = 1;
+			if (card->qdio.default_out_queue != 0)
+				dev_info(&card->gdev->dev,
+					"Priority Queueing not supported\n");
+			card->qdio.default_out_queue = 0;
+		} else {
+			if ((atomic_read(&card->qdio.state) !=
+				QETH_QDIO_UNINITIALIZED) &&
+			    (card->qdio.no_out_queues == 1)) {
+				/* change from 1 to 4 outbound queues */
+				qeth_free_qdio_buffers(card);
+				card->qdio.default_out_queue = 2;
+			}
+			card->qdio.no_out_queues = 4;
+		}
 		card->info.func_level = 0x4100 + chp_dsc->desc;
 		kfree(chp_dsc);
 	}
-	if (card->qdio.no_out_queues == 1) {
-		card->qdio.default_out_queue = 0;
-		dev_info(&card->gdev->dev,
-			"Priority Queueing not supported\n");
-	}
 	QETH_DBF_TEXT_(SETUP, 2, "nr:%x", card->qdio.no_out_queues);
 	QETH_DBF_TEXT_(SETUP, 2, "lvl:%02x", card->info.func_level);
 	return;
@@ -3756,6 +3770,47 @@ static inline int qeth_get_qdio_q_format
 	}
 }
 
+static void qeth_determine_capabilities(struct qeth_card *card)
+{
+	int rc;
+	int length;
+	char *prcd;
+	struct ccw_device *ddev;
+	int ddev_offline = 0;
+
+	QETH_DBF_TEXT(SETUP, 2, "detcapab");
+	ddev = CARD_DDEV(card);
+	if (!ddev->online) {
+		ddev_offline = 1;
+		rc = ccw_device_set_online(ddev);
+		if (rc) {
+			QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
+			goto out;
+		}
+	}
+
+	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
+	if (rc) {
+		QETH_DBF_MESSAGE(2, "%s qeth_read_conf_data returned %i\n",
+			dev_name(&card->gdev->dev), rc);
+		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
+		goto out_offline;
+	}
+	qeth_configure_unitaddr(card, prcd);
+	qeth_configure_blkt_default(card, prcd);
+	kfree(prcd);
+
+	rc = qdio_get_ssqd_desc(ddev, &card->ssqd);
+	if (rc)
+		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+
+out_offline:
+	if (ddev_offline == 1)
+		ccw_device_set_offline(ddev);
+out:
+	return;
+}
+
 static int qeth_qdio_establish(struct qeth_card *card)
 {
 	struct qdio_initialize init_data;
@@ -3886,6 +3941,7 @@ int qeth_core_hardsetup_card(struct qeth
 
 	QETH_DBF_TEXT(SETUP, 2, "hrdsetup");
 	atomic_set(&card->force_alloc_skb, 0);
+	qeth_get_channel_path_desc(card);
 retry:
 	if (retries)
 		QETH_DBF_MESSAGE(2, "%s Retrying to do IDX activates.\n",
@@ -3914,6 +3970,7 @@ retriable:
 		else
 			goto retry;
 	}
+	qeth_determine_capabilities(card);
 	qeth_init_tokens(card);
 	qeth_init_func_level(card);
 	rc = qeth_idx_activate_channel(&card->read, qeth_idx_read_cb);
@@ -4183,41 +4240,6 @@ void qeth_core_free_discipline(struct qe
 	card->discipline.ccwgdriver = NULL;
 }
 
-static void qeth_determine_capabilities(struct qeth_card *card)
-{
-	int rc;
-	int length;
-	char *prcd;
-
-	QETH_DBF_TEXT(SETUP, 2, "detcapab");
-	rc = ccw_device_set_online(CARD_DDEV(card));
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
-		goto out;
-	}
-
-
-	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
-	if (rc) {
-		QETH_DBF_MESSAGE(2, "%s qeth_read_conf_data returned %i\n",
-			dev_name(&card->gdev->dev), rc);
-		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
-		goto out_offline;
-	}
-	qeth_configure_unitaddr(card, prcd);
-	qeth_configure_blkt_default(card, prcd);
-	kfree(prcd);
-
-	rc = qdio_get_ssqd_desc(CARD_DDEV(card), &card->ssqd);
-	if (rc)
-		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
-
-out_offline:
-	ccw_device_set_offline(CARD_DDEV(card));
-out:
-	return;
-}
-
 static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card;

