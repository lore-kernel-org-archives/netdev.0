From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/17] ipv6: fib_rules: Check if rule is a default rule
Date: Wed, 19 Jul 2017 09:02:20 +0200
Message-ID: <20170719070232.28457-6-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33653 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdGSHCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:42 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so7612617wrd.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:42 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As explained in commit 3c71006d15fd ("ipv4: fib_rules: Check if rule is
a default rule"), drivers supporting IPv6 FIB offload need to be able to
sanitize the rules they don't support and potentially flush their
tables.

Add an IPv6 helper to check if a FIB rule is a default rule.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h |  5 +++++
 net/ipv6/fib6_rules.c | 20 ++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 1a88008..6000b0d 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -295,6 +295,7 @@ int ipv6_route_open(struct inode *inode, struct file *file);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 int fib6_rules_init(void);
 void fib6_rules_cleanup(void);
+bool fib6_rule_default(const struct fib_rule *rule);
 #else
 static inline int               fib6_rules_init(void)
 {
@@ -304,5 +305,9 @@ static inline void              fib6_rules_cleanup(void)
 {
 	return ;
 }
+static inline bool fib6_rule_default(const struct fib_rule *rule)
+{
+	return true;
+}
 #endif
 #endif
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index ec849d8..ef1fcee 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -29,6 +29,26 @@ struct fib6_rule {
 	u8			tclass;
 };
 
+static bool fib6_rule_matchall(const struct fib_rule *rule)
+{
+	struct fib6_rule *r = container_of(rule, struct fib6_rule, common);
+
+	if (r->dst.plen || r->src.plen || r->tclass)
+		return false;
+	return fib_rule_matchall(rule);
+}
+
+bool fib6_rule_default(const struct fib_rule *rule)
+{
+	if (!fib6_rule_matchall(rule) || rule->action != FR_ACT_TO_TBL ||
+	    rule->l3mdev)
+		return false;
+	if (rule->table != RT6_TABLE_LOCAL && rule->table != RT6_TABLE_MAIN)
+		return false;
+	return true;
+}
+EXPORT_SYMBOL_GPL(fib6_rule_default);
+
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-- 
2.9.3
