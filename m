From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/10] [BRIDGE]: Unshare skb upon entry
Date: Sun, 14 Oct 2007 12:27:44 +0800
Message-ID: <E1Igv4q-00030k-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1418 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751846AbXJNE2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BRIDGE]: Unshare skb upon entry

Due to the special location of the bridging hook, it should never see a
shared packet anyway (certainly not with any in-kernel code).  So it
makes sense to unshare the skb there if necessary as that will greatly
simplify the code below it (in particular, netfilter).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_input.c |    4 ++++
 1 files changed, 4 insertions(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 3a8a015..f8e0a2f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -126,6 +126,10 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto drop;
 
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
 	if (unlikely(is_link_local(dest))) {
 		/* Pause frames shouldn't be passed up by driver anyway */
 		if (skb->protocol == htons(ETH_P_PAUSE))
