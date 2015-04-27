From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: bridge: fix NULL deref in physin/out ifindex helpers
Date: Mon, 27 Apr 2015 20:41:57 +0200
Message-ID: <1430160117-21150-3-git-send-email-pablo@netfilter.org>
References: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44483 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168AbbD0Shf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 14:37:35 -0400
In-Reply-To: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Might not have an outdev yet. We'll oops when iface goes down while skbs
are still nfqueue'd:

RIP: 0010:[<ffffffff81422a2f>]  [<ffffffff81422a2f>] dev_cmp+0x4f/0x80
nfqnl_rcv_dev_event+0xe2/0x150
notifier_call_chain+0x53/0xa0

Fixes: c737b7c4510026 ("netfilter: bridge: add helpers for fetching physin/outdev")
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index ab8f76d..f2fdb5a 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -39,12 +39,24 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
 
 static inline int nf_bridge_get_physinif(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physindev->ifindex : 0;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge == NULL)
+		return 0;
+
+	nf_bridge = skb->nf_bridge;
+	return nf_bridge->physindev ? nf_bridge->physindev->ifindex : 0;
 }
 
 static inline int nf_bridge_get_physoutif(const struct sk_buff *skb)
 {
-	return skb->nf_bridge ? skb->nf_bridge->physoutdev->ifindex : 0;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->nf_bridge == NULL)
+		return 0;
+
+	nf_bridge = skb->nf_bridge;
+	return nf_bridge->physoutdev ? nf_bridge->physoutdev->ifindex : 0;
 }
 
 static inline struct net_device *
-- 
1.7.10.4
