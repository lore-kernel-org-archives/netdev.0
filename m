From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: [PATCH v3 net] net sched actions: allocate act cookie early
Date: Thu, 20 Apr 2017 14:08:26 +0200
Message-ID: <20170420120826.7641-1-w.bumiller@proxmox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:12282 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967353AbdDTMIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:08:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Policing filters do not use the TCA_ACT_* enum and the tb[]
nlattr array in tcf_action_init_1() doesn't get filled for
them so we should not try to look for a TCA_ACT_COOKIE
attribute in the then uninitialized array.
The error handling in cookie allocation then calls
tcf_hash_release() leading to invalid memory access later
on.
Additionally, if cookie allocation fails after an already
existing non-policing filter has successfully been changed,
tcf_action_release() should not be called, also we would
have to roll back the changes in the error handling, so
instead we now allocate the cookie early and assign it on
success at the end.

CVE-2017-7979
Fixes: 1045ba77a596 ("net sched actions: Add support for user cookies")
Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
This replaces both patches of the previous series:
  - 1/2 net sched actions: fix access to uninitialized data
   Changed: The affected code is now moved up into the first
            (name==NULL) branch rather than adding this condition anew.
  - 2/2 net sched actions: decrement module refcount earlier
   Changed: Instead of moving the module_put above the cookie code,
            the cookie code is moved as described in the commit
            message.

 net/sched/act_api.c | 55 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 32 insertions(+), 23 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b70aa57319ea..e05b924618a0 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -529,20 +529,20 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *actions,
 	return err;
 }
 
-static int nla_memdup_cookie(struct tc_action *a, struct nlattr **tb)
+static struct tc_cookie *nla_memdup_cookie(struct nlattr **tb)
 {
-	a->act_cookie = kzalloc(sizeof(*a->act_cookie), GFP_KERNEL);
-	if (!a->act_cookie)
-		return -ENOMEM;
+	struct tc_cookie *c = kzalloc(sizeof(*c), GFP_KERNEL);
+	if (!c)
+		return NULL;
 
-	a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE], GFP_KERNEL);
-	if (!a->act_cookie->data) {
-		kfree(a->act_cookie);
-		return -ENOMEM;
+	c->data = nla_memdup(tb[TCA_ACT_COOKIE], GFP_KERNEL);
+	if (!c->data) {
+		kfree(c);
+		return NULL;
 	}
-	a->act_cookie->len = nla_len(tb[TCA_ACT_COOKIE]);
+	c->len = nla_len(tb[TCA_ACT_COOKIE]);
 
-	return 0;
+	return c;
 }
 
 struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
@@ -551,6 +551,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
+	struct tc_cookie *cookie = NULL;
 	char act_name[IFNAMSIZ];
 	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct nlattr *kind;
@@ -566,6 +567,18 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 			goto err_out;
 		if (nla_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
+		if (tb[TCA_ACT_COOKIE]) {
+			int cklen = nla_len(tb[TCA_ACT_COOKIE]);
+
+			if (cklen > TC_COOKIE_MAX_SIZE)
+				goto err_out;
+
+			cookie = nla_memdup_cookie(tb);
+			if (!cookie) {
+				err = -ENOMEM;
+				goto err_out;
+			}
+		}
 	} else {
 		err = -EINVAL;
 		if (strlcpy(act_name, name, IFNAMSIZ) >= IFNAMSIZ)
@@ -604,20 +617,12 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
-	if (tb[TCA_ACT_COOKIE]) {
-		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
-
-		if (cklen > TC_COOKIE_MAX_SIZE) {
-			err = -EINVAL;
-			tcf_hash_release(a, bind);
-			goto err_mod;
-		}
-
-		if (nla_memdup_cookie(a, tb) < 0) {
-			err = -ENOMEM;
-			tcf_hash_release(a, bind);
-			goto err_mod;
+	if (name == NULL && tb[TCA_ACT_COOKIE]) {
+		if (a->act_cookie) {
+			kfree(a->act_cookie->data);
+			kfree(a->act_cookie);
 		}
+		a->act_cookie = cookie;
 	}
 
 	/* module count goes up only when brand new policy is created
@@ -632,6 +637,10 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 err_mod:
 	module_put(a_o->owner);
 err_out:
+	if (cookie) {
+		kfree(cookie->data);
+		kfree(cookie);
+	}
 	return ERR_PTR(err);
 }
 
-- 
2.11.0
