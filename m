From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/7] netfilter: bridge: don't leak skb in error paths
Date: Wed,  8 Jul 2015 11:48:17 +0200
Message-ID: <1436348900-13130-5-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51605 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758224AbbGHJm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 05:42:56 -0400
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

br_nf_dev_queue_xmit must free skb in its error path.
NF_DROP is misleading -- its an okfn, not a netfilter hook.

Fixes: 462fb2af9788a ("bridge : Sanitize skb before it enters the IP stack")
Fixes: efb6de9b4ba00 ("netfilter: bridge: forward IPv6 fragmented packets")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 8a394bd..c8b9bcf 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -744,7 +744,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv4(skb))
-			return NF_DROP;
+			goto drop;
 
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
 
@@ -769,7 +769,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv6(skb))
-			return NF_DROP;
+			goto drop;
 
 		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
 
@@ -784,12 +784,16 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 
 		if (v6ops)
 			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit);
-		else
-			return -EMSGSIZE;
+
+		kfree_skb(skb);
+		return -EMSGSIZE;
 	}
 #endif
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
+ drop:
+	kfree_skb(skb);
+	return 0;
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
-- 
1.7.10.4
