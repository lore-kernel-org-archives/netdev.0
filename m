From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/3] s390/qeth: size calculation outbound buffers
Date: Thu, 23 Mar 2017 14:55:08 +0100
Message-ID: <20170323135510.98972-2-ubraun@linux.vnet.ibm.com>
References: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42364 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755863AbdCWNzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:55:24 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2NDrqL4026159
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29c4yw7j7b-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 23 Mar 2017 13:55:17 -0000
In-Reply-To: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Depending on the device type, hard_start_xmit() builds different output
buffer formats. For instance with HiperSockets, on both L2 and L3 we
strip the ETH header from the skb - L3 doesn't need it, and L2 carries
it in the buffer's header element.
For this, we pass data_offset = ETH_HLEN all the way down to
__qeth_fill_buffer(), where skb->data is then adjusted accordingly.
But the initial size calculation still considers the *full* skb length
(including the ETH header). So qeth_get_elements_no() can erroneously
reject a skb as too big, even though it would actually fit into an
output buffer once the ETH header has been trimmed off later.

Fix this by passing an additional offset to qeth_get_elements_no(),
that indicates where in the skb the on-wire data actually begins.
Since the current code uses data_offset=-1 for some special handling
on OSA, we need to clamp data_offset to 0...

On HiperSockets this helps when sending ~MTU-size skbs with weird page
alignment. No change for OSA or AF_IUCV.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 3 ++-
 drivers/s390/net/qeth_core_main.c | 5 +++--
 drivers/s390/net/qeth_l2_main.c   | 5 +++--
 drivers/s390/net/qeth_l3_main.c   | 5 +++--
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index e7addea..d9561e3 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -961,7 +961,8 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role);
 int qeth_bridgeport_an_set(struct qeth_card *card, int enable);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
-int qeth_get_elements_no(struct qeth_card *, struct sk_buff *, int);
+int qeth_get_elements_no(struct qeth_card *card, struct sk_buff *skb,
+			 int extra_elems, int data_offset);
 int qeth_get_elements_for_frags(struct sk_buff *);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int, int, int);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 315d8a2..9a5f99c 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3837,6 +3837,7 @@ EXPORT_SYMBOL_GPL(qeth_get_elements_for_frags);
  * @card:			qeth card structure, to check max. elems.
  * @skb:			SKB address
  * @extra_elems:		extra elems needed, to check against max.
+ * @data_offset:		range starts at skb->data + data_offset
  *
  * Returns the number of pages, and thus QDIO buffer elements, needed to cover
  * skb data, including linear part and fragments. Checks if the result plus
@@ -3844,10 +3845,10 @@ EXPORT_SYMBOL_GPL(qeth_get_elements_for_frags);
  * Note: extra_elems is not included in the returned result.
  */
 int qeth_get_elements_no(struct qeth_card *card,
-		     struct sk_buff *skb, int extra_elems)
+		     struct sk_buff *skb, int extra_elems, int data_offset)
 {
 	int elements = qeth_get_elements_for_range(
-				(addr_t)skb->data,
+				(addr_t)skb->data + data_offset,
 				(addr_t)skb->data + skb_headlen(skb)) +
 			qeth_get_elements_for_frags(skb);
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index bea4833..af4e6a6 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -849,7 +849,7 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * chaining we can not send long frag lists
 	 */
 	if ((card->info.type != QETH_CARD_TYPE_IQD) &&
-	    !qeth_get_elements_no(card, new_skb, 0)) {
+	    !qeth_get_elements_no(card, new_skb, 0, 0)) {
 		int lin_rc = skb_linearize(new_skb);
 
 		if (card->options.performance_stats) {
@@ -894,7 +894,8 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	elements = qeth_get_elements_no(card, new_skb, elements_needed);
+	elements = qeth_get_elements_no(card, new_skb, elements_needed,
+					(data_offset > 0) ? data_offset : 0);
 	if (!elements) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 06d0add..72aa953 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2867,7 +2867,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if ((card->info.type != QETH_CARD_TYPE_IQD) &&
 	    ((use_tso && !qeth_l3_get_elements_no_tso(card, new_skb, 1)) ||
-	     (!use_tso && !qeth_get_elements_no(card, new_skb, 0)))) {
+	     (!use_tso && !qeth_get_elements_no(card, new_skb, 0, 0)))) {
 		int lin_rc = skb_linearize(new_skb);
 
 		if (card->options.performance_stats) {
@@ -2909,7 +2909,8 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	elements = use_tso ?
 		   qeth_l3_get_elements_no_tso(card, new_skb, hdr_elements) :
-		   qeth_get_elements_no(card, new_skb, hdr_elements);
+		   qeth_get_elements_no(card, new_skb, hdr_elements,
+					(data_offset > 0) ? data_offset : 0);
 	if (!elements) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
-- 
2.8.4
