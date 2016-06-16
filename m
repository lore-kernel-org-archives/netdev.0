From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/13] qeth: clean up condition when tso is used
Date: Thu, 16 Jun 2016 16:18:53 +0200
Message-ID: <1466086743-55484-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:33240 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754475AbcFPOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:35 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIxsg055466
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:29 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kpn0hmyn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:29 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:26 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Make conditions under which TSO is activated more stringent.
Make calculation of SBALEs required for the skb more accurate.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h    |  6 ++++++
 drivers/s390/net/qeth_l3_main.c | 44 ++++++++++++++++++++++-------------------
 2 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index eb8f434..c3ab956 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -19,6 +19,7 @@
 #include <linux/seq_file.h>
 #include <linux/ethtool.h>
 #include <linux/hashtable.h>
+#include <linux/ip.h>
 
 #include <net/ipv6.h>
 #include <net/if_inet6.h>
@@ -878,6 +879,11 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
 	}
 }
 
+static inline int qeth_get_ip_protocol(struct sk_buff *skb)
+{
+	return ip_hdr(skb)->protocol;
+}
+
 static inline void qeth_put_buffer_pool_entry(struct qeth_card *card,
 		struct qeth_buffer_pool_entry *entry)
 {
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 7c9968a..86b3bc2 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2794,10 +2794,10 @@ static void qeth_tso_fill_header(struct qeth_card *card,
 }
 
 /**
- * qeth_get_elements_no_tso() - find number of SBALEs for skb data, inc. frags.
- * @card:			qeth card structure, to check max. elems.
- * @skb:			SKB address
- * @extra_elems:		extra elems needed, to check against max.
+ * qeth_l3_get_elements_no_tso() - find number of SBALEs for skb data for tso
+ * @card:			   qeth card structure, to check max. elems.
+ * @skb:			   SKB address
+ * @extra_elems:		   extra elems needed, to check against max.
  *
  * Returns the number of pages, and thus QDIO buffer elements, needed to cover
  * skb data, including linear part and fragments, but excluding TCP header.
@@ -2806,7 +2806,7 @@ static void qeth_tso_fill_header(struct qeth_card *card,
  * Returns 0 if it does not.
  * Note: extra_elems is not included in the returned result.
  */
-static int qeth_get_elements_no_tso(struct qeth_card *card,
+static int qeth_l3_get_elements_no_tso(struct qeth_card *card,
 			struct sk_buff *skb, int extra_elems)
 {
 	addr_t tcpdptr = (addr_t)tcp_hdr(skb) + tcp_hdrlen(skb);
@@ -2841,7 +2841,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			qeth_get_priority_queue(card, skb, ipv, cast_type) :
 			card->qdio.default_out_queue];
 	int tx_bytes = skb->len;
-	bool large_send;
+	bool use_tso;
 	int data_offset = -1;
 	int nr_frags;
 
@@ -2866,10 +2866,12 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		card->perf_stats.outbound_start_time = qeth_get_micros();
 	}
 
-	large_send = skb_is_gso(skb);
+	/* Ignore segment size from skb_is_gso(), 1 page is always used. */
+	use_tso = skb_is_gso(skb) &&
+		  (qeth_get_ip_protocol(skb) == IPPROTO_TCP) && (ipv == 4);
 
-	if ((card->info.type == QETH_CARD_TYPE_IQD) && (!large_send) &&
-	    (skb_shinfo(skb)->nr_frags == 0)) {
+	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
+	    !skb_is_nonlinear(skb)) {
 		new_skb = skb;
 		if (new_skb->protocol == ETH_P_AF_IUCV)
 			data_offset = 0;
@@ -2913,16 +2915,16 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* fix hardware limitation: as long as we do not have sbal
 	 * chaining we can not send long frag lists
 	 */
-	if (large_send) {
-		if (!qeth_get_elements_no_tso(card, new_skb, 1)) {
-			if (skb_linearize(new_skb))
-				goto tx_drop;
-			if (card->options.performance_stats)
-				card->perf_stats.tx_lin++;
-		}
+	if ((card->info.type != QETH_CARD_TYPE_IQD) &&
+	    ((use_tso && !qeth_l3_get_elements_no_tso(card, new_skb, 1)) ||
+	     (!use_tso && !qeth_get_elements_no(card, new_skb, 0)))) {
+		if (skb_linearize(new_skb))
+			goto tx_drop;
+		if (card->options.performance_stats)
+			card->perf_stats.tx_lin++;
 	}
 
-	if (large_send && (cast_type == RTN_UNSPEC)) {
+	if (use_tso) {
 		hdr = (struct qeth_hdr *)skb_push(new_skb,
 						sizeof(struct qeth_hdr_tso));
 		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
@@ -2949,7 +2951,9 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			qeth_l3_hdr_csum(card, hdr, new_skb);
 	}
 
-	elements = qeth_get_elements_no(card, new_skb, hdr_elements);
+	elements = use_tso ?
+		   qeth_l3_get_elements_no_tso(card, new_skb, hdr_elements) :
+		   qeth_get_elements_no(card, new_skb, hdr_elements);
 	if (!elements) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
@@ -2959,7 +2963,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (card->info.type != QETH_CARD_TYPE_IQD) {
 		int len;
-		if (large_send)
+		if (use_tso)
 			len = ((unsigned long)tcp_hdr(new_skb) +
 				tcp_hdrlen(new_skb)) -
 				(unsigned long)new_skb->data;
@@ -2980,7 +2984,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb_any(skb);
 		if (card->options.performance_stats) {
 			nr_frags = skb_shinfo(new_skb)->nr_frags;
-			if (large_send) {
+			if (use_tso) {
 				card->perf_stats.large_send_bytes += tx_bytes;
 				card->perf_stats.large_send_cnt++;
 			}
-- 
2.6.6
