From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/20] netfilter: bridge: really save frag_max_size between PRE and POST_ROUTING
Date: Thu,  9 Apr 2015 13:34:52 +0200
Message-ID: <1428579304-5520-9-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33069 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932893AbbDILbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:11 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We also need to save/store in forward, else br_parse_ip_options call
will zero frag_max_size as well.

Fixes: 93fdd47e5 ('bridge: Save frag_max_size between PRE_ROUTING and POST_ROUTING')
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f3884a1..282ed76 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -686,6 +686,13 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
+		int frag_max_size;
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			frag_max_size = IPCB(skb)->frag_max_size;
+			BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
+		}
+
 		in = nf_bridge->physindev;
 		if (nf_bridge->mask & BRNF_PKT_TYPE) {
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -745,8 +752,14 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
-	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
-		return NF_DROP;
+	if (pf == NFPROTO_IPV4) {
+		int frag_max = BR_INPUT_SKB_CB(skb)->frag_max_size;
+
+		if (br_parse_ip_options(skb))
+			return NF_DROP;
+
+		IPCB(skb)->frag_max_size = frag_max;
+	}
 
 	nf_bridge->physoutdev = skb->dev;
 	if (pf == NFPROTO_IPV4)
-- 
1.7.10.4
