From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Tue, 22 Nov 2016 15:36:16 -0800
Message-ID: <5834D670.2050301@gmail.com>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
 <20161122144844.GB1819@nanopsycho> <58346C7B.7090006@iogearbox.net>
 <20161122161159.GC1819@nanopsycho>
 <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
 <5834AD97.1020600@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35969 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932474AbcKVXgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 18:36:47 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so3329722pgx.3
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 15:36:47 -0800 (PST)
In-Reply-To: <5834AD97.1020600@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-22 12:41 PM, Daniel Borkmann wrote:
> On 11/22/2016 08:28 PM, Cong Wang wrote:
>> On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>>> Hmm, I don't think we want to have such an additional test in fast
>>>> path for each and every classifier. Can we think of ways to avoid that?
>>>>
>>>> My question is, since we unlink individual instances from such
>>>> tp-internal
>>>> lists through RCU and release the instance through call_rcu() as
>>>> well as
>>>> the head (tp->root) via kfree_rcu() eventually, against what are we
>>>> protecting
>>>> setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback?
>>>> Something
>>>> not respecting grace period?
>>>
>>> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
>>> to null.
> 
> But that's not really an answer to my question. ;)
> 
>> We do need to respect the grace period if we touch the globally visible
>> data structure tp in tcf_destroy(). Therefore Roi's patch is not
>> fixing the
>> right place.
> 
> I think there may be multiple issues actually.
> 
> At the time we go into tc_classify(), from ingress as well as egress side,
> we're under RCU, but BH variant. In cls delete()/destroy() callbacks, we
> everywhere use call_rcu() and kfree_rcu(), same as for tcf_destroy() where
> we use kfree_rcu() on tp, although we iterate tps (and implicitly inner
> filters)
> via rcu_dereference_bh() from reader side. Is there a reason why we don't
> use call_rcu_bh() variant on destruction for all this instead?

I can't think of any if its all under _bh we can convert the call_rcu to
call_rcu_bh it just needs an audit.

> 
> Just looking at cls_bpf and others, what protects
> RCU_INIT_POINTER(tp->root,
> NULL) against? The tp is unlinked in tc_ctl_tfilter() from the tp chain in
> tcf_destroy() cases. Still active readers under RCU BH can race against
> this
> (tp->root being NULL), as the commit identified. Only the get() callback
> checks
> for head against NULL, but both are serialized under rtnl, and the only
> place
> we call this is tc_ctl_tfilter(). Even if we create a new tp, head
> should not
> be NULL there, if it was assigned during the init() cb, but contains an
> empty
> list. (It's different for things like cls_cgroup, though.) So, I'm
> wondering
> if the RCU_INIT_POINTER(tp->root, NULL) can just be removed instead
> (unless I'm
> missing something obvious)?


Just took a look at this I think there are a couple possible solutions.
The easiest is likely to fix all the call sites so that 'tp' is unlinked
before calling the destroy() handlers AND not doing the NULL set. I only
see one such call site where destroy is called before unlinking at the
moment. This should enforce that after a grace period there is no path
to reach the classifiers because 'tp' is unlinked. Calling destroy
before unlinking 'tp' however could cause a small race between grace
period of 'tp' and grace period of the filter.

Another would be to only call the destroy path from the call_rcu path
of the 'tp' object so that destroy is only ever called after the object
is guaranteed to be unlinked from the tc_filter path.

I think both solutions would be fine.

Cong were you working on one of these? Or do you have another idea?


> 
>> Also I don't know why you blame my commit, this problem should already
>> exist prior to my commit, probably date back to John's RCU patches.
> 
> It seems so.
