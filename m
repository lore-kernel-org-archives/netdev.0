From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net] qeth: postpone freeing of qdio memory
Date: Wed, 19 Feb 2014 10:14:51 +0100
Message-ID: <20140219091451.GA17591@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:60017 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbaBSJO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 04:14:57 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 09:14:55 -0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

To guarantee that a qdio ccw_device no longer touches the
qdio memory shared with Linux, the qdio ccw_device should
be offline when freeing the qdio memory. Thus this patch
postpones freeing of qdio memory.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    3 ++-
 drivers/s390/net/qeth_l2_main.c   |    3 +++
 drivers/s390/net/qeth_l3_main.c   |    3 +++
 3 files changed, 8 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1660,7 +1660,6 @@ int qeth_qdio_clear_card(struct qeth_car
 				QDIO_FLAG_CLEANUP_USING_CLEAR);
 		if (rc)
 			QETH_CARD_TEXT_(card, 3, "1err%d", rc);
-		qdio_free(CARD_DDEV(card));
 		atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
 		break;
 	case QETH_QDIO_CLEANING:
@@ -2605,6 +2604,7 @@ static int qeth_mpc_initialize(struct qe
 	return 0;
 out_qdio:
 	qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
+	qdio_free(CARD_DDEV(card));
 	return rc;
 }
 
@@ -4919,6 +4919,7 @@ retry:
 	if (rc)
 		goto retriable;
 	rc = qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
+	qdio_free(CARD_DDEV(card));
 retriable:
 	if (rc == -ERESTARTSYS) {
 		QETH_DBF_TEXT(SETUP, 2, "break1");
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1091,6 +1091,7 @@ out_remove:
 	ccw_device_set_offline(CARD_DDEV(card));
 	ccw_device_set_offline(CARD_WDEV(card));
 	ccw_device_set_offline(CARD_RDEV(card));
+	qdio_free(CARD_DDEV(card));
 	if (recover_flag == CARD_STATE_RECOVER)
 		card->state = CARD_STATE_RECOVER;
 	else
@@ -1132,6 +1133,7 @@ static int __qeth_l2_set_offline(struct
 		rc = (rc2) ? rc2 : rc3;
 	if (rc)
 		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
+	qdio_free(CARD_DDEV(card));
 	if (recover_flag == CARD_STATE_UP)
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
@@ -1194,6 +1196,7 @@ static void qeth_l2_shutdown(struct ccwg
 		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 	qeth_qdio_clear_card(card, 0);
 	qeth_clear_qdio_buffers(card);
+	qdio_free(CARD_DDEV(card));
 }
 
 static int qeth_l2_pm_suspend(struct ccwgroup_device *gdev)
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3447,6 +3447,7 @@ out_remove:
 	ccw_device_set_offline(CARD_DDEV(card));
 	ccw_device_set_offline(CARD_WDEV(card));
 	ccw_device_set_offline(CARD_RDEV(card));
+	qdio_free(CARD_DDEV(card));
 	if (recover_flag == CARD_STATE_RECOVER)
 		card->state = CARD_STATE_RECOVER;
 	else
@@ -3493,6 +3494,7 @@ static int __qeth_l3_set_offline(struct
 		rc = (rc2) ? rc2 : rc3;
 	if (rc)
 		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
+	qdio_free(CARD_DDEV(card));
 	if (recover_flag == CARD_STATE_UP)
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
@@ -3545,6 +3547,7 @@ static void qeth_l3_shutdown(struct ccwg
 		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 	qeth_qdio_clear_card(card, 0);
 	qeth_clear_qdio_buffers(card);
+	qdio_free(CARD_DDEV(card));
 }
 
 static int qeth_l3_pm_suspend(struct ccwgroup_device *gdev)
