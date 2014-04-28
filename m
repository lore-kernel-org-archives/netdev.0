From: frank.blaschka@de.ibm.com
Subject: [patch 4/7] qeth: Extend priority queueing to IPv6
Date: Mon, 28 Apr 2014 10:05:08 +0200
Message-ID: <20140428080533.202435872@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:36217 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbaD1IFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:38 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:36 +0100
Content-Disposition: inline; filename=603-qeth-priority-ipv6.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Make the current priority queueing logic apply to IPv6 traffic.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  4 ---
 drivers/s390/net/qeth_core_main.c | 62 ++++++++++++++++++++++-----------------
 drivers/s390/net/qeth_l2_main.c   | 11 +++++--
 drivers/s390/net/qeth_l3_main.c   |  7 +++--
 4 files changed, 48 insertions(+), 36 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 5333b2c..0a4148d 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -268,10 +268,6 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_NO_PRIO_QUEUEING 0
 #define QETH_PRIO_Q_ING_PREC  1
 #define QETH_PRIO_Q_ING_TOS   2
-#define IP_TOS_LOWDELAY 0x10
-#define IP_TOS_HIGHTHROUGHPUT 0x08
-#define IP_TOS_HIGHRELIABILITY 0x04
-#define IP_TOS_NOTIMPORTANT 0x02
 
 /* Packing */
 #define QETH_LOW_WATERMARK_PACK  2
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index f5bd422..dca5161 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -20,6 +20,7 @@
 #include <linux/kthread.h>
 #include <linux/slab.h>
 #include <net/iucv/af_iucv.h>
+#include <net/dsfield.h>
 
 #include <asm/ebcdic.h>
 #include <asm/io.h>
@@ -3670,42 +3671,49 @@ void qeth_qdio_output_handler(struct ccw_device *ccwdev,
 }
 EXPORT_SYMBOL_GPL(qeth_qdio_output_handler);
 
+/**
+ * Note: Function assumes that we have 4 outbound queues.
+ */
 int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 			int ipv, int cast_type)
 {
+	u8 tos;
+
 	if (!ipv && (card->info.type == QETH_CARD_TYPE_OSD ||
 		     card->info.type == QETH_CARD_TYPE_OSX))
 		return card->qdio.default_out_queue;
-	switch (card->qdio.no_out_queues) {
-	case 4:
-		if (cast_type && card->info.is_multicast_different)
-			return card->info.is_multicast_different &
-				(card->qdio.no_out_queues - 1);
-		if (card->qdio.do_prio_queueing && (ipv == 4)) {
-			const u8 tos = ip_hdr(skb)->tos;
-
-			if (card->qdio.do_prio_queueing ==
-				QETH_PRIO_Q_ING_TOS) {
-				if (tos & IP_TOS_NOTIMPORTANT)
-					return 3;
-				if (tos & IP_TOS_HIGHRELIABILITY)
-					return 2;
-				if (tos & IP_TOS_HIGHTHROUGHPUT)
-					return 1;
-				if (tos & IP_TOS_LOWDELAY)
-					return 0;
-			}
-			if (card->qdio.do_prio_queueing ==
-				QETH_PRIO_Q_ING_PREC)
-				return 3 - (tos >> 6);
-		} else if (card->qdio.do_prio_queueing && (ipv == 6)) {
-			/* TODO: IPv6!!! */
+
+	if (cast_type && card->info.is_multicast_different)
+		return card->info.is_multicast_different &
+			(card->qdio.no_out_queues - 1);
+
+	switch (card->qdio.do_prio_queueing) {
+	case QETH_PRIO_Q_ING_TOS:
+	case QETH_PRIO_Q_ING_PREC:
+		switch (ipv) {
+		case 4:
+			tos = ipv4_get_dsfield(ip_hdr(skb));
+			break;
+		case 6:
+			tos = ipv6_get_dsfield(ipv6_hdr(skb));
+			break;
+		default:
+			return card->qdio.default_out_queue;
 		}
-		return card->qdio.default_out_queue;
-	case 1: /* fallthrough for single-out-queue 1920-device */
+		if (card->qdio.do_prio_queueing == QETH_PRIO_Q_ING_PREC)
+			return ~tos >> 6 & 3;
+		if (tos & IPTOS_MINCOST)
+			return 3;
+		if (tos & IPTOS_RELIABILITY)
+			return 2;
+		if (tos & IPTOS_THROUGHPUT)
+			return 1;
+		if (tos & IPTOS_LOWDELAY)
+			return 0;
 	default:
-		return card->qdio.default_out_queue;
+		break;
 	}
+	return card->qdio.default_out_queue;
 }
 EXPORT_SYMBOL_GPL(qeth_get_priority_queue);
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 8dea3f1..e232cec 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -725,15 +725,20 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int elements = 0;
 	struct qeth_card *card = dev->ml_priv;
 	struct sk_buff *new_skb = skb;
-	int ipv = qeth_get_ip_version(skb);
 	int cast_type = qeth_l2_get_cast_type(card, skb);
-	struct qeth_qdio_out_q *queue = card->qdio.out_qs
-		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
+	struct qeth_qdio_out_q *queue;
 	int tx_bytes = skb->len;
 	int data_offset = -1;
 	int elements_needed = 0;
 	int hd_len = 0;
 
+	if (card->qdio.do_prio_queueing || (cast_type &&
+					card->info.is_multicast_different))
+		queue = card->qdio.out_qs[qeth_get_priority_queue(card, skb,
+					qeth_get_ip_version(skb), cast_type)];
+	else
+		queue = card->qdio.out_qs[card->qdio.default_out_queue];
+
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
 		card->stats.tx_carrier_errors++;
 		goto tx_drop;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 3524d34..c8d91d7 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2926,8 +2926,11 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct sk_buff *new_skb = NULL;
 	int ipv = qeth_get_ip_version(skb);
 	int cast_type = qeth_l3_get_cast_type(card, skb);
-	struct qeth_qdio_out_q *queue = card->qdio.out_qs
-		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
+	struct qeth_qdio_out_q *queue =
+		card->qdio.out_qs[card->qdio.do_prio_queueing
+			|| (cast_type && card->info.is_multicast_different) ?
+			qeth_get_priority_queue(card, skb, ipv, cast_type) :
+			card->qdio.default_out_queue];
 	int tx_bytes = skb->len;
 	bool large_send;
 	int data_offset = -1;
