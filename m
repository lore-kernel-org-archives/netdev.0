From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Thu, 24 Nov 2016 15:25:46 -0500 (EST)
Message-ID: <20161124.152546.1174938340314080043.davem@davemloft.net>
References: <58346C7B.7090006@iogearbox.net>
        <20161122161159.GC1819@nanopsycho>
        <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, daniel@iogearbox.net, roid@mellanox.com,
        netdev@vger.kernel.org, jiri@mellanox.com, ogerlitz@mellanox.com,
        cwang@twopensource.com, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755453AbcKXUZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 15:25:53 -0500
In-Reply-To: <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 22 Nov 2016 11:28:37 -0800

> On Tue, Nov 22, 2016 at 8:11 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Nov 22, 2016 at 05:04:11PM CET, daniel@iogearbox.net wrote:
>>>Hmm, I don't think we want to have such an additional test in fast
>>>path for each and every classifier. Can we think of ways to avoid that?
>>>
>>>My question is, since we unlink individual instances from such tp-internal
>>>lists through RCU and release the instance through call_rcu() as well as
>>>the head (tp->root) via kfree_rcu() eventually, against what are we protecting
>>>setting RCU_INIT_POINTER(tp->root, NULL) in ->destroy() callback? Something
>>>not respecting grace period?
>>
>> If you call tp->ops->destroy in call_rcu, you don't have to set tp->root
>> to null.
> 
> We do need to respect the grace period if we touch the globally visible
> data structure tp in tcf_destroy(). Therefore Roi's patch is not fixing the
> right place.

Another idea is to assign tp->root to a dummy static cls_fl_head object,
instead of NULL, which we just make sure has an ht.elems value of zero.

This avoids having to touch the fast path and also avoids all of these
complicated changes being discussed wrt. doing things in call_rcu_bh()
or whatever.
