From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] netfilter: bridge: refactor conditional in br_nf_dev_queue_xmit
Date: Mon,  9 Mar 2015 18:14:34 +0100
Message-ID: <1425921275-9171-12-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47245 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932158AbbCIRLN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:11:13 -0400
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

simpilifies followup patch that re-works brnf ip_fragment handling.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 5b3bceb..ef1fe28 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -803,13 +803,16 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
 	int frag_max_size;
+	unsigned int mtu_reserved;
 
+	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
+		return br_dev_queue_push_xmit(skb);
+
+	mtu_reserved = nf_bridge_mtu_reduction(skb);
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
-	if (skb->protocol == htons(ETH_P_IP) &&
-	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
-	    !skb_is_gso(skb)) {
+	if (skb->len + mtu_reserved > skb->dev->mtu) {
 		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
-- 
1.7.10.4
