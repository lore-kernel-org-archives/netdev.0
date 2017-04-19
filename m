From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Wed, 19 Apr 2017 17:03:12 +0200 (CEST)
Message-ID: <1244443915.139.1492614192777@webmail.proxmox.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
 <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com>
 <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:13789 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752876AbdDSPDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 11:03:17 -0400
In-Reply-To: <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On April 19, 2017 at 1:32 PM Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 
> 
> On 17-04-19 04:09 AM, Wolfgang Bumiller wrote:
> 
> This solves one issue, but I am afraid the issue Cong mentioned is a
> possibility still.
> Lets say user did a replace and tried to also replace the cookie
> in that transaction. The init() succeeds but the cookie allocation
> fails. To be correct we'll have to undo the replace i.e something
> like uninit() which will restore back the old values.
> This is very complex and unnecessary.
> 
> My suggestion:
> If we move the cookie allocation before init we can save it and
> only when init succeeds do we attach it to the action, otherwise
> we free it on error path.

Shouldn't the old code have freed an old a->act_cookie as well before
replacing it then? nla_memdup_cookie() starts off by assigning a->act_cookie.

(I've been running this loop for a while now:
# while : ; do tc actions change action ok index 500 cookie $i; let i++; done
and memory usage *seems* to be growing faster with the loop running - still
slow, but visible. (I stopped most but not all background processes in this
VM))

I don't see the growth with the change below (replacing both patches).
(although given the freeing of the old act_cookie pointer I wonder if
this needs additional locking?)

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
