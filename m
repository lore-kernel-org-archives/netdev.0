From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 14:29:22 +0300
Message-ID: <4CC02412.8050000@iki.fi>
References: <4CC018E1.3000906@iki.fi>	<20101021.035004.212683583.davem@davemloft.net>	<4CC01CC0.7090101@iki.fi> <20101021.040319.191412436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:60557 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757595Ab0JUL3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:29:24 -0400
Received: by ewy20 with SMTP id 20so5611103ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 04:29:23 -0700 (PDT)
In-Reply-To: <20101021.040319.191412436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 02:03 PM, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 21 Oct 2010 13:58:08 +0300
>=20
>> On 10/21/2010 01:50 PM, David Miller wrote:
>>> From: Timo Ter=E4s <timo.teras@iki.fi>
>>> Date: Thu, 21 Oct 2010 13:41:37 +0300
>>>
>>>> Is inet_bind() called from non-userland context? If yes, then this=
 is a
>>>> bad idea. Otherwise I don't think it's that hot path...
>>>
>>> It is.
>>
>> Yet, almost immediately after that there is lock_sock() which can al=
so
>> sleep. How does that work then?
>=20
> RTNL interlocks globally with a heavy primitive, a mutex, lock_sock()
> grabs a spinlcok which is local to the socket's context.
>=20
> So if we have 100,000 sockets binding we'll suck with you're change
> whereas the lock_sock() does not cause that problem.
>=20
> Is this so difficult for you to comprehend?

I was confused with Dave's original reply "It is." as referring to that
inet_bind() can get called from non-userland context. But apparently yo=
u
just meant that "It is (bad idea regardless)."

I thought the problem was possible sleeping, and not contention. Which
became very obvious from Eric's example. I didn't realize that many do
bind()/recv()/send() as general workload.

Sorry for not seeing the obvious.

This is the third time asking, what would be a good way to fix the
problem described in the original commit log?

Changing RTM_NEWADDR after FIB update would break Netlink event
ordering. And this breaks performance. I can't really use RTN_LOCAL
RTM_NEWROUTE events since (at least IPv6 side) has incorrect ifindex.

Should inet_addr_type() be rewritten to not use FIB lookups?
