From: frank.blaschka@de.ibm.com
Subject: [patch 09/10] [PATCH] qeth: improve recovery during resource shortage
Date: Tue, 20 Dec 2011 09:56:35 +0100
Message-ID: <20111220085736.446526376@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:35209 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab1LTI5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:40 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:39 -0000
Content-Disposition: inline; filename=610-qeth-resource-shortage.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case there are no system resources to run a recovery we have to clear
recovery bitmasks so a further automatic or manual driven recovery can
fix up the device.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1329,6 +1329,7 @@ static int qeth_do_start_thread(struct q
 
 static void qeth_start_kernel_thread(struct work_struct *work)
 {
+	struct task_struct *ts;
 	struct qeth_card *card = container_of(work, struct qeth_card,
 					kernel_thread_starter);
 	QETH_CARD_TEXT(card , 2, "strthrd");
@@ -1336,9 +1337,15 @@ static void qeth_start_kernel_thread(str
 	if (card->read.state != CH_STATE_UP &&
 	    card->write.state != CH_STATE_UP)
 		return;
-	if (qeth_do_start_thread(card, QETH_RECOVER_THREAD))
-		kthread_run(card->discipline.recover, (void *) card,
+	if (qeth_do_start_thread(card, QETH_RECOVER_THREAD)) {
+		ts = kthread_run(card->discipline.recover, (void *)card,
 				"qeth_recover");
+		if (IS_ERR(ts)) {
+			qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
+			qeth_clear_thread_running_bit(card,
+				QETH_RECOVER_THREAD);
+		}
+	}
 }
 
 static int qeth_setup_card(struct qeth_card *card)
