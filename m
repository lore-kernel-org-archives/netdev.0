From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 9/9] s390/qeth: do early device setup for z/VM IQD NICs
Date: Tue,  6 Jun 2017 14:33:50 +0200
Message-ID: <20170606123350.13781-10-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53590 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751499AbdFFMeL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:11 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXgTB066304
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:11 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2awmur67ba-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:11 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:08 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qeth currently supports early setup for OSM and OSN devices.
This patch adds early setup support for z/VM HiperSockets,
since they can only be coupled to L3 networks.

Based on an initial version by Dmitriy Lakhvich.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 ++
 drivers/s390/net/qeth_core_main.c | 44 ++++++++++++++++++++++++++++++---------
 drivers/s390/net/qeth_core_sys.c  |  2 +-
 3 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 30bc6105aac3..0efc54a4d82f 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -659,6 +659,7 @@ struct qeth_card_info {
 	int max_mtu;
 	int broadcast_capable;
 	int unique_id;
+	bool layer_enforced;
 	struct qeth_card_blkt blkt;
 	enum qeth_ipa_promisc_modes promisc_mode;
 	__u32 diagass_support;
@@ -696,6 +697,7 @@ struct qeth_osn_info {
 };
 
 enum qeth_discipline_id {
+	QETH_DISCIPLINE_UNDETERMINED = -1,
 	QETH_DISCIPLINE_LAYER3 = 0,
 	QETH_DISCIPLINE_LAYER2 = 1,
 };
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 3cc802cff9d1..1fb92e870040 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1723,6 +1723,25 @@ static void qeth_configure_unitaddr(struct qeth_card *card, char *prcd)
 			       (prcd[0x11] == _ascebc['M']));
 }
 
+/* Determine whether the device requires a specific layer discipline */
+static enum qeth_discipline_id qeth_enforce_discipline(struct qeth_card *card)
+{
+	if (card->info.type == QETH_CARD_TYPE_OSM ||
+	    card->info.type == QETH_CARD_TYPE_OSN) {
+		QETH_DBF_TEXT(SETUP, 3, "force l2");
+		return QETH_DISCIPLINE_LAYER2;
+	}
+
+	/* virtual HiperSocket is L3 only: */
+	if (card->info.guestlan && card->info.type == QETH_CARD_TYPE_IQD) {
+		QETH_DBF_TEXT(SETUP, 3, "force l3");
+		return QETH_DISCIPLINE_LAYER3;
+	}
+
+	QETH_DBF_TEXT(SETUP, 3, "force no");
+	return QETH_DISCIPLINE_UNDETERMINED;
+}
+
 static void qeth_configure_blkt_default(struct qeth_card *card, char *prcd)
 {
 	QETH_DBF_TEXT(SETUP, 2, "cfgblkt");
@@ -5485,6 +5504,7 @@ int qeth_core_load_discipline(struct qeth_card *card,
 		enum qeth_discipline_id discipline)
 {
 	int rc = 0;
+
 	mutex_lock(&qeth_mod_mutex);
 	switch (discipline) {
 	case QETH_DISCIPLINE_LAYER3:
@@ -5495,7 +5515,10 @@ int qeth_core_load_discipline(struct qeth_card *card,
 		card->discipline = try_then_request_module(
 			symbol_get(qeth_l2_discipline), "qeth_l2");
 		break;
+	default:
+		break;
 	}
+
 	if (!card->discipline) {
 		dev_err(&card->gdev->dev, "There is no kernel module to "
 			"support discipline %d\n", discipline);
@@ -5598,6 +5621,7 @@ static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 	struct qeth_card *card;
 	struct device *dev;
 	int rc;
+	enum qeth_discipline_id enforced_disc;
 	unsigned long flags;
 	char dbf_name[DBF_NAME_LEN];
 
@@ -5645,10 +5669,15 @@ static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 		goto err_card;
 	}
 
-	switch (card->info.type) {
-	case QETH_CARD_TYPE_OSN:
-	case QETH_CARD_TYPE_OSM:
-		rc = qeth_core_load_discipline(card, QETH_DISCIPLINE_LAYER2);
+	qeth_determine_capabilities(card);
+	enforced_disc = qeth_enforce_discipline(card);
+	switch (enforced_disc) {
+	case QETH_DISCIPLINE_UNDETERMINED:
+		gdev->dev.type = &qeth_generic_devtype;
+		break;
+	default:
+		card->info.layer_enforced = true;
+		rc = qeth_core_load_discipline(card, enforced_disc);
 		if (rc)
 			goto err_card;
 
@@ -5659,16 +5688,11 @@ static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 		if (rc)
 			goto err_disc;
 		break;
-	default:
-		gdev->dev.type = &qeth_generic_devtype;
-		break;
 	}
 
 	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_add_tail(&card->list, &qeth_core_card_list.list);
 	write_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
-
-	qeth_determine_capabilities(card);
 	return 0;
 
 err_disc:
@@ -5705,7 +5729,7 @@ static int qeth_core_set_online(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
 	int rc = 0;
-	int def_discipline;
+	enum qeth_discipline_id def_discipline;
 
 	if (!card->discipline) {
 		if (card->info.type == QETH_CARD_TYPE_IQD)
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index db6a285d41e0..6d255c22656d 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -413,7 +413,7 @@ static ssize_t qeth_dev_layer2_store(struct device *dev,
 
 	if (card->options.layer2 == newdis)
 		goto out;
-	if (card->info.type == QETH_CARD_TYPE_OSM) {
+	if (card->info.layer_enforced) {
 		/* fixed layer, can't switch */
 		rc = -EOPNOTSUPP;
 		goto out;
-- 
2.11.2
