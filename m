From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Thu, 7 Sep 2017 08:07:10 +0200
Message-ID: <20170907060710.GA1967@nanopsycho>
References: <20170906111419.5115-1-jiri@resnulli.us>
 <CAM_iQpWZJ9VVD66h6RMNofobKyoFyztx2jYqBEHuE6_iAu7PNQ@mail.gmail.com>
 <20170906203323.GA16570@nanopsycho>
 <CAM_iQpX8q8A-J+7w0rzxuZBrTYLmmgLgU1K=cH9-9f0ikkSaPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jakub Kicinski <kubakici@wp.pl>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35344 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753942AbdIGGHN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 02:07:13 -0400
Received: by mail-wr0-f194.google.com with SMTP id n64so522185wrb.2
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 23:07:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpX8q8A-J+7w0rzxuZBrTYLmmgLgU1K=cH9-9f0ikkSaPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 07, 2017 at 01:37:59AM CEST, xiyou.wangcong@gmail.com wrote:
>On Wed, Sep 6, 2017 at 1:33 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Sep 06, 2017 at 07:40:02PM CEST, xiyou.wangcong@gmail.com wrote:
>>>On Wed, Sep 6, 2017 at 4:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> There's a memleak happening for chain 0. The thing is, chain 0 needs to
>>>> be always present, not created on demand. Therefore tcf_block_get upon
>>>> creation of block calls the tcf_chain_create function directly. The
>>>> chain is created with refcnt == 1, which is not correct in this case and
>>>> causes the memleak. So move the refcnt increment into tcf_chain_get
>>>> function even for the case when chain needs to be created.
>>>>
>>>
>>>Your approach could work but you just make the code even
>>>uglier than it is now:
>>>
>>>1. The current code is already ugly for special-casing chain 0:
>>>
>>>        if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
>>>                tcf_chain_destroy(chain);
>>>
>>>2. With your patch, chain 0 has a different _initial_ refcnt with others.
>>
>> No. Initial refcnt is the same. ! for every action that holds the chain.
>> So actually, it returns it back where it should be.
>
>Not all all.
>
>tcf_block_get() calls tcf_chain_create(, 0), after your patch
>chain 0 has refcnt==0 initially.
>
>Non-0 chain? They are created via tcf_chain_get(), aka,
>refcnt==0 initially.

And if they are created on insertion of the filter, put is caller right
away which returns the ref back to 0. As I said, Non-0 refcnt means
either rule is being inserted/removed of there is an action that holds
reference to this chain. So my patch actually fixes the behaviour making
chain 0 and other chains to behave the same.


>
>
>>
>>
>>>
>>>3. Allowing an object (chain 0) exists with refcnt==0
>>
>> So? That is for every chain that does not have goto_chain action
>> pointing at. Please read the code.
>
>So you are pretending to be GC but you are apparently not.
>
>You create all the troubles by setting yourself to believe chain 0
>is special and refcnt==0 is okay. Both are wrong.
>
>Actually the !list_empty() check is totally unnecessary too,
>it is yet another place you get it wrong, you hide the race
>condition in commit 744a4cf63e52 which makes it harder
>to expose.
>
>I understand you don't trust me. Look at DaveM's reaction
>to your refcnt==0 madness.
>
>Remember, refcnt can be very simple, you just want to
>make it harder by abusing it or attempting to invent a GC.
>
>I am going to update my patch (to remove all your madness)
>since this is horribly wrong to me. Sorry.

It is not so easy to use the refcnt also for filters, I had good reason
to relend on filter_chain list to find out if there is a rule. If you
figure out how to do it better, be my guest. I suggest you do that for
net-next and let's fix the net in the easiest way possible.
