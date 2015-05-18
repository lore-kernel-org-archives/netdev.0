From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/21] netfilter: bridge: neigh_head and physoutdev can't be used at same time
Date: Mon, 18 May 2015 18:25:19 +0200
Message-ID: <1431966324-4494-17-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The neigh_header is only needed when we detect DNAT after prerouting
and neigh cache didn't have a mac address for us.

The output port has not been chosen yet so we can re-use the storage
area, bringing struct size down to 32 bytes on x86_64.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h    |    8 +++++---
 net/bridge/br_netfilter.c |    2 ++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c0b574a..3d932e6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -170,12 +170,14 @@ struct nf_bridge_info {
 		BRNF_PROTO_UNCHANGED,
 		BRNF_PROTO_8021Q,
 		BRNF_PROTO_PPPOE
-	} orig_proto;
+	} orig_proto:8;
 	bool			pkt_otherhost;
 	unsigned int		mask;
 	struct net_device	*physindev;
-	struct net_device	*physoutdev;
-	char			neigh_header[8];
+	union {
+		struct net_device *physoutdev;
+		char neigh_header[8];
+	};
 };
 #endif
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab55e24..13973da 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -973,6 +973,8 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 				       nf_bridge->neigh_header,
 				       ETH_HLEN - ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
+
+	nf_bridge->physoutdev = NULL;
 	br_handle_frame_finish(NULL, skb);
 }
 
-- 
1.7.10.4

