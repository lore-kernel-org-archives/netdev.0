From: Eric Paris <eparis@parisplace.org>
Subject: [PATCH] xfrm_policy delete security check misplaced
Date: Fri, 02 Mar 2007 13:29:50 -0500
Message-ID: <1172860190.31047.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jamesm@namei.org, vyekkirala@trustedcs.com,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932321AbXCBSaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 13:30:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The security hooks to check permissions to remove an xfrm_policy were
actually done after the policy was removed.  Since the unlinking and
deletion are done in xfrm_policy_by* functions this moves the hooks
inside those 2 functions.  There we have all the information needed to
do the security check and it can be done before the deletion.  Since
auditing requires the result of that security check err has to be passed
back and forth from the xfrm_policy_by* functions.  

This patch also fixes a bug where a deletion that failed the security
check could cause improper accounting on the xfrm_policy
(xfrm_get_policy didn't have a put on the exit path for the hold taken
by xfrm_policy_by*)

It also fixes the return code when no policy is found in
xfrm_add_pol_expire.  In old code (at least back in the 2.6.18 days) err
wasn't used before the return when no policy is found and so the
initialization would cause err to be ENOENT.  But since err has since
been used above when we don't get a policy back from the xfrm_policy_by*
function we would always return 0 instead of the intended ENOENT.  Also
fixed some white space damage in the same area. 

Signed-off-by: Eric Paris <eparis@redhat.com>

 include/net/xfrm.h     |    5 +++--
 net/key/af_key.c       |    6 ++----
 net/xfrm/xfrm_policy.c |   18 ++++++++++++++++--
 net/xfrm/xfrm_user.c   |   19 +++++++++----------
 4 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 92a1fc4..5a00aa8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -988,8 +988,9 @@ extern int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int,
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
 struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					  struct xfrm_selector *sel,
-					  struct xfrm_sec_ctx *ctx, int delete);
-struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete);
+					  struct xfrm_sec_ctx *ctx, int delete,
+					  int *err);
+struct xfrm_policy *xfrm_policy_byid(u8, int dir, u32 id, int delete, int *err);
 void xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
 void xfrm_alloc_spi(struct xfrm_state *x, __be32 minspi, __be32 maxspi);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1c58204..3542435 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2294,14 +2294,12 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	}
 
 	xp = xfrm_policy_bysel_ctx(XFRM_POLICY_TYPE_MAIN, pol->sadb_x_policy_dir-1,
-				   &sel, tmp.security, 1);
+				   &sel, tmp.security, 1, &err);
 	security_xfrm_policy_free(&tmp);
 
 	if (xp == NULL)
 		return -ENOENT;
 
-	err = security_xfrm_policy_delete(xp);
-
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
 		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
 
@@ -2552,7 +2550,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 		return -EINVAL;
 
 	xp = xfrm_policy_byid(XFRM_POLICY_TYPE_MAIN, dir, pol->sadb_x_policy_id,
-			      hdr->sadb_msg_type == SADB_X_SPDDELETE2);
+			      hdr->sadb_msg_type == SADB_X_SPDDELETE2, &err);
 	if (xp == NULL)
 		return -ENOENT;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 946b715..0c3a70a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -735,12 +735,14 @@ EXPORT_SYMBOL(xfrm_policy_insert);
 
 struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					  struct xfrm_selector *sel,
-					  struct xfrm_sec_ctx *ctx, int delete)
+					  struct xfrm_sec_ctx *ctx, int delete,
+					  int *err)
 {
 	struct xfrm_policy *pol, *ret;
 	struct hlist_head *chain;
 	struct hlist_node *entry;
 
+	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(sel, sel->family, dir);
 	ret = NULL;
@@ -750,6 +752,11 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 		    xfrm_sec_ctx_match(ctx, pol->security)) {
 			xfrm_pol_hold(pol);
 			if (delete) {
+				*err = security_xfrm_policy_delete(pol);
+				if (*err) {
+					write_unlock_bh(&xfrm_policy_lock);
+					return pol;
+				}
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				xfrm_policy_count[dir]--;
@@ -768,12 +775,14 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 }
 EXPORT_SYMBOL(xfrm_policy_bysel_ctx);
 
-struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete)
+struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
+				     int *err)
 {
 	struct xfrm_policy *pol, *ret;
 	struct hlist_head *chain;
 	struct hlist_node *entry;
 
+	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
 	chain = xfrm_policy_byidx + idx_hash(id);
 	ret = NULL;
@@ -781,6 +790,11 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete)
 		if (pol->type == type && pol->index == id) {
 			xfrm_pol_hold(pol);
 			if (delete) {
+				*err = security_xfrm_policy_delete(pol);
+				if (*err) {
+					write_unlock_bh(&xfrm_policy_lock);
+					return pol;
+				}
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				xfrm_policy_count[dir]--;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 956cfe0..77d73de 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1254,7 +1254,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(type, p->dir, p->index, delete);
+		xp = xfrm_policy_byid(type, p->dir, p->index, delete, &err);
 	else {
 		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
 		struct xfrm_policy tmp;
@@ -1270,7 +1270,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, delete);
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security,
+					   delete, &err);
 		security_xfrm_policy_free(&tmp);
 	}
 	if (xp == NULL)
@@ -1288,8 +1289,6 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					      MSG_DONTWAIT);
 		}
 	} else {
-		err = security_xfrm_policy_delete(xp);
-
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
 			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
 
@@ -1303,9 +1302,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		km_policy_notify(xp, p->dir, &c);
 	}
 
-	xfrm_pol_put(xp);
-
 out:
+	xfrm_pol_put(xp);
 	return err;
 }
 
@@ -1502,7 +1500,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 
 	if (p->index)
-		xp = xfrm_policy_byid(type, p->dir, p->index, 0);
+		xp = xfrm_policy_byid(type, p->dir, p->index, 0, &err);
 	else {
 		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
 		struct xfrm_policy tmp;
@@ -1518,13 +1516,14 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 			if ((err = security_xfrm_policy_alloc(&tmp, uctx)))
 				return err;
 		}
-		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, 0);
+		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, tmp.security, 
+					   0, &err);
 		security_xfrm_policy_free(&tmp);
 	}
 
 	if (xp == NULL)
-		return err;
-											read_lock(&xp->lock);
+		return -ENOENT;
+	read_lock(&xp->lock);
 	if (xp->dead) {
 		read_unlock(&xp->lock);
 		goto out;


