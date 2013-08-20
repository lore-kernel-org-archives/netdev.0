From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/19] netfilter: ctnetlink: refactor ctnetlink_create_expect
Date: Tue, 20 Aug 2013 12:54:48 +0200
Message-ID: <1376996091-3964-17-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60130 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab3HTKzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:16 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch refactors ctnetlink_create_expect by spliting it in two
chunks. As a result, we have a new function ctnetlink_alloc_expect
to allocate and to setup the expectation from ctnetlink.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |  156 +++++++++++++++++++---------------
 1 file changed, 87 insertions(+), 69 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e842c0d..9aaa68b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2735,76 +2735,26 @@ ctnetlink_parse_expect_nat(const struct nlattr *attr,
 #endif
 }
 
-static int
-ctnetlink_create_expect(struct net *net, u16 zone,
-			const struct nlattr * const cda[],
-			u_int8_t u3,
-			u32 portid, int report)
+static struct nf_conntrack_expect *
+ctnetlink_alloc_expect(const struct nlattr * const cda[], struct nf_conn *ct,
+		       struct nf_conntrack_helper *helper,
+		       struct nf_conntrack_tuple *tuple,
+		       struct nf_conntrack_tuple *mask)
 {
-	struct nf_conntrack_tuple tuple, mask, master_tuple;
-	struct nf_conntrack_tuple_hash *h = NULL;
+	u_int32_t class = 0;
 	struct nf_conntrack_expect *exp;
-	struct nf_conn *ct;
 	struct nf_conn_help *help;
-	struct nf_conntrack_helper *helper = NULL;
-	u_int32_t class = 0;
-	int err = 0;
-
-	/* caller guarantees that those three CTA_EXPECT_* exist */
-	err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE, u3);
-	if (err < 0)
-		return err;
-	err = ctnetlink_parse_tuple(cda, &mask, CTA_EXPECT_MASK, u3);
-	if (err < 0)
-		return err;
-	err = ctnetlink_parse_tuple(cda, &master_tuple, CTA_EXPECT_MASTER, u3);
-	if (err < 0)
-		return err;
-
-	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(net, zone, &master_tuple);
-	if (!h)
-		return -ENOENT;
-	ct = nf_ct_tuplehash_to_ctrack(h);
-
-	/* Look for helper of this expectation */
-	if (cda[CTA_EXPECT_HELP_NAME]) {
-		const char *helpname = nla_data(cda[CTA_EXPECT_HELP_NAME]);
-
-		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
-						    nf_ct_protonum(ct));
-		if (helper == NULL) {
-#ifdef CONFIG_MODULES
-			if (request_module("nfct-helper-%s", helpname) < 0) {
-				err = -EOPNOTSUPP;
-				goto out;
-			}
-
-			helper = __nf_conntrack_helper_find(helpname,
-							    nf_ct_l3num(ct),
-							    nf_ct_protonum(ct));
-			if (helper) {
-				err = -EAGAIN;
-				goto out;
-			}
-#endif
-			err = -EOPNOTSUPP;
-			goto out;
-		}
-	}
+	int err;
 
 	if (cda[CTA_EXPECT_CLASS] && helper) {
 		class = ntohl(nla_get_be32(cda[CTA_EXPECT_CLASS]));
-		if (class > helper->expect_class_max) {
-			err = -EINVAL;
-			goto out;
-		}
+		if (class > helper->expect_class_max)
+			return ERR_PTR(-EINVAL);
 	}
 	exp = nf_ct_expect_alloc(ct);
-	if (!exp) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!exp)
+		return ERR_PTR(-ENOMEM);
+
 	help = nfct_help(ct);
 	if (!help) {
 		if (!cda[CTA_EXPECT_TIMEOUT]) {
@@ -2842,21 +2792,89 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	exp->class = class;
 	exp->master = ct;
 	exp->helper = helper;
-	memcpy(&exp->tuple, &tuple, sizeof(struct nf_conntrack_tuple));
-	memcpy(&exp->mask.src.u3, &mask.src.u3, sizeof(exp->mask.src.u3));
-	exp->mask.src.u.all = mask.src.u.all;
+	exp->tuple = *tuple;
+	exp->mask.src.u3 = mask->src.u3;
+	exp->mask.src.u.all = mask->src.u.all;
 
 	if (cda[CTA_EXPECT_NAT]) {
 		err = ctnetlink_parse_expect_nat(cda[CTA_EXPECT_NAT],
-						 exp, u3);
+						 exp, nf_ct_l3num(ct));
 		if (err < 0)
 			goto err_out;
 	}
-	err = nf_ct_expect_related_report(exp, portid, report);
+	return exp;
 err_out:
 	nf_ct_expect_put(exp);
-out:
-	nf_ct_put(nf_ct_tuplehash_to_ctrack(h));
+	return ERR_PTR(err);
+}
+
+static int
+ctnetlink_create_expect(struct net *net, u16 zone,
+			const struct nlattr * const cda[],
+			u_int8_t u3, u32 portid, int report)
+{
+	struct nf_conntrack_tuple tuple, mask, master_tuple;
+	struct nf_conntrack_tuple_hash *h = NULL;
+	struct nf_conntrack_helper *helper = NULL;
+	struct nf_conntrack_expect *exp;
+	struct nf_conn *ct;
+	int err;
+
+	/* caller guarantees that those three CTA_EXPECT_* exist */
+	err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE, u3);
+	if (err < 0)
+		return err;
+	err = ctnetlink_parse_tuple(cda, &mask, CTA_EXPECT_MASK, u3);
+	if (err < 0)
+		return err;
+	err = ctnetlink_parse_tuple(cda, &master_tuple, CTA_EXPECT_MASTER, u3);
+	if (err < 0)
+		return err;
+
+	/* Look for master conntrack of this expectation */
+	h = nf_conntrack_find_get(net, zone, &master_tuple);
+	if (!h)
+		return -ENOENT;
+	ct = nf_ct_tuplehash_to_ctrack(h);
+
+	if (cda[CTA_EXPECT_HELP_NAME]) {
+		const char *helpname = nla_data(cda[CTA_EXPECT_HELP_NAME]);
+
+		helper = __nf_conntrack_helper_find(helpname, u3,
+						    nf_ct_protonum(ct));
+		if (helper == NULL) {
+#ifdef CONFIG_MODULES
+			if (request_module("nfct-helper-%s", helpname) < 0) {
+				err = -EOPNOTSUPP;
+				goto err_ct;
+			}
+			helper = __nf_conntrack_helper_find(helpname, u3,
+							    nf_ct_protonum(ct));
+			if (helper) {
+				err = -EAGAIN;
+				goto err_ct;
+			}
+#endif
+			err = -EOPNOTSUPP;
+			goto err_ct;
+		}
+	}
+
+	exp = ctnetlink_alloc_expect(cda, ct, helper, &tuple, &mask);
+	if (IS_ERR(exp)) {
+		err = PTR_ERR(exp);
+		goto err_ct;
+	}
+
+	err = nf_ct_expect_related_report(exp, portid, report);
+	if (err < 0)
+		goto err_exp;
+
+	return 0;
+err_exp:
+	nf_ct_expect_put(exp);
+err_ct:
+	nf_ct_put(ct);
 	return err;
 }
 
-- 
1.7.10.4
