From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/20] netfilter: physdev: use helpers
Date: Thu,  9 Apr 2015 13:34:56 +0200
Message-ID: <1428579304-5520-13-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Avoid skb->nf_bridge accesses where possible.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_physdev.c |   34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 50a5204..1caaccb 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -25,16 +25,15 @@ MODULE_ALIAS("ip6t_physdev");
 static bool
 physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
+	const struct net_device *physdev;
 	unsigned long ret;
 	const char *indev, *outdev;
-	const struct nf_bridge_info *nf_bridge;
 
 	/* Not a bridged IP packet or no info available yet:
 	 * LOCAL_OUT/mangle and LOCAL_OUT/nat don't know if
 	 * the destination device will be a bridge. */
-	if (!(nf_bridge = skb->nf_bridge)) {
+	if (!skb->nf_bridge) {
 		/* Return MATCH if the invert flags of the used options are on */
 		if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
 		    !(info->invert & XT_PHYSDEV_OP_BRIDGED))
@@ -54,30 +53,41 @@ physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return true;
 	}
 
+	physdev = nf_bridge_get_physoutdev(skb);
+	outdev = physdev ? physdev->name : NULL;
+
 	/* This only makes sense in the FORWARD and POSTROUTING chains */
 	if ((info->bitmask & XT_PHYSDEV_OP_BRIDGED) &&
-	    (!!nf_bridge->physoutdev ^ !(info->invert & XT_PHYSDEV_OP_BRIDGED)))
+	    (!!outdev ^ !(info->invert & XT_PHYSDEV_OP_BRIDGED)))
 		return false;
 
+	physdev = nf_bridge_get_physindev(skb);
+	indev = physdev ? physdev->name : NULL;
+
 	if ((info->bitmask & XT_PHYSDEV_OP_ISIN &&
-	    (!nf_bridge->physindev ^ !!(info->invert & XT_PHYSDEV_OP_ISIN))) ||
+	    (!indev ^ !!(info->invert & XT_PHYSDEV_OP_ISIN))) ||
 	    (info->bitmask & XT_PHYSDEV_OP_ISOUT &&
-	    (!nf_bridge->physoutdev ^ !!(info->invert & XT_PHYSDEV_OP_ISOUT))))
+	    (!outdev ^ !!(info->invert & XT_PHYSDEV_OP_ISOUT))))
 		return false;
 
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
-	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	ret = ifname_compare_aligned(indev, info->physindev, info->in_mask);
 
-	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
-		return false;
+	if (indev) {
+		ret = ifname_compare_aligned(indev, info->physindev,
+					     info->in_mask);
+
+		if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
+			return false;
+	}
 
 match_outdev:
 	if (!(info->bitmask & XT_PHYSDEV_OP_OUT))
 		return true;
-	outdev = nf_bridge->physoutdev ?
-		 nf_bridge->physoutdev->name : nulldevname;
+
+	if (!outdev)
+		return false;
+
 	ret = ifname_compare_aligned(outdev, info->physoutdev, info->out_mask);
 
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
-- 
1.7.10.4

