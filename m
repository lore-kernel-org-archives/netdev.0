From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 03 Sep 2014 11:53:57 -0400
Message-ID: <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55237 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330AbaICQCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 12:02:19 -0400
In-Reply-To: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy timestamping takes a different path than the regular timestamping
does in that it will create a clone first so that the packets needing to be
timestamped can be placed in a queue, or the context block could be used.

In order to support these use cases I am pulling the core of the code out
so it can be used in other drivers beyond just phy devices.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/skbuff.h  |    2 ++
 net/core/skbuff.c       |   20 ++++++++++++++++++++
 net/core/timestamping.c |   14 +++-----------
 3 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 02529fc..19eb787 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2690,6 +2690,8 @@ static inline ktime_t net_invalid_timestamp(void)
 	return ktime_set(0, 0);
 }
 
+struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb);
+
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
 
 void skb_clone_tx_timestamp(struct sk_buff *skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 488d902..3f5cf29 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3511,6 +3511,26 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 }
 EXPORT_SYMBOL(sock_dequeue_err_skb);
 
+struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb)
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
+
+	return clone;
+}
+EXPORT_SYMBOL(__skb_clone_tx_timestamp);
+
 static void __skb_complete_tx_timestamp(struct sk_buff *skb,
 					struct sock *sk,
 					int tstype)
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index f48a59f..458f5cb 100644
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
+		clone = __skb_clone_tx_timestamp(skb);
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
