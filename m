From: frank.blaschka@de.ibm.com
Subject: [patch 03/11] [PATCH] qeth: Add new s390 debug feature for each qeth card
Date: Tue, 22 Jun 2010 10:57:04 +0200
Message-ID: <20100622085807.226194000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:47772 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=603-qeth-dbf-per-card.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch adds a debug area for each qeth card. This debug area will replace
various other debug areas that are global for all cards handled by the device
driver. On crash dump analysis this makes life easier when trying to find out
what's going on with an interface. Also, the forest of debug areas for this
device driver is significantly cleared up.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |   13 +++++++++++++
 drivers/s390/net/qeth_core_main.c |   21 ++++++++++++++++++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:54:58.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:54:58.000000000 +0200
@@ -73,6 +73,18 @@ struct qeth_dbf_info {
 #define QETH_DBF_TEXT_(name, level, text...) \
 	qeth_dbf_longtext(qeth_dbf[QETH_DBF_##name].id, level, text)
 
+#define QETH_CARD_TEXT(card, level, text) \
+	debug_text_event(card->debug, level, text)
+
+#define QETH_CARD_HEX(card, level, addr, len) \
+	debug_event(card->debug, level, (void *)(addr), len)
+
+#define QETH_CARD_MESSAGE(card, text...) \
+	debug_sprintf_event(card->debug, level, text)
+
+#define QETH_CARD_TEXT_(card, level, text...) \
+	qeth_dbf_longtext(card->debug, level, text)
+
 #define SENSE_COMMAND_REJECT_BYTE 0
 #define SENSE_COMMAND_REJECT_FLAG 0x80
 #define SENSE_RESETTING_EVENT_BYTE 1
@@ -738,6 +750,7 @@ struct qeth_card {
 	atomic_t force_alloc_skb;
 	struct service_level qeth_service_level;
 	struct qdio_ssqd_desc ssqd;
+	debug_info_t *debug;
 	struct mutex conf_mutex;
 };
 
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:58.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:58.000000000 +0200
@@ -4282,6 +4282,7 @@ static int qeth_core_probe_device(struct
 	struct device *dev;
 	int rc;
 	unsigned long flags;
+	char dbf_name[20];
 
 	QETH_DBF_TEXT(SETUP, 2, "probedev");
 
@@ -4297,6 +4298,17 @@ static int qeth_core_probe_device(struct
 		rc = -ENOMEM;
 		goto err_dev;
 	}
+
+	snprintf(dbf_name, sizeof(dbf_name), "qeth_card_%s",
+		dev_name(&gdev->dev));
+	card->debug = debug_register(dbf_name, 2, 1, 8);
+	if (!card->debug) {
+		QETH_DBF_TEXT_(SETUP, 2, "%s", "qcdbf");
+		rc = -ENOMEM;
+		goto err_card;
+	}
+	debug_register_view(card->debug, &debug_hex_ascii_view);
+
 	card->read.ccwdev  = gdev->cdev[0];
 	card->write.ccwdev = gdev->cdev[1];
 	card->data.ccwdev  = gdev->cdev[2];
@@ -4309,12 +4321,12 @@ static int qeth_core_probe_device(struct
 	rc = qeth_determine_card_type(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
-		goto err_card;
+		goto err_dbf;
 	}
 	rc = qeth_setup_card(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
-		goto err_card;
+		goto err_dbf;
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -4322,7 +4334,7 @@ static int qeth_core_probe_device(struct
 	else
 		rc = qeth_core_create_device_attributes(dev);
 	if (rc)
-		goto err_card;
+		goto err_dbf;
 	switch (card->info.type) {
 	case QETH_CARD_TYPE_OSN:
 	case QETH_CARD_TYPE_OSM:
@@ -4352,6 +4364,8 @@ err_attr:
 		qeth_core_remove_osn_attributes(dev);
 	else
 		qeth_core_remove_device_attributes(dev);
+err_dbf:
+	debug_unregister(card->debug);
 err_card:
 	qeth_core_free_card(card);
 err_dev:
@@ -4375,6 +4389,7 @@ static void qeth_core_remove_device(stru
 	} else {
 		qeth_core_remove_device_attributes(&gdev->dev);
 	}
+	debug_unregister(card->debug);
 	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_del(&card->list);
 	write_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);

