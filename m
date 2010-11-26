From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] [PATCH] qeth: enable interface setup if LAN is offline
Date: Fri, 26 Nov 2010 13:41:19 +0100
Message-ID: <20101126124154.262472809@de.ibm.com>
References: <20101126124116.123736494@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:38106 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0KZMmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 07:42:18 -0500
Content-Disposition: inline; filename=603-qeth-recovery-offline.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Device initialization of a qeth device contains a STARTLAN step.
This step may fail, if cable is not yet plugged in. The qeth device
stays in state HARDSETUP until cable is plugged in. This prevents
further preparational initialization steps of the qeth device and
its network interface. This patch makes sure initialization of qeth
device continues, even though cable is not yet plugged in.
Once carrier is available, qeth is notified, triggers a recovery
which results in a working network interface.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   11 ++++++-----
 drivers/s390/net/qeth_l3_main.c |   11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -849,8 +849,6 @@ static int qeth_l2_open(struct net_devic
 	card->state = CARD_STATE_UP;
 	netif_start_queue(dev);
 
-	if (!card->lan_online && netif_carrier_ok(dev))
-		netif_carrier_off(dev);
 	if (qdio_stop_irq(card->data.ccwdev, 0) >= 0) {
 		napi_enable(&card->napi);
 		napi_schedule(&card->napi);
@@ -1013,13 +1011,14 @@ static int __qeth_l2_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
-			goto out;
+			goto contin;
 		}
 		rc = -ENODEV;
 		goto out_remove;
 	} else
 		card->lan_online = 1;
 
+contin:
 	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
 	    (card->info.type == QETH_CARD_TYPE_OSX))
 		/* configure isolation level */
@@ -1038,7 +1037,10 @@ static int __qeth_l2_set_online(struct c
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
-	netif_carrier_on(card->dev);
+	if (card->lan_online)
+		netif_carrier_on(card->dev);
+	else
+		netif_carrier_off(card->dev);
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
 	if (recover_flag == CARD_STATE_RECOVER) {
@@ -1055,7 +1057,6 @@ static int __qeth_l2_set_online(struct c
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
-out:
 	mutex_unlock(&card->conf_mutex);
 	mutex_unlock(&card->discipline_mutex);
 	return 0;
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3177,8 +3177,6 @@ static int qeth_l3_open(struct net_devic
 	card->state = CARD_STATE_UP;
 	netif_start_queue(dev);
 
-	if (!card->lan_online && netif_carrier_ok(dev))
-		netif_carrier_off(dev);
 	if (qdio_stop_irq(card->data.ccwdev, 0) >= 0) {
 		napi_enable(&card->napi);
 		napi_schedule(&card->napi);
@@ -3450,13 +3448,14 @@ static int __qeth_l3_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
-			goto out;
+			goto contin;
 		}
 		rc = -ENODEV;
 		goto out_remove;
 	} else
 		card->lan_online = 1;
 
+contin:
 	rc = qeth_l3_setadapter_parms(card);
 	if (rc)
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
@@ -3481,10 +3480,13 @@ static int __qeth_l3_set_online(struct c
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
-	netif_carrier_on(card->dev);
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
 	qeth_l3_set_ip_addr_list(card);
+	if (card->lan_online)
+		netif_carrier_on(card->dev);
+	else
+		netif_carrier_off(card->dev);
 	if (recover_flag == CARD_STATE_RECOVER) {
 		if (recovery_mode)
 			qeth_l3_open(card->dev);
@@ -3497,7 +3499,6 @@ static int __qeth_l3_set_online(struct c
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
-out:
 	mutex_unlock(&card->conf_mutex);
 	mutex_unlock(&card->discipline_mutex);
 	return 0;

