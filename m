From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: sched: fix refcount imbalance in actions
Date: Wed, 29 Jul 2015 17:33:57 -0700
Message-ID: <CAHA+R7MVFhv1_J=0QE6zjCiVtCCKsaU=WgX6eH-u3op7GLZW5w@mail.gmail.com>
References: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36066 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616AbbG3Ad6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 20:33:58 -0400
Received: by ykay190 with SMTP id y190so22219683yka.3
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 17:33:58 -0700 (PDT)
In-Reply-To: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 2:35 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> What happens is that in tcf_hash_check(), we check tcf_common for a given
> index and increase tcfc_refcnt and conditionally tcfc_bindcnt when we've
> found an existing action. Now there are the following cases:
>
>   1) We do a late binding of an action. In that case, we leave the
>      tcfc_refcnt/tcfc_bindcnt increased and are done with the ->init()
>      handler. This is correctly handeled.
>
>   2) We replace the given action, or we try to add one without replacing
>      and find out that the action at a specific index already exists
>      (thus, we go out with error in that case).
>
> In case of 2), we have to undo the reference count increase from
> tcf_hash_check() in the tcf_hash_check() function. Currently, we fail to
> do so because of the 'tcfc_bindcnt > 0' check which bails out early with
> an -EPERM error.
>
> Now, while commit 55334a5db5cd prevents 'tc actions del action ...' on an
> already classifier-bound action to drop the reference count (which could
> then become negative, wrap around etc), this restriction only accounts for
> invocations outside a specific action's ->init() handler.
>
> One possible solution would be to add a flag thus we possibly trigger
> the -EPERM ony in situations where it is indeed relevant.
>
> After the patch, above test cases have correct reference count again.
>

Hmm, so in the tcf_hash_check() !=0 path we forget to decrease the refcount,
maybe we should not increase it at all? Does the following simpler fix make
any sense? I will think more about this tomorrow.

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index af427a3..bd63a39 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -53,8 +53,11 @@ int tcf_hash_release(struct tc_action *a, int bind)
        if (p) {
                if (bind)
                        p->tcfc_bindcnt--;
-               else if (p->tcfc_bindcnt > 0)
-                       return -EPERM;
+               else {
+                       if (p->tcfc_bindcnt > 0)
+                               return -EPERM;
+                       return ret;
+               }

                p->tcfc_refcnt--;
                if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
@@ -214,9 +217,10 @@ int tcf_hash_check(u32 index, struct tc_action
*a, int bind)
        struct tcf_hashinfo *hinfo = a->ops->hinfo;
        struct tcf_common *p = NULL;
        if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
-               if (bind)
+               if (bind) {
                        p->tcfc_bindcnt++;
-               p->tcfc_refcnt++;
+                       p->tcfc_refcnt++;
+               }
                a->priv = p;
                return 1;
        }
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index a42a3b2..2685450 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -98,6 +98,8 @@ static int tcf_mirred_init(struct net *net, struct
nlattr *nla,
                        return ret;
                ret = ACT_P_CREATED;
        } else {
+               if (bind)
+                       return 0;
                if (!ovr) {
                        tcf_hash_release(a, bind);
                        return -EEXIST;
