From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Mon, 11 Jan 2016 09:55:49 -0800
Message-ID: <CALx6S35sBDydNEmJwcBfKnbVhFdtEk8dkwjWsVRhrEHOLn4jTQ@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
	<CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
	<568FD844.3020101@solarflare.com>
	<CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
	<CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
	<CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
	<CAEh+42itZQDiQMrk_rf9LLgeYD=WDa2DMPq8u-9VtUf-eCoQ2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32906 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbcAKRzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:55:50 -0500
Received: by mail-io0-f169.google.com with SMTP id q21so356655344iod.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:55:49 -0800 (PST)
In-Reply-To: <CAEh+42itZQDiQMrk_rf9LLgeYD=WDa2DMPq8u-9VtUf-eCoQ2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 9:24 AM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Jan 8, 2016 at 1:22 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Jan 8, 2016 at 11:40 AM, Jesse Gross <jesse@kernel.org> wrote:
>>> On Fri, Jan 8, 2016 at 10:03 AM, Alexander Duyck
>>> <alexander.duyck@gmail.com> wrote:
>>>> On Fri, Jan 8, 2016 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>>>>> On 08/01/16 03:46, Alexander Duyck wrote:
>>>>>> So I just tried testing your patches and as it turns out you are still
>>>>>> missing some bits.  In this patch for instance the calls to
>>>>>> udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
>>>>>> that you pass false for the last parameter and allow the use of your
>>>>>> udp_set_csum modifications.
>>>>>>
>>>>>> - Alex
>>>>> Are you remembering to enable outer checksums on your vxlan tunnel?  It's
>>>>>  the vxflags & VXLAN_F_UDP_CSUM check, and to enable it you need a recent
>>>>>  iproute2 so you can use the 'udpcsum' option when creating the vxlan device.
>>>>
>>>> No I hadn't done that.  I kind of assumed that the checksums were just
>>>> being enabled by default.  That might explain the some of the issues I
>>>> had..  ;-)
>>>>
>>>>> It would be nice if that could just default to enabled now that we have LCO,
>>>>>  but I don't think we can change that now (ABIs set in stone and all that),
>>>>>  so I think it would have to be iproute2 that turned it on by default.
>>>>
>>>> If anything we might want to expose the capabilities of the kernel so
>>>> that iproute2 could make an informed decision on if it want to enable
>>>> the outer checksum by default or not.
>>>
>>> Keep in mind that protocols like VXLAN specify that the UDP checksum
>>> should be set to zero. As a result, enabling the checksum is not a
>>> purely local decision and it probably shouldn't be on by default.
>>
>> Yes, but the RFC allows for a non-zero checksum.  The key difference
>> here is the wording between SHOULD and MUST.  We aren't requiring the
>> other endpoint to enable outer checksum on its end, and we don't
>> require the remote end to validate the outer checksum.  We have made
>> that purely optional.  If however the other end is also a Linux client
>> it can make use of the outer checksum and hardware offloads to greatly
>> improve the performance.
>>
>> It is essentially all the goodness of remote checksum offload without
>> the compatibility negatives, assuming of course everyone implemented
>> things according to the RFC and didn't make the 0 checksum mandatory..
>
> It's hard to say what other types of endpoints might do if they
> receive a VXLAN packet with a checksum set and, of course, there are
> other protocols that don't specify that received UDP checksums can be
> ignored.
>
RFC1122 is very clear on the subject of UDP checksums:

"If a UDP datagram is received with a checksum that is non- zero and
invalid, UDP MUST silently discard the datagram."

So if a VXLAN receiver accepts a UDP packet without checking a
non-zero UDP checksum for validity they are breaking the UDP protocol.
If they blow up because they don't expect to receive non-zero
checksums that is entirely their problem.

> I'm all in favor of enabling support for the checksum but it doesn't
> seem right to make the default behavior go against the RFC
> recommendation and common implementation.

RFC2460 requires UDP checksums for IPv6 which IMO supersedes what is
recommended in RFC7348 which says that the checksum SHOULD be
transmitted as zero. RFC6935 and RFC 6936 permit zero checksums for
tunneled packets over IPv6 under specific conditions, but we cannot
say that those conditions are meant in every deployment to make that a
default. This is interpretation is consistent with other foo/UDP, like
MPLS/UDP RFC7510 which states:

"When UDP is used over IPv6, the UDP checksum is relied upon to
protect both the IPv6 and UDP headers from corruption and MUST be used
unless the requirements in [RFC6935] and [RFC6936] for use of UDP
zero-checksum mode with a tunnel protocol are satisfied."
