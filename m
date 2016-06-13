From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: make tcf_hash_check() boolean
Date: Mon, 13 Jun 2016 13:46:28 -0700
Message-ID: <1465850788-27205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35984 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161183AbcFMUqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:46:37 -0400
Received: by mail-pa0-f68.google.com with SMTP id fg1so11093443pad.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:46:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   | 4 ++--
 net/sched/act_api.c     | 8 ++++----
 net/sched/act_ife.c     | 3 ++-
 net/sched/act_ipt.c     | 3 ++-
 net/sched/act_mirred.c  | 3 ++-
 net/sched/act_simple.c  | 3 ++-
 net/sched/act_skbedit.c | 3 ++-
 net/sched/act_vlan.c    | 4 ++--
 8 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index db218a1..fb82b5b 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -155,8 +155,8 @@ int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct tc_action *a);
 int tcf_hash_search(struct tc_action_net *tn, struct tc_action *a, u32 index);
 u32 tcf_hash_new_index(struct tc_action_net *tn);
-int tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
-		   int bind);
+bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
+		    int bind);
 int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		    struct tc_action *a, int size, int bind, bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b6db56e..f8c61d2 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -224,8 +224,8 @@ int tcf_hash_search(struct tc_action_net *tn, struct tc_action *a, u32 index)
 }
 EXPORT_SYMBOL(tcf_hash_search);
 
-int tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
-		   int bind)
+bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
+		    int bind)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 	struct tcf_common *p = NULL;
@@ -235,9 +235,9 @@ int tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
 		p->tcfc_refcnt++;
 		a->priv = p;
 		a->hinfo = hinfo;
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 EXPORT_SYMBOL(tcf_hash_check);
 
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 02f5a8b..b7fa969 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -423,7 +423,8 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	u16 ife_type = 0;
 	u8 *daddr = NULL;
 	u8 *saddr = NULL;
-	int ret = 0, exists = 0;
+	bool exists = false;
+	int ret = 0;
 	int err;
 
 	err = nla_parse_nested(tb, TCA_IFE_MAX, nla, ife_policy);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 8998a35..6148e32 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -97,7 +97,8 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	struct tcf_ipt *ipt;
 	struct xt_entry_target *td, *t;
 	char *tname;
-	int ret = 0, err, exists = 0;
+	bool exists = false;
+	int ret = 0, err;
 	u32 hook = 0;
 	u32 index = 0;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 787751a..5b135d3 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -62,7 +62,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
-	int ret, ok_push = 0, exists = 0;
+	int ret, ok_push = 0;
+	bool exists = false;
 
 	if (nla == NULL)
 		return -EINVAL;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index be5fbb5..318328d3 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -86,8 +86,9 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_DEF_MAX + 1];
 	struct tc_defact *parm;
 	struct tcf_defact *d;
+	bool exists = false;
+	int ret = 0, err;
 	char *defdata;
-	int ret = 0, err, exists = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 7e2bc3c..53d1486 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -69,7 +69,8 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	struct tcf_skbedit *d;
 	u32 flags = 0, *priority = NULL, *mark = NULL;
 	u16 *queue_mapping = NULL;
-	int ret = 0, err, exists = 0;
+	bool exists = false;
+	int ret = 0, err;
 
 	if (nla == NULL)
 		return -EINVAL;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index b075d50..db9b7ed 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -77,8 +77,8 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	int action;
 	__be16 push_vid = 0;
 	__be16 push_proto = 0;
-	int ret = 0, exists = 0;
-	int err;
+	bool exists = false;
+	int ret = 0, err;
 
 	if (!nla)
 		return -EINVAL;
-- 
2.1.0
