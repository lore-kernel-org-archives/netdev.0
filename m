From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Mon, 22 Feb 2016 19:31:10 -0800
Message-ID: <CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com> <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57706 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756699AbcBWDb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 22:31:29 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D03AD20686
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 03:31:26 +0000 (UTC)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5966720678
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 03:31:25 +0000 (UTC)
Received: by mail-qk0-f174.google.com with SMTP id x1so63807257qkc.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 19:31:25 -0800 (PST)
In-Reply-To: <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 20, 2016 at 11:51 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Feb 19, 2016 at 6:18 PM, Jesse Gross <jesse@kernel.org> wrote:
>> On Fri, Feb 19, 2016 at 4:14 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Fri, Feb 19, 2016 at 4:08 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>> On Fri, Feb 19, 2016 at 3:10 PM, Alex Duyck <aduyck@mirantis.com> wrote:
>>>>> On Fri, Feb 19, 2016 at 1:53 PM, Jesse Gross <jesse@kernel.org> wrote:
>>>>>> On Fri, Feb 19, 2016 at 11:26 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>>>>> This patch series makes it so that we enable the outer Tx checksum for IPv4
>>>>>>> tunnels by default.  This makes the behavior consistent with how we were
>>>>>>> handling this for IPv6.  In addition I have updated the internal flags for
>>>>>>> these tunnels so that we use a ZERO_CSUM_TX flag for IPv4 which should
>>>>>>> match up will with the ZERO_CSUM6_TX flag which was already in use for
>>>>>>> IPv6.
>>>>>>>
>>>>>>> For most network devices this should be a net gain in terms of performance
>>>>>>> as having the outer header checksum present allows for devices to report
>>>>>>> CHECKSUM_UNNECESSARY which we can then convert to CHECKSUM_COMPLETE in order
>>>>>>> to determine if the inner header checksum is valid.
>>>>>>>
>>>>>>> Below is some data I collected with ixgbe with an X540 that demonstrates
>>>>>>> this.  I located two PFs connected back to back in two different name
>>>>>>> spaces and then setup a pair of tunnels on each, one with checksum enabled
>>>>>>> and one without.
>>>>>>>
>>>>>>> Recv   Send    Send                          Utilization
>>>>>>> Socket Socket  Message  Elapsed              Send
>>>>>>> Size   Size    Size     Time     Throughput  local
>>>>>>> bytes  bytes   bytes    secs.    10^6bits/s  % S
>>>>>>>
>>>>>>> noudpcsum:
>>>>>>>  87380  16384  16384    30.00      8898.67   12.80
>>>>>>> udpcsum:
>>>>>>>  87380  16384  16384    30.00      9088.47   5.69
>>>>>>>
>>>>>>> The one spot where this may cause a performance regression is if the
>>>>>>> environment contains devices that can parse the inner headers and a device
>>>>>>> supports NETIF_F_GSO_UDP_TUNNEL but not NETIF_F_GSO_UDP_TUNNEL_CSUM.  In
>>>>>>> the case of such a device we have to fall back to using GSO to segment the
>>>>>>> tunnel instead of TSO and as a result we may take a performance hit as seen
>>>>>>> below with i40e.
>>>>>>
>>>>>> Do you have any numbers from 40G links? Obviously, at 10G the links
>>>>>> are basically saturated and while I can see a difference in the
>>>>>> utilization rate, I suspect that the change will be much more apparent
>>>>>> at higher speeds.
>>>>>
>>>>> Unfortunately I don't have any true 40G links to test with.  The
>>>>> closest I can get is to run PF to VF on an i40e.  Running that I have
>>>>> seen the numbers go from about 20Gb/s to 15Gb/s with almost all the
>>>>> difference being related to the fact that we are having to
>>>>> allocate/free more skbs and make more trips through the
>>>>> i40e_lan_xmit_frame function resulting in more descriptors.
>>>>
>>>> OK, I guess that is more or less in line with what I would expect off
>>>> the top my head. There is a reasonably significant drop in the worst
>>>> case.
>>>>
>>>>>> I'm concerned about the drop in performance for devices that currently
>>>>>> support offloads (almost none of which expose
>>>>>> NETIF_F_GSO_UDP_TUNNEL_CSUM as a feature). Presumably the people that
>>>>>> care most about tunnel performance are the ones that already have
>>>>>> these NICs and will be the most impacted by the drop.
>>>>>
>>>>> The problem is being able to transmit fast is kind of pointless if the
>>>>> receiving end cannot handle it.  We hadn't gotten around to really
>>>>> getting the Rx checksum bits working until the 3.18 kernel which I
>>>>> don't suspect many people are running so at this point messing with
>>>>> the TSO bits isn't really making much of a difference.  Then on top of
>>>>> that most devices have certain limitations on how many ports they can
>>>>> handle and such.  I know the i40e is supposed to support something
>>>>> like 10 port numbers, but the fm10k and ixgbe are limited to one port
>>>>> as I recall.  So this whole thing is already really brittle as it is.
>>>>> My goal with this change is to make the behavior more consistent
>>>>> across the board.
>>>>
>>>> That's true to some degree but there are certainly plenty of cases
>>>> where TSO makes a difference - lower CPU usage, transmitting to
>>>> multiple receivers, people will upgrade their kernels, etc. It's
>>>> clearly good to make things more consistent but hopefully not by
>>>> reducing existing performance. :)
>>>>
>>>>>> My hope is that we can continue to use TSO on devices that only
>>>>>> support NETIF_F_GSO_UDP_TUNNEL. The main problem is that the UDP
>>>>>> length field may vary across segments. However, in practice this is
>>>>>> the only on the final segment and only in cases where the total length
>>>>>> is not a multiple of the MSS. If we could detect cases where those
>>>>>> conditions are met, we could continue to use TSO with the UDP checksum
>>>>>> field pre-populated. A possible step even further would be to break
>>>>>> off the final segment into a separate packet to make things conform if
>>>>>> necessary. This would avoid a performance regression and I think make
>>>>>> this more palatable to a lot of people.
>>>>>
>>>>> I think Tom and I had discussed this possibility a bit at netconf.
>>>>> The GSO logic is something I planned on looking at over the next
>>>>> several weeks as I suspect there is probably room for improvement
>>>>> there.
>>>>
>>>> That sounds great.
>>>>
>>>>>>> I also haven't investigated the effect this will have on OVS.  However I
>>>>>>> suspect the impact should be minimal as the worst case scenario should be
>>>>>>> that Tx checksumming will become enabled by default which should be
>>>>>>> consistent with the existing behavior for IPv6.
>>>>>>
>>>>>> I don't think that it should cause any problems.
>>>>>
>>>>> Good to hear.
>>>>>
>>>>> Do you know if OVS has some way to control the VXLAN configuration so
>>>>> that it could disable Tx checksums?  If so that would probably be a
>>>>> good way to address the 40G issues assuming someone is running an
>>>>> environment hat had nothing but NICs that can support the TSO and Rx
>>>>> checksum on inner headers.
>>>>
>>>> Yes - OVS can control tx checksums on a per-endpoint basis (actually,
>>>> rx checksum present requirements as well though it's not exposed to
>>>> the user at the moment). If you had the information then you could
>>>> optimize what to use in an environment of, say, hypervisors and
>>>> hardware switches.
>>>>
>>>> However, it's certainly possible that you have a mixed set of NICs
>>>> such as an encap aware NIC on the transmit side and non-aware on the
>>>> receive side. In that case, both possible checksum settings penalize
>>>> somebody: off (lose GRO on receiver), on (lose TSO on sender assuming
>>>> no support for NETIF_F_GSO_UDP_TUNNEL_CSUM). That's why I think it's
>>>> important to be able to use encap TSO with local checksum to avoid
>>>> these bad tradeoffs, not to mention being cleaner.
>>>
>>> By "local checksum" do you mean LCO?
>>
>> Yes, that's what I meant.
>>
> Right. To use LCO with TSO we would need to ensure that all packets
> are the same size so that the UDP length field and thus checksum are
> constant for all created segments. But this property this would also
> make any payload lengths in headers constant for all packets so that
> the only fields that need be set per generated packet would be the TCP
> sequence number and checksum. This simplifying assumption could be
> used to make a very protocol-generic GSO/TSO (up to the transport
> header)!
>
> Conceptually, a device would just need to know the start of the
> packet, the offset of the transport header, and the size of each
> segment. Any bits from the start of the packet to the beginning of the
> transport header are just copied to each segment, so any combination
> of encapsulation/network protocols is  supported as long as they are
> constant for each segment (e.g. MPLS, NSH, etc. are on the horizon for
> needing TSO support).
>
> If we are able to do this then GSO could be a lot simpler and more
> extensible. We should be able to eliminate all the GSO flags for GRE,
> IPIP, SIT, UDP, checksum variants, shouldn't need to distinguish
> between TCPv4 and TCPv6, and wouldn't need to disallow nested
> encapsulations. The inner headers in the skbuf might also be removed.
> GSO for SCTP or FCOE still needs a little thought, we'd need to
> consider the possibility of needing both a CRC and checksum in a
> single packet.

Yes, I think this is definitely a good direction to go in general. At
that point, the main distinguishing feature of TSO support in NICs
would basically be the depth into the packet that the card is capable
of manipulating the L4 header. I assume that the NICs that do
encapsulation offloads would be able to handle the same depth when
they are not doing encapsulation and I know that some NICs (such as
ixgbe) don't explicitly support TSO with encapsulation but can handle
headers deeper in the packet than they current expose.

The only issue that I see is that making TSO completely unaware of
outer headers will likely cause performance regressions in some cases.
Imagine if we have an incoming TCP stream with incrementing IP IDs
that we aggregate through GRO and forward. Today's TSO would be able
to recreate the stream by incrementing the ID as new segments are
created. However, if the outgoing NIC is truly only dealing with the
L4 header then it wouldn't be able to do this.
