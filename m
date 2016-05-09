From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 00/11] ipv6: Enable GUEoIPv6 and more fixes
 for v6 tunneling
Date: Mon, 9 May 2016 09:56:35 -0700
Message-ID: <CALx6S34QeJpb4MocpDN_0XuvV4fxN25yO7-SjYBNta5ALzoDSw@mail.gmail.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
	<CAKgT0UdvZbDsDewsGRvMO93OZNSSXKfWaT7RvWkb6DQaG9jvyA@mail.gmail.com>
	<CALx6S36uA83qEoYw2daxHrpege0zyNO=5u0iJ9tZu=RaBAK8cA@mail.gmail.com>
	<CAKgT0UdM1aQF8cLWVLXMmXyJnMHkZUum8YyKsyCSVFvBALmyCA@mail.gmail.com>
	<CALx6S37MF5Q7mVurAZR0KPpu2Y-rSQrRPGY3TkSZOpZgkaCHmw@mail.gmail.com>
	<CAKgT0Ucs4oJ6yCb3AKR8jVvdF7WBojBX6hbqrS5e--deP7KZvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38717 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcEIQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:56:37 -0400
Received: by mail-ig0-f171.google.com with SMTP id m9so96909737ige.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 09:56:36 -0700 (PDT)
In-Reply-To: <CAKgT0Ucs4oJ6yCb3AKR8jVvdF7WBojBX6hbqrS5e--deP7KZvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 8:03 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Fri, May 6, 2016 at 7:11 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Fri, May 6, 2016 at 7:03 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Fri, May 6, 2016 at 6:57 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> On Fri, May 6, 2016 at 6:09 PM, Alexander Duyck
>>>> <alexander.duyck@gmail.com> wrote:
>>>>> On Fri, May 6, 2016 at 3:11 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>>>> This patch set:
>>>>>>   - Fixes GRE6 to process translate flags correctly from configuration
>>>>>>   - Adds support for GSO and GRO for ip6ip6 and ip4ip6
>>>>>>   - Add support for FOU and GUE in IPv6
>>>>>>   - Support GRE, ip6ip6 and ip4ip6 over FOU/GUE
>>>>>>   - Fixes ip6_input to deal with UDP encapsulations
>>>>>>   - Some other minor fixes
>>>>>>
>>>>>> v2:
>>>>>>   - Removed a check of GSO types in MPLS
>>>>>>   - Define GSO type SKB_GSO_IPXIP6 and SKB_GSO_IPXIP4 (based on input
>>>>>>     from Alexander)
>>>>>>   - Don't define GSO types specifally for IP6IP6 and IP4IP6, above
>>>>>>     fix makes that uncessary
>>>>>>   - Don't bother clearing encapsulation flag in UDP tunnel segment
>>>>>>     (another item suggested by Alexander).
>>>>>>
>>>>>> v3:
>>>>>>   - Address some minor comments from Alexander
>>>>>>
>>>>>> Tested:
>>>>>>    Tested a variety of case, but not the full matrix (which is quite
>>>>>>    large now). Most of the obivous cases (e.g. GRE) work fine. Still
>>>>>>    some issues probably with GSO/GRO being effective in all cases.
>>>>>>
>>>>>>     - IPv4/GRE/GUE/IPv6 with RCO
>>>>>>       1 TCP_STREAM
>>>>>>         6616 Mbps
>>>>>>       200 TCP_RR
>>>>>>         1244043 tps
>>>>>>         141/243/446 90/95/99% latencies
>>>>>>         86.61% CPU utilization
>>>>>>     - IPv6/GRE/GUE/IPv6 with RCO
>>>>>>       1 TCP_STREAM
>>>>>>         6940 Mbps
>>>>>>       200 TCP_RR
>>>>>>         1270903 tps
>>>>>>         138/236/440 90/95/99% latencies
>>>>>>         87.51% CPU utilization
>>>>>>
>>>>>>      - IP6IP6
>>>>>>       1 TCP_STREAM
>>>>>>         2576 Mbps
>>>>>>       200 TCP_RR
>>>>>>         498981 tps
>>>>>>         388/498/631 90/95/99% latencies
>>>>>>         19.75% CPU utilization (1 CPU saturated)
>>>>>>
>>>>>>      - IP6IP6/GUE/IPv6 with RCO
>>>>>>       1 TCP_STREAM
>>>>>>         1854 Mbps
>>>>>>       200 TCP_RR
>>>>>>         1233818 tps
>>>>>>         143/244/451 90/95/99% latencies
>>>>>>         87.57 CPU utilization
>>>>>>
>>>>>>      - IP4IP6
>>>>>>       1 TCP_STREAM
>>>>>>       200 TCP_RR
>>>>>>         763774 tps
>>>>>>         250/318/466 90/95/99% latencies
>>>>>>         35.25% CPU utilization (1 CPU saturated)
>>>>>>
>>>>>>      - GRE with keyid
>>>>>>       200 TCP_RR
>>>>>>         744173 tps
>>>>>>         258/332/461 90/95/99% latencies
>>>>>>         34.59% CPU utilization (1 CPU saturated)
>>>>>
>>>>> So I tried testing your patch set and it looks like I cannot get GRE
>>>>> working for any netperf test.  If I pop the patches off it is even
>>>>> worse since it looks like patch 3 fixes some tunnel flags issues, but
>>>>> still doesn't resolve all the issues introduced with b05229f44228
>>>>> ("gre6: Cleanup GREv6 transmit path, call common GRE functions").
>>>>> Reverting the entire patch seems to resolve the issues, but I will try
>>>>> to pick it apart tonight to see if I can find the other issues that
>>>>> weren't addressed in this patch series.
>>>>>
>>>>
>>>> Can you give details about configuration, test you're running, and HW?
>>>
>>> The issue looks like it may be specific to ip6gretap.  I'm running the
>>> test over an i40e adapter, but it shouldn't make much difference.  I'm
>>> thinking it may have something to do with the MTU configuration as
>>> that is one of the things I am noticing has changed between the
>>> working and the broken version of the code.
>>>
>> I'm not seeing any issue with configuring:
>>
>> ip link add name tun8 type ip6gretap remote
>> 2401:db00:20:911a:face:0:27:0 local 2401:db00:20:911a:face:0:25:0 ttl
>> 225
>>
>> MTU issues would not surprise me with IPv6 though. This is part of the
>> area of code that seems drastically different than what IPv4 is doing.
>
> I am also using a key.
>
>         ip link add $name type ip6gretap key $net \
>                 local fec0::1 remote $addr6 ttl 225 dev $PF0
>
I don't see any issue with key enabled.

> Does the device you are using support any kind of checksum offload for
> inner headers on GRE tunnels?  It looks like if I turn off checksums

I don't believe so.

> and correct the MTU I can then send traffic without issues.  I'd say
> that the Tx cleanup probably introduced 3 regressions.  The first one
> you addressed in patch 3 which fixes the flags.  The second being the
> fact that the MTU is wrong, and the third being something that
> apparently broke checksum and maybe segmentation offload for
> ip6gretap.
>
The MTU can be set in place in IPv6 code that doesn't exist in Ipv4. I
am especially wondering about the "if (p->flags & IP6_TNL_F_CAP_XMIT)"
block.

> Really I think the transmit path cleanup should have probably been
> broken down into a set of patches rather than slamming it in all in
> one block.  I can spend some time next week trying to sort it out if
> you don't have any hardware that supports GRE segmentation or checksum
> offload.  If worse comes to worse I will just try breaking the revert
> down into a set of smaller patches so I can figure out exactly which
> change broke things.
>
I am still trying to reproduce.

Tom

> - Alex
