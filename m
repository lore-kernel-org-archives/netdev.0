From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 05:44:03 +0200
Message-ID: <1309837443.2720.8.camel@edumazet-laptop>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	 <20110704130531.37cf876e@Nokia-N900>
	 <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110704162726.4072e715@maggie> <20110704164351.338dc12e@maggie>
	 <1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
	 <CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45139 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab1GEDoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 23:44:12 -0400
Received: by wwe5 with SMTP id 5so5523140wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 20:44:10 -0700 (PDT)
In-Reply-To: <CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 02:29 +0400, Alexey Zaytsev a =C3=A9cri=
t :
> On Tue, Jul 5, 2011 at 00:25, Alexey Zaytsev <alexey.zaytsev@gmail.co=
m> wrote:
> > On Mon, Jul 4, 2011 at 19:12, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >> Le lundi 04 juillet 2011 =C3=A0 16:43 +0200, Michael B=C3=BCsch a =
=C3=A9crit :
> >>> On Mon, 4 Jul 2011 16:27:26 +0200
> >>> Michael B=C3=BCsch <m@bues.ch> wrote:
> >>> > We do this in b43, which has exactly the same DMA engine.
> >>>
> >>> (Ok, it turns out we don't do this in b43 (We only do it on the T=
X side).
> >>>  But that's a bug. We should do a wmb() on the RX side before adv=
ancing the
> >>>  descriptor ring pointer.)
> >>
> >> I am wondering what happens if RX ring is set to 64, and we receiv=
e
> >> exactly 64 buffers in one round, B44_DMARX_PTR wont change at all =
?
> >>
> >> Alexey, could you try this patch please ?
> >
> > Sorry, did not help.
> >
>=20
> Ran a few rounds of tcpdump. Seeing a significant number or duplicate
> ACKs from the problematic machine. Not seeing them when testing
> between this machine and an other linux box. Or the illumos machine
> and the other linux box.
>=20
> Dumps are available here:
>=20
> http://zaytsev.su/tmp/caps/
>=20
> dump1-3 - between the problematic machine an the illumos box,
> collected on illumos side. All show dups.
> dump5 - between an other linux box and the illumos machine, no dups.
> Collcted on the illumos side.
> dump-linux - between 2 linux machines, collected on the
> non-problematic side. No dups, no corruptions.
>=20
> 192.168.0.33 - the problematic machine.
> 192.168.0.72 - the illumos machine.
> 192.168.0.122 - an other linux machine.

??

I dont care about duplicate acks at this point.

Thats a separate issue (TCP layer)

Do you still have memory scribbles ?

I wonder if the problem is not coming from the "fast recovery" added in
commit 32737e934a952c (PATCH: b44 Handle RX FIFO overflow better
(simplified))

Maybe we should do instead a fast dequeue of packets (recycling them
instead of pushing them to upper stack) in case too many packets are
ready to be delivered, and always make sure NIC has a reserve of
available buffers for DMA accesses, before it can assert ISTAT_RFO



