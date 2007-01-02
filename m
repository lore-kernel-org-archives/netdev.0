From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] xfrm_user: avoid pointless void ** casts
Date: Tue, 2 Jan 2007 15:39:06 +0100
Message-ID: <20070102143906.GA13970@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:48001 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755281AbXABOwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 09:52:11 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All ->doit handlers want a struct rtattr **, so pass down the right
type.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/net/xfrm/xfrm_user.c
===================================================================
--- linux-2.6.orig/net/xfrm/xfrm_user.c	2006-12-12 11:30:55.000000000 +0100
+++ linux-2.6/net/xfrm/xfrm_user.c	2007-01-02 15:35:31.000000000 +0100
@@ -434,18 +434,19 @@
 	return NULL;
 }
 
-static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_usersa_info *p = NLMSG_DATA(nlh);
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
 
-	err = verify_newsa_info(p, (struct rtattr **)xfrma);
+	err = verify_newsa_info(p, xfrma);
 	if (err)
 		return err;
 
-	x = xfrm_state_construct(p, (struct rtattr **)xfrma, &err);
+	x = xfrm_state_construct(p, xfrma, &err);
 	if (!x)
 		return err;
 
@@ -507,14 +508,15 @@
 	return x;
 }
 
-static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_state *x;
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 
-	x = xfrm_user_state_lookup(p, (struct rtattr **)xfrma, &err);
+	x = xfrm_user_state_lookup(p, xfrma, &err);
 	if (x == NULL)
 		return err;
 
@@ -672,14 +674,15 @@
 	return skb;
 }
 
-static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
 	struct xfrm_state *x;
 	struct sk_buff *resp_skb;
 	int err = -ESRCH;
 
-	x = xfrm_user_state_lookup(p, (struct rtattr **)xfrma, &err);
+	x = xfrm_user_state_lookup(p, xfrma, &err);
 	if (x == NULL)
 		goto out_noput;
 
@@ -718,7 +721,8 @@
 	return 0;
 }
 
-static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_state *x;
 	struct xfrm_userspi_info *p;
@@ -1013,7 +1017,8 @@
 	return NULL;
 }
 
-static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_userpolicy_info *p = NLMSG_DATA(nlh);
 	struct xfrm_policy *xp;
@@ -1024,11 +1029,11 @@
 	err = verify_newpolicy_info(p);
 	if (err)
 		return err;
-	err = verify_sec_ctx_len((struct rtattr **)xfrma);
+	err = verify_sec_ctx_len(xfrma);
 	if (err)
 		return err;
 
-	xp = xfrm_policy_construct(p, (struct rtattr **)xfrma, &err);
+	xp = xfrm_policy_construct(p, xfrma, &err);
 	if (!xp)
 		return err;
 
@@ -1227,7 +1232,8 @@
 	return skb;
 }
 
-static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_userpolicy_id *p;
@@ -1239,7 +1245,7 @@
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
 
-	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	err = copy_from_user_policy_type(&type, xfrma);
 	if (err)
 		return err;
 
@@ -1250,11 +1256,10 @@
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, delete);
 	else {
-		struct rtattr **rtattrs = (struct rtattr **)xfrma;
-		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
+		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
 		struct xfrm_policy tmp;
 
-		err = verify_sec_ctx_len(rtattrs);
+		err = verify_sec_ctx_len(xfrma);
 		if (err)
 			return err;
 
@@ -1302,7 +1307,8 @@
 	return err;
 }
 
-static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct km_event c;
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
@@ -1367,7 +1373,8 @@
 	return -1;
 }
 
-static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_state *x;
 	struct sk_buff *r_skb;
@@ -1415,7 +1422,8 @@
 	return err;
 }
 
-static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_state *x;
 	struct km_event c;
@@ -1439,7 +1447,7 @@
 		goto out;
 
 	spin_lock_bh(&x->lock);
-	err = xfrm_update_ae_params(x,(struct rtattr **)xfrma);
+	err = xfrm_update_ae_params(x, xfrma);
 	spin_unlock_bh(&x->lock);
 	if (err	< 0)
 		goto out;
@@ -1455,14 +1463,15 @@
 	return err;
 }
 
-static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct km_event c;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
 	struct xfrm_audit audit_info;
 
-	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	err = copy_from_user_policy_type(&type, xfrma);
 	if (err)
 		return err;
 
@@ -1477,7 +1486,8 @@
 	return 0;
 }
 
-static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_polexpire *up = NLMSG_DATA(nlh);
@@ -1485,18 +1495,17 @@
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 
-	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	err = copy_from_user_policy_type(&type, xfrma);
 	if (err)
 		return err;
 
 	if (p->index)
 		xp = xfrm_policy_byid(type, p->dir, p->index, 0);
 	else {
-		struct rtattr **rtattrs = (struct rtattr **)xfrma;
-		struct rtattr *rt = rtattrs[XFRMA_SEC_CTX-1];
+		struct rtattr *rt = xfrma[XFRMA_SEC_CTX-1];
 		struct xfrm_policy tmp;
 
-		err = verify_sec_ctx_len(rtattrs);
+		err = verify_sec_ctx_len(xfrma);
 		if (err)
 			return err;
 
@@ -1537,7 +1546,8 @@
 	return err;
 }
 
-static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_state *x;
 	int err;
@@ -1568,7 +1578,8 @@
 	return err;
 }
 
-static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
 {
 	struct xfrm_policy *xp;
 	struct xfrm_user_tmpl *ut;
@@ -1647,7 +1658,7 @@
 #undef XMSGSIZE
 
 static struct xfrm_link {
-	int (*doit)(struct sk_buff *, struct nlmsghdr *, void **);
+	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct rtattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
@@ -1735,7 +1746,7 @@
 
 	if (link->doit == NULL)
 		goto err_einval;
-	*errp = link->doit(skb, nlh, (void **) &xfrma);
+	*errp = link->doit(skb, nlh, xfrma);
 
 	return *errp;
 
