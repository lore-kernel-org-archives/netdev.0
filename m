From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Wed, 19 Apr 2017 10:09:48 +0200 (CEST)
Message-ID: <462700507.23.1492589388406@webmail.proxmox.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
 <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:53813 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760719AbdDSIJ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 04:09:57 -0400
In-Reply-To: <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On April 19, 2017 at 8:23 AM Cong Wang <xiyou.wangcong@gmail.com> wrote:
> 
> 
> On Tue, Apr 18, 2017 at 7:21 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> > Indeed. Allocate the cookie before init? That way, we fail early
> > and dont need to worry about restoring anything.
> 
> No, a->act_cookie needs an action pointer first. ;)
> 
> > In the case of a replace, do you really want to call tcf_hash_release?
> >
> 
> Good point. Probably no, we already call it inside ->init().

Right, doing this (before your change, and after patching tc to allow
sending overlong cookies):

    # tc actions add action ok index 500
    # tc actions change action ok index 500 cookie 112233445566778899aabb
    RTNETLINK answers: Invalid argument
    We have an error talking to the kernel

results in the action disappearing (`tc actions ls action gact` is empty)

And doing this in a loop keeps bumping the module refcount:

    # lsmod |grep act_gact
    act_gact               16384  8023

If I guard the tcf_hash_release() the way you suggested the action
doesn't disappear with the `change` command, and the module refcount
doesn't grow either.

Tested with the adapted version below (since we still need a second
variable due to err changing):

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8cc883c063f0..c7e5e437b847 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -555,6 +555,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct nlattr *kind;
 	int err;
+	bool created;
 
 	if (name == NULL) {
 		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
@@ -603,20 +604,19 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 		err = a_o->init(net, nla, est, &a, ovr, bind);
 	if (err < 0)
 		goto err_mod;
+	created = err == ACT_P_CREATED;
 
 	if (name == NULL && tb[TCA_ACT_COOKIE]) {
 		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
 
 		if (cklen > TC_COOKIE_MAX_SIZE) {
 			err = -EINVAL;
-			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_release;
 		}
 
 		if (nla_memdup_cookie(a, tb) < 0) {
 			err = -ENOMEM;
-			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_release;
 		}
 	}
 
@@ -624,11 +624,14 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	 * if it exists and is only bound to in a_o->init() then
 	 * ACT_P_CREATED is not returned (a zero is).
 	 */
-	if (err != ACT_P_CREATED)
+	if (!created)
 		module_put(a_o->owner);
 
 	return a;
 
+err_release:
+	if (created)
+		tcf_hash_release(a, bind);
 err_mod:
 	module_put(a_o->owner);
 err_out:
