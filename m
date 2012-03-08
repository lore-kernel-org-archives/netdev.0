From: pablo@netfilter.org
Subject: [PATCH 06/23] netfilter: ctnetlink: allow to set helper for new expectations
Date: Thu,  8 Mar 2012 02:00:55 +0100
Message-ID: <1331168472-5820-7-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allow you to set the helper for newly created
expectations based of the CTA_EXPECT_HELP_NAME attribute.
Before this, the helper set was NULL.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 04fb409..1b0aea6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2042,6 +2042,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	struct nf_conntrack_expect *exp;
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
+	struct nf_conntrack_helper *helper = NULL;
 	int err = 0;
 
 	/* caller guarantees that those three CTA_EXPECT_* exist */
@@ -2060,6 +2061,33 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
+
+	/* Look for helper of this expectation */
+	if (cda[CTA_EXPECT_HELP_NAME]) {
+		const char *helpname = nla_data(cda[CTA_EXPECT_HELP_NAME]);
+
+		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
+						    nf_ct_protonum(ct));
+		if (helper == NULL) {
+#ifdef CONFIG_MODULES
+			if (request_module("nfct-helper-%s", helpname) < 0) {
+				err = -EOPNOTSUPP;
+				goto out;
+			}
+
+			helper = __nf_conntrack_helper_find(helpname,
+							    nf_ct_l3num(ct),
+							    nf_ct_protonum(ct));
+			if (helper) {
+				err = -EAGAIN;
+				goto out;
+			}
+#endif
+			err = -EOPNOTSUPP;
+			goto out;
+		}
+	}
+
 	exp = nf_ct_expect_alloc(ct);
 	if (!exp) {
 		err = -ENOMEM;
@@ -2090,7 +2118,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	exp->class = 0;
 	exp->expectfn = NULL;
 	exp->master = ct;
-	exp->helper = NULL;
+	exp->helper = helper;
 	memcpy(&exp->tuple, &tuple, sizeof(struct nf_conntrack_tuple));
 	memcpy(&exp->mask.src.u3, &mask.src.u3, sizeof(exp->mask.src.u3));
 	exp->mask.src.u.all = mask.src.u.all;
-- 
1.7.7.3

