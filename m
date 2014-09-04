From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v4 1/3] net-timestamp: Merge shared code between
 phy and regular timestamping
Date: Thu, 04 Sep 2014 13:31:10 -0400
Message-ID: <20140904173040.7702.40237.stgit@ahduyck-bv4.jf.intel.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12641 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143AbaIDRjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 13:39:54 -0400
In-Reply-To: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change merges the shared bits that exist between skb_tx_tstamp and
skb_complete_tx_timestamp.  By doing this we can avoid the two diverging as
there were already changes pushed into skb_tx_tstamp that hadn't made it
into the other function.

In addition this resolves issues with the fact that
skb_complete_tx_timestamp was included in linux/skbuff.h even though it was
only compiled in if phy timestamping was enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

---

v2: Dropped comment and restored original order based on comments
    from Willem de Bruijn.
v3: No changes.
v4: No changes.

 net/core/skbuff.c       |   65 ++++++++++++++++++++++++++++++-----------------
 net/core/timestamping.c |   29 ---------------------
 2 files changed, 42 insertions(+), 52 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 53ce536..697e696 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,33 +3511,13 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
-void __skb_tstamp_tx(struct sk_buff *orig_skb,
-		     struct skb_shared_hwtstamps *hwtstamps,
-		     struct sock *sk, int tstype)
+static void __skb_complete_tx_timestamp(struct sk_buff *skb,
+					struct sock *sk,
+					int tstype)
 {
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb;
 	int err;
 
-	if (!sk)
-		return;
-
-	if (hwtstamps) {
-		*skb_hwtstamps(orig_skb) =
-			*hwtstamps;
-	} else {
-		/*
-		 * no hardware time stamps available,
-		 * so keep the shared tx_flags and only
-		 * store software time stamp
-		 */
-		orig_skb->tstamp = ktime_get_real();
-	}
-
-	skb = skb_clone(orig_skb, GFP_ATOMIC);
-	if (!skb)
-		return;
-
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
@@ -3554,6 +3534,45 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	if (err)
 		kfree_skb(skb);
 }
+
+void skb_complete_tx_timestamp(struct sk_buff *skb,
+			       struct skb_shared_hwtstamps *hwtstamps)
+{
+	struct sock *sk = skb->sk;
+
+	skb->sk = NULL;
+
+	if (hwtstamps) {
+		*skb_hwtstamps(skb) = *hwtstamps;
+		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
+	} else {
+		kfree_skb(skb);
+	}
+
+	sock_put(sk);
+}
+EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
+
+void __skb_tstamp_tx(struct sk_buff *orig_skb,
+		     struct skb_shared_hwtstamps *hwtstamps,
+		     struct sock *sk, int tstype)
+{
+	struct sk_buff *skb;
+
+	if (!sk)
+		return;
+
+	if (hwtstamps)
+		*skb_hwtstamps(orig_skb) = *hwtstamps;
+	else
+		orig_skb->tstamp = ktime_get_real();
+
+	skb = skb_clone(orig_skb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	__skb_complete_tx_timestamp(skb, sk, tstype);
+}
 EXPORT_SYMBOL_GPL(__skb_tstamp_tx);
 
 void skb_tstamp_tx(struct sk_buff *orig_skb,
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index a877039..f48a59f 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -63,35 +63,6 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(skb_clone_tx_timestamp);
 
-void skb_complete_tx_timestamp(struct sk_buff *skb,
-			       struct skb_shared_hwtstamps *hwtstamps)
-{
-	struct sock *sk = skb->sk;
-	struct sock_exterr_skb *serr;
-	int err;
-
-	if (!hwtstamps) {
-		sock_put(sk);
-		kfree_skb(skb);
-		return;
-	}
-
-	*skb_hwtstamps(skb) = *hwtstamps;
-
-	serr = SKB_EXT_ERR(skb);
-	memset(serr, 0, sizeof(*serr));
-	serr->ee.ee_errno = ENOMSG;
-	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
-	skb->sk = NULL;
-
-	err = sock_queue_err_skb(sk, skb);
-
-	sock_put(sk);
-	if (err)
-		kfree_skb(skb);
-}
-EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
-
 bool skb_defer_rx_timestamp(struct sk_buff *skb)
 {
 	struct phy_device *phydev;
