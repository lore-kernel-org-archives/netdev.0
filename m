From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/21] netfilter: bridge: free nf_bridge info on xmit
Date: Mon, 18 May 2015 18:25:20 +0200
Message-ID: <1431966324-4494-18-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

nf_bridge information is only needed for -m physdev, so we can always free
it after POST_ROUTING.  This has the advantage that allocation and free will
typically happen on the same cpu.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 13973da..2b0e8bb 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -129,6 +129,14 @@ static struct nf_bridge_info *nf_bridge_info_get(const struct sk_buff *skb)
 	return skb->nf_bridge;
 }
 
+static void nf_bridge_info_free(struct sk_buff *skb)
+{
+	if (skb->nf_bridge) {
+		nf_bridge_put(skb->nf_bridge);
+		skb->nf_bridge = NULL;
+	}
+}
+
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -841,6 +849,7 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 	skb_copy_to_linear_data_offset(skb, -data->size, data->mac, data->size);
 	__skb_push(skb, data->encap_size);
 
+	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
 }
 
@@ -850,8 +859,10 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 	int frag_max_size;
 	unsigned int mtu_reserved;
 
-	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
+	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP)) {
+		nf_bridge_info_free(skb);
 		return br_dev_queue_push_xmit(sk, skb);
+	}
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
 	/* This is wrong! We should preserve the original fragment
@@ -877,6 +888,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 
 		ret = ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	} else {
+		nf_bridge_info_free(skb);
 		ret = br_dev_queue_push_xmit(sk, skb);
 	}
 
@@ -885,7 +897,8 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 #else
 static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
-        return br_dev_queue_push_xmit(sk, skb);
+	nf_bridge_info_free(skb);
+	return br_dev_queue_push_xmit(sk, skb);
 }
 #endif
 
-- 
1.7.10.4

