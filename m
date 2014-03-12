From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 09/31] iw_cxgb4: Treat CPL_ERR_KEEPALV_NEG_ADVICE as negative advice
Date: Wed, 12 Mar 2014 21:20:24 +0530
Message-ID: <1394639446-6504-10-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17072 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755316AbaCLP7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:59:22 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Based on original work by Anand Priyadarshee <anandp@chelsio.com>.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c            | 24 ++++++++++++------------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |  1 +
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 2b2af96..3629b52 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1648,6 +1648,15 @@ static inline int act_open_has_tid(int status)
 	       status != CPL_ERR_ARP_MISS;
 }
 
+/* Returns whether a CPL status conveys negative advice.
+ */
+static int is_neg_adv(unsigned int status)
+{
+	return status == CPL_ERR_RTX_NEG_ADVICE ||
+	       status == CPL_ERR_PERSIST_NEG_ADVICE ||
+	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
+}
+
 #define ACT_OPEN_RETRY_COUNT 2
 
 static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
@@ -1836,7 +1845,7 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	PDBG("%s ep %p atid %u status %u errno %d\n", __func__, ep, atid,
 	     status, status2errno(status));
 
-	if (status == CPL_ERR_RTX_NEG_ADVICE) {
+	if (is_neg_adv(status)) {
 		printk(KERN_WARNING MOD "Connection problems for atid %u\n",
 			atid);
 		return 0;
@@ -2266,15 +2275,6 @@ static int peer_close(struct c4iw_dev *dev, struct sk_buff *skb)
 	return 0;
 }
 
-/*
- * Returns whether an ABORT_REQ_RSS message is a negative advice.
- */
-static int is_neg_adv_abort(unsigned int status)
-{
-	return status == CPL_ERR_RTX_NEG_ADVICE ||
-	       status == CPL_ERR_PERSIST_NEG_ADVICE;
-}
-
 static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct cpl_abort_req_rss *req = cplhdr(skb);
@@ -2288,7 +2288,7 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 	unsigned int tid = GET_TID(req);
 
 	ep = lookup_tid(t, tid);
-	if (is_neg_adv_abort(req->status)) {
+	if (is_neg_adv(req->status)) {
 		PDBG("%s neg_adv_abort ep %p tid %u\n", __func__, ep,
 		     ep->hwtid);
 		return 0;
@@ -3571,7 +3571,7 @@ static int peer_abort_intr(struct c4iw_dev *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return 0;
 	}
-	if (is_neg_adv_abort(req->status)) {
+	if (is_neg_adv(req->status)) {
 		PDBG("%s neg_adv_abort ep %p tid %u\n", __func__, ep,
 		     ep->hwtid);
 		kfree_skb(skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index cd6874b..f2738c7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -116,6 +116,7 @@ enum CPL_error {
 	CPL_ERR_KEEPALIVE_TIMEDOUT = 34,
 	CPL_ERR_RTX_NEG_ADVICE     = 35,
 	CPL_ERR_PERSIST_NEG_ADVICE = 36,
+	CPL_ERR_KEEPALV_NEG_ADVICE = 37,
 	CPL_ERR_ABORT_FAILED       = 42,
 	CPL_ERR_IWARP_FLM          = 50,
 };
-- 
1.8.4
