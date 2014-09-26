From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Fri, 26 Sep 2014 16:04:19 -0700
Message-ID: <CA+mtBx-0ov5W_xVsgEJsw7o=A9CYSq6ZC_C34=MMsUxgzJWp_g@mail.gmail.com>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
	<CAJ3xEMjVx6-XK9Eb2akLHei_43pw10rnHM-zXrOD7pzoXuXaRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:55561 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819AbaIZXEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 19:04:20 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so338921igb.9
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 16:04:20 -0700 (PDT)
In-Reply-To: <CAJ3xEMjVx6-XK9Eb2akLHei_43pw10rnHM-zXrOD7pzoXuXaRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 1:16 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Fri, Sep 26, 2014 at 7:22 PM, Tom Herbert <therbert@google.com> wrote:
> [...]
>> Notes:
>>   - GSO for GRE/UDP where GRE checksum is enabled does not work.
>>     Handling this will require some special case code.
>>   - Software GSO now supports many varieties of encapsulation with
>>     SKB_GSO_UDP_TUNNEL{_CSUM}. We still need a mechanism to query
>>     for device support of particular combinations (I intend to
>>     add ndo_gso_check for that).
>
> Tom,
>
> As I wrote you earlier on another thread/s, fact is that there are
> upstream drivers who advertize SKB_GSO_UDP_TUNNEL and aren't capable @
> this point to issue proper HW segmentation of something which isn't
> VXLAN.
>
> Just to make sure, this series isn't expected to introduce a
> regression, right? we don't expect the stack to attempt and xmit a
> large 64KB UDP packet which isn't vxlan through these devices.
>
I am planning to post ndo_gso_check shortly. These patches should not
cause a regression with currently deployed functionality (VXLAN).

>
>
>>   - MPLS seems to be the only previous user of inner_protocol. I don't
>>     believe these patches can affect that. For supporting GSO with
>>     MPLS over UDP, the inner_protocol should be set using the
>>     helper functions in this patch.
>>   - GSO for L2TP/UDP should also be straightforward now.
>
>> Tested GRE, IPIP, and SIT over fou as well as VLXAN. This was
>> done using 200 TCP_STREAMs in netperf.
> [...]
>>    VXLAN
>>       TCP_STREAM TSO enabled on tun interface
>>         16.42% TX CPU utilization
>>         23.66% RX CPU utilization
>>         9081 Mbps
>>       TCP_STREAM TSO disabled on tun interface
>>         30.32% TX CPU utilization
>>         30.55% RX CPU utilization
>>         9185 Mbps
>
> so TSO disabled has better BW vs TSO enabled?
>
Yes, I've noticed that on occasion, it does seem like TSO disabled
tends to get a little more throughput. I see this with plain GRE, so I
don't think it's directly related to fou or these patches. I suppose
there may be some subtle interactions with BQL or something like that.
I'd probably want to repro this on some other devices at some point to
dig deeper.

>>    Baseline (no encp, TSO and LRO enabled)
>>       TCP_STREAM
>>         11.85% TX CPU utilization
>>         15.13% RX CPU utilization
>>         9452 Mbps
>
> I would strongly recommend to have a far better baseline when
> developing and testing these changes in the stack in the form of 40Gbs
> NICs.
>
The only point of putting the baseline was to show that encapsulation
with GSO/GRO/checksum-unnec-conversion is in the ballpark of
performance with native traffic which was a goal. So I'm pretty happy
with this performance right now, although it probably does mean remote
checksum offload won't show so impressive results with this test (TX
csum with data in case isn't so expensive).

Out of curiosity, why do you think using 40Gbs is far better for a baseline?

> Or.
>
>
>>
>> Tom Herbert (5):
>>   udp: Generalize skb_udp_segment
>>   sit: Set inner IP protocol in sit
>>   ipip: Set inner IP protocol in ipip
>>   gre: Set inner protocol in v4 and v6 GRE transmit
>>   vxlan: Set inner protocol before transmit
>>
>>  drivers/net/vxlan.c    |  4 ++++
>>  include/linux/skbuff.h | 26 +++++++++++++++++++++++--
>>  include/net/udp.h      |  3 ++-
>>  net/core/skbuff.c      |  1 +
>>  net/ipv4/ip_gre.c      |  2 ++
>>  net/ipv4/ipip.c        |  2 ++
>>  net/ipv4/udp_offload.c | 51 +++++++++++++++++++++++++++++++++++++++++++++-----
>>  net/ipv6/ip6_gre.c     |  8 ++++++--
>>  net/ipv6/sit.c         |  4 ++++
>>  net/ipv6/udp_offload.c |  2 +-
>>  10 files changed, 92 insertions(+), 11 deletions(-)
>>
>> --
>> 2.1.0.rc2.206.gedb03e5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
