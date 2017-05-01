From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/53] netfilter: expect: Make sure the max_expected limit is effective
Date: Mon,  1 May 2017 12:46:32 +0200
Message-ID: <1493635640-24325-6-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Because the type of expecting, the member of nf_conn_help, is u8, it
would overflow after reach U8_MAX(255). So it doesn't work when we
configure the max_expected exceeds 255 with expect policy.

Now add the check for max_expected. Return the -EINVAL when it exceeds
the limit.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_expect.h | 1 +
 net/netfilter/nf_conntrack_helper.c         | 3 +++
 net/netfilter/nf_conntrack_irc.c            | 6 ++++++
 net/netfilter/nfnetlink_cthelper.c          | 6 ++++++
 4 files changed, 16 insertions(+)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 65cc2cb005d9..e84df8d3bf37 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -73,6 +73,7 @@ struct nf_conntrack_expect_policy {
 };
 
 #define NF_CT_EXPECT_CLASS_DEFAULT	0
+#define NF_CT_EXPECT_MAX_CNT		255
 
 int nf_conntrack_expect_pernet_init(struct net *net);
 void nf_conntrack_expect_pernet_fini(struct net *net);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 6dc44d9b4190..752a977e9eef 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -385,6 +385,9 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 	BUG_ON(me->expect_class_max >= NF_CT_MAX_EXPECT_CLASSES);
 	BUG_ON(strlen(me->name) > NF_CT_HELPER_NAME_LEN - 1);
 
+	if (me->expect_policy->max_expected > NF_CT_EXPECT_MAX_CNT)
+		return -EINVAL;
+
 	mutex_lock(&nf_ct_helper_mutex);
 	hlist_for_each_entry(cur, &nf_ct_helper_hash[h], hnode) {
 		if (nf_ct_tuple_src_mask_cmp(&cur->tuple, &me->tuple, &mask)) {
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 1972a149f958..1a5af4d4af2d 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -243,6 +243,12 @@ static int __init nf_conntrack_irc_init(void)
 		return -EINVAL;
 	}
 
+	if (max_dcc_channels > NF_CT_EXPECT_MAX_CNT) {
+		pr_err("max_dcc_channels must not be more than %u\n",
+		       NF_CT_EXPECT_MAX_CNT);
+		return -EINVAL;
+	}
+
 	irc_exp_policy.max_expected = max_dcc_channels;
 	irc_exp_policy.timeout = dcc_timeout;
 
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index d45558178da5..d5025cc25df3 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -150,6 +150,9 @@ nfnl_cthelper_expect_policy(struct nf_conntrack_expect_policy *expect_policy,
 		nla_data(tb[NFCTH_POLICY_NAME]), NF_CT_HELPER_NAME_LEN);
 	expect_policy->max_expected =
 		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_MAX]));
+	if (expect_policy->max_expected > NF_CT_EXPECT_MAX_CNT)
+		return -EINVAL;
+
 	expect_policy->timeout =
 		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_TIMEOUT]));
 
@@ -290,6 +293,9 @@ nfnl_cthelper_update_policy_one(const struct nf_conntrack_expect_policy *policy,
 
 	new_policy->max_expected =
 		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_MAX]));
+	if (new_policy->max_expected > NF_CT_EXPECT_MAX_CNT)
+		return -EINVAL;
+
 	new_policy->timeout =
 		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_TIMEOUT]));
 
-- 
2.1.4

