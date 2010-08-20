From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] bridge: netfilter: fix a memory leak
Date: Fri, 20 Aug 2010 13:03:16 +0800
Message-ID: <1282280596-18992-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:63381 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab0HTFDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 01:03:37 -0400
Received: by pvg2 with SMTP id 2so1050220pvg.19
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 22:03:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_bridge_alloc() always reset the skb->nf_bridge, so we should always
put the old one. skb->nf_bridge->use is initialized in nf_bridge_alloc(),
so we don't need to initialize it again.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/bridge/br_netfilter.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 2c911c0..7fde554 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -159,11 +159,9 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
 	if (atomic_read(&nf_bridge->use) > 1) {
 		struct nf_bridge_info *tmp = nf_bridge_alloc(skb);
 
-		if (tmp) {
+		if (tmp)
 			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
-			atomic_set(&tmp->use, 1);
-			nf_bridge_put(nf_bridge);
-		}
+		nf_bridge_put(nf_bridge);
 		nf_bridge = tmp;
 	}
 	return nf_bridge;
