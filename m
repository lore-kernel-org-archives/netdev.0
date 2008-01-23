From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 15/15]: Use nla_policy for attribute validation in ematches
Date: Wed, 23 Jan 2008 17:36:57 +0100 (MET)
Message-ID: <20080123163616.6459.97188.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49758 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbYAWQg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:58 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use nla_policy for attribute validation in ematches

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9420f06512465a8a90f3ff0df8b943989bc7e2e7
tree 7556b31b93647c9d2c30eb567b50671d368f8ced
parent 99302e1c1ed003305e9a0102aa772e2f2d61114c
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:23:09 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:23:09 +0100

 net/sched/em_meta.c |    9 ++++++---
 net/sched/ematch.c  |   11 ++++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index d9f487d..a1e5619 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -745,6 +745,10 @@ static inline int meta_is_supported(struct meta_value *val)
 	return (!meta_id(val) || meta_ops(val)->get);
 }
 
+static const struct nla_policy meta_policy[TCA_EM_META_MAX + 1] = {
+	[TCA_EM_META_HDR]	= { .len = sizeof(struct tcf_meta_hdr) },
+};
+
 static int em_meta_change(struct tcf_proto *tp, void *data, int len,
 			  struct tcf_ematch *m)
 {
@@ -753,13 +757,12 @@ static int em_meta_change(struct tcf_proto *tp, void *data, int len,
 	struct tcf_meta_hdr *hdr;
 	struct meta_match *meta = NULL;
 
-	err = nla_parse(tb, TCA_EM_META_MAX, data, len, NULL);
+	err = nla_parse(tb, TCA_EM_META_MAX, data, len, meta_policy);
 	if (err < 0)
 		goto errout;
 
 	err = -EINVAL;
-	if (tb[TCA_EM_META_HDR] == NULL ||
-	    nla_len(tb[TCA_EM_META_HDR]) < sizeof(*hdr))
+	if (tb[TCA_EM_META_HDR] == NULL)
 		goto errout;
 	hdr = nla_data(tb[TCA_EM_META_HDR]);
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index daa9c4e..74ff918 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -282,6 +282,11 @@ errout:
 	return err;
 }
 
+static const struct nla_policy em_policy[TCA_EMATCH_TREE_MAX + 1] = {
+	[TCA_EMATCH_TREE_HDR]	= { .len = sizeof(struct tcf_ematch_tree_hdr) },
+	[TCA_EMATCH_TREE_LIST]	= { .type = NLA_NESTED },
+};
+
 /**
  * tcf_em_tree_validate - validate ematch config TLV and build ematch tree
  *
@@ -312,7 +317,7 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 		return 0;
 	}
 
-	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, em_policy);
 	if (err < 0)
 		goto errout;
 
@@ -323,10 +328,6 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 	if (rt_hdr == NULL || rt_list == NULL)
 		goto errout;
 
-	if (nla_len(rt_hdr) < sizeof(*tree_hdr) ||
-	    nla_len(rt_list) < sizeof(*rt_match))
-		goto errout;
-
 	tree_hdr = nla_data(rt_hdr);
 	memcpy(&tree->hdr, tree_hdr, sizeof(*tree_hdr));
 
