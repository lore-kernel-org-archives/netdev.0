From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced  by  tuning?
Date: Tue, 16 Jun 2009 08:12:30 +0200
Message-ID: <4A3737CE.3020305@gmail.com>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <20090527131437.5870e342.akpm@linux-foundation.org> <20090527231949.GB30002@elte.hu> <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx> <4A3702CF.9070303@gmail.com> <6.2.5.6.2.20090616000017.05b5da70@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>, linux-kernel@vger.kernel.org,
        Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
        hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com,
        kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com,
        apw@canonical.com, wli@movementarian.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: starlight@binnacle.cx
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <6.2.5.6.2.20090616000017.05b5da70@binnacle.cx>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Please dont top post, we prefer other way around :)

starlight@binnacle.cx a =E9crit :
> Eric,
>=20
> Great thought--thank you.  Running a similar server with=20
> 82571/e1000e and it does not exhibit the problem.  'e1000e' has=20
> default copybreak=3D256 while 'ixgbe' has no copybreak.  Rational=20
> given is
>=20
>    http://osdir.com/ml/linux.drivers.e1000.devel/2008-01/msg00103.html
>=20
> But the comparion is a bit apples-and-oranges since the 'e1000e'=20
> system is dual Opteron 2354 while the 'ixgbe' system is Xeon=20
> E5430 (a painful choice thus far).  Also 'e1000e' system passes=20
> data via a PACKET socket while the 'ixgbe' system passes data=20
> via UDP (a configurable option).
>=20
> I'm not fully up on how this all works: am I to understand that=20
> the error could result from RX ring-queue buffers not freeing=20
> quickly enough because they have a use-count held non-zero as
> the packet travels the stack?

Well, error is normal in stress situation, when no more kernel
memory is available.

cat /proc/net/udp

can show you (in last column) sockets where packets where dropped
by UDP stack if their receive queue was full.

>=20
> I've just doubled some SLAB tuneables that seem relevant, but=20
> if the cause is the aforementioned, this won't help.  Will
> have the answer on the tweaks by the end of Tuesday.
>=20
> David

copybreak in drivers themselves is nice because driver can recycle
its rx skbs much faster, but that is suboptimal in forwarding (routers)
workloads. Its also a lot of duplicated code in every driver.

So we could do the skb trimming (ie : reallocating the data portion to ex=
actly
the size of packet) in core network stack, when we know packet must be ha=
ndled
by an application, and not dropped or forwarded by kernel.

Because of slab rounding, this reallocation should be done only if result=
ing data
portion is really smaller (50 %) than original skb.

>=20
>=20
>=20
> At 04:26 AM 6/16/2009 +0200, Eric Dumazet wrote:
>> 152691992335/724246449 =3D 210 bytes per rx packet in average
>>
>> It could make sense to add copybreak feature in this driver to=20
>> reduce memory needs, but that also would consume more cpu=20
>> cycles, and slow down forwarding setups.
>>
>> Maybe this packet trimming could be done generically in UDP=20
>> stack input path, before queueing packet into a receive queue,=20
>> if amount of available memory is under a given threshold.
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
