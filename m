From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable
 outer Tx checksum by default)
Date: Fri, 11 Mar 2016 13:09:12 -0800
Message-ID: <CAKgT0Ud0bj=1Baty7O_8Bi5dEU67-036EeZxLpXjvovANem=6Q@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34617 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbcCKVJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 16:09:13 -0500
Received: by mail-io0-f171.google.com with SMTP id m184so161063091iof.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 13:09:12 -0800 (PST)
In-Reply-To: <56E32966.7090409@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 12:24 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 11/03/16 20:16, Tom Herbert wrote:
>> On Fri, Mar 11, 2016 at 11:59 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> On 11/03/16 19:57, Tom Herbert wrote:
>>>> On Fri, Mar 11, 2016 at 11:20 AM, Edward Cree <ecree@solarflare.com> wrote:
>>>>> Tom,
>>>>>
>>>>> Are you planning to / working on implementing this?  If not, I might have a
>>>>> crack at it; I've talked to our firmware guys and (provisionally) we think
>>>>> we can support it in current sfc hardware.
>>>>> Or were there any blocking problems raised in the thread?  My understanding
>>>>> of the IP ID issue was that it only matters for the inner frame, because
>>>>> the rest aren't TCP (so hopefully no-one is doing SLHC on them).  But I may
>>>>> have missed something.
>>>>>
>>>> Right, then the interface would need to just include the offset of the
>>>> IP ID. But doesn't this break using LCO with GSO though-- i.e. the
>>>> outer checksum and inner checksum still need to be updated per packet
>>>> so we need to tell device where outer checksum(s) is.
>>> No, outer checksum shouldn't change: IP ID is protected by inner IP header
>>> checksum, which device will edit.  No?
>> Right, the interface would probably still need offset to the IPv4 hdr?
> Yes; I'm assuming the interface could just be "offset to inner IP header",
> and the hardware knows well enough what IP and TCP headers look like that
> it can figure out the rest (including skipping over options if e.g. ihl>5).
> So, do you want to try and implement it or shall I?

I've already started looking into this and was waiting for feedback
from Dave about the IPv4 ID issue which is looks like he is okay with
a static ID value as long as the DF bit is set.

The only real issue with the "generic" TSO is that it isn't going to
be so generic.  We have different devices that will support different
levels of stuff.  For example the ixgbe drivers will need to treat the
outer tunnel header as one giant L2 header.  As a result we will need
to populate all the fields in the outer header including the outer IP
ID, checksum, udp->len, and UDP or GRE checksum if requested.  For
i40e I think this gets a bit simpler as they already handle the outer
IPv4 ID and checksum.  I think there we may need to only populate the
checksum for it to work out correctly.  As such I may look at coming
up with a number of functions so that we can mix and match based on
what is needed in order to assemble a partially segmented frame.

The other issue I am working on at the moment to enable all this is to
fix the differents between csum_tcpudp_magic and csum_ipv6_magic in
terms of handling packet lengths greater than 65535.  Currently we are
messing up the checksum in relation to IPv6 since we are using the
truncated uh->len value.  I'll be submitting some patches later today
that will hopefully get that fixed and that in turn should make the
rest of the segmentation work easier.

- Alex
