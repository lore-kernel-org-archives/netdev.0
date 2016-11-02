From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Wed, 2 Nov 2016 08:35:02 +0100
Message-ID: <20161102073502.GB1713@nanopsycho.orion>
References: <20161031225737.7nfoy4ka3ydzhptq@splinter>
 <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
 <5818B146.20209@cumulusnetworks.com>
 <20161101.113650.140429913221385583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
        idosch@idosch.org, netdev@vger.kernel.org, jiri@mellanox.com,
        mlxsw@mellanox.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, idosch@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36037 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbcKBHfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 03:35:05 -0400
Received: by mail-wm0-f66.google.com with SMTP id c17so1519428wmc.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 00:35:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161101.113650.140429913221385583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 01, 2016 at 04:36:50PM CET, davem@davemloft.net wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>Date: Tue, 01 Nov 2016 08:14:14 -0700
>
>> On 11/1/16, 7:19 AM, Eric Dumazet wrote:
>>> On Tue, 2016-11-01 at 00:57 +0200, Ido Schimmel wrote:
>>>> On Mon, Oct 31, 2016 at 02:24:06PM -0700, Eric Dumazet wrote:
>>>>> How well will this work for large FIB tables ?
>>>>>
>>>>> Holding rtnl while sending thousands of skb will prevent consumers to
>>>>> make progress ?
>>>> Can you please clarify what do you mean by "while sending thousands of
>>>> skb"? This patch doesn't generate notifications to user space, but
>>>> instead invokes notification routines inside the kernel. I probably
>>>> misunderstood you.
>>>>
>>>> Are you suggesting this be done using RCU instead? Well, there are a
>>>> couple of reasons why I took RTNL here:
>>>>
>>> No, I do not believe RCU is wanted here, in control path where we might
>>> sleep anyway.
>>>
>>>> 1) The FIB notification chain is blocking, so listeners are expected to
>>>> be able to sleep. This isn't possible if we use RCU. Note that this
>>>> chain is mainly useful for drivers that reflect the FIB table into a
>>>> capable device and hardware operations usually involve sleeping.
>>>>
>>>> 2) The insertion of a single route is done with RTNL held. I didn't want
>>>> to differentiate between both cases. This property is really useful for
>>>> listeners, as they don't need to worry about locking in writer-side.
>>>> Access to data structs is serialized by RTNL.
>>> My concern was that for large iterations, you might hold RTNL and/or
>>> current cpu for hundred of ms or even seconds...
>>>
>> I have the same concern as Eric here.
>> 
>> I understand why you need it, but can the driver request for an initial dump and that
>> dump be made more efficient somehow ie not hold rtnl for the whole dump ?.
>> instead of making the fib notifier registration code doing it.
>> 
>> these routing table sizes can be huge and an analogy for this in user-space:
>> We do request a netlink dump of  routing tables at initialization (on driver starts or resets)...
>> but, existing netlink routing table dumps for that scale don't hold rtnl for the whole dump.
>> The dump is split into multiple responses to the user and hence it does not starve other rtnl users.
>> 
>> In-fact I don't think netlink routing table dumps from user-space hold rtnl_lock for the whole dump.
>> IIRC this was done to allow route add/dels to be allowed in parallel for performance reasons.
>> (I will need to double check to confirm this).
>
>I've always had some reservations about using notifiers for getting
>the FIB entries down to the offloaded device.

Yeah, me too. But there is no really other way to do it. I thought about
it quite long. But maybe I missed something.


>
>And this problem is just another symptom that it is the wrong
>mechanism for propagating this information.
>
>As suggested by Roopa here, perhaps we're looking at the problem from
>the wrong direction.  We tend to design NDO ops and notifiers, to
>"push" things to the driver, but maybe something more like a push+pull
>model is better.

How do you imagine this mode should looks like? Could you draw me some
example?

Thanks!
