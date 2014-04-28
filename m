From: frank.blaschka@de.ibm.com
Subject: [patch 5/7] qeth: Add new priority queueing options
Date: Mon, 28 Apr 2014 10:05:09 +0200
Message-ID: <20140428080533.322295072@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:44217 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbaD1IFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:39 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:38 +0100
Content-Disposition: inline; filename=604-qeth-priority-options.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The existing options for priority queueing within OSA devices were based on
the now partially defunct TOS field. This patch adds two new options as
follows:
   - prio_queueing_skb: bases priority queueing on skb-priority
   - prio_queueing_vlan: uses the priority code point in the 802.1Q header

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 ++
 drivers/s390/net/qeth_core_main.c | 15 +++++++++++----
 drivers/s390/net/qeth_core_sys.c  | 14 ++++++++++++++
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 0a4148d..a2088af 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -268,6 +268,8 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_NO_PRIO_QUEUEING 0
 #define QETH_PRIO_Q_ING_PREC  1
 #define QETH_PRIO_Q_ING_TOS   2
+#define QETH_PRIO_Q_ING_SKB   3
+#define QETH_PRIO_Q_ING_VLAN  4
 
 /* Packing */
 #define QETH_LOW_WATERMARK_PACK  2
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index dca5161..34993009 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3677,12 +3677,9 @@ EXPORT_SYMBOL_GPL(qeth_qdio_output_handler);
 int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 			int ipv, int cast_type)
 {
+	__be16 *tci;
 	u8 tos;
 
-	if (!ipv && (card->info.type == QETH_CARD_TYPE_OSD ||
-		     card->info.type == QETH_CARD_TYPE_OSX))
-		return card->qdio.default_out_queue;
-
 	if (cast_type && card->info.is_multicast_different)
 		return card->info.is_multicast_different &
 			(card->qdio.no_out_queues - 1);
@@ -3710,6 +3707,16 @@ int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 			return 1;
 		if (tos & IPTOS_LOWDELAY)
 			return 0;
+		break;
+	case QETH_PRIO_Q_ING_SKB:
+		if (skb->priority > 5)
+			return 0;
+		return ~skb->priority >> 1 & 3;
+	case QETH_PRIO_Q_ING_VLAN:
+		tci = &((struct ethhdr *)skb->data)->h_proto;
+		if (*tci == ETH_P_8021Q)
+			return ~*(tci + 1) >> (VLAN_PRIO_SHIFT + 1) & 3;
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 8547de8..8a25a2b 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -217,6 +217,10 @@ static ssize_t qeth_dev_prioqing_show(struct device *dev,
 		return sprintf(buf, "%s\n", "by precedence");
 	case QETH_PRIO_Q_ING_TOS:
 		return sprintf(buf, "%s\n", "by type of service");
+	case QETH_PRIO_Q_ING_SKB:
+		return sprintf(buf, "%s\n", "by skb-priority");
+	case QETH_PRIO_Q_ING_VLAN:
+		return sprintf(buf, "%s\n", "by VLAN headers");
 	default:
 		return sprintf(buf, "always queue %i\n",
 			       card->qdio.default_out_queue);
@@ -253,9 +257,19 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 	if (!strcmp(tmp, "prio_queueing_prec")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_PREC;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	} else if (!strcmp(tmp, "prio_queueing_skb")) {
+		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_SKB;
+		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
 	} else if (!strcmp(tmp, "prio_queueing_tos")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_TOS;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	} else if (!strcmp(tmp, "prio_queueing_vlan")) {
+		if (!card->options.layer2) {
+			rc = -ENOTSUPP;
+			goto out;
+		}
+		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_VLAN;
+		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
 	} else if (!strcmp(tmp, "no_prio_queueing:0")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 0;
