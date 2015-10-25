From: Masashi Honma <masashi.honma@gmail.com>
Subject: [PATCH] ipv6 route: Use flag instead of calling fib6_get_table() twice
Date: Sun, 25 Oct 2015 11:44:27 +0900
Message-ID: <1445741067-14891-1-git-send-email-masashi.honma@gmail.com>
References: <562C418B.9050909@gmail.com>
Cc: netdev@vger.kernel.org, Masashi Honma <masashi.honma@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35740 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbbJYCoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 22:44:44 -0400
Received: by pasz6 with SMTP id z6so152821746pas.2
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 19:44:43 -0700 (PDT)
In-Reply-To: <562C418B.9050909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_get_table() is called twice to show the warning.
This patch reduces calling the function.

Signed-off-by: Masashi Honma <masashi.honma@gmail.com>
---
 include/net/ip6_fib.h |  2 +-
 net/ipv6/fib6_rules.c |  3 ++-
 net/ipv6/ip6_fib.c    | 10 +++++++---
 net/ipv6/route.c      | 13 ++++---------
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aaf9700..d6c5dff 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -256,7 +256,7 @@ typedef struct rt6_info *(*pol_lookup_t)(struct net *,
  */
 
 struct fib6_table *fib6_get_table(struct net *net, u32 id);
-struct fib6_table *fib6_new_table(struct net *net, u32 id);
+struct fib6_table *fib6_new_table(struct net *net, u32 id, int *exist);
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup);
 
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 9f777ec..7512941 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -187,12 +187,13 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	int err = -EINVAL;
 	struct net *net = sock_net(skb->sk);
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
+	int exist;
 
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
 
-		if (fib6_new_table(net, rule->table) == NULL) {
+		if (fib6_new_table(net, rule->table, &exist) == NULL) {
 			err = -ENOBUFS;
 			goto errout;
 		}
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 7d2e002..abf65ef 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -226,16 +226,19 @@ static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
 	return table;
 }
 
-struct fib6_table *fib6_new_table(struct net *net, u32 id)
+struct fib6_table *fib6_new_table(struct net *net, u32 id, int *exist)
 {
 	struct fib6_table *tb;
 
 	if (id == 0)
 		id = RT6_TABLE_MAIN;
 	tb = fib6_get_table(net, id);
-	if (tb)
+	if (tb) {
+		*exist = 1;
 		return tb;
+	}
 
+	*exist = 0;
 	tb = fib6_alloc_table(net, id);
 	if (tb)
 		fib6_link_table(net, tb);
@@ -272,8 +275,9 @@ static void __net_init fib6_tables_init(struct net *net)
 }
 #else
 
-struct fib6_table *fib6_new_table(struct net *net, u32 id)
+struct fib6_table *fib6_new_table(struct net *net, u32 id, int *exist)
 {
+	*exist = 1;
 	return fib6_get_table(net, id);
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb32ce2..7c4e0c2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1757,6 +1757,7 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 	struct inet6_dev *idev = NULL;
 	struct fib6_table *table;
 	int addr_type;
+	int exist;
 
 	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
 		return -EINVAL;
@@ -1778,16 +1779,10 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
 	err = -ENOBUFS;
+	table = fib6_new_table(net, cfg->fc_table, &exist);
 	if (cfg->fc_nlinfo.nlh &&
-	    !(cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_CREATE)) {
-		table = fib6_get_table(net, cfg->fc_table);
-		if (!table) {
-			pr_warn("NLM_F_CREATE should be specified when creating new route\n");
-			table = fib6_new_table(net, cfg->fc_table);
-		}
-	} else {
-		table = fib6_new_table(net, cfg->fc_table);
-	}
+	    !(cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_CREATE) && !exist)
+		pr_warn("NLM_F_CREATE should be specified when creating new route\n");
 
 	if (!table)
 		goto out;
-- 
1.9.1
