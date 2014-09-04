From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Thu, 04 Sep 2014 13:31:35 -0400
Message-ID: <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31568 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbaIDRjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 13:39:25 -0400
In-Reply-To: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy timestamping takes a different path than the regular timestamping
does in that it will create a clone first so that the packets needing to be
timestamped can be placed in a queue, or the context block could be used.

In order to support these use cases I am pulling the core of the code out
so it can be used in other drivers beyond just phy devices.

In addition I have added a destructor named sock_efree which is meant to
provide a simple way for dropping the reference to skb exceptions that
aren't part of either the receive or send windows for the socket, and I
have removed some duplication in spots where this destructor could be used
in place of sock_edemux.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

---

v2: Renamed function to skb_clone_sk.
    Added destructor to call sock_put instead of doing it ourselves.
    Dropped freeing functionality from skb_complete_tx_timestamp.
    Added additional documentation to the code.

v3: Renamed destructor sock_efree and moved to sock.c/h
    Added sock_hold/sock_put around call to sock_queue_err_skb

v4: Dropped combining sock_edemux with sock_efree where the 2 are identical

 drivers/net/phy/dp83640.c |    6 +++---
 include/linux/skbuff.h    |    2 ++
 include/net/sock.h        |    1 +
 net/core/skbuff.c         |   32 +++++++++++++++++++++++++-------
 net/core/sock.c           |    6 ++++++
 net/core/timestamping.c   |   14 +++-----------
 6 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index d5991ac..87648b3 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1148,7 +1148,7 @@ static void dp83640_remove(struct phy_device *phydev)
 		kfree_skb(skb);
 
 	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
-		skb_complete_tx_timestamp(skb, NULL);
+		kfree_skb(skb);
 
 	clock = dp83640_clock_get(dp83640->clock);
 
@@ -1405,7 +1405,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 
 	case HWTSTAMP_TX_ONESTEP_SYNC:
 		if (is_sync(skb, type)) {
-			skb_complete_tx_timestamp(skb, NULL);
+			kfree_skb(skb);
 			return;
 		}
 		/* fall through */
@@ -1416,7 +1416,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 
 	case HWTSTAMP_TX_OFF:
 	default:
-		skb_complete_tx_timestamp(skb, NULL);
+		kfree_skb(skb);
 		break;
 	}
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 02529fc..1cf0cfa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2690,6 +2690,8 @@ static inline ktime_t net_invalid_timestamp(void)
 	return ktime_set(0, 0);
 }
 
+struct sk_buff *skb_clone_sk(struct sk_buff *skb);
+
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
 
 void skb_clone_tx_timestamp(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 3fde613..e02be37 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1574,6 +1574,7 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 void sock_wfree(struct sk_buff *skb);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
+void sock_efree(struct sk_buff *skb);
 void sock_edemux(struct sk_buff *skb);
 
 int sock_setsockopt(struct socket *sock, int level, int op,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 697e696..a936a40 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,6 +3511,27 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
+struct sk_buff *skb_clone_sk(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	struct sk_buff *clone;
+
+	if (!sk || !atomic_inc_not_zero(&sk->sk_refcnt))
+		return NULL;
+
+	clone = skb_clone(skb, GFP_ATOMIC);
+	if (!clone) {
+		sock_put(sk);
+		return NULL;
+	}
+
+	clone->sk = sk;
+	clone->destructor = sock_efree;
+
+	return clone;
+}
+EXPORT_SYMBOL(skb_clone_sk);
+
 static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 					struct sock *sk,
 					int tstype)
@@ -3540,14 +3561,11 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 {
 	struct sock *sk = skb->sk;
 
-	skb->sk = NULL;
+	/* take a reference to prevent skb_orphan() from freeing the socket */
+	sock_hold(sk);
 
-	if (hwtstamps) {
-		*skb_hwtstamps(skb) = *hwtstamps;
-		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
-	} else {
-		kfree_skb(skb);
-	}
+	*skb_hwtstamps(skb) = *hwtstamps;
+	__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
 
 	sock_put(sk);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index f1a638e..d04005c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1637,6 +1637,12 @@ void sock_rfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_rfree);
 
+void sock_efree(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+EXPORT_SYMBOL(sock_efree);
+
 void sock_edemux(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index f48a59f..43d3dd6 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -36,10 +36,9 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 {
 	struct phy_device *phydev;
 	struct sk_buff *clone;
-	struct sock *sk = skb->sk;
 	unsigned int type;
 
-	if (!sk)
+	if (!skb->sk)
 		return;
 
 	type = classify(skb);
@@ -48,16 +47,9 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 
 	phydev = skb->dev->phydev;
 	if (likely(phydev->drv->txtstamp)) {
-		if (!atomic_inc_not_zero(&sk->sk_refcnt))
+		clone = skb_clone_sk(skb);
+		if (!clone)
 			return;
-
-		clone = skb_clone(skb, GFP_ATOMIC);
-		if (!clone) {
-			sock_put(sk);
-			return;
-		}
-
-		clone->sk = sk;
 		phydev->drv->txtstamp(phydev, clone, type);
 	}
 }
