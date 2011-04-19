From: kaber@trash.net
Subject: [PATCH 2/3] netfilter: ipset: set match and SET target fixes
Date: Tue, 19 Apr 2011 16:51:44 +0200
Message-ID: <1303224705-17400-3-git-send-email-kaber@trash.net>
References: <1303224705-17400-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303224705-17400-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The SET target with --del-set did not work due to using wrongly
the internal dimension of --add-set instead of --del-set.
Also, the checkentries did not release the set references when
returned an error. Bugs reported by Lennert Buytenhek.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_set.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 061d48c..b3babae 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -81,6 +81,7 @@ set_match_v0_checkentry(const struct xt_mtchk_param *par)
 	if (info->match_set.u.flags[IPSET_DIM_MAX-1] != 0) {
 		pr_warning("Protocol error: set match dimension "
 			   "is over the limit!\n");
+		ip_set_nfnl_put(info->match_set.index);
 		return -ERANGE;
 	}
 
@@ -135,6 +136,8 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find del_set index %u as target\n",
 				   info->del_set.index);
+			if (info->add_set.index != IPSET_INVALID_ID)
+				ip_set_nfnl_put(info->add_set.index);
 			return -ENOENT;
 		}
 	}
@@ -142,6 +145,10 @@ set_target_v0_checkentry(const struct xt_tgchk_param *par)
 	    info->del_set.u.flags[IPSET_DIM_MAX-1] != 0) {
 		pr_warning("Protocol error: SET target dimension "
 			   "is over the limit!\n");
+		if (info->add_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(info->add_set.index);
+		if (info->del_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(info->del_set.index);
 		return -ERANGE;
 	}
 
@@ -192,6 +199,7 @@ set_match_checkentry(const struct xt_mtchk_param *par)
 	if (info->match_set.dim > IPSET_DIM_MAX) {
 		pr_warning("Protocol error: set match dimension "
 			   "is over the limit!\n");
+		ip_set_nfnl_put(info->match_set.index);
 		return -ERANGE;
 	}
 
@@ -219,7 +227,7 @@ set_target(struct sk_buff *skb, const struct xt_action_param *par)
 	if (info->del_set.index != IPSET_INVALID_ID)
 		ip_set_del(info->del_set.index,
 			   skb, par->family,
-			   info->add_set.dim,
+			   info->del_set.dim,
 			   info->del_set.flags);
 
 	return XT_CONTINUE;
@@ -245,13 +253,19 @@ set_target_checkentry(const struct xt_tgchk_param *par)
 		if (index == IPSET_INVALID_ID) {
 			pr_warning("Cannot find del_set index %u as target\n",
 				   info->del_set.index);
+			if (info->add_set.index != IPSET_INVALID_ID)
+				ip_set_nfnl_put(info->add_set.index);
 			return -ENOENT;
 		}
 	}
 	if (info->add_set.dim > IPSET_DIM_MAX ||
-	    info->del_set.flags > IPSET_DIM_MAX) {
+	    info->del_set.dim > IPSET_DIM_MAX) {
 		pr_warning("Protocol error: SET target dimension "
 			   "is over the limit!\n");
+		if (info->add_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(info->add_set.index);
+		if (info->del_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(info->del_set.index);
 		return -ERANGE;
 	}
 
-- 
1.7.2.3

