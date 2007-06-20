From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/8] s390: qeth driver does not recover
Date: Wed, 20 Jun 2007 12:56:49 +0200
Message-ID: <20070620105649.GB9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44688 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563AbXFTKxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:53:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KAriUU019552
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:53:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAricO558062
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:53:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAriBm018466
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

While first recovery continues, the card issues 
a STARTLAN command itself. In this case qeth 
schedules another recovery. This second
recovery is cancelled because of an already running first recovery.
Stop first recovery in case of 0xe080.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index ea2fd98..c5a9507 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -986,15 +986,15 @@ qeth_recover(void *ptr)
 	card->use_hard_stop = 1;
 	__qeth_set_offline(card->gdev,1);
 	rc = __qeth_set_online(card->gdev,1);
+	/* don't run another scheduled recovery */
+	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
+	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	if (!rc)
 		PRINT_INFO("Device %s successfully recovered!\n",
 			   CARD_BUS_ID(card));
 	else
 		PRINT_INFO("Device %s could not be recovered!\n",
 			   CARD_BUS_ID(card));
-	/* don't run another scheduled recovery */
-	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
-	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	return 0;
 }
 
@@ -7476,11 +7476,11 @@ qeth_softsetup_card(struct qeth_card *card)
 		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
 		if (rc == 0xe080){
 			PRINT_WARN("LAN on card %s if offline! "
-				   "Continuing softsetup.\n",
+				   "Waiting for STARTLAN from card.\n",
 				   CARD_BUS_ID(card));
 			card->lan_online = 0;
-		} else
-			return rc;
+		}
+		return rc;
 	} else
 		card->lan_online = 1;
 	if (card->info.type==QETH_CARD_TYPE_OSN)
-- 
1.5.2.1

