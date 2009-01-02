From: frank.blaschka@de.ibm.com
Subject: [patch 3/6] qeth: avoid crash in case of layer mismatch for VSWITCH
Date: Fri, 02 Jan 2009 16:01:42 +0100
Message-ID: <20090102150254.617580000@de.ibm.com>
References: <20090102150139.830998000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:45850 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbZABPC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 10:02:58 -0500
Content-Disposition: inline; filename=607-qeth-layercrash.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For z/VM GuestLAN or VSWITCH devices the transport layer is
configured in z/VM. The layer2 attribute of a participating Linux
device has to match the z/VM definition. In case of a mismatch
Linux currently crashes in qeth recovery due to a reference to the
not yet existing net_device.
Solution: add a check for existence of net_device and add a message
pointing to the mismatch of layer definitions in Linux and z/VM.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    4 ++++
 drivers/s390/net/qeth_l2_main.c   |    8 +++++---
 drivers/s390/net/qeth_l3_main.c   |    8 +++++---
 3 files changed, 14 insertions(+), 6 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:07.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-01-02 10:22:07.000000000 +0100
@@ -572,6 +572,10 @@ static void qeth_send_control_data_cb(st
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	if (qeth_check_idx_response(iob->data)) {
 		qeth_clear_ipacmd_list(card);
+		if (((iob->data[2] & 0xc0) == 0xc0) && iob->data[4] == 0xf6)
+			dev_err(&card->gdev->dev,
+				"The qeth device is not configured "
+				"for the OSI layer required by z/VM\n");
 		qeth_schedule_recovery(card);
 		goto out;
 	}
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-01-02 10:21:51.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-01-02 10:22:07.000000000 +0100
@@ -1126,9 +1126,11 @@ static int qeth_l2_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		rtnl_lock();
-		dev_close(card->dev);
-		rtnl_unlock();
+		if (card->dev) {
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
+		}
 		dev_warn(&card->gdev->dev, "The qeth device driver "
 			"failed to recover an error on the device\n");
 	}
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-01-02 10:22:07.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-01-02 10:22:07.000000000 +0100
@@ -2082,9 +2082,11 @@ static int qeth_l3_stop_card(struct qeth
 		if (recovery_mode)
 			qeth_l3_stop(card->dev);
 		else {
-			rtnl_lock();
-			dev_close(card->dev);
-			rtnl_unlock();
+			if (card->dev) {
+				rtnl_lock();
+				dev_close(card->dev);
+				rtnl_unlock();
+			}
 		}
 		if (!card->use_hard_stop) {
 			rc = qeth_send_stoplan(card);

-- 
