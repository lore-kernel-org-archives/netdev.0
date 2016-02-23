From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by default
Date: Tue, 23 Feb 2016 10:18:21 -0800
Message-ID: <CAKgT0UeBQeG9ni1wXe8TpWei_8+5x-AgVLwUB0EXQV15UWu1Mw@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
	<CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
	<CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
	<CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
	<CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
	<CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
	<CAEh+42hzkW6i+M52iDAyFtCBfxcJJmsZOiNdqd-DqYrN5isMBw@mail.gmail.com>
	<56CC7848.2000704@solarflare.com>
	<CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
	<CALx6S37p8eV-gURM0C8hP=G7XLt+=FFwV9HNF3z_FdciKxLf0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Edward Cree <ecree@solarflare.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38421 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536AbcBWSSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:18:22 -0500
Received: by mail-ig0-f171.google.com with SMTP id y8so109893656igp.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 10:18:22 -0800 (PST)
In-Reply-To: <CALx6S37p8eV-gURM0C8hP=G7XLt+=FFwV9HNF3z_FdciKxLf0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 9:42 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Feb 23, 2016 at 9:31 AM, Jesse Gross <jesse@kernel.org> wrote:
>> On Tue, Feb 23, 2016 at 8:47 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Tue, Feb 23, 2016 at 7:18 AM, Edward Cree <ecree@solarflare.com> wrote:
>>>> On 23/02/16 03:31, Jesse Gross wrote:
>>>>> The only issue that I see is that making TSO completely unaware of
>>>>> outer headers will likely cause performance regressions in some cases.
>>>>> Imagine if we have an incoming TCP stream with incrementing IP IDs
>>>>> that we aggregate through GRO and forward. Today's TSO would be able
>>>>> to recreate the stream by incrementing the ID as new segments are
>>>>> created. However, if the outgoing NIC is truly only dealing with the
>>>>> L4 header then it wouldn't be able to do this.
>>>> Perhaps TSO should force setting the DF bit, so that the IP ID can be
>>>> ignored.  After all, if your network is going to cause fragmentation and
>>>> reassembly, your performance will probably be bad enough that TSO won't
>>>> help you much.  (And TCP usually wants DF anyway so it can do PMTUD.)
>>>> Arguably, as soon as we perform GRO on traffic to be forwarded, we've
>>>> already violated the end-to-end principle (there are always imaginable
>>>> situations in which a different packet stream comes out than went in),
>>>> so it doesn't really matter if we go on to change the network layer
>>>> parameters in this way - it's not really the same IP datagram any more
>>>> so it's OK for its identification to change.
>>>> And of course this problem doesn't present itself for IPv6 :)
>>>
>>> Right, GRO should probably not coalesce packets with non-zero IP
>>> identifiers due to the loss of information. Besides that, RFC6848 says
>>> the IP identifier should only be set for fragmentation anyway so there
>>> shouldn't be any issue and really no need for HW TSO (or LRO) to
>>> support that.
>>
>> Most OSs (including Linux with connected TCP sockets) use non-zero IP
>> IDs so requiring this would effectively disable GRO.
>>
>> I think the practical way to go about this is to introduce a new GSO
>> type for L4-only offload. There are some existing types that we could
>> immediately convert and kill off with no impact (such as GRE) and some
>> new protocols that would come for free (such as MPLS) so it would be a
>> net win. Once the infrastructure is in, it will be easier to evaluate
>> what else can be simplified on a case by case basis. (i.e. Even
>> UDP_TUNNEL will have some potential adverse impact from this compared
>> to explicit support since we'd need to break off the last segment from
>> a TSO burst where the size isn't an even multiple of the MSS. I guess
>> the impact is probably small but it would be good to know.)
>
> Why not just fix the stack to conform to RFC6864? As Edward pointed
> out we lose the actual IP ID's in GRO anyway, so attempts to set them
> in GSO may be wildly incorrect from the source point of view-- even in
> that case were probably better off changing the IP identifier to zero
> (okay since we're already breaking the E2E model anyway :-) ).

The wording of RFC6864 seems to imply that we can ignore the IP ID
field in the case of DF being set and the MF and fragment offset bits
being cleared.  It states we can use an arbitrary value for the IP ID
on "atomic" frames so we can probably just leave it at whatever the
initial value is for the frame to be segmented, not need to force it
to 0.

The problem as I see it is that we will need to update GRO so that it
is willing to accept frames with an inner IP ID that is not
incrementing for atomic frames before we can really get into the GSO
side of the equation.  From what I can tell it looks like currently it
doesn't honor that and requires IP ID to increment in order to
coalesce frames.

I will look into trying to setup TSO for these devices like I did
NETIF_F_HW_CSUM for the Intel parts.  Basically we will leave the
outer IP header and the inner transport header to be handled by the
hardware, and then we can compute the length and checksum for the UDP
header and inner IP header.  That way we can deal with things like
VLAN tags that need to be inserted before the outer network header
while maintaining the IP ID for the outer IP header as well since most
devices seem to handle that correctly.

- Alex
