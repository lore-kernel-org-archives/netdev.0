From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 4/6] netfilter: bridge: don't use nf_bridge_info to store proto value
Date: Thu, 12 Mar 2015 18:05:23 +0100
Message-ID: <1426179925-18220-5-git-send-email-fw@strlen.de>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53692 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754890AbbCLRFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 13:05:47 -0400
In-Reply-To: <1426179925-18220-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is not need to use any external storage for this -- we only need
to know about original skb->protocol value inside bridge netfilter
itself.  skb->cb can be used to store this information.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h |  2 --
 net/bridge/br_netfilter.c        | 28 +++++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 05437f8..66245b5 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -19,8 +19,6 @@ enum nf_br_hook_priorities {
 
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
-#define BRNF_8021Q			0x10
-#define BRNF_PPPoE			0x20
 
 int br_handle_frame_finish(struct sk_buff *skb);
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8649ef5..215ec3f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -47,6 +47,12 @@
 #include <linux/sysctl.h>
 #endif
 
+enum brnf_orig_skb_proto {
+	BRNF_PROTO_UNCHANGED,
+	BRNF_PROTO_8021Q,
+	BRNF_PROTO_PPPOE,
+};
+
 struct nf_bridge_skb_cb {
 	union {
 		struct inet_skb_parm i;
@@ -54,6 +60,7 @@ struct nf_bridge_skb_cb {
 	} u;
 
 	u8 packet_otherhost:1;
+	enum brnf_orig_skb_proto origproto:2;
 };
 
 #define BRNF_CB(skb) ((struct nf_bridge_skb_cb *)(skb)->cb)
@@ -264,10 +271,16 @@ drop:
 
 static void nf_bridge_update_protocol(struct sk_buff *skb)
 {
-	if (skb->nf_bridge->mask & BRNF_8021Q)
+	struct nf_bridge_skb_cb *cb = BRNF_CB(skb);
+
+	switch (cb->origproto) {
+	case BRNF_PROTO_8021Q:
 		skb->protocol = htons(ETH_P_8021Q);
-	else if (skb->nf_bridge->mask & BRNF_PPPoE)
+		break;
+	case BRNF_PROTO_PPPOE:
 		skb->protocol = htons(ETH_P_PPP_SES);
+		break;
+	}
 }
 
 static void nf_bridge_restore_otherhost(struct sk_buff *skb)
@@ -522,10 +535,13 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = brnf_get_logical_dev(skb, skb->dev);
+
 	if (skb->protocol == htons(ETH_P_8021Q))
-		nf_bridge->mask |= BRNF_8021Q;
+		cb->origproto = BRNF_PROTO_8021Q;
 	else if (skb->protocol == htons(ETH_P_PPP_SES))
-		nf_bridge->mask |= BRNF_PPPoE;
+		cb->origproto = BRNF_PROTO_PPPOE;
+	else
+		cb->origproto = BRNF_PROTO_UNCHANGED;
 
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
@@ -848,7 +864,9 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
 
 static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
-	if (skb->nf_bridge->mask & BRNF_PPPoE)
+	struct nf_bridge_skb_cb *cb = BRNF_CB(skb);
+
+	if (cb->origproto == BRNF_PROTO_PPPOE)
 		return PPPOE_SES_HLEN;
 	return 0;
 }
-- 
2.0.5
