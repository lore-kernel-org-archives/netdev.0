From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Thu, 4 Feb 2016 08:12:21 -0500
Message-ID: <56B34E35.3020307@mojatatu.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203101109.GB20905@office.Home> <56B1D4A9.3050801@gmail.com>
 <56B1D713.3080803@mellanox.com> <56B1F0C9.3020802@mojatatu.com>
 <56B24B8B.1010205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jiri@resnulli.us, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: "Fastabend, John R" <john.fastabend@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33937 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964999AbcBDNMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 08:12:23 -0500
Received: by mail-ig0-f174.google.com with SMTP id ik10so14363626igb.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 05:12:23 -0800 (PST)
In-Reply-To: <56B24B8B.1010205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 16-02-03 01:48 PM, Fastabend, John R wrote:

BTW: For the record John, I empathize with you that we need to
move. Please have patience - we are close; lets just get this resolved
in Seville. I like your patches a lot and would love to just have
your patches pushed in, but the challenges with community is being able
to reach some middle ground. We are not as bad as some of the standards
organizations. I am sure we'll get this resolved by end of next week
if not, I am %100 in agreement some form of your patches (And Amir's
need to go in and then we can refactor as needed)

>> 1) "priorities" for filters and some form of "index" for actions is
>> is needed. I think index (which tends to be a 32 bit value is what
>> Amir's patches refered to as "cookie" - or at least some hardware
>> can be used to query the action with). Priorities maybe implicit in
>> the order in which they are added. And th idea of appending vs
>> exclusivity vs replace (which  netlink already supports)
>> is important to worry about (TCAMS tend to assume an append mode
>> for example).
>
> The code denotes add/del/replace already. I'm not sure why a TCAM
> would assume an append mode but OK maybe that is some API you have
> the APIs I use don't have these semantics.
>

Basically most hardware (or i should say driver implementations of
mostly TCAMS) allow you to add exactly the same filter as many times
as you want. They dont really look at what you want to filter on
and then scream "conflict". IOW, you (user) are responsible for
conflict resolution at the filter level. The driver sees this blob
and requests for some index/key from the hardware then just adds it.
You can then use this key/index to delete/replace etc.
This is what i meant by "append" mode.
However if a classifier implementation cares about filter ambiguity
resolution, then priorities are used. We need to worry about the
bigger picture.


> For this series using cls_u32 the handle gives you everything you need
> to put entries in the right table and row. Namely the ht # and order #
> from 'tc'.

True - but with a caveat. There are only 2^12 max tables you can
have for example and up to 2^12 filters per bucket etc.

>Take a look at u32_change and u32_classify its the handle
> that places the filter into the list and the handle that is matched in
> classify. We should place the filters in the hardware in the same order
> that is used by u32_change.
>

I can see some parallels, but:
The nodeid in itself is insufficent for two reasons:
You cant have more than 2^12 filters per bucket;
and the nodeid then takes two meanings: a) it is an id
b) it specifies the order in which things are looked up.

I think you need to take the u32 address and map it to something in your
hardware. But at the same time it is important to have the abstraction
closely emulate your hardware.

> Also ran a few tests and can't see how priority works in u32 maybe you
> can shed some light but as best I can tell it doesn't have any effect
> on rule execution.
>

True.
u32 doesnt care because it will give you a nodeid if you dont specify
one. i.e conflict resolution is mapped to you not specifying exactly
the same ht:bkt:nodeid more than once. And if you will let the
kernel do it for you (as i am assumming you are saying your hardware
will) then no need.

>>
>> 2) I like the u32 approach where it makes sense; but sometimes it
>> doesnt make sense from a usability pov. I work with some ASICs
>> that have 10 tuples that are  fixed. Yes, a user can describe a policy
>> with u32 but flower would be more  usable say with flower (both
>> programmatic and cli)
>
> Sure so create a set of offload hooks for flower we don't need only
> one hardware classifier any more than we would like a single software
> classifiers.


Glad to hear that.
I was a little concerned that despite my love for u32 it was
going to be _the_ classifier. It doesnt fit for all offload cases
and sometimes it is because of human operators (the 10 tuple
hardware classifier i mentioned earlier).
BTW: Classifier in this case is very wide ranging (a regex hardware
offload for example qualifies).

>
> Again I'm trying to faithfully implement what we have in software
> and load that into the hardware. The handle today gives ingress/egres
> hook. If you want an all ports hook we should add it to 'tc' software
> first and then push that to the hardware not create magic hardware
> bits. See I've drank the cool aid software first than hardware.
>

;-> No disagreement. It felt like a small sensible
change - thats why i suggested it.

>> 4) Why are we forsaking switchdev John?
>> This is certainly re-usable beyond NICs and SRIOV.
>>
>
> Sure and switchdev can use it just like they use fdb_add and friends.
> I just don't want to require switchdev infrastructure on things that
> really are not switches. I think Amir indicated he would take a try
> at the switchdev integration. If not I'm willing to do it but it
> doesn't block this series in any way imo.
>

Ok. Makes sense.

>> 5)What happened to being both able to hardware and/or software?
>
> Follow up patch once we get the basic infrastructure in place with
> the big feature flag bit. I have a patch I'm testing for this now
> but again I want to move in logical and somewhat minimal sets.
>

Sounds sensible.

>>
>> Anyways, I think Seville would be a blast! Come one, come all.
>>
>
> I'll be there but lets be sure to follow up with this online I
> know folks are following this who wont be at Seville and I don't
> see any reason to block these patches and stop the thread for a
> week or more.
>

I really dont see much of a blocker.

cheers,
jamal
