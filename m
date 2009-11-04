From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Thu, 05 Nov 2009 00:32:18 +0100
Message-ID: <4AF20F02.7000601@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com> <200911050104.09538.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36550 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932791AbZKDXcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 18:32:16 -0500
In-Reply-To: <200911050104.09538.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Wednesday 04 November 2009 23:30:27 you wrote:
>=20
>> I knew someone would do this kind of patch one day, I tried it one y=
ear ago
>>  :)
>>
>=20
> And I knew you would give us feedback, thanks ! You are unstoppable l=
ately,=20
> how many of are out there? :)=20
>=20
>> First of all, you are mixing several things in this patch.
>>
>> Dont do this, its not possible for us to correctly review such compl=
ex
>>  patch.
>>
>> Then, your patch is not based on net-next-2.6, and you really need t=
o work
>>  on this tree.
>>
>=20
> Yes, the patch is not in any shape for review, we just wanted some ea=
rly=20
> feedback on the approach itself, and I've noticed its more likely to =
get=20
> feedback when code is posted.
>=20
>> Then, if you had worked on net-next-2.6, you whould have noticed UDP=
 hash
>>  tables are now dynamically sized at boot.
>> An admin can even force a 65536 slots hash table for heavy duty UDP
>>  servers.
>>
>> Then, last point : Say I have a machine with 65000 udp sockets bound=
 to a
>>  different port, and a 65536 slots hash table, (sane values in fact,=
 in
>>  order to have best performances), then your two phase lookup will b=
e
>>  slower than the one-phase current lookup (two cache misses instead =
of one)
>>
>> So your patch seems to solve a pathological case (where many udp soc=
kets
>>  are bounded to a particular port, but on many different IPs), and s=
low
>>  down 99% of other uses.
>>
>=20
> Very true, the benchmark itself shows a significant overhead increase=
 on the TX=20
> side and indeed this case is not very common. But for us its an impor=
tant=20
> usecase.=20
>=20
> Maybe there is a more clever way of fixing this specific use-case wit=
hout=20
> hurting the common case?
>=20

Clever way ? Well, we will see :)

I now understand previous Lucian patch (best match) :)

Could you please describe your usecase ? I guess something is possible,
not necessarly hurting performance of regular usecases :)

I have struct reorderings in progress to reduce number of cache lines r=
ead
per socket from two to one. So this would reduce by 50% time to find
a particular socket in the chain.

But if you *really* want/need 512 sockets bound to _same_ port, we prob=
ably can use
secondary hash tables (or rbtree), as soon as we stack more than XX soc=
kets on a
particular slot.

At lookup, we check if extended hash table exists before doing
normal rcu lookup.

Probably can be done under 300 lines of code.
On normal machines, these extra tables/trees would not be used/allocate=
d
