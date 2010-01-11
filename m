From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] [PATCH] qeth: default BLKT values for new OSA/3 hardware
Date: Mon, 11 Jan 2010 13:50:52 +0100
Message-ID: <20100111125125.343396000@de.ibm.com>
References: <20100111125049.566359000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:50475 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab0AKMv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 07:51:27 -0500
Content-Disposition: inline; filename=606-qeth-blkt-values.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

Set default BLKT values for new OSA/3 hardware.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   41 ++++++++++++++++++++++++--------------
 drivers/s390/net/qeth_core_sys.c  |    6 ++---
 2 files changed, 29 insertions(+), 18 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1362,26 +1362,29 @@ static int qeth_read_conf_data(struct qe
 	return ret;
 }
 
-static int qeth_get_unitaddr(struct qeth_card *card)
+static void qeth_configure_unitaddr(struct qeth_card *card, char *prcd)
 {
-	int length;
-	char *prcd;
-	int rc;
-
-	QETH_DBF_TEXT(SETUP, 2, "getunit");
-	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
-	if (rc) {
-		QETH_DBF_MESSAGE(2, "%s qeth_read_conf_data returned %i\n",
-			dev_name(&card->gdev->dev), rc);
-		return rc;
-	}
+	QETH_DBF_TEXT(SETUP, 2, "cfgunit");
 	card->info.chpid = prcd[30];
 	card->info.unit_addr2 = prcd[31];
 	card->info.cula = prcd[63];
 	card->info.guestlan = ((prcd[0x10] == _ascebc['V']) &&
 			       (prcd[0x11] == _ascebc['M']));
-	kfree(prcd);
-	return 0;
+}
+
+static void qeth_configure_blkt_default(struct qeth_card *card, char *prcd)
+{
+	QETH_DBF_TEXT(SETUP, 2, "cfgblkt");
+
+	if (prcd[74] == 0xF0 && prcd[75] == 0xF0 && prcd[76] == 0xF5) {
+		card->info.blkt.time_total = 250;
+		card->info.blkt.inter_packet = 5;
+		card->info.blkt.inter_packet_jumbo = 15;
+	} else {
+		card->info.blkt.time_total = 0;
+		card->info.blkt.inter_packet = 0;
+		card->info.blkt.inter_packet_jumbo = 0;
+	}
 }
 
 static void qeth_init_tokens(struct qeth_card *card)
@@ -4169,6 +4172,8 @@ void qeth_core_free_discipline(struct qe
 static void qeth_determine_capabilities(struct qeth_card *card)
 {
 	int rc;
+	int length;
+	char *prcd;
 
 	QETH_DBF_TEXT(SETUP, 2, "detcapab");
 	rc = ccw_device_set_online(CARD_DDEV(card));
@@ -4177,11 +4182,17 @@ static void qeth_determine_capabilities(
 		goto out;
 	}
 
-	rc = qeth_get_unitaddr(card);
+
+	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
 	if (rc) {
+		QETH_DBF_MESSAGE(2, "%s qeth_read_conf_data returned %i\n",
+			dev_name(&card->gdev->dev), rc);
 		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 		goto out_offline;
 	}
+	qeth_configure_unitaddr(card, prcd);
+	qeth_configure_blkt_default(card, prcd);
+	kfree(prcd);
 
 	rc = qdio_get_ssqd_desc(CARD_DDEV(card), &card->ssqd);
 	if (rc)
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -539,7 +539,7 @@ static ssize_t qeth_dev_blkt_total_store
 	struct qeth_card *card = dev_get_drvdata(dev);
 
 	return qeth_dev_blkt_store(card, buf, count,
-				   &card->info.blkt.time_total, 1000);
+				   &card->info.blkt.time_total, 5000);
 }
 
 
@@ -561,7 +561,7 @@ static ssize_t qeth_dev_blkt_inter_store
 	struct qeth_card *card = dev_get_drvdata(dev);
 
 	return qeth_dev_blkt_store(card, buf, count,
-				   &card->info.blkt.inter_packet, 100);
+				   &card->info.blkt.inter_packet, 1000);
 }
 
 static DEVICE_ATTR(inter, 0644, qeth_dev_blkt_inter_show,
@@ -582,7 +582,7 @@ static ssize_t qeth_dev_blkt_inter_jumbo
 	struct qeth_card *card = dev_get_drvdata(dev);
 
 	return qeth_dev_blkt_store(card, buf, count,
-				   &card->info.blkt.inter_packet_jumbo, 100);
+				   &card->info.blkt.inter_packet_jumbo, 1000);
 }
 
 static DEVICE_ATTR(inter_jumbo, 0644, qeth_dev_blkt_inter_jumbo_show,

