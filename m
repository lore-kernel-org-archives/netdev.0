From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 06/14] netfilter: bridge: rename and resize 'data' field
Date: Wed,  1 Apr 2015 22:36:32 +0200
Message-ID: <1427920600-20366-7-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42843 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753270AbbDAUg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:57 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only user left is neigh resolution when DNAT is detected, to hold
the original source mac address (neigh resolution builds new mac header
using bridge mac).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h    | 2 +-
 net/bridge/br_netfilter.c | 9 ++++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index afa53e4..0991259 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -175,7 +175,7 @@ struct nf_bridge_info {
 	unsigned int		mask;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
-	unsigned long		data[32 / sizeof(unsigned long)];
+	char			neigh_header[8];
 };
 #endif
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 02ccf38..947a2f6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -329,7 +329,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 			 */
 			skb_copy_from_linear_data_offset(skb,
 							 -(ETH_HLEN-ETH_ALEN),
-							 skb->nf_bridge->data,
+							 nf_bridge->neigh_header,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
 			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
@@ -991,8 +991,11 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb_pull(skb, ETH_HLEN);
 	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
 
-	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+	BUILD_BUG_ON(sizeof(nf_bridge->neigh_header) != (ETH_HLEN - ETH_ALEN));
+
+	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN - ETH_ALEN),
+				       nf_bridge->neigh_header,
+				       ETH_HLEN - ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
 	br_handle_frame_finish(skb);
 }
-- 
2.0.5
