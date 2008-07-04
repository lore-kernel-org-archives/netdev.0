From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 2/9] net: add fib_rules_ops to flush_cache method
Date: Fri,  4 Jul 2008 17:17:05 +0400
Message-ID: <1215177432-25934-2-git-send-email-den@openvz.org>
References: <1215177360.27873.50.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39980 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbYGDNQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 09:16:50 -0400
In-Reply-To: <1215177360.27873.50.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required to pass namespace context into rt_cache_flush called from
->flush_cache.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/fib_rules.h |    2 +-
 net/core/fib_rules.c    |    2 +-
 net/decnet/dn_rules.c   |    2 +-
 net/ipv4/fib_rules.c    |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index a5c6ccc..c2bb5ca 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -62,7 +62,7 @@ struct fib_rules_ops
 
 	/* Called after modifications to the rules set, must flush
 	 * the route cache if one exists. */
-	void			(*flush_cache)(void);
+	void			(*flush_cache)(struct fib_rules_ops *ops);
 
 	int			nlgroup;
 	const struct nla_policy	*policy;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index e3e9ab0..1c2943a 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -69,7 +69,7 @@ static void rules_ops_put(struct fib_rules_ops *ops)
 static void flush_route_cache(struct fib_rules_ops *ops)
 {
 	if (ops->flush_cache)
-		ops->flush_cache();
+		ops->flush_cache(ops);
 }
 
 int fib_rules_register(struct fib_rules_ops *ops)
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 5b7539b..14fbca5 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -229,7 +229,7 @@ static u32 dn_fib_rule_default_pref(struct fib_rules_ops *ops)
 	return 0;
 }
 
-static void dn_fib_rule_flush_cache(void)
+static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 {
 	dn_rt_cache_flush(-1);
 }
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index bc05de4..6080d71 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -258,9 +258,9 @@ static size_t fib4_rule_nlmsg_payload(struct fib_rule *rule)
 	       + nla_total_size(4); /* flow */
 }
 
-static void fib4_rule_flush_cache(void)
+static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 {
-	rt_cache_flush(&init_net, -1);
+	rt_cache_flush(ops->fro_net, -1);
 }
 
 static struct fib_rules_ops fib4_rules_ops_template = {
-- 
1.5.3.rc5

