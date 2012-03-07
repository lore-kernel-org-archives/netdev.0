From: frank.blaschka@de.ibm.com
Subject: [patch 3/7] [PATCH] qeth: synchronize discipline module loading
Date: Wed, 07 Mar 2012 13:06:25 +0100
Message-ID: <20120307120707.827023000@de.ibm.com>
References: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:39417 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513Ab2CGMHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:46 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:44 -0000
Content-Disposition: inline; filename=610-qeth-sync-modules.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

During system startup udev may try to configure devices in
parallel so we have to synchronize discipline module
loading.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2012-03-06 13:35:59.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2012-03-06 13:35:59.000000000 +0100
@@ -51,6 +51,7 @@ static struct kmem_cache *qeth_qdio_outb
 static struct device *qeth_core_root_dev;
 static unsigned int known_devices[][6] = QETH_MODELLIST_ARRAY;
 static struct lock_class_key qdio_out_skb_queue_key;
+static struct mutex qeth_mod_mutex;
 
 static void qeth_send_control_data_cb(struct qeth_channel *,
 			struct qeth_cmd_buffer *);
@@ -5040,6 +5041,7 @@ int qeth_core_load_discipline(struct qet
 		enum qeth_discipline_id discipline)
 {
 	int rc = 0;
+	mutex_lock(&qeth_mod_mutex);
 	switch (discipline) {
 	case QETH_DISCIPLINE_LAYER3:
 		card->discipline.ccwgdriver = try_then_request_module(
@@ -5057,6 +5059,7 @@ int qeth_core_load_discipline(struct qet
 			"support discipline %d\n", discipline);
 		rc = -EINVAL;
 	}
+	mutex_unlock(&qeth_mod_mutex);
 	return rc;
 }
 
@@ -5540,6 +5543,7 @@ static int __init qeth_core_init(void)
 	pr_info("loading core functions\n");
 	INIT_LIST_HEAD(&qeth_core_card_list.list);
 	rwlock_init(&qeth_core_card_list.rwlock);
+	mutex_init(&qeth_mod_mutex);
 
 	rc = qeth_register_dbf_views();
 	if (rc)
