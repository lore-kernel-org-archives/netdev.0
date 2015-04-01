From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 12/14] netfilter: bridge: discard nf_bridge info on xmit
Date: Wed,  1 Apr 2015 22:36:38 +0200
Message-ID: <1427920600-20366-13-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_bridge information is only needed for -m physdev, so we can always
dismantle this information after POST_ROUTING if we know we're the only
owner.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 3f1f920..715157c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -199,6 +199,14 @@ static void nf_bridge_info_del(struct sk_buff *skb)
 	}
 }
 
+static void nf_bridge_info_drop(struct sk_buff *skb)
+{
+	if (!skb_shared(skb)) {
+		nf_bridge_info_del(skb);
+		skb->nf_bridge_state = BRNF_STATE_NONE;
+	}
+}
+
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -924,6 +932,7 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 	skb_copy_to_linear_data_offset(skb, -data->size, data->mac, data->size);
 	__skb_push(skb, data->encap_size);
 
+	nf_bridge_info_drop(skb);
 	return br_dev_queue_push_xmit(skb);
 }
 
@@ -942,8 +951,10 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 	unsigned int mtu_reserved, mtu;
 	struct nf_bridge_info *nf_bridge;
 
-	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
+	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP)) {
+		nf_bridge_info_drop(skb);
 		return br_dev_queue_push_xmit(skb);
+	}
 
 	nf_bridge = nf_bridge_info_get(skb);
 	if (!nf_bridge)
@@ -986,6 +997,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 
 		ret = ip_fragment(skb, mtu, br_nf_push_frag_xmit);
 	} else {
+		nf_bridge_info_drop(skb);
 		ret = br_dev_queue_push_xmit(skb);
 	}
 
@@ -998,6 +1010,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 #else
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
+	nf_bridge_info_drop(skb);
 	return br_dev_queue_push_xmit(skb);
 }
 #endif
-- 
2.0.5

