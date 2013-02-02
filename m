From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Sat, 2 Feb 2013 18:27:03 +0100
Message-ID: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	Emmanuel THIERRY <emmanuel.thierry@telecom-bretagne.eu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current algorithm to insert XFRM policies with a mark and a mask
allows the insertion of more generic policies, but fails when trying
to install more specific policies.

For example, executing the below commands in that order succeed:
 ip -6 xfrm policy flush
 ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 1 mask 0xffffffff
 ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out

But it fails in the reverse order:
 ip -6 xfrm policy flush
 ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
 ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 1 mask 0xffffffff
 RTNETLINK answers: File exists

This patch modifies the tests on the marks and masks and takes the most
straightforward way: compare the mask and mark separately. It requires to 
give the xfrm_mark structure as an argument to some of the xfrm_policy_*
functions, instead of just the mark.

This patch covers the problem for XFRM policies, a similar problem
exists with XFRM states. If the proposed solution is satisfactory, I 
will propose a similar patch for the states. Comments are welcome.

Signed-off-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
---
 include/net/xfrm.h     |    6 ++++--
 net/xfrm/xfrm_policy.c |   18 +++++++++++-------
 net/xfrm/xfrm_user.c   |   13 +++++++------
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 63445ed..cdd79b7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1529,12 +1529,14 @@ extern int xfrm_policy_walk(struct net *net, struct xfrm_policy_walk *walk,
 	int (*func)(struct xfrm_policy *, int, int, void*), void *);
 extern void xfrm_policy_walk_done(struct xfrm_policy_walk *walk);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
-struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net,
+					  struct xfrm_mark *mark,
 					  u8 type, int dir,
 					  struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err);
-struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir, u32 id, int delete, int *err);
+struct xfrm_policy *xfrm_policy_byid(struct net *net, struct xfrm_mark *mark,
+				     u8, int dir, u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 extern int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 07c5857..d9fe665 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -569,7 +569,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
 	struct hlist_node *entry, *newpos;
-	u32 mark = policy->mark.v & policy->mark.m;
 
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
@@ -578,7 +577,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
-		    (mark & pol->mark.m) == pol->mark.v &&
+		    policy->mark.v == pol->mark.v &&
+		    policy->mark.m == pol->mark.m &&
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
@@ -623,7 +623,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 }
 EXPORT_SYMBOL(xfrm_policy_insert);
 
-struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
+struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net,
+					  struct xfrm_mark *mark, u8 type,
 					  int dir, struct xfrm_selector *sel,
 					  struct xfrm_sec_ctx *ctx, int delete,
 					  int *err)
@@ -638,7 +639,8 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == type &&
-		    (mark & pol->mark.m) == pol->mark.v &&
+		    mark->v == pol->mark.v &&
+		    mark->m == pol->mark.m &&
 		    !selector_cmp(sel, &pol->selector) &&
 		    xfrm_sec_ctx_match(ctx, pol->security)) {
 			xfrm_pol_hold(pol);
@@ -663,8 +665,9 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
-struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
-				     int dir, u32 id, int delete, int *err)
+struct xfrm_policy *xfrm_policy_byid(struct net *net, struct xfrm_mark *mark,
+				     u8 type, int dir, u32 id,
+				     int delete, int *err)
 {
 	struct xfrm_policy *pol, *ret;
 	struct hlist_head *chain;
@@ -680,7 +683,8 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, byidx) {
 		if (pol->type == type && pol->index == id &&
-		    (mark & pol->mark.m) == pol->mark.v) {
+		    mark->v == pol->mark.v &&
+		    mark->m == pol->mark.m) {
 			xfrm_pol_hold(pol);
 			if (delete) {
 				*err = security_xfrm_policy_delete(
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index eb872b2..2d41902 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1602,7 +1602,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	int delete;
 	struct xfrm_mark m;
-	u32 mark = xfrm_mark_get(attrs, &m);
+	xfrm_mark_get(attrs, &m);
 
 	p = nlmsg_data(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
@@ -1616,7 +1616,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, mark, type, p->dir, p->index, delete, &err);
+		xp = xfrm_policy_byid(net, &m, type, p->dir,
+				      p->index, delete, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1633,7 +1634,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, mark, type, p->dir, &p->sel,
+		xp = xfrm_policy_bysel_ctx(net, &m, type, p->dir, &p->sel,
 					   ctx, delete, &err);
 		security_xfrm_policy_free(ctx);
 	}
@@ -1905,7 +1906,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 	struct xfrm_mark m;
-	u32 mark = xfrm_mark_get(attrs, &m);
+	xfrm_mark_get(attrs, &m);
 
 	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
@@ -1916,7 +1917,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(net, mark, type, p->dir, p->index, 0, &err);
+		xp = xfrm_policy_byid(net, &m, type, p->dir, p->index, 0, &err);
 	else {
 		struct nlattr *rt = attrs[XFRMA_SEC_CTX];
 		struct xfrm_sec_ctx *ctx;
@@ -1933,7 +1934,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if (err)
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(net, mark, type, p->dir,
+		xp = xfrm_policy_bysel_ctx(net, &m, type, p->dir,
 					   &p->sel, ctx, 0, &err);
 		security_xfrm_policy_free(ctx);
 	}
-- 
1.7.2.5
