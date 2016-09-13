From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 04/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_is_neg_adv()
Date: Tue, 13 Sep 2016 21:23:59 +0530
Message-ID: <c1d0b6d9b21722a8770efd7f9e3a6d597e08657f.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47487 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758563AbcIMP5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:57:03 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_is_neg_adv() in libcxgb_cm.h to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 15 +++------------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h |  9 +++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 11 +----------
 3 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index a08a748..b35fdc0 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1987,15 +1987,6 @@ static inline int act_open_has_tid(int status)
 		status != CPL_ERR_CONN_EXIST);
 }
 
-/* Returns whether a CPL status conveys negative advice.
- */
-static int is_neg_adv(unsigned int status)
-{
-	return status == CPL_ERR_RTX_NEG_ADVICE ||
-	       status == CPL_ERR_PERSIST_NEG_ADVICE ||
-	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
-}
-
 static char *neg_adv_str(unsigned int status)
 {
 	switch (status) {
@@ -2235,7 +2226,7 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	PDBG("%s ep %p atid %u status %u errno %d\n", __func__, ep, atid,
 	     status, status2errno(status));
 
-	if (is_neg_adv(status)) {
+	if (cxgb_is_neg_adv(status)) {
 		PDBG("%s Connection problems for atid %u status %u (%s)\n",
 		     __func__, atid, status, neg_adv_str(status));
 		ep->stats.connect_neg_adv++;
@@ -2751,7 +2742,7 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 	if (!ep)
 		return 0;
 
-	if (is_neg_adv(req->status)) {
+	if (cxgb_is_neg_adv(req->status)) {
 		PDBG("%s Negative advice on abort- tid %u status %d (%s)\n",
 		     __func__, ep->hwtid, req->status,
 		     neg_adv_str(req->status));
@@ -4227,7 +4218,7 @@ static int peer_abort_intr(struct c4iw_dev *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return 0;
 	}
-	if (is_neg_adv(req->status)) {
+	if (cxgb_is_neg_adv(req->status)) {
 		PDBG("%s Negative advice on abort- tid %u status %d (%s)\n",
 		     __func__, ep->hwtid, req->status,
 		     neg_adv_str(req->status));
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index c4df04a..57fcc98 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -47,4 +47,13 @@ struct dst_entry *
 cxgb_find_route6(struct cxgb4_lld_info *,
 		 struct net_device *(*)(struct net_device *),
 		 __u8 *, __u8 *, __be16, __be16, u8, __u32);
+
+/* Returns whether a CPL status conveys negative advice.
+ */
+static inline bool cxgb_is_neg_adv(unsigned int status)
+{
+	return status == CPL_ERR_RTX_NEG_ADVICE ||
+	       status == CPL_ERR_PERSIST_NEG_ADVICE ||
+	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index e961ac4..c46bdd5 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -73,15 +73,6 @@ out:
 	return wr_waitp->ret;
 }
 
-/* Returns whether a CPL status conveys negative advice.
- */
-static int cxgbit_is_neg_adv(unsigned int status)
-{
-	return status == CPL_ERR_RTX_NEG_ADVICE ||
-		status == CPL_ERR_PERSIST_NEG_ADVICE ||
-		status == CPL_ERR_KEEPALV_NEG_ADVICE;
-}
-
 static int cxgbit_np_hashfn(const struct cxgbit_np *cnp)
 {
 	return ((unsigned long)cnp >> 10) & (NP_INFO_HASH_SIZE - 1);
@@ -1704,7 +1695,7 @@ static void cxgbit_abort_req_rss(struct cxgbit_sock *csk, struct sk_buff *skb)
 	pr_debug("%s: csk %p; tid %u; state %d\n",
 		 __func__, csk, tid, csk->com.state);
 
-	if (cxgbit_is_neg_adv(hdr->status)) {
+	if (cxgb_is_neg_adv(hdr->status)) {
 		pr_err("%s: got neg advise %d on tid %u\n",
 		       __func__, hdr->status, tid);
 		goto rel_skb;
-- 
2.0.2
