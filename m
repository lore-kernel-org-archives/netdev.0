From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] qeth: postpone open till recovery is finished
Date: Thu, 13 Jan 2011 07:42:24 +0100
Message-ID: <20110113064310.564184240@de.ibm.com>
References: <20110113064223.429450048@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:52013 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab1AMGnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 01:43:13 -0500
Content-Disposition: inline; filename=601-qeth-postpone-open.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The open function of qeth is not executed if the qeth device is in
state DOWN or HARDSETUP. A recovery switches from state SOFTSETUP to 
HARDSETUP to DOWN to HARDSETUP and back to SOFTSETUP. If open and
recover are running concurrently, open fails if it hits the states
HARDSETUP or DOWN. This patch inserts waiting for recovery finish
in the qeth open functions to enable successful qeth device opening
in spite of a running recovery.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   18 ++++++++++++++++--
 drivers/s390/net/qeth_l3_main.c |   18 ++++++++++++++++--
 2 files changed, 32 insertions(+), 4 deletions(-)

--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -831,12 +831,14 @@ tx_drop:
 	return NETDEV_TX_OK;
 }
 
-static int qeth_l2_open(struct net_device *dev)
+static int __qeth_l2_open(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
 	int rc = 0;
 
 	QETH_CARD_TEXT(card, 4, "qethopen");
+	if (card->state == CARD_STATE_UP)
+		return rc;
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 
@@ -857,6 +859,18 @@ static int qeth_l2_open(struct net_devic
 	return rc;
 }
 
+static int qeth_l2_open(struct net_device *dev)
+{
+	struct qeth_card *card = dev->ml_priv;
+
+	QETH_CARD_TEXT(card, 5, "qethope_");
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_CARD_TEXT(card, 3, "openREC");
+		return -ERESTARTSYS;
+	}
+	return __qeth_l2_open(dev);
+}
+
 static int qeth_l2_stop(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
@@ -1046,7 +1060,7 @@ contin:
 	if (recover_flag == CARD_STATE_RECOVER) {
 		if (recovery_mode &&
 		    card->info.type != QETH_CARD_TYPE_OSN) {
-			qeth_l2_open(card->dev);
+			__qeth_l2_open(card->dev);
 		} else {
 			rtnl_lock();
 			dev_open(card->dev);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3240,12 +3240,14 @@ tx_drop:
 	return NETDEV_TX_OK;
 }
 
-static int qeth_l3_open(struct net_device *dev)
+static int __qeth_l3_open(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
 	int rc = 0;
 
 	QETH_CARD_TEXT(card, 4, "qethopen");
+	if (card->state == CARD_STATE_UP)
+		return rc;
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 	card->data.state = CH_STATE_UP;
@@ -3260,6 +3262,18 @@ static int qeth_l3_open(struct net_devic
 	return rc;
 }
 
+static int qeth_l3_open(struct net_device *dev)
+{
+	struct qeth_card *card = dev->ml_priv;
+
+	QETH_CARD_TEXT(card, 5, "qethope_");
+	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
+		QETH_CARD_TEXT(card, 3, "openREC");
+		return -ERESTARTSYS;
+	}
+	return __qeth_l3_open(dev);
+}
+
 static int qeth_l3_stop(struct net_device *dev)
 {
 	struct qeth_card *card = dev->ml_priv;
@@ -3564,7 +3578,7 @@ contin:
 		netif_carrier_off(card->dev);
 	if (recover_flag == CARD_STATE_RECOVER) {
 		if (recovery_mode)
-			qeth_l3_open(card->dev);
+			__qeth_l3_open(card->dev);
 		else {
 			rtnl_lock();
 			dev_open(card->dev);

