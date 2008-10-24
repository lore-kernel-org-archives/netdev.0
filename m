From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] qeth: remove non-recover-thread checkings
Date: Fri, 24 Oct 2008 11:16:52 +0200
Message-ID: <20081024091730.972078000@de.ibm.com>
References: <20081024091651.603673000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:33734 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbYJXJRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:17:33 -0400
Content-Disposition: inline; filename=600-qeth-thread.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

IP-threads have been removed from the qeth driver. Only the
recover-thread is left over. This makes checkings for
non-recover threads superfluous.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   14 +-------------
 drivers/s390/net/qeth_l3_main.c |   13 +------------
 2 files changed, 2 insertions(+), 25 deletions(-)

Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c
+++ git_linus/drivers/s390/net/qeth_l2_main.c
@@ -373,8 +373,6 @@ static int qeth_l2_stop_card(struct qeth
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
-		return -ERESTARTSYS;
 	if (card->read.state == CH_STATE_UP &&
 	    card->write.state == CH_STATE_UP &&
 	    (card->state == CARD_STATE_UP)) {
@@ -975,12 +973,6 @@ static int __qeth_l2_set_online(struct c
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
-		PRINT_WARN("set_online of card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
-
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
 	if (rc) {
@@ -1091,11 +1083,7 @@ static int __qeth_l2_set_offline(struct 
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
-	if (qeth_l2_stop_card(card, recovery_mode) == -ERESTARTSYS) {
-		PRINT_WARN("Stopping card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
+	qeth_l2_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
 	rc3 = ccw_device_set_offline(CARD_RDEV(card));
Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c
+++ git_linus/drivers/s390/net/qeth_l3_main.c
@@ -2064,8 +2064,6 @@ static int qeth_l3_stop_card(struct qeth
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
-		return -ERESTARTSYS;
 	if (card->read.state == CH_STATE_UP &&
 	    card->write.state == CH_STATE_UP &&
 	    (card->state == CARD_STATE_UP)) {
@@ -3049,11 +3047,6 @@ static int __qeth_l3_set_online(struct c
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
-		PRINT_WARN("set_online of card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
 
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
@@ -3170,11 +3163,7 @@ static int __qeth_l3_set_offline(struct 
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
-	if (qeth_l3_stop_card(card, recovery_mode) == -ERESTARTSYS) {
-		PRINT_WARN("Stopping card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
+	qeth_l3_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
 	rc3 = ccw_device_set_offline(CARD_RDEV(card));

-- 
