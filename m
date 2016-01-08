From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 13:22:47 -0800
Message-ID: <CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
	<CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
	<568FD844.3020101@solarflare.com>
	<CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
	<CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:33109 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932315AbcAHVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 16:22:48 -0500
Received: by mail-ig0-f193.google.com with SMTP id y8so9010344igw.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 13:22:47 -0800 (PST)
In-Reply-To: <CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 11:40 AM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Jan 8, 2016 at 10:03 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Jan 8, 2016 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> On 08/01/16 03:46, Alexander Duyck wrote:
>>>> So I just tried testing your patches and as it turns out you are still
>>>> missing some bits.  In this patch for instance the calls to
>>>> udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
>>>> that you pass false for the last parameter and allow the use of your
>>>> udp_set_csum modifications.
>>>>
>>>> - Alex
>>> Are you remembering to enable outer checksums on your vxlan tunnel?  It's
>>>  the vxflags & VXLAN_F_UDP_CSUM check, and to enable it you need a recent
>>>  iproute2 so you can use the 'udpcsum' option when creating the vxlan device.
>>
>> No I hadn't done that.  I kind of assumed that the checksums were just
>> being enabled by default.  That might explain the some of the issues I
>> had..  ;-)
>>
>>> It would be nice if that could just default to enabled now that we have LCO,
>>>  but I don't think we can change that now (ABIs set in stone and all that),
>>>  so I think it would have to be iproute2 that turned it on by default.
>>
>> If anything we might want to expose the capabilities of the kernel so
>> that iproute2 could make an informed decision on if it want to enable
>> the outer checksum by default or not.
>
> Keep in mind that protocols like VXLAN specify that the UDP checksum
> should be set to zero. As a result, enabling the checksum is not a
> purely local decision and it probably shouldn't be on by default.

Yes, but the RFC allows for a non-zero checksum.  The key difference
here is the wording between SHOULD and MUST.  We aren't requiring the
other endpoint to enable outer checksum on its end, and we don't
require the remote end to validate the outer checksum.  We have made
that purely optional.  If however the other end is also a Linux client
it can make use of the outer checksum and hardware offloads to greatly
improve the performance.

It is essentially all the goodness of remote checksum offload without
the compatibility negatives, assuming of course everyone implemented
things according to the RFC and didn't make the 0 checksum mandatory..
