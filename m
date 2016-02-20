From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Fri, 19 Feb 2016 18:18:59 -0800
Message-ID: <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com> <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37001 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427411AbcBTCTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 21:19:18 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 854A42058A
	for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 02:19:17 +0000 (UTC)
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0E5A620573
	for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 02:19:15 +0000 (UTC)
Received: by mail-qg0-f51.google.com with SMTP id y9so76939797qgd.3
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 18:19:15 -0800 (PST)
In-Reply-To: <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 4:14 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Feb 19, 2016 at 4:08 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Fri, Feb 19, 2016 at 3:10 PM, Alex Duyck <aduyck@mirantis.com> wrote:
>>> On Fri, Feb 19, 2016 at 1:53 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>> On Fri, Feb 19, 2016 at 11:26 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>>> This patch series makes it so that we enable the outer Tx checksum for IPv4
>>>>> tunnels by default.  This makes the behavior consistent with how we were
>>>>> handling this for IPv6.  In addition I have updated the internal flags for
>>>>> these tunnels so that we use a ZERO_CSUM_TX flag for IPv4 which should
>>>>> match up will with the ZERO_CSUM6_TX flag which was already in use for
>>>>> IPv6.
>>>>>
>>>>> For most network devices this should be a net gain in terms of performance
>>>>> as having the outer header checksum present allows for devices to report
>>>>> CHECKSUM_UNNECESSARY which we can then convert to CHECKSUM_COMPLETE in order
>>>>> to determine if the inner header checksum is valid.
>>>>>
>>>>> Below is some data I collected with ixgbe with an X540 that demonstrates
>>>>> this.  I located two PFs connected back to back in two different name
>>>>> spaces and then setup a pair of tunnels on each, one with checksum enabled
>>>>> and one without.
>>>>>
>>>>> Recv   Send    Send                          Utilization
>>>>> Socket Socket  Message  Elapsed              Send
>>>>> Size   Size    Size     Time     Throughput  local
>>>>> bytes  bytes   bytes    secs.    10^6bits/s  % S
>>>>>
>>>>> noudpcsum:
>>>>>  87380  16384  16384    30.00      8898.67   12.80
>>>>> udpcsum:
>>>>>  87380  16384  16384    30.00      9088.47   5.69
>>>>>
>>>>> The one spot where this may cause a performance regression is if the
>>>>> environment contains devices that can parse the inner headers and a device
>>>>> supports NETIF_F_GSO_UDP_TUNNEL but not NETIF_F_GSO_UDP_TUNNEL_CSUM.  In
>>>>> the case of such a device we have to fall back to using GSO to segment the
>>>>> tunnel instead of TSO and as a result we may take a performance hit as seen
>>>>> below with i40e.
>>>>
>>>> Do you have any numbers from 40G links? Obviously, at 10G the links
>>>> are basically saturated and while I can see a difference in the
>>>> utilization rate, I suspect that the change will be much more apparent
>>>> at higher speeds.
>>>
>>> Unfortunately I don't have any true 40G links to test with.  The
>>> closest I can get is to run PF to VF on an i40e.  Running that I have
>>> seen the numbers go from about 20Gb/s to 15Gb/s with almost all the
>>> difference being related to the fact that we are having to
>>> allocate/free more skbs and make more trips through the
>>> i40e_lan_xmit_frame function resulting in more descriptors.
>>
>> OK, I guess that is more or less in line with what I would expect off
>> the top my head. There is a reasonably significant drop in the worst
>> case.
>>
>>>> I'm concerned about the drop in performance for devices that currently
>>>> support offloads (almost none of which expose
>>>> NETIF_F_GSO_UDP_TUNNEL_CSUM as a feature). Presumably the people that
>>>> care most about tunnel performance are the ones that already have
>>>> these NICs and will be the most impacted by the drop.
>>>
>>> The problem is being able to transmit fast is kind of pointless if the
>>> receiving end cannot handle it.  We hadn't gotten around to really
>>> getting the Rx checksum bits working until the 3.18 kernel which I
>>> don't suspect many people are running so at this point messing with
>>> the TSO bits isn't really making much of a difference.  Then on top of
>>> that most devices have certain limitations on how many ports they can
>>> handle and such.  I know the i40e is supposed to support something
>>> like 10 port numbers, but the fm10k and ixgbe are limited to one port
>>> as I recall.  So this whole thing is already really brittle as it is.
>>> My goal with this change is to make the behavior more consistent
>>> across the board.
>>
>> That's true to some degree but there are certainly plenty of cases
>> where TSO makes a difference - lower CPU usage, transmitting to
>> multiple receivers, people will upgrade their kernels, etc. It's
>> clearly good to make things more consistent but hopefully not by
>> reducing existing performance. :)
>>
>>>> My hope is that we can continue to use TSO on devices that only
>>>> support NETIF_F_GSO_UDP_TUNNEL. The main problem is that the UDP
>>>> length field may vary across segments. However, in practice this is
>>>> the only on the final segment and only in cases where the total length
>>>> is not a multiple of the MSS. If we could detect cases where those
>>>> conditions are met, we could continue to use TSO with the UDP checksum
>>>> field pre-populated. A possible step even further would be to break
>>>> off the final segment into a separate packet to make things conform if
>>>> necessary. This would avoid a performance regression and I think make
>>>> this more palatable to a lot of people.
>>>
>>> I think Tom and I had discussed this possibility a bit at netconf.
>>> The GSO logic is something I planned on looking at over the next
>>> several weeks as I suspect there is probably room for improvement
>>> there.
>>
>> That sounds great.
>>
>>>>> I also haven't investigated the effect this will have on OVS.  However I
>>>>> suspect the impact should be minimal as the worst case scenario should be
>>>>> that Tx checksumming will become enabled by default which should be
>>>>> consistent with the existing behavior for IPv6.
>>>>
>>>> I don't think that it should cause any problems.
>>>
>>> Good to hear.
>>>
>>> Do you know if OVS has some way to control the VXLAN configuration so
>>> that it could disable Tx checksums?  If so that would probably be a
>>> good way to address the 40G issues assuming someone is running an
>>> environment hat had nothing but NICs that can support the TSO and Rx
>>> checksum on inner headers.
>>
>> Yes - OVS can control tx checksums on a per-endpoint basis (actually,
>> rx checksum present requirements as well though it's not exposed to
>> the user at the moment). If you had the information then you could
>> optimize what to use in an environment of, say, hypervisors and
>> hardware switches.
>>
>> However, it's certainly possible that you have a mixed set of NICs
>> such as an encap aware NIC on the transmit side and non-aware on the
>> receive side. In that case, both possible checksum settings penalize
>> somebody: off (lose GRO on receiver), on (lose TSO on sender assuming
>> no support for NETIF_F_GSO_UDP_TUNNEL_CSUM). That's why I think it's
>> important to be able to use encap TSO with local checksum to avoid
>> these bad tradeoffs, not to mention being cleaner.
>
> By "local checksum" do you mean LCO?

Yes, that's what I meant.

> Seems like we should be able to
> get that to work with NETIF_F_GSO_TUNNEL_CSUM.

I assume you mean NETIF_F_GSO_TUNNEL (no _CSUM)?
