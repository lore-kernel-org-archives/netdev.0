From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v4)
Date: Fri, 04 Mar 2011 07:50:26 +0100
Message-ID: <1299221426.2547.47.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <1299168235.2983.116.camel@edumazet-laptop>
	 <20110303084839.3ae312ed@nehalam>
	 <1299191333.2547.12.camel@edumazet-laptop>
	 <20110303160343.71c55274@nehalam>  <20110303163016.60f24e8b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48526 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab1CDGud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 01:50:33 -0500
Received: by wwb22 with SMTP id 22so2346665wwb.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 22:50:31 -0800 (PST)
In-Reply-To: <20110303163016.60f24e8b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 16:30 -0800, Stephen Hemminger a =C3=A9cri=
t :
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> finding bugs.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v4 - change slots[] to hlist from simple linked list
>=20
>  include/linux/pkt_sched.h |   15=20
>  net/sched/Kconfig         |   11=20
>  net/sched/Makefile        |    1=20
>  net/sched/sch_qfq.c       | 1133 +++++++++++++++++++++++++++++++++++=
+++++++++++
>  4 files changed, 1160 insertions(+)

Thanks

Still crashing hard here in qfq_reset_qdisc(), when packets are present
in queues.

Probably hlist_for_each_entry_safe() is needed, since
qfq_deactivate_class() is called ...

Also rename cl->next to cl->hnode so that following is clearer ?

-	hlist_for_each_entry(cl, n, &grp->slots[j], next) {
+	hlist_for_each_entry_safe(cl, n, next, &grp->slots[j], hnode) {

=46abio, any idea why everything is blocked after a few packets for me =
?

Here is script to reproduce the problem :

# cat qfq_setup.sh
modprobe dummy

ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up

for i in `seq 1 16`
do
 arp -H ether -i dummy0 -s 10.2.2.$i 00:00:0c:07:ac:$(printf %02x $i)
done

DEV=3Ddummy0
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


-----------------------------------------------------------------------=
-------

After a run I get only 5 packets sent, 240 queued in backlog, and all
other packets dropped.

# tc -s -d qdisc show dev dummy0
qdisc cbq 1: root refcnt 2 rate 1000Mbit cell 8b (bounded,isolated) pri=
o
no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 460 bytes 5 pkt (dropped 198800, overlimits 199043 requeues 0)=20
 backlog 0b 240p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
qdisc qfq 11: parent 1:11=20
 Sent 460 bytes 5 pkt (dropped 198800, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 0b 240p requeues 0=20
qdisc pfifo 8011: parent 11:1 limit 30p
 Sent 0 bytes 0 pkt (dropped 6178, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8012: parent 11:2 limit 30p
 Sent 92 bytes 1 pkt (dropped 37048, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8013: parent 11:3 limit 30p
 Sent 0 bytes 0 pkt (dropped 24856, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8014: parent 11:4 limit 30p
 Sent 276 bytes 3 pkt (dropped 37358, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8015: parent 11:5 limit 30p
 Sent 0 bytes 0 pkt (dropped 24934, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8016: parent 11:6 limit 30p
 Sent 0 bytes 0 pkt (dropped 24882, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8017: parent 11:7 limit 30p
 Sent 0 bytes 0 pkt (dropped 12328, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
qdisc pfifo 8018: parent 11:8 limit 30p
 Sent 92 bytes 1 pkt (dropped 31216, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20


and :

# tc -s -d class show dev dummy0
class cbq 1:11 parent 1:1 leaf 11: rate 40000Kbit cell 128b mpu 64b
(bounded) prio 2/2 weight 40000Kbit allot 20000b=20
level 0 ewma 5 avpkt 1400b maxidle 0us=20
 Sent 460 bytes 5 pkt (dropped 198800, overlimits 15 requeues 0)=20
 rate 0bit 0pps backlog 0b 240p requeues 0=20
  borrowed 0 overactions 3 avgidle -225 undertime -6.46702e+07
class cbq 1: root rate 1000Mbit cell 8b (bounded,isolated) prio
no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 460 bytes 5 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
class cbq 1:1 parent 1: rate 1000Mbit cell 64b mpu 64b (bounded) prio
1/1 weight 1000Mbit allot 10000b=20
level 1 ewma 5 avpkt 1500b maxidle 0us=20
 Sent 460 bytes 5 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 0b 0p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
class qfq 11:1 root leaf 8011: weight 1 maxpkt 2048=20
 Sent 2760 bytes 30 pkt (dropped 6178, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:2 root leaf 8012: weight 1 maxpkt 2048=20
 Sent 2852 bytes 31 pkt (dropped 37048, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:3 root leaf 8013: weight 1 maxpkt 2048=20
 Sent 2760 bytes 30 pkt (dropped 24856, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:4 root leaf 8014: weight 1 maxpkt 2048=20
 Sent 3036 bytes 33 pkt (dropped 37358, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:5 root leaf 8015: weight 1 maxpkt 2048=20
 Sent 2760 bytes 30 pkt (dropped 24934, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:6 root leaf 8016: weight 1 maxpkt 2048=20
 Sent 2760 bytes 30 pkt (dropped 24882, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:7 root leaf 8017: weight 1 maxpkt 2048=20
 Sent 2760 bytes 30 pkt (dropped 12328, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20
class qfq 11:8 root leaf 8018: weight 1 maxpkt 2048=20
 Sent 2852 bytes 31 pkt (dropped 31216, overlimits 0 requeues 0)=20
 backlog 2760b 30p requeues 0=20




Then this crashes :

# tc qdisc del dev dummy0 root




