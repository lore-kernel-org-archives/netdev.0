From: Dan Streetman <dan.streetman@canonical.com>
Subject: Re: ip_rcv_finish() NULL pointer kernel panic
Date: Mon, 13 Mar 2017 13:30:02 -0400
Message-ID: <CAOZ2QJPUNm2ymTdcyW6HO9B2yhHv1MfeycywOajDSty0A6ZHFQ@mail.gmail.com>
References: <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org>
 <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170126162433.GB1778@breakpoint.cc> <20170126.130428.2050566986836855986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fw@strlen.de, eric.dumazet@gmail.com, lkml@rkeene.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170126.130428.2050566986836855986.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2017 at 1:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Thu, 26 Jan 2017 17:24:33 +0100
>
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> > Though possibly with different things not setting the "input" function
>>> > pointer in the "struct dst_entry".
>>> >
>>> > include/net/dst.h:
>>> >   496 static inline int dst_input(struct sk_buff *skb) {
>>> >   498         return skb_dst(skb)->input(skb);
>>> >   499 }
>>> >
>>> > Is there any reason not to check to see if this pointer is NULL before
>>> > blindly calling it ?
>>>
>>> Sure. It can not be NULL at this point.
>>>
>>> Just look at the code in ip_rcv_finish() :
>>>
>>> It first make sure to get a valid dst.
>>>
>>> Something is broken, probably in bridge netfilter code.
>>>
>>> I suspect the dst here points to &br->fake_rtable, and this is not
>>> expected.
>>>
>>> br_drop_fake_rtable() should have been called somewhere ...
>>
>> I think it makes sense to set dst->incoming
>> to a stub in br_netfilter_rtable_init() to just kfree_skb()+
>> WARN_ON_ONCE(), no need to add code to ip stack or crash kernel
>> due to brnf bug.
>
> That would certainly make recovery from such bugs must better.
>
> But I have to say that this netfilter bridging fake dst has caused
> several dozen bugs over the years, it is fundamentally a serious
> problem in and of itself.  It provides DST facilities by hand, in a
> static object, without using any of the usual methods for creating and
> facilitating dst objects.
>
> Therefore every time someone makes an adjustment to common dst code,
> this turd (and yes, it _is_ a turd) breaks.  Every single time.
>
> So in the long term, instead of polishing this turd, let's get rid of
> it.

I'm getting reports of this bug as well; is anyone working on removing
the bridge fake dst?
