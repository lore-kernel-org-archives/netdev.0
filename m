From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: fix THROTTLED/RUNNING race
Date: Thu, 24 Mar 2011 07:53:57 +0100
Message-ID: <1300949637.2810.75.camel@edumazet-laptop>
References: <1299087087.2920.27.camel@edumazet-laptop>
	 <1299140868.2456.35.camel@edumazet-laptop>
	 <1299148820.2983.56.camel@edumazet-laptop>
	 <1299165497.2983.104.camel@edumazet-laptop>
	 <20110303161912.GC29685@gandalf.sssup.it>
	 <1299170053.2983.134.camel@edumazet-laptop>
	 <20110303181339.GD29685@gandalf.sssup.it>
	 <1299180567.2547.4.camel@edumazet-laptop>
	 <1299192974.2547.13.camel@edumazet-laptop>
	 <20110304064302.GE29685@gandalf.sssup.it>
	 <1299222074.2547.50.camel@edumazet-laptop>
	 <AANLkTinAGjZ5SAOA1iUAFu5rtYydeb6Soy_Xg5kMvn-z@mail.gmail.com>
	 <1299274468.2758.4.camel@edumazet-laptop>
	 <AANLkTikeQCfShKfZWq2Y7V_MA4iRjQvWWtkC68rK9nUm@mail.gmail.com>
	 <1299277003.2758.52.camel@edumazet-laptop>
	 <AANLkTinR7QDC2uGjQurJQ1JfBA7q1pxyewePggh87z8E@mail.gmail.com>
	 <1299278778.2758.53.camel@edumazet-laptop>
	 <AANLkTikBoQd+ZA1kY0F0MvUsJ8Y=9KwGkfmZNdi4hLXz@mail.gmail.com>
	 <20110304150741.5d4aa354@nehalam>
	 <AANLkTi=HBDayfd0bEA+AQqzjTKMajghet=UJAw9vL56A@mail.gmail.com>
	 <20110309110242.3307ca69@nehalam>
	 <1300016057.2761.16.camel@edumazet-laptop>
	 <1300034690.2761.29.camel@edumazet-laptop>
	 <1300862758.2717.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Checconi <fchecconi@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60829 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932845Ab1CXGyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 02:54:03 -0400
Received: by fxm17 with SMTP id 17so8086352fxm.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 23:54:02 -0700 (PDT)
In-Reply-To: <1300862758.2717.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 mars 2011 =C3=A0 07:45 +0100, Eric Dumazet a =C3=A9crit =
:

> While polishing QFQ scheduler, and tracking a bug in it, I finally
> replaced in my tc scripts "QFQ experimental" by "SFQ rock solid" and
> found I could have a hang in some situations :(
>=20
> I made a bisection and found :
>=20
> # git bisect good
> 7a6362800cb7d1d618a697a650c7aaed3eb39320 is the first bad commit
>=20
> It seems I am stuck...
>=20
> # git bisect log
> git bisect start
> # bad: [c360d5b53a7fec44ae4402e1f13fc888f57ddc3b] Merge branch 'maste=
r'
> of git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
> git bisect bad c360d5b53a7fec44ae4402e1f13fc888f57ddc3b
> # good: [07a2039b8eb0af4ff464efd3dfd95de5c02648c6] Linux 2.6.30
> git bisect good 07a2039b8eb0af4ff464efd3dfd95de5c02648c6
> # good: [2ec8c6bb5d8f3a62a79f463525054bae1e3d4487] Merge branch 'mast=
er'
> of /home/davem/src/GIT/linux-2.6/
> git bisect good 2ec8c6bb5d8f3a62a79f463525054bae1e3d4487
> # good: [e0e170bd7ded2ec16e2813d63c0faff43193fde8] Merge branch 'next=
'
> of git://git.monstr.eu/linux-2.6-microblaze
> git bisect good e0e170bd7ded2ec16e2813d63c0faff43193fde8
> # good: [40c73abbb37e399eba274fe49e520ffa3dd65bdb] Merge branch
> 'for_linus' of
> git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs-2.6
> git bisect good 40c73abbb37e399eba274fe49e520ffa3dd65bdb
> # good: [4b66fef9b591b95f447aea12242a1133deb0bd22] mcast: net_device =
dev
> not used
> git bisect good 4b66fef9b591b95f447aea12242a1133deb0bd22
> # bad: [7a6362800cb7d1d618a697a650c7aaed3eb39320] Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
> git bisect bad 7a6362800cb7d1d618a697a650c7aaed3eb39320
> # good: [971f115a50afbe409825c9f3399d5a3b9aca4381] Merge branch
> 'usb-next' of
> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
> git bisect good 971f115a50afbe409825c9f3399d5a3b9aca4381
> # good: [5917def58ab9f5848f2d1da835a33a490d0c8c69] staging/easycap:
> reduce code nesting in easycap_sound.c
> git bisect good 5917def58ab9f5848f2d1da835a33a490d0c8c69
> # good: [6445ced8670f37cfc2c5e24a9de9b413dbfc788d] Merge branch
> 'staging-next' of
> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6
> git bisect good 6445ced8670f37cfc2c5e24a9de9b413dbfc788d
> # good: [da91981bee8de20bcd06ee0dbddd53d62d23b1bd] ipv4: Use flowi4 i=
n
> ipmr code.
> git bisect good da91981bee8de20bcd06ee0dbddd53d62d23b1bd
> # good: [106af2c99a5249b809aaed45b8353ac087821f4a] Merge branch 'mast=
er'
> of
> git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6
> into for-davem
> git bisect good 106af2c99a5249b809aaed45b8353ac087821f4a
> # good: [638be344593b66ccca6802c6076a5b3d9200829d] Phonet: fix
> aligned-mode pipe socket buffer header reserve
> git bisect good 638be344593b66ccca6802c6076a5b3d9200829d
> # good: [c337ffb68e1e71bad069b14d2246fa1e0c31699c] Merge branch 'mast=
er'
> of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
> git bisect good c337ffb68e1e71bad069b14d2246fa1e0c31699c
> # good: [ee0caa79569a9c44febc18480beef4847aa8cecd] Merge branch 'mast=
er'
> of git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6
> git bisect good ee0caa79569a9c44febc18480beef4847aa8cecd
> # good: [0bd80dad57d82676ee484fb1f9aa4c5e8b5bc469] net: get rid of
> multiple bond-related netdevice->priv_flags
> git bisect good 0bd80dad57d82676ee484fb1f9aa4c5e8b5bc469
> # good: [8a4eb5734e8d1dc60a8c28576bbbdfdcc643626d] net: introduce
> rx_handler results and logic around that
> git bisect good 8a4eb5734e8d1dc60a8c28576bbbdfdcc643626d
> # good: [ceda86a108671294052cbf51660097b6534672f5] bonding: enable
> netpoll without checking link status
> git bisect good ceda86a108671294052cbf51660097b6534672f5
>=20
> Any idea how we can find the problem ?
>=20
> Script to reproduce the problem :
>=20
>=20
> modprobe dummy
>=20
> ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up
>=20
> for i in `seq 1 240`
> do
>  arp -H ether -i dummy0 -s 10.2.2.$i 00:00:0c:07:ac:$(printf %02x $i)
> done
>=20
>=20
> DEV=3Ddummy0
> RATE=3D"rate 40Mbit"
> TNETS=3D"10.2.2.0/25"
> ALLOT=3D"allot 20000"
>=20
>=20
> tc qdisc del dev dummy0 root 2>/dev/null
>=20
>=20
> tc qdisc add dev $DEV root handle 1: est 1sec 8sec cbq avpkt 1000 rat=
e 100Mbit \
> 	bandwidth 100Mbit
> tc class add dev $DEV parent 1: classid 1:1 \
> 	est 1sec 8sec cbq allot 10000 mpu 64 \
> 	rate 100Mbit prio 1 avpkt 1500 bounded
>=20
> # output to test nets :  40 Mbit limit
> tc class add dev $DEV parent 1:1 classid 1:11 \
> 	est 1sec 8sec cbq $ALLOT mpu 64      \
> 	$RATE prio 2 avpkt 1400 bounded
>=20
> tc qdisc add dev $DEV parent 1:11 handle 11:  \
> 	est 1sec 8sec sfq
>=20
>=20
> for privnet in $TNETS
> do
> 	tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
> 		match ip dst $privnet flowid 1:11
> done
>=20
> tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
> 	match ip protocol 0 0x00 flowid 1:1
>=20
>=20
> iperf -u -c 10.2.2.1 -P 32 -l 50
> iperf -u -c 10.2.2.1 -P 32 -l 50
> iperf -u -c 10.2.2.1 -P 32 -l 50
> tc -s -d qdisc show dev dummy0
>=20

Okay... this bug was hard to find.

David, would you be OK if we send QFQ patch for 2.6.39 ?

I know its a bit late but its a new qdisc, very well tested now, just
tell us :)

Thanks

[PATCH] net_sched: fix THROTTLED/RUNNING race

commit fd245a4adb52 (net_sched: move TCQ_F_THROTTLED flag)
added a race.

qdisc_watchdog() is run from softirq, so special care should be taken o=
r
we can lose one state transition (THROTTLED/RUNNING)

Prior to fd245a4adb52, we were manipulating q->flags (qdisc->flags &=3D
~TCQ_F_THROTTLED;) and this manipulation could only race with
qdisc_warn_nonwc().

Since we want to avoid atomic ops in qdisc fast path - it was the
meaning of commit 371121057607e (QDISC_STATE_RUNNING dont need atomic
bit ops) - fix is to move THROTTLE bit into 'state' field, this one
being manipulated with SMP and IRQ safe operations.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Fabio Checconi <fchecconi@gmail.com>
---
 include/net/sch_generic.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a9505b6..b931f02 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -25,6 +25,7 @@ struct qdisc_rate_table {
 enum qdisc_state_t {
 	__QDISC_STATE_SCHED,
 	__QDISC_STATE_DEACTIVATED,
+	__QDISC_STATE_THROTTLED,
 };
=20
 /*
@@ -32,7 +33,6 @@ enum qdisc_state_t {
  */
 enum qdisc___state_t {
 	__QDISC___STATE_RUNNING =3D 1,
-	__QDISC___STATE_THROTTLED =3D 2,
 };
=20
 struct qdisc_size_table {
@@ -106,17 +106,17 @@ static inline void qdisc_run_end(struct Qdisc *qd=
isc)
=20
 static inline bool qdisc_is_throttled(const struct Qdisc *qdisc)
 {
-	return (qdisc->__state & __QDISC___STATE_THROTTLED) ? true : false;
+	return test_bit(__QDISC_STATE_THROTTLED, &qdisc->state) ? true : fals=
e;
 }
=20
 static inline void qdisc_throttled(struct Qdisc *qdisc)
 {
-	qdisc->__state |=3D __QDISC___STATE_THROTTLED;
+	set_bit(__QDISC_STATE_THROTTLED, &qdisc->state);
 }
=20
 static inline void qdisc_unthrottled(struct Qdisc *qdisc)
 {
-	qdisc->__state &=3D ~__QDISC___STATE_THROTTLED;
+	clear_bit(__QDISC_STATE_THROTTLED, &qdisc->state);
 }
=20
 struct Qdisc_class_ops {


