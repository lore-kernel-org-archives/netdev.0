From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 04/14] netfilter: bridge: start splitting mask into public/private chunks
Date: Wed,  1 Apr 2015 22:36:30 +0200
Message-ID: <1427920600-20366-5-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42841 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753104AbbDAUg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:56 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->mask is a bit info field that mixes various use cases.

In particular, we have flags that are mutually exlusive, and flags that
are only used within br_netfilter while others need to be exposed to
other parts of the kernel.

Remove BRNF_8021Q/PPPoE flags.  They're mutually exclusive and only
needed within br_netfilter context.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h |  2 --
 include/linux/skbuff.h           |  5 +++++
 net/bridge/br_netfilter.c        | 17 ++++++++++++-----
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index b131613..848226e 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -20,8 +20,6 @@ enum nf_br_hook_priorities {
 #define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
-#define BRNF_8021Q			0x10
-#define BRNF_PPPoE			0x20
 
 int br_handle_frame_finish(struct sk_buff *skb);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 36f3f43..fe1b557 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -166,6 +166,11 @@ struct nf_conntrack {
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 struct nf_bridge_info {
 	atomic_t		use;
+	enum {
+		BRNF_PROTO_UNCHANGED,
+		BRNF_PROTO_8021Q,
+		BRNF_PROTO_PPPOE
+	} orig_proto;
 	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 6ccb1af..8c86f37 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -257,10 +257,16 @@ drop:
 
 static void nf_bridge_update_protocol(struct sk_buff *skb)
 {
-	if (skb->nf_bridge->mask & BRNF_8021Q)
+	switch (skb->nf_bridge->orig_proto) {
+	case BRNF_PROTO_8021Q:
 		skb->protocol = htons(ETH_P_8021Q);
-	else if (skb->nf_bridge->mask & BRNF_PPPoE)
+		break;
+	case BRNF_PROTO_PPPOE:
 		skb->protocol = htons(ETH_P_PPP_SES);
+		break;
+	case BRNF_PROTO_UNCHANGED:
+		break;
+	}
 }
 
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
@@ -498,10 +504,11 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = brnf_get_logical_dev(skb, skb->dev);
+
 	if (skb->protocol == htons(ETH_P_8021Q))
-		nf_bridge->mask |= BRNF_8021Q;
+		nf_bridge->orig_proto = BRNF_PROTO_8021Q;
 	else if (skb->protocol == htons(ETH_P_PPP_SES))
-		nf_bridge->mask |= BRNF_PPPoE;
+		nf_bridge->orig_proto = BRNF_PROTO_PPPOE;
 
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
@@ -836,7 +843,7 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 
 static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
-	if (skb->nf_bridge->mask & BRNF_PPPoE)
+	if (skb->nf_bridge->orig_proto == BRNF_PROTO_PPPOE)
 		return PPPOE_SES_HLEN;
 	return 0;
 }
-- 
2.0.5
