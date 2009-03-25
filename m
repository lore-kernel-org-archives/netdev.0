From: frank.blaschka@de.ibm.com
Subject: [patch 2/6] [PATCH] qeth: add statistics for tx csum
Date: Wed, 25 Mar 2009 07:57:15 +0100
Message-ID: <20090325065808.829059000@de.ibm.com>
References: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:40048 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbZCYG6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:11 -0400
Content-Disposition: inline; filename=606-qeth-tx_csum-statistics.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Add statistics counter for software tx checksumming.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 +
 drivers/s390/net/qeth_core_main.c |    2 ++
 drivers/s390/net/qeth_l2_main.c   |    5 ++++-
 drivers/s390/net/qeth_l3_main.c   |    5 ++++-
 4 files changed, 11 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2009-02-18 12:06:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2009-02-18 12:06:31.000000000 +0100
@@ -134,6 +134,7 @@ struct qeth_perf_stats {
 	unsigned int sg_skbs_rx;
 	unsigned int sg_frags_rx;
 	unsigned int sg_alloc_page_rx;
+	unsigned int tx_csum;
 };
 
 /* Routing stuff */
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2009-02-18 12:06:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2009-02-18 12:06:31.000000000 +0100
@@ -4327,6 +4327,7 @@ static struct {
 /* 30 */{"tx count"},
 	{"tx do_QDIO time"},
 	{"tx do_QDIO count"},
+	{"tx csum"},
 };
 
 int qeth_core_get_stats_count(struct net_device *dev)
@@ -4378,6 +4379,7 @@ void qeth_core_get_ethtool_stats(struct 
 	data[30] = card->perf_stats.outbound_cnt;
 	data[31] = card->perf_stats.outbound_do_qdio_time;
 	data[32] = card->perf_stats.outbound_do_qdio_cnt;
+	data[33] = card->perf_stats.tx_csum;
 }
 EXPORT_SYMBOL_GPL(qeth_core_get_ethtool_stats);
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:14.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:31.000000000 +0100
@@ -707,8 +707,11 @@ static int qeth_l2_hard_start_xmit(struc
 	}
 
 	if ((large_send == QETH_LARGE_SEND_NO) &&
-	    (skb->ip_summed == CHECKSUM_PARTIAL))
+	    (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		qeth_tx_csum(new_skb);
+		if (card->options.performance_stats)
+			card->perf_stats.tx_csum++;
+	}
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2009-02-18 12:06:31.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2009-02-18 12:06:31.000000000 +0100
@@ -2711,8 +2711,11 @@ static int qeth_l3_hard_start_xmit(struc
 	}
 
 	if ((large_send == QETH_LARGE_SEND_NO) &&
-	    (new_skb->ip_summed == CHECKSUM_PARTIAL))
+	    (new_skb->ip_summed == CHECKSUM_PARTIAL)) {
 		qeth_tx_csum(new_skb);
+		if (card->options.performance_stats)
+			card->perf_stats.tx_csum++;
+	}
 
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,

