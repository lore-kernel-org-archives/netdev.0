From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v4)
Date: Fri, 4 Mar 2011 09:18:59 -0800
Message-ID: <20110304091859.395f2752@nehalam>
References: <20110228171738.2cc8c9a0@nehalam>
	<1299168235.2983.116.camel@edumazet-laptop>
	<20110303084839.3ae312ed@nehalam>
	<1299191333.2547.12.camel@edumazet-laptop>
	<20110303160343.71c55274@nehalam>
	<20110303163016.60f24e8b@nehalam>
	<1299221426.2547.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57509 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab1CDRTB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 12:19:01 -0500
In-Reply-To: <1299221426.2547.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Mar 2011 07:50:26 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 03 mars 2011 =E0 16:30 -0800, Stephen Hemminger a =E9crit :
> > This is an implementation of the Quick Fair Queue scheduler develop=
ed
> > by Fabio Checconi. The same algorithm is already implemented in ipf=
w
> > in FreeBSD. Fabio had an earlier version developed on Linux, I just
> > cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> > finding bugs.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> > v4 - change slots[] to hlist from simple linked list
> >=20
> >  include/linux/pkt_sched.h |   15=20
> >  net/sched/Kconfig         |   11=20
> >  net/sched/Makefile        |    1=20
> >  net/sched/sch_qfq.c       | 1133 +++++++++++++++++++++++++++++++++=
+++++++++++++
> >  4 files changed, 1160 insertions(+)
>=20
> Thanks
>=20
> Still crashing hard here in qfq_reset_qdisc(), when packets are prese=
nt
> in queues.
>=20
> Probably hlist_for_each_entry_safe() is needed, since
> qfq_deactivate_class() is called ...
>=20
> Also rename cl->next to cl->hnode so that following is clearer ?
>=20
> -	hlist_for_each_entry(cl, n, &grp->slots[j], next) {
> +	hlist_for_each_entry_safe(cl, n, next, &grp->slots[j], hnode) {
>=20
> Fabio, any idea why everything is blocked after a few packets for me =
?
>=20
> Here is script to reproduce the problem :
>=20
> # cat qfq_setup.sh
> modprobe dummy
>=20
> ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up
>=20
> for i in `seq 1 16`
> do
>  arp -H ether -i dummy0 -s 10.2.2.$i 00:00:0c:07:ac:$(printf %02x $i)
> done
>=20
> DEV=3Ddummy0
> RATE=3D"rate 40Mbit"
> TNETS=3D"10.2.2.0/25"
> ALLOT=3D"allot 20000"
>=20
> tc qdisc del dev dummy0 root 2>/dev/null
>=20
> tc qdisc add dev $DEV root handle 1: cbq avpkt 1000 rate 1000Mbit \
> 	bandwidth 1000Mbit

QFQ is non work conserving, it may choose to send a smaller packet
ahead of a larger packet in other flow...


--=20
