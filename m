From: kaber@trash.net
Subject: [PATCH 34/84] netfilter: xtables: consolidate code into xt_request_find_match
Date: Mon, 10 May 2010 22:18:05 +0200
Message-ID: <1273522735-24672-35-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54521 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756763Ab0EJUTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:07 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    2 ++
 net/bridge/netfilter/ebtables.c    |    5 +----
 net/ipv4/netfilter/ip_tables.c     |   18 ++++++++----------
 net/ipv6/netfilter/ip6_tables.c    |   18 ++++++++----------
 net/netfilter/x_tables.c           |   11 +++++++++++
 5 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index f8f5551..dd9d15a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -436,6 +436,8 @@ extern struct xt_table_info *xt_replace_table(struct xt_table *table,
 
 extern struct xt_match *xt_find_match(u8 af, const char *name, u8 revision);
 extern struct xt_target *xt_find_target(u8 af, const char *name, u8 revision);
+extern struct xt_match *xt_request_find_match(u8 af, const char *name,
+					      u8 revision);
 extern struct xt_target *xt_request_find_target(u8 af, const char *name,
 						u8 revision);
 extern int xt_find_revision(u8 af, const char *name, u8 revision,
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 6d3b256..c41f3fa 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -361,12 +361,9 @@ ebt_check_match(struct ebt_entry_match *m, struct xt_mtchk_param *par,
 	    left - sizeof(struct ebt_entry_match) < m->match_size)
 		return -EINVAL;
 
-	match = try_then_request_module(xt_find_match(NFPROTO_BRIDGE,
-		m->u.name, 0), "ebt_%s", m->u.name);
+	match = xt_request_find_match(NFPROTO_BRIDGE, m->u.name, 0);
 	if (IS_ERR(match))
 		return PTR_ERR(match);
-	if (match == NULL)
-		return -ENOENT;
 	m->u.match = match;
 
 	par->match     = match;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index e24ec48..09f6567 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -629,12 +629,11 @@ find_check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 	struct xt_match *match;
 	int ret;
 
-	match = try_then_request_module(xt_find_match(AF_INET, m->u.user.name,
-						      m->u.user.revision),
-					"ipt_%s", m->u.user.name);
-	if (IS_ERR(match) || !match) {
+	match = xt_request_find_match(NFPROTO_IPV4, m->u.user.name,
+				      m->u.user.revision);
+	if (IS_ERR(match)) {
 		duprintf("find_check_match: `%s' not found\n", m->u.user.name);
-		return match ? PTR_ERR(match) : -ENOENT;
+		return PTR_ERR(match);
 	}
 	m->u.kernel.match = match;
 
@@ -1472,13 +1471,12 @@ compat_find_calc_match(struct ipt_entry_match *m,
 {
 	struct xt_match *match;
 
-	match = try_then_request_module(xt_find_match(AF_INET, m->u.user.name,
-						      m->u.user.revision),
-					"ipt_%s", m->u.user.name);
-	if (IS_ERR(match) || !match) {
+	match = xt_request_find_match(NFPROTO_IPV4, m->u.user.name,
+				      m->u.user.revision);
+	if (IS_ERR(match)) {
 		duprintf("compat_check_calc_match: `%s' not found\n",
 			 m->u.user.name);
-		return match ? PTR_ERR(match) : -ENOENT;
+		return PTR_ERR(match);
 	}
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 842bef3..41e2429 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -660,12 +660,11 @@ find_check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
 	struct xt_match *match;
 	int ret;
 
-	match = try_then_request_module(xt_find_match(AF_INET6, m->u.user.name,
-						      m->u.user.revision),
-					"ip6t_%s", m->u.user.name);
-	if (IS_ERR(match) || !match) {
+	match = xt_request_find_match(NFPROTO_IPV6, m->u.user.name,
+				      m->u.user.revision);
+	if (IS_ERR(match)) {
 		duprintf("find_check_match: `%s' not found\n", m->u.user.name);
-		return match ? PTR_ERR(match) : -ENOENT;
+		return PTR_ERR(match);
 	}
 	m->u.kernel.match = match;
 
@@ -1506,13 +1505,12 @@ compat_find_calc_match(struct ip6t_entry_match *m,
 {
 	struct xt_match *match;
 
-	match = try_then_request_module(xt_find_match(AF_INET6, m->u.user.name,
-						      m->u.user.revision),
-					"ip6t_%s", m->u.user.name);
-	if (IS_ERR(match) || !match) {
+	match = xt_request_find_match(NFPROTO_IPV6, m->u.user.name,
+				      m->u.user.revision);
+	if (IS_ERR(match)) {
 		duprintf("compat_check_calc_match: `%s' not found\n",
 			 m->u.user.name);
-		return match ? PTR_ERR(match) : -ENOENT;
+		return PTR_ERR(match);
 	}
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index bf2806a..ee7fe21 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -214,6 +214,17 @@ struct xt_match *xt_find_match(u8 af, const char *name, u8 revision)
 }
 EXPORT_SYMBOL(xt_find_match);
 
+struct xt_match *
+xt_request_find_match(uint8_t nfproto, const char *name, uint8_t revision)
+{
+	struct xt_match *match;
+
+	match = try_then_request_module(xt_find_match(nfproto, name, revision),
+					"%st_%s", xt_prefix[nfproto], name);
+	return (match != NULL) ? match : ERR_PTR(-ENOENT);
+}
+EXPORT_SYMBOL_GPL(xt_request_find_match);
+
 /* Find target, grabs ref.  Returns ERR_PTR() on error. */
 struct xt_target *xt_find_target(u8 af, const char *name, u8 revision)
 {
-- 
1.7.0.4

