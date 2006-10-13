From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct inet_peer), cleanup,
 change in peer_check_expire()
Date: Fri, 13 Oct 2006 05:56:43 +0200
Message-ID: <452F0E7B.3010701@cosmosbay.com>
References: <43CCBF3D.2070900@cosmosbay.com> <4415A4C1.1030906@cosmosbay.com>
 <452EA214.7080905@cosmosbay.com> <20061012.151529.95506153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:64662 "EHLO Smtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1751604AbWJMD4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 23:56:40 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J72009CW2YECXU1@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 13 Oct 2006 05:56:38 +0200 (CEST)
In-reply-to: <20061012.151529.95506153.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 12 Oct 2006 22:14:12 +0200
>=20
>> 1) shrink struct inet_peer on 64 bits platforms.
>> ------------------------------------------------
>> I noticed sizeof(struct inet_peer) was 64+8 on x86_64
>>
>> As we dont really need 64 bits timestamps (we only care for garbage=20
>> collection), we can use 32bits ones and reduce sizeof(struct inet_pe=
er) to 64=20
>> bytes : Because of SLAB_HWCACHE_ALIGN constraint, final allocation i=
s 64 bytes=20
>> instead of 128 bytes per inet_peer structure.
>=20
> I'm not convinced this is %100 correct.  There are wrapping
> cases that I think aren't covered.
>=20
> Consider an entry that lives long enough for the lower 32-bits
> of jiffies to wrap, then we kill it, but we won't purge it
> properly if the wrapped jiffie is close to dtime.
>=20
> I'm sure there are other similar cases as well.

Hum, if it was incorrect, I urge you to grep for tcp_time_stamp, and co=
rrect=20
this as soon as possible :)

2^31 is 2147483648

Thats a *lot* of timer ticks, an inet_peer entry should not stay in=20
unused_list for more than 10 minutes.

Even if the system is under stress for more than 30 days, and some entr=
ies=20
stay that long in unused list, they wont leak : either they are re-used=
,=20
either they are purged by cleanup_once(0); done in inet_getpeer().

Eric

