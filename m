From: frank.blaschka@de.ibm.com
Subject: [patch 08/11] qeth: layer 3 add missing dev_open/close to ccwgroup handler
Date: Thu, 24 Apr 2008 10:15:25 +0200
Message-ID: <20080424081907.286652000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:41690 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbYDXITK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:10 -0400
Content-Disposition: inline; filename=707-qeth-openclose.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case the ccwgroup device is set online/offline we have to run
the corresponding dev_open/close for the netdevice.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:52.000000000 +0200
@@ -2091,6 +2091,11 @@ static int qeth_l3_stop_card(struct qeth
 	    (card->state == CARD_STATE_UP)) {
 		if (recovery_mode)
 			qeth_l3_stop(card->dev);
+		else {
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
+		}
 		if (!card->use_hard_stop) {
 			rc = qeth_send_stoplan(card);
 			if (rc)
@@ -3135,9 +3140,15 @@ static int __qeth_l3_set_online(struct c
 	netif_carrier_on(card->dev);
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
-	if ((recover_flag == CARD_STATE_RECOVER) && recovery_mode) {
+	if (recover_flag == CARD_STATE_RECOVER) {
+		if (recovery_mode)
 			qeth_l3_open(card->dev);
-			qeth_l3_set_multicast_list(card->dev);
+		else {
+			rtnl_lock();
+			dev_open(card->dev);
+			rtnl_unlock();
+		}
+		qeth_l3_set_multicast_list(card->dev);
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);

-- 
