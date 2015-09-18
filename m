From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: bridge: fix routing of bridge frames with call-iptables=1
Date: Fri, 18 Sep 2015 11:17:54 +0200
Message-ID: <1442567876-4046-3-git-send-email-pablo@netfilter.org>
References: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We can't re-use the physoutdev storage area.

1.  When using NFQUEUE in PREROUTING, we attempt to bump a bogus
refcnt since nf_bridge->physoutdev is garbage (ipv4/ipv6 address)

2. for same reason, we crash in physdev match in FORWARD or later if
skb is routed instead of bridged.

This increases nf_bridge_info to 40 bytes, but we have no other choice.

Fixes: 72b1e5e4cac7 ("netfilter: bridge: reduce nf_bridge_info to 32 bytes again")
Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2738d35..9987af0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -179,6 +179,9 @@ struct nf_bridge_info {
 	u8			bridged_dnat:1;
 	__u16			frag_max_size;
 	struct net_device	*physindev;
+
+	/* always valid & non-NULL from FORWARD on, for physdev match */
+	struct net_device	*physoutdev;
 	union {
 		/* prerouting: detect dnat in orig/reply direction */
 		__be32          ipv4_daddr;
@@ -189,9 +192,6 @@ struct nf_bridge_info {
 		 * skb is out in neigh layer.
 		 */
 		char neigh_header[8];
-
-		/* always valid & non-NULL from FORWARD on, for physdev match */
-		struct net_device *physoutdev;
 	};
 };
 #endif
-- 
1.7.10.4

