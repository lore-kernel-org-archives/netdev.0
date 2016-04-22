From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/23] netfilter: x_tables: add and use xt_check_entry_offsets
Date: Fri, 22 Apr 2016 15:39:34 +0200
Message-ID: <1461332394-3994-4-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45206 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132AbcDVNkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:07 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 57632B185
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4184C8E553
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C3B32FAB48
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:02 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Currently arp/ip and ip6tables each implement a short helper to check that
the target offset is large enough to hold one xt_entry_target struct and
that t->u.target_size fits within the current rule.

Unfortunately these checks are not sufficient.

To avoid adding new tests to all of ip/ip6/arptables move the current
checks into a helper, then extend this helper in followup patches.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |  4 ++++
 net/ipv4/netfilter/arp_tables.c    | 11 +----------
 net/ipv4/netfilter/ip_tables.c     | 12 +-----------
 net/ipv6/netfilter/ip6_tables.c    | 12 +-----------
 net/netfilter/x_tables.c           | 34 ++++++++++++++++++++++++++++++++++
 5 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 80a305b..0de0862 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -242,6 +242,10 @@ void xt_unregister_match(struct xt_match *target);
 int xt_register_matches(struct xt_match *match, unsigned int n);
 void xt_unregister_matches(struct xt_match *match, unsigned int n);
 
+int xt_check_entry_offsets(const void *base,
+			   unsigned int target_offset,
+			   unsigned int next_offset);
+
 int xt_check_match(struct xt_mtchk_param *, unsigned int size, u_int8_t proto,
 		   bool inv_proto);
 int xt_check_target(struct xt_tgchk_param *, unsigned int size, u_int8_t proto,
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index ec37f7c..74668c1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -496,19 +496,10 @@ next:
 
 static inline int check_entry(const struct arpt_entry *e)
 {
-	const struct xt_entry_target *t;
-
 	if (!arp_checkentry(&e->arp))
 		return -EINVAL;
 
-	if (e->target_offset + sizeof(struct xt_entry_target) > e->next_offset)
-		return -EINVAL;
-
-	t = arpt_get_target_c(e);
-	if (e->target_offset + t->u.target_size > e->next_offset)
-		return -EINVAL;
-
-	return 0;
+	return xt_check_entry_offsets(e, e->target_offset, e->next_offset);
 }
 
 static inline int check_target(struct arpt_entry *e, const char *name)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 503038e..71c204d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -590,20 +590,10 @@ static void cleanup_match(struct xt_entry_match *m, struct net *net)
 static int
 check_entry(const struct ipt_entry *e)
 {
-	const struct xt_entry_target *t;
-
 	if (!ip_checkentry(&e->ip))
 		return -EINVAL;
 
-	if (e->target_offset + sizeof(struct xt_entry_target) >
-	    e->next_offset)
-		return -EINVAL;
-
-	t = ipt_get_target_c(e);
-	if (e->target_offset + t->u.target_size > e->next_offset)
-		return -EINVAL;
-
-	return 0;
+	return xt_check_entry_offsets(e, e->target_offset, e->next_offset);
 }
 
 static int
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 126f2a0..24ae7f4 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -602,20 +602,10 @@ static void cleanup_match(struct xt_entry_match *m, struct net *net)
 static int
 check_entry(const struct ip6t_entry *e)
 {
-	const struct xt_entry_target *t;
-
 	if (!ip6_checkentry(&e->ipv6))
 		return -EINVAL;
 
-	if (e->target_offset + sizeof(struct xt_entry_target) >
-	    e->next_offset)
-		return -EINVAL;
-
-	t = ip6t_get_target_c(e);
-	if (e->target_offset + t->u.target_size > e->next_offset)
-		return -EINVAL;
-
-	return 0;
+	return xt_check_entry_offsets(e, e->target_offset, e->next_offset);
 }
 
 static int check_match(struct xt_entry_match *m, struct xt_mtchk_param *par)
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 582c9cf..1f44bfa 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -541,6 +541,40 @@ int xt_compat_match_to_user(const struct xt_entry_match *m,
 EXPORT_SYMBOL_GPL(xt_compat_match_to_user);
 #endif /* CONFIG_COMPAT */
 
+/**
+ * xt_check_entry_offsets - validate arp/ip/ip6t_entry
+ *
+ * @base: pointer to arp/ip/ip6t_entry
+ * @target_offset: the arp/ip/ip6_t->target_offset
+ * @next_offset: the arp/ip/ip6_t->next_offset
+ *
+ * validates that target_offset and next_offset are sane.
+ *
+ * The arp/ip/ip6t_entry structure @base must have passed following tests:
+ * - it must point to a valid memory location
+ * - base to base + next_offset must be accessible, i.e. not exceed allocated
+ *   length.
+ *
+ * Return: 0 on success, negative errno on failure.
+ */
+int xt_check_entry_offsets(const void *base,
+			   unsigned int target_offset,
+			   unsigned int next_offset)
+{
+	const struct xt_entry_target *t;
+	const char *e = base;
+
+	if (target_offset + sizeof(*t) > next_offset)
+		return -EINVAL;
+
+	t = (void *)(e + target_offset);
+	if (target_offset + t->u.target_size > next_offset)
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL(xt_check_entry_offsets);
+
 int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
-- 
2.1.4
