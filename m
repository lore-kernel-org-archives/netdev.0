From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next v2 2/2] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Wed, 03 Sep 2014 19:42:26 -0400
Message-ID: <20140903233911.7517.59378.stgit@ahduyck-bv4.jf.intel.com>
References: <20140903233447.7517.52329.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50859 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935522AbaICXtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 19:49:47 -0400
In-Reply-To: <20140903233447.7517.52329.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy timestamping takes a different path than the regular timestamping
does in that it will create a clone first so that the packets needing to be
timestamped can be placed in a queue, or the context block could be used.

In order to support these use cases I am pulling the core of the code out
so it can be used in other drivers beyond just phy devices.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

---

v2: Renamed function to skb_clone_sk.
    Added destructor to call sock_put instead of doing it ourselves.
    Dropped freeing functionality from skb_complete_tx_timestamp.
    Added additional documentation to the code.

 drivers/net/phy/dp83640.c |    6 +++---
 include/linux/skbuff.h    |    2 ++
 net/core/skbuff.c         |   40 ++++++++++++++++++++++++++++------------
 net/core/timestamping.c   |   14 +++-----------
 4 files changed, 36 insertions(+), 26 deletions(-)

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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 697e696..92c7288 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,6 +3511,32 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
+static void skb_clone_sk_destructor(struct sk_buff *skb)
+{
+	sock_put(skb->sk);	
+}
+
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
+	clone->destructor = skb_clone_sk_destructor;
+
+	return clone;
+}
+EXPORT_SYMBOL(skb_clone_sk);
+
 static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 					struct sock *sk,
 					int tstype)
@@ -3538,18 +3564,8 @@ static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 void skb_complete_tx_timestamp(struct sk_buff *skb,
 			       struct skb_shared_hwtstamps *hwtstamps)
 {
-	struct sock *sk = skb->sk;
-
-	skb->sk = NULL;
-
-	if (hwtstamps) {
-		*skb_hwtstamps(skb) = *hwtstamps;
-		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
-	} else {
-		kfree_skb(skb);
-	}
-
-	sock_put(sk);
+	*skb_hwtstamps(skb) = *hwtstamps;
+	__skb_complete_tx_timestamp(skb, skb->sk, SCM_TSTAMP_SND);
 }
 EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
 
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
