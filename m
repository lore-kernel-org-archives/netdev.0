From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nft_ct: fix expiration getter
Date: Tue, 12 Jul 2016 18:11:01 +0200
Message-ID: <1468339862-4028-6-git-send-email-pablo@netfilter.org>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We need to compute timeout.expires - jiffies, not the other way around.
Add a helper, another patch can then later change more places in
conntrack code where we currently open-code this.

Will allow us to only change one place later when we remove per-ct timer.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h | 8 ++++++++
 net/netfilter/nft_ct.c               | 6 +-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index dd78bea..b6083c3 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -284,6 +284,14 @@ static inline bool nf_is_loopback_packet(const struct sk_buff *skb)
 	return skb->dev && skb->skb_iif && skb->dev->flags & IFF_LOOPBACK;
 }
 
+/* jiffies until ct expires, 0 if already expired */
+static inline unsigned long nf_ct_expires(const struct nf_conn *ct)
+{
+	long timeout = (long)ct->timeout.expires - (long)jiffies;
+
+	return timeout > 0 ? timeout : 0;
+}
+
 struct kernel_param;
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 137e308..81fbb45 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -54,7 +54,6 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_tuple *tuple;
 	const struct nf_conntrack_helper *helper;
-	long diff;
 	unsigned int state;
 
 	ct = nf_ct_get(pkt->skb, &ctinfo);
@@ -94,10 +93,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		return;
 #endif
 	case NFT_CT_EXPIRATION:
-		diff = (long)jiffies - (long)ct->timeout.expires;
-		if (diff < 0)
-			diff = 0;
-		*dest = jiffies_to_msecs(diff);
+		*dest = jiffies_to_msecs(nf_ct_expires(ct));
 		return;
 	case NFT_CT_HELPER:
 		if (ct->master == NULL)
-- 
2.1.4

