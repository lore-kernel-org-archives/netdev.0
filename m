From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable
 outer Tx checksum by default)
Date: Fri, 11 Mar 2016 14:31:29 -0800
Message-ID: <CAKgT0UeBx8NepNM2oGkYOnPV2Niy9GPd7RDZdgDMY3EcRMxNmw@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33522 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbcCKWba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 17:31:30 -0500
Received: by mail-io0-f180.google.com with SMTP id n190so163153928iof.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 14:31:30 -0800 (PST)
In-Reply-To: <56E338A3.5070909@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 1:29 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 11/03/16 21:09, Alexander Duyck wrote:
>> The only real issue with the "generic" TSO is that it isn't going to
>> be so generic.  We have different devices that will support different
>> levels of stuff.  For example the ixgbe drivers will need to treat the
>> outer tunnel header as one giant L2 header.  As a result we will need
>> to populate all the fields in the outer header including the outer IP
>> ID, checksum, udp->len, and UDP or GRE checksum if requested.  For
>> i40e I think this gets a bit simpler as they already handle the outer
>> IPv4 ID and checksum.  I think there we may need to only populate the
>> checksum for it to work out correctly.  As such I may look at coming
>> up with a number of functions so that we can mix and match based on
>> what is needed in order to assemble a partially segmented frame.
> AIUI, the point of the design is that we _can_ populate everything,
> because we're keeping lengths and outer IP ID fixed, so outer checksums
> stay the same and the outer tunnel header _is_ just one giant L2 header
> which is bit-for-bit identical for each generated segment.  So every
> devicegets to just be dumb and treat it as opaque.

This works so long as the device isn't trying to do anything like
insert VLAN tags.  Then I think we might have an issue since we don't
want to confuse the device and have it trying to insert the tag on the
inner frame's Ethernet header.

I suspect we may have differing levels of "dumb" that we have to deal
with.  That is all I am saying.  By default we could just populate all
of the length and checksum fields in the outer header, we would just
have to be consistent about what is provided then.  In addition there
will be the matter of sorting out the IP ID bits.  For example some of
the i40e parts support tunnel offloads, but not tunnel offloads with
checksums enabled.  I suspect those parts will end up wanting to
handle the outer IP header and UDP length values.  As a result there
trying to do a "dumb" send may result in us really messing up the IP
ID values if we don't take steps to make it a bit smarter.

>> The other issue I am working on at the moment to enable all this is to
>> fix the differents between csum_tcpudp_magic and csum_ipv6_magic in
>> terms of handling packet lengths greater than 65535.  Currently we are
>> messing up the checksum in relation to IPv6 since we are using the
>> truncated uh->len value.  I'll be submitting some patches later today
>> that will hopefully get that fixed and that in turn should make the
>> rest of the segmentation work easier.
> Again, in the superpacket we want to calculate the checksum based on the
> subsegment length, rather than the length of the superpacket.  The idea
> is to create the header for an MSS-sized segment, then follow it with an
> inner IP & TCP header, and n*MSS bytes of payload.  (This of course
> produces a superpacket that's not what you'd send over a link with a 64k
> MTU, unlike how we do it today.)

The question is at what point do we do the chopping.  Should we be
doing this in the drivers or somewhere higher in the stack like we do
for standard GSO segmentation.  I would think we would need to add
another bit that says we can do GSO with custom outer headers since I
can see VLANs being a possible issue otherwise.

> Then hw just chops up the payload, fixes up the inner headers, and glues
> the "L2" header on each packet.

Yea, it sounds really straight forward and easy.  It isn't till you
start digging into the actual code that it gets a bit hairy.

What this effectively is is another form of TSO where each driver will
want to do things a little differently.  Alot of it has to do with the
fact that this is kind of a nasty hack that we are trying to add since
many devices won't like the fact that we are lying about the size of
our actual L2 header so things like VLAN tag insertion are going to
end up blowing back on us.

Really my preference in the case of ixgbe would have been to let the
hardware update the outer IP header and the inner TCP header and then
do the UDP and inner IP header as the static headers.  That way we
could still theoretically support fragmentation on the outer headers
which last I knew is a very real possibility since the DF bit is not
set on the outer headers for VXLAN I believe.

- Alex
