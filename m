From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nfnetlink_acct: report overquota to the right netns
Date: Thu, 18 Aug 2016 19:29:05 +0200
Message-ID: <1471541348-1538-4-git-send-email-pablo@netfilter.org>
References: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

We should report the over quota message to the right net namespace
instead of the init netns.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_acct.h | 4 ++--
 net/netfilter/nfnetlink_acct.c           | 9 +++++----
 net/netfilter/xt_nfacct.c                | 2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_acct.h b/include/linux/netfilter/nfnetlink_acct.h
index 80ca889..664da00 100644
--- a/include/linux/netfilter/nfnetlink_acct.h
+++ b/include/linux/netfilter/nfnetlink_acct.h
@@ -15,6 +15,6 @@ struct nf_acct;
 struct nf_acct *nfnl_acct_find_get(struct net *net, const char *filter_name);
 void nfnl_acct_put(struct nf_acct *acct);
 void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct);
-extern int nfnl_acct_overquota(const struct sk_buff *skb,
-			      struct nf_acct *nfacct);
+int nfnl_acct_overquota(struct net *net, const struct sk_buff *skb,
+			struct nf_acct *nfacct);
 #endif /* _NFNL_ACCT_H */
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 1b4de4b..796605b 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -443,7 +443,7 @@ void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct)
 }
 EXPORT_SYMBOL_GPL(nfnl_acct_update);
 
-static void nfnl_overquota_report(struct nf_acct *nfacct)
+static void nfnl_overquota_report(struct net *net, struct nf_acct *nfacct)
 {
 	int ret;
 	struct sk_buff *skb;
@@ -458,11 +458,12 @@ static void nfnl_overquota_report(struct nf_acct *nfacct)
 		kfree_skb(skb);
 		return;
 	}
-	netlink_broadcast(init_net.nfnl, skb, 0, NFNLGRP_ACCT_QUOTA,
+	netlink_broadcast(net->nfnl, skb, 0, NFNLGRP_ACCT_QUOTA,
 			  GFP_ATOMIC);
 }
 
-int nfnl_acct_overquota(const struct sk_buff *skb, struct nf_acct *nfacct)
+int nfnl_acct_overquota(struct net *net, const struct sk_buff *skb,
+			struct nf_acct *nfacct)
 {
 	u64 now;
 	u64 *quota;
@@ -480,7 +481,7 @@ int nfnl_acct_overquota(const struct sk_buff *skb, struct nf_acct *nfacct)
 
 	if (now >= *quota &&
 	    !test_and_set_bit(NFACCT_OVERQUOTA_BIT, &nfacct->flags)) {
-		nfnl_overquota_report(nfacct);
+		nfnl_overquota_report(net, nfacct);
 	}
 
 	return ret;
diff --git a/net/netfilter/xt_nfacct.c b/net/netfilter/xt_nfacct.c
index 3048a7e..cf32759 100644
--- a/net/netfilter/xt_nfacct.c
+++ b/net/netfilter/xt_nfacct.c
@@ -26,7 +26,7 @@ static bool nfacct_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	nfnl_acct_update(skb, info->nfacct);
 
-	overquota = nfnl_acct_overquota(skb, info->nfacct);
+	overquota = nfnl_acct_overquota(par->net, skb, info->nfacct);
 
 	return overquota == NFACCT_UNDERQUOTA ? false : true;
 }
-- 
2.1.4

