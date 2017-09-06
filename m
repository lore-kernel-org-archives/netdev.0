From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Wed, 6 Sep 2017 16:37:59 -0700
Message-ID: <CAM_iQpX8q8A-J+7w0rzxuZBrTYLmmgLgU1K=cH9-9f0ikkSaPw@mail.gmail.com>
References: <20170906111419.5115-1-jiri@resnulli.us> <CAM_iQpWZJ9VVD66h6RMNofobKyoFyztx2jYqBEHuE6_iAu7PNQ@mail.gmail.com>
 <20170906203323.GA16570@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34331 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752525AbdIFXiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 19:38:20 -0400
Received: by mail-pf0-f194.google.com with SMTP id y68so3698293pfd.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 16:38:20 -0700 (PDT)
In-Reply-To: <20170906203323.GA16570@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 1:33 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Sep 06, 2017 at 07:40:02PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Wed, Sep 6, 2017 at 4:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> There's a memleak happening for chain 0. The thing is, chain 0 needs to
>>> be always present, not created on demand. Therefore tcf_block_get upon
>>> creation of block calls the tcf_chain_create function directly. The
>>> chain is created with refcnt == 1, which is not correct in this case and
>>> causes the memleak. So move the refcnt increment into tcf_chain_get
>>> function even for the case when chain needs to be created.
>>>
>>
>>Your approach could work but you just make the code even
>>uglier than it is now:
>>
>>1. The current code is already ugly for special-casing chain 0:
>>
>>        if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>>                tcf_chain_destroy(chain);
>>
>>2. With your patch, chain 0 has a different _initial_ refcnt with others.
>
> No. Initial refcnt is the same. ! for every action that holds the chain.
> So actually, it returns it back where it should be.

Not all all.

tcf_block_get() calls tcf_chain_create(, 0), after your patch
chain 0 has refcnt==0 initially.

Non-0 chain? They are created via tcf_chain_get(), aka,
refcnt==0 initially.


>
>
>>
>>3. Allowing an object (chain 0) exists with refcnt==0
>
> So? That is for every chain that does not have goto_chain action
> pointing at. Please read the code.

So you are pretending to be GC but you are apparently not.

You create all the troubles by setting yourself to believe chain 0
is special and refcnt==0 is okay. Both are wrong.

Actually the !list_empty() check is totally unnecessary too,
it is yet another place you get it wrong, you hide the race
condition in commit 744a4cf63e52 which makes it harder
to expose.

I understand you don't trust me. Look at DaveM's reaction
to your refcnt==0 madness.

Remember, refcnt can be very simple, you just want to
make it harder by abusing it or attempting to invent a GC.

I am going to update my patch (to remove all your madness)
since this is horribly wrong to me. Sorry.
