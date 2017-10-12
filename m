From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters
 in i40e
Date: Thu, 12 Oct 2017 00:05:10 -0700
Message-ID: <CAKgT0UcAKvhRKJPKf3DR3yGoLU_mM3UWV-vksd_KY+-yveWaxQ@mail.gmail.com>
References: <20171011125635.GD2039@nanopsycho> <CAKgT0UcP8refj2KLMT258xPNS2h3KhLqKD5sJkNLXRdNJrRCVg@mail.gmail.com>
 <20171011203832.GA9297@nanopsycho> <20171011.134652.1653141099248918341.davem@davemloft.net>
 <20171011205830.GD9297@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:45488 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdJLHFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 03:05:12 -0400
Received: by mail-qk0-f176.google.com with SMTP id f199so324512qke.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 00:05:11 -0700 (PDT)
In-Reply-To: <20171011205830.GD9297@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 1:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Oct 11, 2017 at 10:46:52PM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Wed, 11 Oct 2017 22:38:32 +0200
>>
>>> Wed, Oct 11, 2017 at 07:46:27PM CEST, alexander.duyck@gmail.com wrote:
>>>>On Wed, Oct 11, 2017 at 5:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> Wed, Oct 11, 2017 at 02:24:12AM CEST, amritha.nambiar@intel.com wrote:
>>>>>>This patch series enables configuring cloud filters in i40e
>>>>>>using the tc-flower classifier. The classification function
>>>>>>of the filter is to match a packet to a class. cls_flower is
>>>>>>extended to offload classid to hardware. The offloaded classid
>>>>>>is used direct matched packets to a traffic class on the device.
>>>>>>The approach here is similar to the tc 'prio' qdisc which uses
>>>>>>the classid for band selection. The ingress qdisc is called ffff:0,
>>>>>>so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).
>>>>>
>>>>>
>>>>> NACK. This clearly looks like abuse of classid to something
>>>>> else. Classid is here to identify qdisc instance. However, you use it
>>>>> for hw tclass identification. This is mixing of apples and oranges.
>>>>>
>>>>> Why?
>>>>>
>>>>> Please don't try to abuse things! This is not nice.
>>>>
>>>>This isn't an abuse. This is reproducing in hardware what is already
>>>>the behavior for software. Isn't that how offloads are supposed to
>>>>work?
>>>
>>> What is meaning of classid in HW? Classid is SW only identification of
>>> qdisc instances. No relation to HW instances = abuse.
>>
>>Jiri I really don't see what the problem is.
>>
>>As long as the driver does the right thing when changes are made to the
>>qdisc, it doesn't really matter what "key" they use to refer to it.
>>
>>It could have just as easily used the qdisc pointer and then internally
>>use some IDR allocated ID to refer to it in the driver and hardware.
>>
>>But that's such a waste, we have a unique handle already so why can't
>>the driver just use that?
>
> Well if I see classid, I expect it should refer to qdisc instance. So
> far, this has been always a case. But for some drivers, this would mean
> something totally different and unrelated. So what should I think?
> What's next? Classid could be abused to identify something else. I don't
> understand why.

The general idea is we are trying to offload some of the qdisc work
down into the hardware. It is kind of hard to do that without
providing this sort of abstraction.

> classid in kernel and tclass in hw are 2 completely unrelated things.
> Why they should share the same userspace api? What am I missing that
> indicates this is not an abuse?

This is both true and not quite true. In the case of mqprio it is
already creating virtual qdiscs for each traffic class. That is
essentially what we are trying to emulate on the receive side. That
was why we thought we might use this abstraction.

> There should be clean and well-defined userspace api:
> 1) classid to identify qdisc instances
> 2) something else to identify HW tclasses

I agree with the well defined userspace api portion of this. However I
somewhat disagree on the HW tclasses argument as we have virtual
qdiscs floating around inside of mqprio for instance that represent
the same type of thing. You will find that the classid values with a
minor value less than or equal to the number of TCs don't actually
exist other than for collecting statistics. If that is all you are
looking for we could probably update ingress and clsact to at a
minimum display the class IDs and treat them as full virtual classids
within the qdisc. I figure it wouldn't make sense to add statistics
since they don't actually enqueue any packets.

One thought I am considering, is what if we change the class ID of the
virtual qdiscs for mqprio that represent priority based traffic
classes so that we reserved TC_H_MIN values 0xFFE0 - 0xFFEF to
represent traffic classes 0 through 15? The advantage would be that it
would make the classid layout for mqprio closer to what is already
there for mq, and then in addition we would have a block of values we
could use as reserved for mq, mqprio, ingress, and clsact to represent
what you refer to as the HW tclasses since mqprio is already doing
something like this.

- Alex
