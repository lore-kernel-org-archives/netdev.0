From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Thu, 27 Oct 2011 18:27:12 +0200
Message-ID: <1319732832.2601.43.camel@edumazet-laptop>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
	 <1319716772.2601.26.camel@edumazet-laptop>
	 <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>
	 <1319731732.2601.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Karel Rericha <karel@maxtel.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:51179 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab1J0Q1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 12:27:25 -0400
Received: by ggnb1 with SMTP id b1so2811706ggn.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 09:27:24 -0700 (PDT)
In-Reply-To: <1319731732.2601.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 18:08 +0200, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 27 octobre 2011 =C3=A0 14:46 +0200, Karel Rericha a =C3=A9cr=
it :
>=20
> > Actually I am doing some reseach to replace our main shaping machin=
e
> > with 60 000+ htb classes, which now saturates 12 core Xeon Westmere=
 to
> > 30% (there are five gigabit network ports on each interface affinit=
ed
> > to cores). AFAIK QFQ should be O(1) complexity so it would bring
> > saturation a requirements for number of cores down considerably (HT=
B
> > has O(log(N)) complexity).
> >=20
> > I have test machine and about two months to decide if we will stay
> > with HTB or we will try something else. So it would be VERY helpful=
,
> > if you would search you memory instead your dead disk :-) and send =
me
> > some example of QFQ usage, if I can ask for a little of your time. =
I
> > promise to have results published here in return.
> >=20
> > Thanks, Karel
> >=20
>=20
> That seems a good challenge to me ;)
>=20
> First upgrade to a recent kernel with QFQ included.
> Also upgrade iproute2 to a recent enough version as well.
>=20
> Then you discover "tc  ... qfq help" is not that helpful :(
>=20
> # tc qdisc add dev eth3 root qfq help
> Usage: ... qfq
>=20
> OK, its parameters are :
>=20
> 	qfq weight num1 [maxpkt BYTES]
>=20
> You should not touch maxpkt, its default value being 2048
>=20
> Oh well, I just tried the obvious and my (remote) machine doesnt answ=
er
> to me anymore...
>=20
> Time for a bit of debugging I am afraid :(

Never mind, it was an user error :)

Here is what I used during my tests, I guess you can adapt your
scripts...

DEV=3Deth3
RATE=3D"rate 40Mbit"
TNETS=3D"10.2.2.0/25"
ALLOT=3D"allot 20000"

tc qdisc del dev dummy0 root 2>/dev/null

tc qdisc add dev $DEV root handle 1: cbq avpkt 1000 rate 1000Mbit \
	bandwidth 1000Mbit
tc class add dev $DEV parent 1: classid 1:1 \
	est 1sec 8sec cbq allot 10000 mpu 64 \
	rate 1000Mbit prio 1 avpkt 1500 bounded

# output to test nets :  40 Mbit limit
tc class add dev $DEV parent 1:1 classid 1:11 \
	est 1sec 8sec cbq $ALLOT mpu 64      \
	$RATE prio 2 avpkt 1400 bounded

tc qdisc add dev $DEV parent 1:11 handle 11:  \
	est 1sec 8sec qfq

tc filter add dev $DEV protocol ip parent 11: handle 3 \
	flow hash keys rxhash divisor 8

for i in `seq 1 8`
do
 classid=3D11:$(printf %x $i)
 tc class add dev $DEV classid $classid qfq=20
 tc qdisc add dev $DEV parent $classid pfifo limit 30
done

for privnet in $TNETS
do
	tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
		match ip dst $privnet flowid 1:11
done

tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
	match ip protocol 0 0x00 flowid 1:1

iperf -u -c 10.2.2.1 -P 32 -l 50
