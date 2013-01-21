From: frank.blaschka@de.ibm.com
Subject: [patch 5/6] [PATCH] qeth: Make s390dbf card entries persistent
Date: Mon, 21 Jan 2013 13:30:22 +0100
Message-ID: <20130121123037.645533798@de.ibm.com>
References: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:50600 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab3AUMam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:42 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:30:06 -0000
Content-Disposition: inline; filename=604-qeth-persistent-s390dbf.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

As of now, s390dbf entries for the cards are discarded as soon as the
device is removed. However, this will also bar us of all chances of
getting valuable debug information after a device has been removed.
This patch will keep the s390dbf entries around until the qeth module
is removed.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |   90 ++++++++++++++++++++++++++++++++------
 1 file changed, 78 insertions(+), 12 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5122,13 +5122,81 @@ static const struct device_type qeth_osn
 	.groups = qeth_osn_attr_groups,
 };
 
+#define DBF_NAME_LEN	20
+
+struct qeth_dbf_entry {
+	char dbf_name[DBF_NAME_LEN];
+	debug_info_t *dbf_info;
+	struct list_head dbf_list;
+};
+
+static LIST_HEAD(qeth_dbf_list);
+static DEFINE_MUTEX(qeth_dbf_list_mutex);
+
+static debug_info_t *qeth_get_dbf_entry(char *name)
+{
+	struct qeth_dbf_entry *entry;
+	debug_info_t *rc = NULL;
+
+	mutex_lock(&qeth_dbf_list_mutex);
+	list_for_each_entry(entry, &qeth_dbf_list, dbf_list) {
+		if (strcmp(entry->dbf_name, name) == 0) {
+			rc = entry->dbf_info;
+			break;
+		}
+	}
+	mutex_unlock(&qeth_dbf_list_mutex);
+	return rc;
+}
+
+static int qeth_add_dbf_entry(struct qeth_card *card, char *name)
+{
+	struct qeth_dbf_entry *new_entry;
+
+	card->debug = debug_register(name, 2, 1, 8);
+	if (!card->debug) {
+		QETH_DBF_TEXT_(SETUP, 2, "%s", "qcdbf");
+		goto err;
+	}
+	if (debug_register_view(card->debug, &debug_hex_ascii_view))
+		goto err_dbg;
+	new_entry = kzalloc(sizeof(struct qeth_dbf_entry), GFP_KERNEL);
+	if (!new_entry)
+		goto err_dbg;
+	strncpy(new_entry->dbf_name, name, DBF_NAME_LEN);
+	new_entry->dbf_info = card->debug;
+	mutex_lock(&qeth_dbf_list_mutex);
+	list_add(&new_entry->dbf_list, &qeth_dbf_list);
+	mutex_unlock(&qeth_dbf_list_mutex);
+
+	return 0;
+
+err_dbg:
+	debug_unregister(card->debug);
+err:
+	return -ENOMEM;
+}
+
+static void qeth_clear_dbf_list(void)
+{
+	struct qeth_dbf_entry *entry, *tmp;
+
+	mutex_lock(&qeth_dbf_list_mutex);
+	list_for_each_entry_safe(entry, tmp, &qeth_dbf_list, dbf_list) {
+		list_del(&entry->dbf_list);
+		debug_unregister(entry->dbf_info);
+		kfree(entry);
+	}
+	mutex_unlock(&qeth_dbf_list_mutex);
+}
+
 static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card;
 	struct device *dev;
 	int rc;
 	unsigned long flags;
-	char dbf_name[20];
+	char dbf_name[DBF_NAME_LEN];
 
 	QETH_DBF_TEXT(SETUP, 2, "probedev");
 
@@ -5147,13 +5215,12 @@ static int qeth_core_probe_device(struct
 
 	snprintf(dbf_name, sizeof(dbf_name), "qeth_card_%s",
 		dev_name(&gdev->dev));
-	card->debug = debug_register(dbf_name, 2, 1, 8);
+	card->debug = qeth_get_dbf_entry(dbf_name);
 	if (!card->debug) {
-		QETH_DBF_TEXT_(SETUP, 2, "%s", "qcdbf");
-		rc = -ENOMEM;
-		goto err_card;
+		rc = qeth_add_dbf_entry(card, dbf_name);
+		if (rc)
+			goto err_card;
 	}
-	debug_register_view(card->debug, &debug_hex_ascii_view);
 
 	card->read.ccwdev  = gdev->cdev[0];
 	card->write.ccwdev = gdev->cdev[1];
@@ -5167,12 +5234,12 @@ static int qeth_core_probe_device(struct
 	rc = qeth_determine_card_type(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
-		goto err_dbf;
+		goto err_card;
 	}
 	rc = qeth_setup_card(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
-		goto err_dbf;
+		goto err_card;
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -5185,7 +5252,7 @@ static int qeth_core_probe_device(struct
 	case QETH_CARD_TYPE_OSM:
 		rc = qeth_core_load_discipline(card, QETH_DISCIPLINE_LAYER2);
 		if (rc)
-			goto err_dbf;
+			goto err_card;
 		rc = card->discipline->setup(card->gdev);
 		if (rc)
 			goto err_disc;
@@ -5204,8 +5271,6 @@ static int qeth_core_probe_device(struct
 
 err_disc:
 	qeth_core_free_discipline(card);
-err_dbf:
-	debug_unregister(card->debug);
 err_card:
 	qeth_core_free_card(card);
 err_dev:
@@ -5225,7 +5290,6 @@ static void qeth_core_remove_device(stru
 		qeth_core_free_discipline(card);
 	}
 
-	debug_unregister(card->debug);
 	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_del(&card->list);
 	write_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
@@ -5579,6 +5643,7 @@ static int __init qeth_core_init(void)
 
 	pr_info("loading core functions\n");
 	INIT_LIST_HEAD(&qeth_core_card_list.list);
+	INIT_LIST_HEAD(&qeth_dbf_list);
 	rwlock_init(&qeth_core_card_list.rwlock);
 	mutex_init(&qeth_mod_mutex);
 
@@ -5630,6 +5695,7 @@ out_err:
 
 static void __exit qeth_core_exit(void)
 {
+	qeth_clear_dbf_list();
 	destroy_workqueue(qeth_wq);
 	ccwgroup_driver_unregister(&qeth_core_ccwgroup_driver);
 	ccw_driver_unregister(&qeth_ccw_driver);
