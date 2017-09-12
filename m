From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v3 1/3] net_sched: get rid of tcfa_rcu
Date: Tue, 12 Sep 2017 14:10:22 -0700
Message-ID: <CAM_iQpWN+OFdWZgKsm8qk58jFKqssOMMW8JM7N6FConHumQXxg@mail.gmail.com>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-2-xiyou.wangcong@gmail.com> <20170912094215.GB2036@nanopsycho>
 <20170912104004.GE2036@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36384 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdILVKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 17:10:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id f84so6680097pfj.3
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 14:10:43 -0700 (PDT)
In-Reply-To: <20170912104004.GE2036@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 3:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Sep 12, 2017 at 11:42:15AM CEST, jiri@resnulli.us wrote:
>>Tue, Sep 12, 2017 at 01:33:30AM CEST, xiyou.wangcong@gmail.com wrote:
>>>gen estimator has been rewritten in commit 1c0d32fde5bd
>>>("net_sched: gen_estimator: complete rewrite of rate estimators"),
>>>the caller is no longer needed to wait for a grace period.
>>>So this patch gets rid of it.
>>>
>>>This also completely closes a race condition between action free
>>>path and filter chain add/remove path for the following patch.
>>>Because otherwise the nested RCU callback can't be caught by
>>>rcu_barrier().
>>>
>>>Please see also the comments in code.
>>
>>Looks like this is causing a null pointer dereference bug for me, 100%
>>of the time. Just add and remove any rule with action and you get:
>>
>
> [...]
>
>>
>>Looks like you need to save owner of the module before you call
>>__tcf_idr_release so you can later on use it for module_put

Why do you believe it is this patch introduces the bug?

That code has been there since the beginning of git history:

+       for (a = act; a; a = act) {
+               if (a->ops && a->ops->cleanup) {
+                       DPRINTK("tcf_action_destroy destroying %p next %p\n",
+                               a, a->next);
+                       if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
+                               module_put(a->ops->owner);
+                       act = act->next;

Seems to be a very old one. The reason why it exposes, I guess,
is call_rcu() somehow delays the free after module_put().


>
> This patch helps:

Looks good to me. Please feel free to submit a formal patch.
