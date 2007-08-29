From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 5/7] s390: crash during reboot after failing online setting
Date: Wed, 29 Aug 2007 11:26:56 +0200
Message-ID: <20070829101851.054015000@linux.vnet.ibm.com>
References: <20070829092651.411517000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:31385 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbXH2KS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 06:18:58 -0400
Content-Disposition: inline; filename=709-qeth-crash.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Online setting of a qeth device may fail for instance because of:
- out-of-memory condition when allocating qdio queues
- IDX ACTIVATE problem
- ...
Such a device is still returned in a driver_for_each_device loop
processed in qeth_reboot_event(), which calls
qeth_clear_qdio_buffers(). Make sure qeth_clear_output_buffer() is
called only, if the qdio queues have been successfully allocated
during initialization of a qeth device.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -3356,10 +3356,12 @@ out_freeoutq:
 	while (i > 0)
 		kfree(card->qdio.out_qs[--i]);
 	kfree(card->qdio.out_qs);
+	card->qdio.out_qs = NULL;
 out_freepool:
 	qeth_free_buffer_pool(card);
 out_freeinq:
 	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
 out_nomem:
 	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
 	return -ENOMEM;
@@ -3375,16 +3377,20 @@ qeth_free_qdio_buffers(struct qeth_card 
 		QETH_QDIO_UNINITIALIZED)
 		return;
 	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
 	qeth_free_buffer_pool(card);
 	/* free outbound qdio_qs */
-	for (i = 0; i < card->qdio.no_out_queues; ++i){
-		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
-			qeth_clear_output_buffer(card->qdio.out_qs[i],
-					&card->qdio.out_qs[i]->bufs[j]);
-		kfree(card->qdio.out_qs[i]);
+	if (card->qdio.out_qs) {
+		for (i = 0; i < card->qdio.no_out_queues; ++i) {
+			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+				qeth_clear_output_buffer(card->qdio.out_qs[i],
+						&card->qdio.out_qs[i]->bufs[j]);
+			kfree(card->qdio.out_qs[i]);
+		}
+		kfree(card->qdio.out_qs);
+		card->qdio.out_qs = NULL;
 	}
-	kfree(card->qdio.out_qs);
 }
 
 static void
@@ -3395,7 +3401,7 @@ qeth_clear_qdio_buffers(struct qeth_card
 	QETH_DBF_TEXT(trace, 2, "clearqdbf");
 	/* clear outbound buffers to free skbs */
 	for (i = 0; i < card->qdio.no_out_queues; ++i)
-		if (card->qdio.out_qs[i]){
+		if (card->qdio.out_qs && card->qdio.out_qs[i]) {
 			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
 				qeth_clear_output_buffer(card->qdio.out_qs[i],
 						&card->qdio.out_qs[i]->bufs[j]);

-- 
