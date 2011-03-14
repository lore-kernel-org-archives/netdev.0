From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] [PATCH] qeth: change some configurations defaults
Date: Mon, 14 Mar 2011 14:20:54 +0100
Message-ID: <20110314132127.374926261@de.ibm.com>
References: <20110314132053.132019386@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:39482 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809Ab1CNNVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 09:21:32 -0400
Content-Disposition: inline; filename=603-qeth-defaults.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

This patch turns on RX checksum and GRO by default. To improve
receiving performance and reduce congestion in case of network
bursts we also increase the default number of inbound buffers.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core.h      |    3 ++-
 drivers/s390/net/qeth_core_main.c |    5 ++++-
 drivers/s390/net/qeth_l3_main.c   |    5 +++++
 3 files changed, 11 insertions(+), 2 deletions(-)
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -225,7 +225,8 @@ static inline int qeth_is_ipa_enabled(st
 /*****************************************************************************/
 #define QETH_MAX_QUEUES 4
 #define QETH_IN_BUF_SIZE_DEFAULT 65536
-#define QETH_IN_BUF_COUNT_DEFAULT 16
+#define QETH_IN_BUF_COUNT_DEFAULT 64
+#define QETH_IN_BUF_COUNT_HSDEFAULT 128
 #define QETH_IN_BUF_COUNT_MIN 8
 #define QETH_IN_BUF_COUNT_MAX 128
 #define QETH_MAX_BUFFER_ELEMENTS(card) ((card)->qdio.in_buf_size >> 12)
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1026,7 +1026,10 @@ static void qeth_init_qdio_info(struct q
 	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
 	/* inbound */
 	card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
-	card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_DEFAULT;
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_HSDEFAULT;
+	else
+		card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_DEFAULT;
 	card->qdio.in_buf_pool.buf_count = card->qdio.init_pool.buf_count;
 	INIT_LIST_HEAD(&card->qdio.in_buf_pool.entry_list);
 	INIT_LIST_HEAD(&card->qdio.init_pool.entry_list);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3392,6 +3392,8 @@ static int qeth_l3_setup_netdev(struct q
 			if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
 				card->dev->dev_id = card->info.unique_id &
 							 0xffff;
+			if (!card->info.guestlan)
+				card->dev->features |= NETIF_F_GRO;
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
 		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
@@ -3430,6 +3432,9 @@ static int qeth_l3_probe_device(struct c
 	card->discipline.output_handler = (qdio_handler_t *)
 		qeth_qdio_output_handler;
 	card->discipline.recover = qeth_l3_recover;
+	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
+	    (card->info.type == QETH_CARD_TYPE_OSX))
+		card->options.checksum_type = HW_CHECKSUMMING;
 	return 0;
 }
 

