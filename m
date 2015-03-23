From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: bridge: remove BRNF_STATE_BRIDGED flag
Date: Mon, 23 Mar 2015 12:36:18 +0100
Message-ID: <1427110584-5190-3-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Its not needed anymore since 2bf540b73ed5b
([NETFILTER]: bridge-netfilter: remove deferred hooks).
Before this it was possible to have physoutdev set for locally generated
packets -- this isn't the case anymore:

BRNF_STATE_BRIDGED flag is set when we assign nf_bridge->physoutdev,
so physoutdev != NULL means BRNF_STATE_BRIDGED is set.
If physoutdev is NULL, then we are looking at locally-delivered and
routed packet.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |    1 -
 net/bridge/br_netfilter.c        |    9 ++++++---
 net/netfilter/xt_physdev.c       |    3 +--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index de123d7..ed0d3bf 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -19,7 +19,6 @@ enum nf_br_hook_priorities {
 
 #define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
-#define BRNF_BRIDGED			0x04
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 261fcd5..bd2d24d 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -736,8 +736,6 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
 		return NF_DROP;
 
-	/* The physdev module checks on this */
-	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
@@ -857,7 +855,12 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	u_int8_t pf;
 
-	if (!nf_bridge || !(nf_bridge->mask & BRNF_BRIDGED))
+	/* if nf_bridge is set, but ->physoutdev is NULL, this packet came in
+	 * on a bridge, but was delivered locally and is now being routed:
+	 *
+	 * POST_ROUTING was already invoked from the ip stack.
+	 */
+	if (!nf_bridge || !nf_bridge->physoutdev)
 		return NF_ACCEPT;
 
 	if (!realoutdev)
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index f440f57..50a5204 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -56,8 +56,7 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	/* This only makes sense in the FORWARD and POSTROUTING chains */
 	if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
-	    (!!(nf_bridge->mask & BRNF_BRIDGED) ^
-	    !(info->invert & XT_PHYSDEV_OP_BRIDGED)))
+	    (!!nf_bridge->physoutdev ^ !(info->invert & XT_PHYSDEV_OP_BRIDGED)))
 		return false;
 
 	if ((info->bitmask & XT_PHYSDEV_OP_ISIN &&
-- 
1.7.10.4

