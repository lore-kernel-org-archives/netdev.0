From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Fri, 16 Dec 2011 16:30:26 +0200
Message-ID: <4EEB5602.2060806@iki.fi>
References: <4EE8C6A8.3060308@iki.fi> <20111214.125010.82857701285437834.davem@davemloft.net> <20111215134957.GI6348@secunet.com> <20111216122147.GJ6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:50809 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759429Ab1LPOa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 09:30:29 -0500
Received: by lagp5 with SMTP id p5so1461369lag.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 06:30:27 -0800 (PST)
In-Reply-To: <20111216122147.GJ6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2011 02:21 PM, Steffen Klassert wrote:
> On Thu, Dec 15, 2011 at 02:49:57PM +0100, Steffen Klassert wrote:
>> On Wed, Dec 14, 2011 at 12:50:10PM -0500, David Miller wrote:
>>> From: Timo Ter=E4s <timo.teras@iki.fi>
>>> Date: Wed, 14 Dec 2011 17:54:16 +0200
>>>
>>>> So something is does not get updated here. This used to work thoug=
h.
>>>> The current production boxes where I know this work is 2.6.38.8.
>>>
>>> We store the PMTU externally in inetpeer entries, Eric Dumazet
>>> fixed recently but that fix hasn't been submitted to -stable
>>> yet.
>>>
>>
>> I think we still have at least two problems with pmtu handling.
>> One is that "ip route flush cache" flushes the routing cache
>> but not the cached metrics on the inetpeer.
>=20
> "ip route flush cache" does not even flush the routing cache,
> it just markes the routing cache as invalid by changing the
> rt_genid which make the old routes invisible. And since we don't
> have rt_check_expire() anymore, we have to wait until we have
> collected gc_thresh (1024) useless routes before rt_garbage_collect()
> starts to remove some of them (btw. is this intentional).
>=20
> I think we need a trigger in rt_cache_invalidate() that expires
> all cached pmtu values similar to the routing cache entries.
> For a moment I thought we could just reset the __rt_peer_genid
> value back to zero to mark all cached pmtu values as expired,
> but that's apparently not save to do. So I came to no conclusion
> how to fix this today. Any ideas?

Oh, right. This problem is secondary. As long as the mtu value is
reflected properly, I'll be happy :)

>> Another problem might be that we ignore the user configured
>> fib_metrics in rt_init_metrics() if we have a cached metric
>> on the inetpeer.
>>
>=20
> I think this could be fixed with something like the patch
> below. With this it should be possible to overwrite cached
> values from userspace. It has not much testing, so it's
> just for review at the monent.
>=20
> ---------
> Subject: [PATCH] route: Initialize with the fib_metrics in the non de=
fault case
>[snip]

Thanks! After a very quick test spin, it would appear to fix the bug.
Will continue testing.
