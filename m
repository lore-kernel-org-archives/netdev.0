From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] [PATCH] qeth: avoid crash after detach of replugged device
Date: Wed, 20 May 2009 09:38:37 +0200
Message-ID: <20090520073927.687089000@de.ibm.com>
References: <20090520073836.897878000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:57039 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755303AbZETHja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:39:30 -0400
Content-Disposition: inline; filename=612-qeth-replug-crash.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If a qeth device is plugged off, setting the device online stops in
state HARDSETUP and a failure is reported to the base cio-layer
causing halt/clear to be invoked. Replugging the device again triggers
a qeth recovery without notification of the cio-layer. If a device
is ungrouped in this state, the qeth set_offline function is not
invoked, because the corresponding ccwgroup device is not in state
ONLINE. Then incoming traffic is still handled by the qdio layer
resulting in a crash in qeth_l<x>_qdio_input_handler, because (part
of) the qeth data structures for this device are already removed.
Solution: After replugging the device qeth recovery should lead to a
working net device. Thus a "LAN offline" result when setting a qeth
device online must not report a failure to the base cio-layer.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    4 +++-
 drivers/s390/net/qeth_l3_main.c |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-05-20 08:56:25.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-05-20 08:56:42.000000000 +0200
@@ -839,6 +839,7 @@ static void qeth_l2_remove_device(struct
 {
 	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
 
+	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
 	if (cgdev->state == CCWGROUP_ONLINE) {
@@ -974,8 +975,9 @@ static int __qeth_l2_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
+			return 0;
 		}
-		return rc;
+		goto out_remove;
 	} else
 		card->lan_online = 1;
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-05-20 08:56:25.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-05-20 08:56:42.000000000 +0200
@@ -3070,6 +3070,7 @@ static void qeth_l3_remove_device(struct
 {
 	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
 
+	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
 	if (cgdev->state == CCWGROUP_ONLINE) {
@@ -3141,8 +3142,9 @@ static int __qeth_l3_set_online(struct c
 			dev_warn(&card->gdev->dev,
 				"The LAN is offline\n");
 			card->lan_online = 0;
+			return 0;
 		}
-		return rc;
+		goto out_remove;
 	} else
 		card->lan_online = 1;
 	qeth_set_large_send(card, card->options.large_send);

