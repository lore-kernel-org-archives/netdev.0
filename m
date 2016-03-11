From: Edward Cree <ecree@solarflare.com>
Subject: Re: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable
 outer Tx checksum by default)
Date: Fri, 11 Mar 2016 21:29:07 +0000
Message-ID: <56E338A3.5070909@solarflare.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:30558 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040AbcCKVdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 16:33:38 -0500
In-Reply-To: <CAKgT0Ud0bj=1Baty7O_8Bi5dEU67-036EeZxLpXjvovANem=6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 21:09, Alexander Duyck wrote:
> The only real issue with the "generic" TSO is that it isn't going to
> be so generic.  We have different devices that will support different
> levels of stuff.  For example the ixgbe drivers will need to treat the
> outer tunnel header as one giant L2 header.  As a result we will need
> to populate all the fields in the outer header including the outer IP
> ID, checksum, udp->len, and UDP or GRE checksum if requested.  For
> i40e I think this gets a bit simpler as they already handle the outer
> IPv4 ID and checksum.  I think there we may need to only populate the
> checksum for it to work out correctly.  As such I may look at coming
> up with a number of functions so that we can mix and match based on
> what is needed in order to assemble a partially segmented frame.
AIUI, the point of the design is that we _can_ populate everything,
because we're keeping lengths and outer IP ID fixed, so outer checksums
stay the same and the outer tunnel header _is_ just one giant L2 header
which is bit-for-bit identical for each generated segment.  So every
devicegets to just be dumb and treat it as opaque.
> The other issue I am working on at the moment to enable all this is to
> fix the differents between csum_tcpudp_magic and csum_ipv6_magic in
> terms of handling packet lengths greater than 65535.  Currently we are
> messing up the checksum in relation to IPv6 since we are using the
> truncated uh->len value.  I'll be submitting some patches later today
> that will hopefully get that fixed and that in turn should make the
> rest of the segmentation work easier.
Again, in the superpacket we want to calculate the checksum based on the
subsegment length, rather than the length of the superpacket.  The idea
is to create the header for an MSS-sized segment, then follow it with an
inner IP & TCP header, and n*MSS bytes of payload.  (This of course
produces a superpacket that's not what you'd send over a link with a 64k
MTU, unlike how we do it today.)
Then hw just chops up the payload, fixes up the inner headers, and glues
the "L2" header on each packet.

-Ed
