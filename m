From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 14/14] netfilter: bridge: hold physinport ref during neigh resolution
Date: Wed,  1 Apr 2015 22:36:40 +0200
Message-ID: <1427920600-20366-15-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This problem existed forever: when performing DNAT resolution we keep
physinport around for later use as skb->dev .

We should ensure it cannot go away.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h |  1 +
 net/bridge/br_netfilter.c        | 15 +++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index c31024a..8a6a4af 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -39,6 +39,7 @@ struct nf_bridge_info {
 		BRNF_PROTO_PPPOE
 	} orig_proto;
 	bool			pkt_otherhost;
+	bool			physin_ref;
 	unsigned long		owner;
 	struct net_device	*physindev;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 0730be6..ae03117 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -154,6 +154,8 @@ static struct nf_bridge_info *nf_bridge_info_get(const struct sk_buff *skb)
 
 static void nf_bridge_info_free(struct nf_bridge_info *info)
 {
+	if (info->physin_ref)
+		dev_put(info->physindev);
 	kmem_cache_free(nf_bridge_cachep, info);
 }
 
@@ -174,6 +176,9 @@ static bool nf_bridge_info_copy(struct sk_buff *dst, const struct sk_buff *src)
 
 	newinfo->owner = (unsigned long)dst;
 
+	if (newinfo->physin_ref)
+		dev_hold(newinfo->physindev);
+
 	if (rhashtable_insert_fast(&nf_bridge_info_table, &newinfo->node,
 				   nf_bridge_info_params) == 0)
 		return true;
@@ -235,6 +240,7 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 
 	nf_bridge->orig_proto = BRNF_PROTO_UNCHANGED;
 	nf_bridge->pkt_otherhost = false;
+	nf_bridge->physin_ref = false;
 	nf_bridge->owner = (unsigned long)skb;
 	nf_bridge->physoutdev = NULL;
 
@@ -422,6 +428,10 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
 			skb->nf_bridge_state = BRNF_STATE_BRIDGED_DNAT;
+
+			nf_bridge->physin_ref = true;
+			dev_hold(nf_bridge->physindev);
+
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
@@ -1113,6 +1123,11 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 	nf_bridge->physoutdev = NULL;
 
+	WARN_ON_ONCE(!nf_bridge->physin_ref);
+
+	dev_put(nf_bridge->physindev);
+	nf_bridge->physin_ref = false;
+
 	br_handle_frame_finish(skb);
 }
 
-- 
2.0.5

