From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery
Date: Fri, 04 Dec 2009 01:28:11 +0100
Message-ID: <4B18579B.7020702@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com> <200912040215.16690.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35562 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbZLDA2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:28:09 -0500
In-Reply-To: <200912040215.16690.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Friday 04 December 2009 01:52:44 you wrote:
>> Octavian Purdila a =E9crit :
>=20
>>> Since at this point we are using UP ports contention is not really =
an
>>> issue for us. I've extrapolated this (lock per hash bucket) based o=
n how
>>> locking is done in other places, like UDP.
>> Yes but you know we want to remove those locks per UDP hash bucket, =
since
>>  we dont really need them anymore. ;)
>>
>> If you remember, we had in the past one rwlock for the whole UDP tab=
le.
>>
>> Then this was converted to one spinlock per hash slot (128 slots) + =
RCU
>>  lookups for unicast RX
>>
>> Then we dynamically sized udp table at boot (up to 65536 slots)
>>
>> multicast optimization (holding lock for small duration + double has=
hing)
>>
>> bind optimization (thanks to double hashing)
>>
>> To be done :
>>
>> 1) multicast RX can be done without taking any lock, and RCU lookups
>> 2) zap all locks and use one lock, or a small array of hashed spinlo=
cks
>>
>=20
> Thanks for the nice summary Eric !
>=20
> I still have one doubt related to this: we still need locking for cre=
ating and=20
> destroying sockets to insert/remove them into/from the hash, RCU can'=
t help us=20
> here, right?=20

Sure. RCU is used for readers only. We still need locks to protect writ=
ers
against them.

>=20
> In that case wouldn't spinlock contention become an issue for short l=
ived=20
> connections? Probably not for UDP (or LLC), but for TCP I certainly c=
an think=20
> of a few usecases for short lived connections.

Yes, this is why an array of hashed spinlocks would be good, (as alread=
y done with TCP
for example, or IP route cache)

(Say you have a table of 65536 UDP slots on your high performance serve=
r,
handling millions of udp sockets, you dont _need_ 65536 spinlocks, but =
some number
related to number of cpus)


