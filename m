From: frank.blaschka@de.ibm.com
Subject: [patch 02/13] [PATCH] qeth: do not apply priority queuing to HiperSockets
Date: Mon, 08 Aug 2011 13:33:48 +0200
Message-ID: <20110808113515.489806765@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33051 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
Content-Disposition: inline; filename=qeth-nr-outq.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

OSA cards can be configured to support 1 or 4 output queues. This
does not apply to HiperSockets. This patch limits determination of
the configured number of output queues to OSA cards only, but excludes
HiperSockets.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 qeth_core_main.c |   40 +++++++++++++++++++++-------------------
 1 file changed, 21 insertions(+), 19 deletions(-)

--- linux-2.5/drivers/s390/net/qeth_core_main.c	22 Jul 2011 08:38:02 -0000	1.119
+++ linux-2.5/drivers/s390/net/qeth_core_main.c	4 Aug 2011 07:02:55 -0000	1.120
@@ -995,27 +995,29 @@ static void qeth_get_channel_path_desc(s
 	ccwdev = card->data.ccwdev;
 	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
 	if (chp_dsc != NULL) {
-		/* CHPP field bit 6 == 1 -> single queue */
-		if ((chp_dsc->chpp & 0x02) == 0x02) {
-			if ((atomic_read(&card->qdio.state) !=
-				QETH_QDIO_UNINITIALIZED) &&
-			    (card->qdio.no_out_queues == 4))
-				/* change from 4 to 1 outbound queues */
-				qeth_free_qdio_buffers(card);
-			card->qdio.no_out_queues = 1;
-			if (card->qdio.default_out_queue != 0)
-				dev_info(&card->gdev->dev,
+		if (card->info.type != QETH_CARD_TYPE_IQD) {
+			/* CHPP field bit 6 == 1 -> single queue */
+			if ((chp_dsc->chpp & 0x02) == 0x02) {
+				if ((atomic_read(&card->qdio.state) !=
+					QETH_QDIO_UNINITIALIZED) &&
+				    (card->qdio.no_out_queues == 4))
+					/* change from 4 to 1 outbound queues */
+					qeth_free_qdio_buffers(card);
+				card->qdio.no_out_queues = 1;
+				if (card->qdio.default_out_queue != 0)
+					dev_info(&card->gdev->dev,
 					"Priority Queueing not supported\n");
-			card->qdio.default_out_queue = 0;
-		} else {
-			if ((atomic_read(&card->qdio.state) !=
-				QETH_QDIO_UNINITIALIZED) &&
-			    (card->qdio.no_out_queues == 1)) {
-				/* change from 1 to 4 outbound queues */
-				qeth_free_qdio_buffers(card);
-				card->qdio.default_out_queue = 2;
+				card->qdio.default_out_queue = 0;
+			} else {
+				if ((atomic_read(&card->qdio.state) !=
+					QETH_QDIO_UNINITIALIZED) &&
+				    (card->qdio.no_out_queues == 1)) {
+					/* change from 1 to 4 outbound queues */
+					qeth_free_qdio_buffers(card);
+					card->qdio.default_out_queue = 2;
+				}
+				card->qdio.no_out_queues = 4;
 			}
-			card->qdio.no_out_queues = 4;
 		}
 		card->info.func_level = 0x4100 + chp_dsc->desc;
 		kfree(chp_dsc);

