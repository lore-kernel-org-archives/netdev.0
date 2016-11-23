From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer before
 dereferncing it
Date: Wed, 23 Nov 2016 12:29:02 +0100
Message-ID: <58357D7E.3010100@iogearbox.net>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com> <20161122144844.GB1819@nanopsycho> <58346C7B.7090006@iogearbox.net> <20161122161159.GC1819@nanopsycho> <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com> <5834AD97.1020600@iogearbox.net> <5834D670.2050301@gmail.com> <CAM_iQpWhGfrZgBD1Li+efZCv4Q6uGno1ttXcBL4C_F+4es4e_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45707 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932878AbcKWMUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:20:43 -0500
In-Reply-To: <CAM_iQpWhGfrZgBD1Li+efZCv4Q6uGno1ttXcBL4C_F+4es4e_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 06:24 AM, Cong Wang wrote:
> On Tue, Nov 22, 2016 at 3:36 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> On 16-11-22 12:41 PM, Daniel Borkmann wrote:
>>> On 11/22/2016 08:28 PM, Cong Wang wrote:
>>>> On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>>>>> Hmm, I don't think we want to have such an additional test in fast
>>>>>> path for each and every classifier. Can we think of ways to avoid that?
>>>>>>
>>>>>> My question is, since we unlink individual instances from such
>>>>>> tp-internal
>>>>>> lists through RCU and release the instance through call_rcu() as
>>>>>> well as
>>>>>> the head (tp->root) via kfree_rcu() eventually, against what are we
>>>>>> protecting
>>>>>> setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback?
>>>>>> Something
>>>>>> not respecting grace period?
>>>>>
>>>>> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
>>>>> to null.
>>>
>>> But that's not really an answer to my question. ;)
>>>
>>>> We do need to respect the grace period if we touch the globally visible
>>>> data structure tp in tcf_destroy(). Therefore Roi's patch is not
>>>> fixing the
>>>> right place.
>>>
>>> I think there may be multiple issues actually.
>>>
>>> At the time we go into tc_classify(), from ingress as well as egress side,
>>> we're under RCU, but BH variant. In cls delete()/destroy() callbacks, we
>>> everywhere use call_rcu() and kfree_rcu(), same as for tcf_destroy() where
>>> we use kfree_rcu() on tp, although we iterate tps (and implicitly inner
>>> filters)
>>> via rcu_dereference_bh() from reader side. Is there a reason why we don't
>>> use call_rcu_bh() variant on destruction for all this instead?
>>
>> I can't think of any if its all under _bh we can convert the call_rcu to
>> call_rcu_bh it just needs an audit.
>>
>>> Just looking at cls_bpf and others, what protects
>>> RCU_INIT_POINTER(tp->root,
>>> NULL) against? The tp is unlinked in tc_ctl_tfilter() from the tp chain in
>>> tcf_destroy() cases. Still active readers under RCU BH can race against
>>> this
>>> (tp->root being NULL), as the commit identified. Only the get() callback
>>> checks
>>> for head against NULL, but both are serialized under rtnl, and the only
>>> place
>>> we call this is tc_ctl_tfilter(). Even if we create a new tp, head
>>> should not
>>> be NULL there, if it was assigned during the init() cb, but contains an
>>> empty
>>> list. (It's different for things like cls_cgroup, though.) So, I'm
>>> wondering
>>> if the RCU_INIT_POINTER(tp->root, NULL) can just be removed instead
>>> (unless I'm
>>> missing something obvious)?
>>
>> Just took a look at this I think there are a couple possible solutions.
>> The easiest is likely to fix all the call sites so that 'tp' is unlinked
>> before calling the destroy() handlers AND not doing the NULL set. I only
>> see one such call site where destroy is called before unlinking at the
>> moment. This should enforce that after a grace period there is no path
>> to reach the classifiers because 'tp' is unlinked. Calling destroy
>> before unlinking 'tp' however could cause a small race between grace
>> period of 'tp' and grace period of the filter.
>>
>> Another would be to only call the destroy path from the call_rcu path
>> of the 'tp' object so that destroy is only ever called after the object
>> is guaranteed to be unlinked from the tc_filter path.
>>
>> I think both solutions would be fine.
>>
>> Cong were you working on one of these? Or do you have another idea?
>
> Yeah, this is basic what I think as well, however, both are hard.
> On one hand, we can't detach the tp from the global singly-linked list
> before tcf_destroy() since we rely on its return value to make this decision.
> On the other hand, it is a singly-linked list, we have to pass in the address
> of its previous pointer to rcu callback to remove it, it seems racy as well
> since we modify a previous pointer which is still visible globally...

Can't we drop the 'force' parameter from tcf_destroy() and related cls
destroy() callbacks, and change the logic roughly like this:

[...]
         case RTM_DELTFILTER:
                 err = tp->ops->delete(tp, fh, &drop_tp);
                 if (err == 0) {
                         struct tcf_proto *next = rtnl_dereference(tp->next);

                         tfilter_notify(net, skb, n, tp,
                                        t->tcm_handle,
                                        RTM_DELTFILTER, false);
                         if (drop_tp) {
                                 RCU_INIT_POINTER(*back, next);
                                 tcf_destroy(tp);
                         }
                 }
                 goto errout;
[...]

This one was the only tcf_destroy() instance with force=false. Why can't
the prior delete() callback make the decision whether the tp now has no
further internal filters and thus can be dropped. Afaik, delete() and
destroy() are protected by RTNL anyway. Thus, we could unlink the tp from
the list before tcf_destroy(), which should then work with grace period
as well. Given we remove the setting of tp->root to NULL, any outstanding
readers for that grace period should either still execute the 'scheduled
for removal' filter we just dropped, or find an empty list of filters.

> Hmm, perhaps we really have to switch to a doubly-linked list, that is
> list_head. I need to double check. And also the semantic of ->destroy()
> needs to revise too.

Can you elaborate why double-linked list? Isn't the tp list always protected
from modifications via RTNL in control path, and walked via rcu_dereference_bh()
in data path?

> So yeah, my commit should be blamed. :-/
