From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sun, 18 Apr 2010 11:39:33 +0200
Message-ID: <1271583573.16881.4798.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53732 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754682Ab0DRJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 05:39:42 -0400
Received: by bwz25 with SMTP id 25so4433564bwz.28
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 02:39:40 -0700 (PDT)
In-Reply-To: <1271525519.3929.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 17 avril 2010 =C3=A0 13:31 -0400, jamal a =C3=A9crit :
> On Sat, 2010-04-17 at 09:35 +0200, Eric Dumazet wrote:
>=20
> > I did some tests on a dual quad core machine (E5450  @ 3.00GHz), no=
t
> > nehalem. So a 3-4 years old design.
>=20
> Eric, I thank you kind sir for going out of your way to do this - it =
is
> certainly a good processor to compare against=20
>=20
> > For all test, I use the best time of 3 runs of "ping -f -q -c 10000=
0
> > 192.168.0.2". Yes ping is not very good, but its available ;)
>=20
> It is a reasonable quick test, no fancy setup required ;->
>=20
> > Note: I make sure all 8 cpus of target are busy, eating cpu cycles =
in
> > user land.=20
>=20
> I didnt keep the cpus busy. I should re-run with such a setup, any
> specific app that you used to keep them busy? Keeping them busy could
> have consequences;  I am speculating you probably ended having greate=
r
> than one packet/IPI ratio i.e amortization benefit..

No, only one packet per IPI, since I setup my tg3 coalescing parameter
to the minimum value, I received one packet per interrupt.

The specific app is :

for f in `seq 1 8`; do while :; do :; done& done


>  =20
> > I dont want to tweak acpi or whatever smart power saving
> > mechanisms.
>=20
> I should mention i turned off acpi as well in the bios; it was consum=
ing
> more cpu cycles than net-processing and was interfering in my tests.
>=20
> > When RPS off
> > 100000 packets transmitted, 100000 received, 0% packet loss, time 4=
160ms
> >=20
> > RPS on, but directed on the cpu0 handling device interrupts (tg3, n=
api)
> > (echo 01 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
> > 100000 packets transmitted, 100000 received, 0% packet loss, time 4=
234ms
> >=20
> > So the cost of queing the packet into our own queue (netif_receive_=
skb
> > -> enqueue_to_backlog) is about 0.74 us  (74 ms / 100000)
> >=20
>=20
> Excellent analysis.
>=20
> > I personally think we should process packet instead of queeing it, =
but
> > Tom disagree with me.
>=20
> Sorry - I am gonna have to turn on some pedagogy and offer my
> Canadian 2 cents;->
> I would lean on agreeing with Tom, but maybe go one step further (san=
s
> packet-reordering): we should never process packets to socket layer o=
n
> the demuxing cpu.
> enqueue everything you receive on a different cpu - so somehow receiv=
ing
> cpu becomes part of a hashing decision ...
>=20
> The reason is derived from queueing theory - of which i know dangerou=
sly
> little - but refer you to mr. little his-self[1] (pun fully
> intended;->):
> i.e fixed serving time provides more predictable results as opposed t=
o
> once in a while a spike as you receive packets destined to "our cpu".
> Queueing packets and later allocating cycles to processing them adds =
to
> variability, but is not as bad as processing to completion to socket
> layer.
>=20
> > RPS on, directed on cpu1 (other socket)
> > (echo 02 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
> > 100000 packets transmitted, 100000 received, 0% packet loss, time 4=
542ms
>=20
> Good test - should be worst case scenario. But there are two other=20
> scenarios which will give different results in my opinion.
> On your setup i think each socket has two dies, each with two cores. =
So
> my feeling is you will get different numbers if you go within same di=
e
> and across dies within same socket. If i am not mistaken, the mapping
> would be something like socket0/die0{core0/2}, socket0/die1{core4/6},
> socket1/die0{core1/3}, socket1{core5/7}.
> If you have cycles can you try the same socket+die but different core=
s
> and same socket but different die test?

Sure, lets redo a full test, taking lowest time of three ping runs


echo 00 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4151m=
s

echo 01 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4254m=
s

echo 02 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4563m=
s

echo 04 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4458m=
s

echo 08 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4563m=
s

echo 10 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4327m=
s

echo 20 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4571m=
s

echo 40 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4472m=
s

echo 80 >/sys/class/net/eth3/queues/rx-0/rps_cpus
100000 packets transmitted, 100000 received, 0% packet loss, time 4568m=
s


# egrep "physical id|core|apicid" /proc/cpuinfo=20
physical id	: 0
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0

physical id	: 1
core id		: 0
cpu cores	: 4
apicid		: 4
initial apicid	: 4

physical id	: 0
core id		: 2
cpu cores	: 4
apicid		: 2
initial apicid	: 2

physical id	: 1
core id		: 2
cpu cores	: 4
apicid		: 6
initial apicid	: 6

physical id	: 0
core id		: 1
cpu cores	: 4
apicid		: 1
initial apicid	: 1

physical id	: 1
core id		: 1
cpu cores	: 4
apicid		: 5
initial apicid	: 5

physical id	: 0
core id		: 3
cpu cores	: 4
apicid		: 3
initial apicid	: 3

physical id	: 1
core id		: 3
cpu cores	: 4
apicid		: 7
initial apicid	: 7



