From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: check return code from nla_parse_tested
Date: Mon,  1 Jul 2013 01:54:30 +0200
Message-ID: <1372636481-3705-2-git-send-email-pablo@netfilter.org>
References: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1372636481-3705-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>

These are the only calls under net/ that do not check nla_parse_nested()
for its error code, but simply continue execution. If parsing of netlink
attributes fails, we should return with an error instead of continuing.
In nearly all of these calls we have a policy attached, that is being
type verified during nla_parse_nested(), which we would miss checking
for otherwise.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   30 +++++++++++++++++++++++-------
 net/netfilter/nfnetlink_cthelper.c   |   16 ++++++++++++----
 net/netfilter/nfnetlink_cttimeout.c  |    6 ++++--
 3 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6d0f8a1..f83a522 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -828,7 +828,9 @@ ctnetlink_parse_tuple_ip(struct nlattr *attr, struct nf_conntrack_tuple *tuple)
 	struct nf_conntrack_l3proto *l3proto;
 	int ret = 0;
 
-	nla_parse_nested(tb, CTA_IP_MAX, attr, NULL);
+	ret = nla_parse_nested(tb, CTA_IP_MAX, attr, NULL);
+	if (ret < 0)
+		return ret;
 
 	rcu_read_lock();
 	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
@@ -895,7 +897,9 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 
 	memset(tuple, 0, sizeof(*tuple));
 
-	nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], tuple_nla_policy);
+	err = nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], tuple_nla_policy);
+	if (err < 0)
+		return err;
 
 	if (!tb[CTA_TUPLE_IP])
 		return -EINVAL;
@@ -946,9 +950,12 @@ static inline int
 ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
 		     struct nlattr **helpinfo)
 {
+	int err;
 	struct nlattr *tb[CTA_HELP_MAX+1];
 
-	nla_parse_nested(tb, CTA_HELP_MAX, attr, help_nla_policy);
+	err = nla_parse_nested(tb, CTA_HELP_MAX, attr, help_nla_policy);
+	if (err < 0)
+		return err;
 
 	if (!tb[CTA_HELP_NAME])
 		return -EINVAL;
@@ -1431,7 +1438,9 @@ ctnetlink_change_protoinfo(struct nf_conn *ct, const struct nlattr * const cda[]
 	struct nf_conntrack_l4proto *l4proto;
 	int err = 0;
 
-	nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy);
+	err = nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy);
+	if (err < 0)
+		return err;
 
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
@@ -1452,9 +1461,12 @@ static const struct nla_policy nat_seq_policy[CTA_NAT_SEQ_MAX+1] = {
 static inline int
 change_nat_seq_adj(struct nf_nat_seq *natseq, const struct nlattr * const attr)
 {
+	int err;
 	struct nlattr *cda[CTA_NAT_SEQ_MAX+1];
 
-	nla_parse_nested(cda, CTA_NAT_SEQ_MAX, attr, nat_seq_policy);
+	err = nla_parse_nested(cda, CTA_NAT_SEQ_MAX, attr, nat_seq_policy);
+	if (err < 0)
+		return err;
 
 	if (!cda[CTA_NAT_SEQ_CORRECTION_POS])
 		return -EINVAL;
@@ -2115,7 +2127,9 @@ ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 	struct nlattr *cda[CTA_MAX+1];
 	int ret;
 
-	nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
+	ret = nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
+	if (ret < 0)
+		return ret;
 
 	spin_lock_bh(&nf_conntrack_lock);
 	ret = ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
@@ -2710,7 +2724,9 @@ ctnetlink_parse_expect_nat(const struct nlattr *attr,
 	struct nf_conntrack_tuple nat_tuple = {};
 	int err;
 
-	nla_parse_nested(tb, CTA_EXPECT_NAT_MAX, attr, exp_nat_nla_policy);
+	err = nla_parse_nested(tb, CTA_EXPECT_NAT_MAX, attr, exp_nat_nla_policy);
+	if (err < 0)
+		return err;
 
 	if (!tb[CTA_EXPECT_NAT_DIR] || !tb[CTA_EXPECT_NAT_TUPLE])
 		return -EINVAL;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index a191b6d..9e287cb 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -67,9 +67,12 @@ static int
 nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *tuple,
 			  const struct nlattr *attr)
 {
+	int err;
 	struct nlattr *tb[NFCTH_TUPLE_MAX+1];
 
-	nla_parse_nested(tb, NFCTH_TUPLE_MAX, attr, nfnl_cthelper_tuple_pol);
+	err = nla_parse_nested(tb, NFCTH_TUPLE_MAX, attr, nfnl_cthelper_tuple_pol);
+	if (err < 0)
+		return err;
 
 	if (!tb[NFCTH_TUPLE_L3PROTONUM] || !tb[NFCTH_TUPLE_L4PROTONUM])
 		return -EINVAL;
@@ -121,9 +124,12 @@ static int
 nfnl_cthelper_expect_policy(struct nf_conntrack_expect_policy *expect_policy,
 			    const struct nlattr *attr)
 {
+	int err;
 	struct nlattr *tb[NFCTH_POLICY_MAX+1];
 
-	nla_parse_nested(tb, NFCTH_POLICY_MAX, attr, nfnl_cthelper_expect_pol);
+	err = nla_parse_nested(tb, NFCTH_POLICY_MAX, attr, nfnl_cthelper_expect_pol);
+	if (err < 0)
+		return err;
 
 	if (!tb[NFCTH_POLICY_NAME] ||
 	    !tb[NFCTH_POLICY_EXPECT_MAX] ||
@@ -153,8 +159,10 @@ nfnl_cthelper_parse_expect_policy(struct nf_conntrack_helper *helper,
 	struct nf_conntrack_expect_policy *expect_policy;
 	struct nlattr *tb[NFCTH_POLICY_SET_MAX+1];
 
-	nla_parse_nested(tb, NFCTH_POLICY_SET_MAX, attr,
-					nfnl_cthelper_expect_policy_set);
+	ret = nla_parse_nested(tb, NFCTH_POLICY_SET_MAX, attr,
+			       nfnl_cthelper_expect_policy_set);
+	if (ret < 0)
+		return ret;
 
 	if (!tb[NFCTH_POLICY_SET_NUM])
 		return -EINVAL;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 65074df..5058049 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -59,8 +59,10 @@ ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
 	if (likely(l4proto->ctnl_timeout.nlattr_to_obj)) {
 		struct nlattr *tb[l4proto->ctnl_timeout.nlattr_max+1];
 
-		nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
-				 attr, l4proto->ctnl_timeout.nla_policy);
+		ret = nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
+				       attr, l4proto->ctnl_timeout.nla_policy);
+		if (ret < 0)
+			return ret;
 
 		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, net,
 							  &timeout->data);
-- 
1.7.10.4

