From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/20] netfilter: bridge: make BRNF_PKT_TYPE flag a bool
Date: Thu,  9 Apr 2015 13:34:59 +0200
Message-ID: <1428579304-5520-16-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33131 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933035AbbDILbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:18 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nf_bridge_info->mask is used for several things, for example to
remember if skb->pkt_type was set to OTHER_HOST.

For a bridge, OTHER_HOST is expected case. For ip forward its a non-starter
though -- routing expects PACKET_HOST.

Bridge netfilter thus changes OTHER_HOST to PACKET_HOST before hook
invocation and then un-does it after hook traversal.

This information is irrelevant outside of br_netfilter.

After this change, ->mask now only contains flags that need to be
known outside of br_netfilter in fast-path.

Future patch changes mask into a 2bit state field in sk_buff, so that
we can remove skb->nf_bridge pointer for good and consider all remaining
places that access nf_bridge info content a not-so fastpath.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |    1 -
 include/linux/skbuff.h           |    1 +
 net/bridge/br_netfilter.c        |   18 +++++++++---------
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index d47a32d..8912e8c 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -17,7 +17,6 @@ enum nf_br_hook_priorities {
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 
-#define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6f75fb5..0991259 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -171,6 +171,7 @@ struct nf_bridge_info {
 		BRNF_PROTO_8021Q,
 		BRNF_PROTO_PPPOE
 	} orig_proto;
+	bool			pkt_otherhost;
 	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab1e988..e8ac743 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -282,9 +282,9 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
+	if (nf_bridge->pkt_otherhost) {
 		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
+		nf_bridge->pkt_otherhost = false;
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
@@ -415,9 +415,9 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	frag_max_size = IPCB(skb)->frag_max_size;
 	BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
 
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
+	if (nf_bridge->pkt_otherhost) {
 		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
+		nf_bridge->pkt_otherhost = false;
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
@@ -503,7 +503,7 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
+		nf_bridge->pkt_otherhost = true;
 	}
 
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
@@ -711,9 +711,9 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 		}
 
 		in = nf_bridge->physindev;
-		if (nf_bridge->mask & BRNF_PKT_TYPE) {
+		if (nf_bridge->pkt_otherhost) {
 			skb->pkt_type = PACKET_OTHERHOST;
-			nf_bridge->mask ^= BRNF_PKT_TYPE;
+			nf_bridge->pkt_otherhost = false;
 		}
 		nf_bridge_update_protocol(skb);
 	} else {
@@ -769,7 +769,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
+		nf_bridge->pkt_otherhost = true;
 	}
 
 	if (pf == NFPROTO_IPV4) {
@@ -927,7 +927,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	 * about the value of skb->pkt_type. */
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
+		nf_bridge->pkt_otherhost = true;
 	}
 
 	nf_bridge_pull_encap_header(skb);
-- 
1.7.10.4
