From: David Miller <davem@davemloft.net>
Subject: [PATCH] xfrm: Convert several xfrm policy match functions to bool.
Date: Tue, 15 May 2012 15:05:16 -0400 (EDT)
Message-ID: <20120515.150516.1410633228619707393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966266Ab2EOTFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 15:05:18 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q4FJ5G2X008621
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 15 May 2012 12:05:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


xfrm_selector_match
xfrm_sec_ctx_match
__xfrm4_selector_match
__xfrm6_selector_match

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |   12 ++++++------
 net/xfrm/xfrm_policy.c |   27 ++++++++++++++-------------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1cb32bf..e0a55df 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -886,15 +886,15 @@ __be16 xfrm_flowi_dport(const struct flowi *fl, const union flowi_uli *uli)
 	return port;
 }
 
-extern int xfrm_selector_match(const struct xfrm_selector *sel,
-			       const struct flowi *fl,
-			       unsigned short family);
+extern bool xfrm_selector_match(const struct xfrm_selector *sel,
+				const struct flowi *fl,
+				unsigned short family);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 /*	If neither has a context --> match
  * 	Otherwise, both must have a context and the sids, doi, alg must match
  */
-static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
+static inline bool xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
 {
 	return ((!s1 && !s2) ||
 		(s1 && s2 &&
@@ -903,9 +903,9 @@ static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ct
 		 (s1->ctx_alg == s2->ctx_alg)));
 }
 #else
-static inline int xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
+static inline bool xfrm_sec_ctx_match(struct xfrm_sec_ctx *s1, struct xfrm_sec_ctx *s2)
 {
-	return 1;
+	return true;
 }
 #endif
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7661576..3c87a1c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -56,7 +56,7 @@ static int xfrm_bundle_ok(struct xfrm_dst *xdst);
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
 
-static inline int
+static inline bool
 __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	const struct flowi4 *fl4 = &fl->u.ip4;
@@ -69,7 +69,7 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		(fl4->flowi4_oif == sel->ifindex || !sel->ifindex);
 }
 
-static inline int
+static inline bool
 __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	const struct flowi6 *fl6 = &fl->u.ip6;
@@ -82,8 +82,8 @@ __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		(fl6->flowi6_oif == sel->ifindex || !sel->ifindex);
 }
 
-int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
-			unsigned short family)
+bool xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
+			 unsigned short family)
 {
 	switch (family) {
 	case AF_INET:
@@ -91,7 +91,7 @@ int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
 	case AF_INET6:
 		return __xfrm6_selector_match(sel, fl);
 	}
-	return 0;
+	return false;
 }
 
 static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
@@ -877,7 +877,8 @@ static int xfrm_policy_match(const struct xfrm_policy *pol,
 			     u8 type, u16 family, int dir)
 {
 	const struct xfrm_selector *sel = &pol->selector;
-	int match, ret = -ESRCH;
+	int ret = -ESRCH;
+	bool match;
 
 	if (pol->family != family ||
 	    (fl->flowi_mark & pol->mark.m) != pol->mark.v ||
@@ -1006,8 +1007,8 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
 
 	read_lock_bh(&xfrm_policy_lock);
 	if ((pol = sk->sk_policy[dir]) != NULL) {
-		int match = xfrm_selector_match(&pol->selector, fl,
-						sk->sk_family);
+		bool match = xfrm_selector_match(&pol->selector, fl,
+						 sk->sk_family);
 		int err = 0;
 
 		if (match) {
@@ -2767,8 +2768,8 @@ EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
-static int xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
-				       const struct xfrm_selector *sel_tgt)
+static bool xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
+					const struct xfrm_selector *sel_tgt)
 {
 	if (sel_cmp->proto == IPSEC_ULPROTO_ANY) {
 		if (sel_tgt->family == sel_cmp->family &&
@@ -2778,14 +2779,14 @@ static int xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
 				  sel_cmp->family) == 0 &&
 		    sel_tgt->prefixlen_d == sel_cmp->prefixlen_d &&
 		    sel_tgt->prefixlen_s == sel_cmp->prefixlen_s) {
-			return 1;
+			return true;
 		}
 	} else {
 		if (memcmp(sel_tgt, sel_cmp, sizeof(*sel_tgt)) == 0) {
-			return 1;
+			return true;
 		}
 	}
-	return 0;
+	return false;
 }
 
 static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector *sel,
-- 
1.7.7.6
