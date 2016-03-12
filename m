From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable
 outer Tx checksum by default)
Date: Fri, 11 Mar 2016 21:40:44 -0800
Message-ID: <CAKgT0UfffHvVZPNbfQseOSTXFXAhjtscdoaVKzYxL1t4rooNEw@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
	<CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
	<CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
	<CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
	<CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
	<CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
	<CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
	<56E31A89.9020602@solarflare.com>
	<CALx6S37G5N-3GxXYf8uF9p8QNC+U_d6-Vf+8Jg6bFqEv_FpULg@mail.gmail.com>
	<56E3239B.7080009@solarflare.com>
	<CALx6S37P+gVA_O7vxBjGMxHpY69Cx2aL3E79ptvGkRW4L2x5Ug@mail.gmail.com>
	<56E32966.7090409@solarflare.com>
	<CAKgT0Ud0bj=1Baty7O_8Bi5dEU67-036EeZxLpXjvovANem=6Q@mail.gmail.com>
	<56E338A3.5070909@solarflare.com>
	<CAKgT0UeBx8NepNM2oGkYOnPV2Niy9GPd7RDZdgDMY3EcRMxNmw@mail.gmail.com>
	<CALx6S36wJdFnq=2ZkTfijqro1TM1GTqap=aLQ0+NszgWC6Sznw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35321 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbcCLFkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 00:40:45 -0500
Received: by mail-ig0-f179.google.com with SMTP id vf5so25840327igb.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 21:40:44 -0800 (PST)
In-Reply-To: <CALx6S36wJdFnq=2ZkTfijqro1TM1GTqap=aLQ0+NszgWC6Sznw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 2:55 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Mar 11, 2016 at 2:31 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Mar 11, 2016 at 1:29 PM, Edward Cree <ecree@solarflare.com> wrote:
>>> On 11/03/16 21:09, Alexander Duyck wrote:
>>>> The only real issue with the "generic" TSO is that it isn't going to
>>>> be so generic.  We have different devices that will support different
>>>> levels of stuff.  For example the ixgbe drivers will need to treat the
>>>> outer tunnel header as one giant L2 header.  As a result we will need
>>>> to populate all the fields in the outer header including the outer IP
>>>> ID, checksum, udp->len, and UDP or GRE checksum if requested.  For
>>>> i40e I think this gets a bit simpler as they already handle the outer
>>>> IPv4 ID and checksum.  I think there we may need to only populate the
>>>> checksum for it to work out correctly.  As such I may look at coming
>>>> up with a number of functions so that we can mix and match based on
>>>> what is needed in order to assemble a partially segmented frame.
>>> AIUI, the point of the design is that we _can_ populate everything,
>>> because we're keeping lengths and outer IP ID fixed, so outer checksums
>>> stay the same and the outer tunnel header _is_ just one giant L2 header
>>> which is bit-for-bit identical for each generated segment.  So every
>>> devicegets to just be dumb and treat it as opaque.
>>
>> This works so long as the device isn't trying to do anything like
>> insert VLAN tags.  Then I think we might have an issue since we don't
>> want to confuse the device and have it trying to insert the tag on the
>> inner frame's Ethernet header.
>>
> In Edward's giant L2 header mode, couldn't VLAN tags just be part of that?

The problem is things like VFs which aren't allowed to insert their
own tags.  Having them try to lie about where the network header
actually starts may trigger things like anti-spoof events.

>> I suspect we may have differing levels of "dumb" that we have to deal
>> with.  That is all I am saying.  By default we could just populate all
>> of the length and checksum fields in the outer header, we would just
>> have to be consistent about what is provided then.  In addition there
>> will be the matter of sorting out the IP ID bits.  For example some of
>> the i40e parts support tunnel offloads, but not tunnel offloads with
>> checksums enabled.  I suspect those parts will end up wanting to
>> handle the outer IP header and UDP length values.  As a result there
>> trying to do a "dumb" send may result in us really messing up the IP
>> ID values if we don't take steps to make it a bit smarter.
>>
>>>> The other issue I am working on at the moment to enable all this is to
>>>> fix the differents between csum_tcpudp_magic and csum_ipv6_magic in
>>>> terms of handling packet lengths greater than 65535.  Currently we are
>>>> messing up the checksum in relation to IPv6 since we are using the
>>>> truncated uh->len value.  I'll be submitting some patches later today
>>>> that will hopefully get that fixed and that in turn should make the
>>>> rest of the segmentation work easier.
>>> Again, in the superpacket we want to calculate the checksum based on the
>>> subsegment length, rather than the length of the superpacket.  The idea
>>> is to create the header for an MSS-sized segment, then follow it with an
>>> inner IP & TCP header, and n*MSS bytes of payload.  (This of course
>>> produces a superpacket that's not what you'd send over a link with a 64k
>>> MTU, unlike how we do it today.)
>>
>> The question is at what point do we do the chopping.  Should we be
>> doing this in the drivers or somewhere higher in the stack like we do
>> for standard GSO segmentation.  I would think we would need to add
>> another bit that says we can do GSO with custom outer headers since I
>> can see VLANs being a possible issue otherwise.
>>
>>> Then hw just chops up the payload, fixes up the inner headers, and glues
>>> the "L2" header on each packet.
>>
>> Yea, it sounds really straight forward and easy.  It isn't till you
>> start digging into the actual code that it gets a bit hairy.
>>
>> What this effectively is is another form of TSO where each driver will
>> want to do things a little differently.  Alot of it has to do with the
>> fact that this is kind of a nasty hack that we are trying to add since
>> many devices won't like the fact that we are lying about the size of
>> our actual L2 header so things like VLAN tag insertion are going to
>> end up blowing back on us.
>>
> Right, the point is that we're trying to get out of the model where
> every driver/device implements TSO differently, supports ad hoc
> protocols, etc. Do you see any other common invasive technique that we
> need to deal with other than VLAN insertion and IP ID?

Well that is the thing.  Before we can actually start tinkering with
the outer header we probably need to make sure we set the DF bit and
that it would be honored on the outer headers for IPv4.  I don't
believe any of the tunnels are currently doing that so repeating the
IP ID would be the worst possible scenario until that is resolved
since VXLAN tunneled frames can be fragmented while TCP frames cannot
so we really shouldn't be repeating IP IDs for the outer headers.

- Alex
