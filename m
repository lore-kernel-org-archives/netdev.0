From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 2/4] net: use RCU noref infrastructure to track dst noref
Date: Fri,  6 Oct 2017 14:57:47 +0200
Message-ID: <7c7d6183314d8d4cafb9689ce498ec8759c440b0.1507294365.git.pabeni@redhat.com>
References: <cover.1507294365.git.pabeni@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507294365.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can now ensure noref dsts do no escape the relevant RCU
section. This does not introduce any functional changes, it adds
the relevant debug code enabled by CONFIG_RCU_NOREF_DEBUG.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 1 +
 include/net/dst.h      | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061..5df77c8a0319 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -905,6 +905,7 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
 {
 	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
+	rcu_track_noref(skb, dst, true);
 	skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
 }
 
diff --git a/include/net/dst.h b/include/net/dst.h
index 06a6765da074..6bc6fefe178e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -294,6 +294,8 @@ static inline void refdst_drop(unsigned long refdst)
 static inline void skb_dst_drop(struct sk_buff *skb)
 {
 	if (skb->_skb_refdst) {
+		if (skb->_skb_refdst & SKB_DST_NOREF)
+			rcu_track_noref(skb, skb_dst(skb), false);
 		refdst_drop(skb->_skb_refdst);
 		skb->_skb_refdst = 0UL;
 	}
@@ -304,6 +306,8 @@ static inline void __skb_dst_copy(struct sk_buff *nskb, unsigned long refdst)
 	nskb->_skb_refdst = refdst;
 	if (!(nskb->_skb_refdst & SKB_DST_NOREF))
 		dst_clone(skb_dst(nskb));
+	else
+		rcu_track_noref(nskb, skb_dst(nskb), true);
 }
 
 static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb)
@@ -335,6 +339,7 @@ static inline void skb_dst_force(struct sk_buff *skb)
 		struct dst_entry *dst = skb_dst(skb);
 
 		WARN_ON(!rcu_read_lock_held());
+		rcu_track_noref(skb, dst, false);
 		if (!dst_hold_safe(dst))
 			dst = NULL;
 
-- 
2.13.6
