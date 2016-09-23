From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 03/11] net: Prepare for IPsec GRO
Date: Fri, 23 Sep 2016 09:53:40 +0200
Message-ID: <1474617228-26103-4-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45994 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758329AbcIWHyE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:04 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the generic codepath for IPsec GRO.
We introduce a new GRO_CONSUMED notifier to reflect that
IPsec can return asynchronous. On IPsec GRO we grab the
packet and reinject it back to layer 2 after IPsec
processing. We also use one xfrm_gro bit on the sk_buff
that will be set from IPsec to notify about GRO. If this
bit is set, we call napi_gro_receive for the backlog device
instead of __netif_receive_skb.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h |  1 +
 include/linux/skbuff.h    | 14 +++++++++++++-
 net/core/dev.c            | 17 ++++++++++++++++-
 net/xfrm/Kconfig          |  4 ++++
 4 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a10d8d1..8bbd2d3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -342,6 +342,7 @@ enum gro_result {
 	GRO_HELD,
 	GRO_NORMAL,
 	GRO_DROP,
+	GRO_CONSUMED,
 };
 typedef enum gro_result gro_result_t;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4c5662f..f21da42 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -732,7 +732,10 @@ struct sk_buff {
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
 #endif
-	/* 2, 4 or 5 bit hole */
+#ifdef CONFIG_XFRM_OFFLOAD
+	__u8			xfrm_gro:1;
+#endif
+	/* 1 to 5 bits hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -3679,6 +3682,15 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 #endif
 }
 
+static inline bool skb_xfrm_gro(struct sk_buff *skb)
+{
+#ifdef CONFIG_XFRM_OFFLOAD
+	return skb->xfrm_gro;
+#else
+	return false;
+#endif
+}
+
 /* Keeps track of mac header offset relative to skb->head.
  * It is useful for TSO of Tunneling protocol. e.g. GRE.
  * For non-tunnel skb it points to skb_mac_header() and for
diff --git a/net/core/dev.c b/net/core/dev.c
index 9dbece2..19e621d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4531,6 +4531,11 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	}
 	rcu_read_unlock();
 
+	if (PTR_ERR(pp) == -EINPROGRESS) {
+		ret = GRO_CONSUMED;
+		goto ok;
+	}
+
 	if (&ptype->list == head)
 		goto normal;
 
@@ -4629,6 +4634,9 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 	case GRO_MERGED_FREE:
 		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
 			skb_dst_drop(skb);
+#ifdef CONFIG_XFRM_OFFLOAD
+			secpath_put(skb->sp);
+#endif
 			kmem_cache_free(skbuff_head_cache, skb);
 		} else {
 			__kfree_skb(skb);
@@ -4637,6 +4645,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 	case GRO_HELD:
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
@@ -4707,6 +4716,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi,
 		break;
 
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
@@ -4849,7 +4859,12 @@ static int process_backlog(struct napi_struct *napi, int quota)
 
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
 			rcu_read_lock();
-			__netif_receive_skb(skb);
+
+			if (skb_xfrm_gro(skb))
+				napi_gro_receive(napi, skb);
+			else
+				__netif_receive_skb(skb);
+
 			rcu_read_unlock();
 			input_queue_head_incr(sd);
 			if (++work >= quota)
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index bda1a13..442ac61 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -5,6 +5,10 @@ config XFRM
        bool
        depends on NET
 
+config XFRM_OFFLOAD
+	bool
+	depends on XFRM
+
 config XFRM_ALGO
 	tristate
 	select XFRM
-- 
1.9.1
