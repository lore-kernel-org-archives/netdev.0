From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: dev: move inline skb_needs_linearize helper to header
Date: Fri,  6 Dec 2013 11:36:16 +0100
Message-ID: <1386326177-4483-3-git-send-email-dborkman@redhat.com>
References: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754313Ab3LFKgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 05:36:23 -0500
In-Reply-To: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we need it elsewhere, move the inline helper function of
skb_needs_linearize() over to skbuff.h include file. While
at it, also convert the return to 'bool' instead of 'int'
and add a proper kernel doc.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/skbuff.h | 18 ++++++++++++++++++
 net/core/dev.c         | 15 ---------------
 2 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bec1cc7..7100531 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2395,6 +2395,24 @@ static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 	return buffer;
 }
 
+/**
+ *	skb_needs_linearize - check if we need to linearize a given skb
+ *			      depending on the given device features.
+ *	@skb: socket buffer to check
+ *	@features: net device features
+ *
+ *	Returns true if either:
+ *	1. skb has frag_list and the device doesn't support FRAGLIST, or
+ *	2. skb is fragmented and the device does not support SG.
+ */
+static inline bool skb_needs_linearize(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	return skb_is_nonlinear(skb) &&
+	       ((skb_has_frag_list(skb) && !(features & NETIF_F_FRAGLIST)) ||
+		(skb_shinfo(skb)->nr_frags && !(features & NETIF_F_SG)));
+}
+
 static inline void skb_copy_from_linear_data(const struct sk_buff *skb,
 					     void *to,
 					     const unsigned int len)
diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea..fc38a36 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2523,21 +2523,6 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_skb_features);
 
-/*
- * Returns true if either:
- *	1. skb has frag_list and the device doesn't support FRAGLIST, or
- *	2. skb is fragmented and the device does not support SG.
- */
-static inline int skb_needs_linearize(struct sk_buff *skb,
-				      netdev_features_t features)
-{
-	return skb_is_nonlinear(skb) &&
-			((skb_has_frag_list(skb) &&
-				!(features & NETIF_F_FRAGLIST)) ||
-			(skb_shinfo(skb)->nr_frags &&
-				!(features & NETIF_F_SG)));
-}
-
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq, void *accel_priv)
 {
-- 
1.8.3.1
