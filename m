From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer before
 dereferncing it
Date: Tue, 22 Nov 2016 21:41:59 +0100
Message-ID: <5834AD97.1020600@iogearbox.net>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com> <20161122144844.GB1819@nanopsycho> <58346C7B.7090006@iogearbox.net> <20161122161159.GC1819@nanopsycho> <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>,
        John Fastabend <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37483 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756691AbcKVUmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 15:42:06 -0500
In-Reply-To: <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 08:28 PM, Cong Wang wrote:
> On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>> Hmm, I don't think we want to have such an additional test in fast
>>> path for each and every classifier. Can we think of ways to avoid that?
>>>
>>> My question is, since we unlink individual instances from such tp-internal
>>> lists through RCU and release the instance through call_rcu() as well as
>>> the head (tp->root) via kfree_rcu() eventually, against what are we protecting
>>> setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback? Something
>>> not respecting grace period?
>>
>> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
>> to null.

But that's not really an answer to my question. ;)

> We do need to respect the grace period if we touch the globally visible
> data structure tp in tcf_destroy(). Therefore Roi's patch is not fixing the
> right place.

I think there may be multiple issues actually.

At the time we go into tc_classify(), from ingress as well as egress side,
we're under RCU, but BH variant. In cls delete()/destroy() callbacks, we
everywhere use call_rcu() and kfree_rcu(), same as for tcf_destroy() where
we use kfree_rcu() on tp, although we iterate tps (and implicitly inner filters)
via rcu_dereference_bh() from reader side. Is there a reason why we don't
use call_rcu_bh() variant on destruction for all this instead?

Just looking at cls_bpf and others, what protects RCU_INIT_POINTER(tp->root,
NULL) against? The tp is unlinked in tc_ctl_tfilter() from the tp chain in
tcf_destroy() cases. Still active readers under RCU BH can race against this
(tp->root being NULL), as the commit identified. Only the get() callback checks
for head against NULL, but both are serialized under rtnl, and the only place
we call this is tc_ctl_tfilter(). Even if we create a new tp, head should not
be NULL there, if it was assigned during the init() cb, but contains an empty
list. (It's different for things like cls_cgroup, though.) So, I'm wondering
if the RCU_INIT_POINTER(tp->root, NULL) can just be removed instead (unless I'm
missing something obvious)?

> Also I don't know why you blame my commit, this problem should already
> exist prior to my commit, probably date back to John's RCU patches.

It seems so.
