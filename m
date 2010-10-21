From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 13:41:37 +0300
Message-ID: <4CC018E1.3000906@iki.fi>
References: <1287655930-16879-1-git-send-email-timo.teras@iki.fi> <1287656753.6871.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:65455 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102Ab0JUKlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:41:39 -0400
Received: by ewy20 with SMTP id 20so5577345ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 03:41:38 -0700 (PDT)
In-Reply-To: <1287656753.6871.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 01:25 PM, Eric Dumazet wrote:
> Le jeudi 21 octobre 2010 =C3=A0 13:12 +0300, Timo Ter=C3=A4s a =C3=A9=
crit :
>> Otherwise we have race condition to user land:
>>  1. process A changes IP address
>>  2. kernel sends RTM_NEWADDR
>>  3. process B gets notification
>>  4. process B tries to bind() to new IP but that fails with
>> EADDRNOTAVAIL because FIB is not yet updated and inet_addr_type() in
>> inet_bind() does not recognize the IP as local
>>  5. kernel calls inetaddr_chain notifiers which updates FIB
>>
>> IPv6 side seems to handle the notifications properly: bind()
>> immediately after RTM_NEWADDR succeeds as expected. This is because
>> ipv6_chk_addr() uses inet6_addr_lst which is updated before address
>> notification.
>>
>> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
>> ---
>>  net/ipv4/af_inet.c  |    9 +++++++++
>>  net/ipv6/af_inet6.c |    4 +++-
>>  2 files changed, 12 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 6a1100c..21200e4 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -466,6 +466,15 @@ int inet_bind(struct socket *sock, struct socka=
ddr *uaddr, int addr_len)
>>  	if (addr_len < sizeof(struct sockaddr_in))
>>  		goto out;
>> =20
>> +	/* Acquire rtnl_lock to synchronize with possible simultaneous
>> +	 * IP-address changes. This is needed because when RTM_NEWADDR
>> +	 * is sent the new IP is not yet in FIB, but alas inet_addr_type
>> +	 * checks the address type using FIB. Acquiring rtnl lock once
>> +	 * makse sure that any address for which RTM_NEWADDR was sent
>> +	 * earlier exists also in FIB. */
>> +	rtnl_lock();
>> +	rtnl_unlock();
>=20
> You must be kidding ?
>=20
> Really, this is a hot path...

Is inet_bind() called from non-userland context? If yes, then this is a
bad idea. Otherwise I don't think it's that hot path...

The other idea of doing notifier calls before RTM_NEWADDR sending is
worse because it changes ordering of userland visible netlink notificat=
ions.

This looked like the easiest way out. If this is unacceptable, I guess
we are left with changing inet_addr_type() to not use FIB.

Or is there better ideas?


