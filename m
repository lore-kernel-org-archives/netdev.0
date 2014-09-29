From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Sun, 28 Sep 2014 20:59:23 -0700
Message-ID: <CA+mtBx_QGSiY14dVVqp76sU5JNkLMayE-PX1e_dyN-mUWeeEug@mail.gmail.com>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
	<CAJ3xEMjVx6-XK9Eb2akLHei_43pw10rnHM-zXrOD7pzoXuXaRg@mail.gmail.com>
	<CA+mtBx-0ov5W_xVsgEJsw7o=A9CYSq6ZC_C34=MMsUxgzJWp_g@mail.gmail.com>
	<CAJ3xEMi5V0ijSVmga0chTFF1ghUaGs7h9PGfYGb10ZdyPcs5_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:45924 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaI2D7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 23:59:24 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so2623314igd.16
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 20:59:24 -0700 (PDT)
In-Reply-To: <CAJ3xEMi5V0ijSVmga0chTFF1ghUaGs7h9PGfYGb10ZdyPcs5_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 27, 2014 at 12:26 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Sat, Sep 27, 2014 at 2:04 AM, Tom Herbert <therbert@google.com> wrote:
>> On Fri, Sep 26, 2014 at 1:16 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Fri, Sep 26, 2014 at 7:22 PM, Tom Herbert <therbert@google.com> wrote:
>>> [...]
>>>> Notes:
>>>>   - GSO for GRE/UDP where GRE checksum is enabled does not work.
>>>>     Handling this will require some special case code.
>>>>   - Software GSO now supports many varieties of encapsulation with
>>>>     SKB_GSO_UDP_TUNNEL{_CSUM}. We still need a mechanism to query
>>>>     for device support of particular combinations (I intend to
>>>>     add ndo_gso_check for that).
>>>
>>> Tom,
>>>
>>> As I wrote you earlier on another thread/s, fact is that there are
>>> upstream drivers who advertize SKB_GSO_UDP_TUNNEL and aren't capable @
>>> this point to issue proper HW segmentation of something which isn't
>>> VXLAN.
>>>
>>> Just to make sure, this series isn't expected to introduce a
>>> regression, right? we don't expect the stack to attempt and xmit a
>>> large 64KB UDP packet which isn't vxlan through these devices.
>
>> I am planning to post ndo_gso_check shortly. These patches should not
>> cause a regression with currently deployed functionality (VXLAN).
>
> Can you sum up (please) in 1-2 liner what is the trick to avoid such
> regression? that is what/where is the knob that would prevent such
> giant chunk to be sent down to a NIC driver which does advertize
> SKB_GSO_UDP_TUNNEL?
>
I posted patch for ndo_gso_check. Please let me know if you'll be able
to work with this. I'll also post the iproute changes soon so that the
FOU results can be repro'd.

>
>>>>   - MPLS seems to be the only previous user of inner_protocol. I don't
>>>>     believe these patches can affect that. For supporting GSO with
>>>>     MPLS over UDP, the inner_protocol should be set using the
>>>>     helper functions in this patch.
>>>>   - GSO for L2TP/UDP should also be straightforward now.
>>>
>>>> Tested GRE, IPIP, and SIT over fou as well as VLXAN. This was
>>>> done using 200 TCP_STREAMs in netperf.
>>> [...]
>>>>    VXLAN
>>>>       TCP_STREAM TSO enabled on tun interface
>>>>         16.42% TX CPU utilization
>>>>         23.66% RX CPU utilization
>>>>         9081 Mbps
>>>>       TCP_STREAM TSO disabled on tun interface
>>>>         30.32% TX CPU utilization
>>>>         30.55% RX CPU utilization
>>>>         9185 Mbps
>>>
>>> so TSO disabled has better BW vs TSO enabled?
>>>
>> Yes, I've noticed that on occasion, it does seem like TSO disabled
>> tends to get a little more throughput. I see this with plain GRE, so I
>> don't think it's directly related to fou or these patches. I suppose
>> there may be some subtle interactions with BQL or something like that.
>> I'd probably want to repro this on some other devices at some point to
>> dig deeper.
>>
>>>>    Baseline (no encp, TSO and LRO enabled)
>>>>       TCP_STREAM
>>>>         11.85% TX CPU utilization
>>>>         15.13% RX CPU utilization
>>>>         9452 Mbps
>>>
>>> I would strongly recommend to have a far better baseline when
>>> developing and testing these changes in the stack in the form of 40Gbs
>>> NICs.
>>>
>> The only point of putting the baseline was to show that encapsulation
>> with GSO/GRO/checksum-unnec-conversion is in the ballpark of
>> performance with native traffic which was a goal.
>
> under (over...) 10Gbs, in the ballpark indeed.
>
> We know nothing what would happen with baseline of 38Gbs (SB 40Gbs
> NIC) 56Gbs (two bonded ports of 40Gbs NIC on PCIe gen3) or 100Gbs
> (tomorrow's NIC HW, probably coming up next year)
>
>> So I'm pretty happy
>> with this performance right now, although it probably does mean remote
>> checksum offload won't show so impressive results with this test (TX
>> csum with data in case isn't so expensive).
>> Out of curiosity, why do you think using 40Gbs is far better for a baseline?
>
> Oh, simply b/c with 40Gbs NICs, the baseline I expect for few sessions
> (1,2,4 or 200 as you did) of plain TCP is four times better vs. your
> current one (38Gbs vs 9.5Gbs) and this should pose a harder challenge
> for the GSO/encapsulating stack to catch up with, agree?
>
Sure, I agree that it would be nice to have this tested on different
devices (40G, 1G, wireless, etc.)-- but right now I don't see anything
particularly obvious why performance shouldn't scale linearly.

> Or.
