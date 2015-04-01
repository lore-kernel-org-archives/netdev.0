From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 13/14] netfilter: bridge: neigh_head and physoutdev can't be used at same time
Date: Wed,  1 Apr 2015 22:36:39 +0200
Message-ID: <1427920600-20366-14-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42855 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753535AbbDAUhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:37:04 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The neigh_header is only needed when we detect DNAT after prerouting
and neigh cache didn't have a mac address for us.

The output port has not been chosen yet so we can re-use its memory,
bringing size of meta data down to 40 bytes on x86_64.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 7 +++++--
 net/bridge/br_netfilter.c        | 2 ++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 621a2e4..c31024a 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -41,8 +41,11 @@ struct nf_bridge_info {
 	bool			pkt_otherhost;
 	unsigned long		owner;
 	struct net_device	*physindev;
-	struct net_device	*physoutdev;
-	char			neigh_header[8];
+
+	union {
+		struct net_device *physoutdev;
+		char neigh_header[8];
+	};
 };
 
 struct nf_bridge_info *nf_bridge_find(const struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 715157c..0730be6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1111,6 +1111,8 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 				       nf_bridge->neigh_header,
 				       ETH_HLEN - ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
+	nf_bridge->physoutdev = NULL;
+
 	br_handle_frame_finish(skb);
 }
 
-- 
2.0.5
