From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] qeth: no recovery after layer mismatch (z/VM NICs)
Date: Tue, 09 Mar 2010 07:36:56 +0100
Message-ID: <20100309063936.870978000@de.ibm.com>
References: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:35972 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab0CIGji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:38 -0500
Content-Disposition: inline; filename=605-qeth-layer-mismatch.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Depending on their definition in z/VM, virtual devices for z/VM 
VSWITCH or GuestLAN must be configured either in layer2 or in
layer3 mode. If qeth detects a layer mismatch, device activation
fails. Trying to recover from this error cannot help; thus
scheduling a recovery should be avoided.
In addition, since recovery is forbidden during online setting of
a qeth device, existence of its network device is guaranteed for all
dev_close() calls in qeth. The corresponding checks can be removed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    3 ++-
 drivers/s390/net/qeth_l2_main.c   |   16 ++++++----------
 drivers/s390/net/qeth_l3_main.c   |   16 ++++++----------
 3 files changed, 14 insertions(+), 21 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -537,7 +537,8 @@ static void qeth_send_control_data_cb(st
 			dev_err(&card->gdev->dev,
 				"The qeth device is not configured "
 				"for the OSI layer required by z/VM\n");
-		qeth_schedule_recovery(card);
+		else
+			qeth_schedule_recovery(card);
 		goto out;
 	}
 
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1071,11 +1071,9 @@ static int qeth_l2_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		if (card->dev) {
-			rtnl_lock();
-			dev_close(card->dev);
-			rtnl_unlock();
-		}
+		rtnl_lock();
+		dev_close(card->dev);
+		rtnl_unlock();
 		dev_warn(&card->gdev->dev, "The qeth device driver "
 			"failed to recover an error on the device\n");
 	}
@@ -1129,11 +1127,9 @@ static int qeth_l2_pm_resume(struct ccwg
 	if (card->state == CARD_STATE_RECOVER) {
 		rc = __qeth_l2_set_online(card->gdev, 1);
 		if (rc) {
-			if (card->dev) {
-				rtnl_lock();
-				dev_close(card->dev);
-				rtnl_unlock();
-			}
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
 		}
 	} else
 		rc = __qeth_l2_set_online(card->gdev, 0);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2219,11 +2219,9 @@ static int qeth_l3_stop_card(struct qeth
 		if (recovery_mode)
 			qeth_l3_stop(card->dev);
 		else {
-			if (card->dev) {
-				rtnl_lock();
-				dev_close(card->dev);
-				rtnl_unlock();
-			}
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
 		}
 		if (!card->use_hard_stop) {
 			rc = qeth_send_stoplan(card);
@@ -3536,11 +3534,9 @@ static int qeth_l3_pm_resume(struct ccwg
 	if (card->state == CARD_STATE_RECOVER) {
 		rc = __qeth_l3_set_online(card->gdev, 1);
 		if (rc) {
-			if (card->dev) {
-				rtnl_lock();
-				dev_close(card->dev);
-				rtnl_unlock();
-			}
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
 		}
 	} else
 		rc = __qeth_l3_set_online(card->gdev, 0);

