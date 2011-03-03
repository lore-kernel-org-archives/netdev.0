From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 10:35:11 +0100
Message-ID: <1299144911.2983.19.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>  <4D6E8997.4010001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Fabio Checconi <fchecconi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53360 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877Ab1CCJfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 04:35:16 -0500
Received: by bwz15 with SMTP id 15so973553bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 01:35:15 -0800 (PST)
In-Reply-To: <4D6E8997.4010001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 19:16 +0100, Patrick McHardy a =C3=A9cr=
it :
> Am 02.03.2011 18:31, schrieb Eric Dumazet:
> > Le mercredi 02 mars 2011 =C3=A0 17:18 +0100, Eric Dumazet a =C3=A9c=
rit :
> >> Le mercredi 02 mars 2011 =C3=A0 08:11 -0800, Stephen Hemminger a =C3=
=A9crit :
> >>
> >>> I put the iproute2 code into the repository in the experimental b=
ranch.
> >>>
> >>
> >> Thanks
> >>
> >> It seems as soon as packets are dropped, qdisc is frozen (no more
> >> packets dequeued)
> >>
> >> Hmm...
> >>
> >=20
> > It seems class deletes are buggy.
> >=20
> > After one "tc class del dev $ETH classid 11:1 ..."
> >=20
> > a "tc -s -d qdisc show dev $ETH" triggers an Oops
>=20
> What classes and filters did you have before issuing that command?

(Fabio found the origin of the problem in qfq_destroy_class())

Here is the script I wrote to use QFQ on dummy0 device
(I then use a normal udpflood workload to stress the thing)

More or less copied from other stuff I had, so its probably very
stupid ;)

# cat egress_dummy0.sh
ETH=3Ddummy0
RATE=3D"rate 40Mbit"
PRIVNETS=3D"172.16.0.0/12 192.168.0.0/16 10.0.0.0/8"
ALLOT=3D"allot 20000"


ethtool -K $ETH tso off

tc qdisc del dev $ETH root 2>/dev/null


tc qdisc add dev $ETH root handle 1: cbq avpkt 1000 rate 1000Mbit \
	bandwidth 1000Mbit
tc class add dev $ETH parent 1: classid 1:1 \
	est 1sec 8sec cbq allot 10000 mpu 64 \
	rate 1000Mbit prio 1 avpkt 1500 bounded

# output to private nets :  40 Mbit limit
tc class add dev $ETH parent 1:1 classid 1:11 \
	est 1sec 8sec cbq $ALLOT mpu 64      \
	$RATE prio 2 avpkt 1400 bounded

tc qdisc add dev $ETH parent 1:11 handle 11:  \
	est 1sec 8sec qfq

tc filter add dev $ETH protocol ip parent 11: handle 3 \
	flow hash keys rxhash divisor 16

tc class add dev $ETH classid 11:1 est 0.5sec 2sec qfq weight 100 maxpk=
t 1100
tc class add dev $ETH classid 11:2 est 0.5sec 2sec qfq weight 200 maxpk=
t 1200
tc class add dev $ETH classid 11:3 est 0.5sec 2sec qfq weight 300 maxpk=
t 1300
tc class add dev $ETH classid 11:4 est 0.5sec 2sec qfq weight 400 maxpk=
t 1400
tc class add dev $ETH classid 11:5 est 0.5sec 2sec qfq weight 500 maxpk=
t 1500
tc class add dev $ETH classid 11:6 est 0.5sec 2sec qfq weight 600 maxpk=
t 1600
tc class add dev $ETH classid 11:7 est 0.5sec 2sec qfq weight 700 maxpk=
t 1700
tc class add dev $ETH classid 11:8 est 0.5sec 2sec qfq weight 800 maxpk=
t 1800
tc class add dev $ETH classid 11:9 est 0.5sec 2sec qfq weight 900 maxpk=
t 1900
tc class add dev $ETH classid 11:a est 0.5sec 2sec qfq weight 1000 maxp=
kt 2000
tc class add dev $ETH classid 11:b est 0.5sec 2sec qfq weight 1100 maxp=
kt 2048
tc class add dev $ETH classid 11:c est 0.5sec 2sec qfq weight 1200 maxp=
kt 2048
tc class add dev $ETH classid 11:d est 0.5sec 2sec qfq weight 1300 maxp=
kt 2048
tc class add dev $ETH classid 11:e est 0.5sec 2sec qfq weight 1400 maxp=
kt 2048
tc class add dev $ETH classid 11:f est 0.5sec 2sec qfq weight 1500 maxp=
kt 2048
tc class add dev $ETH classid 11:10 est 0.5sec 2sec qfq weight 1600 max=
pkt 2048


for privnet in $PRIVNETS
do
	tc filter add dev $ETH parent 1: protocol ip prio 100 u32 \
		match ip dst $privnet flowid 1:11
done

tc filter add dev $ETH parent 1: protocol ip prio 100 u32 \
	match ip protocol 0 0x00 flowid 1:1



