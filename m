From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 19:53:52 +0200
Message-ID: <20090518175352.GB2755@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:52552 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbZERRz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 13:55:27 -0400
Received: by bwz22 with SMTP id 22so3358915bwz.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 10:55:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 05:54:18PM +0100, Antonio Almeida wrote:
> I'm not sure if I'm able to test this patch. What do you mean with
> "smallest sizes"? Are you talking about packet's size? What kind of
> sizes?
> When I feed my bridge with 950Mbits/s of packets with 800 bytes that
> is close to 150.000pps and CPUs start to get busy. For packets 100
> bytes long, 150.000pps would be close to 125Mbits/s and CPUs start to
> get busy already, so I'm not able to get close to 500Mbits/s. For
> rates near 125bits/s the bad accuracy is not so expressive. For
> packets of 100 bytes increasing analyser sent traffic, at some point
> is not HTB shaping but the CPU that can't process so many packets. I
> might misunderstood your point.
>=20
> I applied this tc_core.c patch and for packets of 800 bytes it had no
> effect in HTB accuracy with rates over 500Mbit.
> Anyway I also test it with packets of 100 bytes, generating 200Mbits,
> and the result is the same as without this patch:

You're right: if there were only 800 byte packets this patch shouldn't
matter. It should matter e.g. if these 800 byte were mixed with 100
byte packets, rate 550Mbit, and HZ 1000. Btw. if could you send your
=2Econfig (gzipped)? I guess, I've to look for some other reason yet.

Thanks,
Jarek P.

>=20
> With the patch:
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 100000Kbit ceil 100000Kbit burst 14087b/8 mpu 0b overhead 0b cburst
> 14087b/8 mpu 0b overhead 0b level 0
>  Sent 2187884640 bytes 22790465 pkt (dropped 8624566, overlimits 0 re=
queues 0)
>  rate 124946Kbit 162691pps backlog 0b 0p requeues 0
>  lended: 22790465 borrowed: 0 giants: 0
>  tokens: 180 ctokens: 180
>=20
>=20
> Without the patch:
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 100000Kbit ceil 100000Kbit burst 14087b/8 mpu 0b overhead 0b cburst
> 14087b/8 mpu 0b overhead 0b level 0
>  Sent 1260235680 bytes 13127455 pkt (dropped 4531299, overlimits 0 re=
queues 0)
>  rate 124575Kbit 162207pps backlog 0b 0p requeues 0
>  lended: 13127455 borrowed: 0 giants: 0
>  tokens: 123 ctokens: 123
>=20
>=20
> Thanks
>   Antonio Almeida
>=20
>=20
> On Mon, May 18, 2009 at 7:56 AM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
> > Return non-zero tc_calc_xmittime() for rate tables
> >
> > While looking at the problem of HTB accuracy for high speed (~500Mb=
it
> > rates) I've found that rate tables have cells filled with zeros for
> > the smallest sizes. It means such packets aren't accounted at all.
> > Apart from the correctness of such configs, let's make it safe with
> > rather overaccounting than living it unlimited.
> >
> > Reported-by: Antonio Almeida <vexwek@gmail.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > ---
> >
> > =A0tc/tc_core.c | =A0 =A04 +++-
> > =A01 files changed, 3 insertions(+), 1 deletions(-)
> >
> > diff --git a/tc/tc_core.c b/tc/tc_core.c
> > index 9a0ff39..14f25bc 100644
> > --- a/tc/tc_core.c
> > +++ b/tc/tc_core.c
> > @@ -58,7 +58,9 @@ unsigned tc_core_ktime2time(unsigned ktime)
> >
> > =A0unsigned tc_calc_xmittime(unsigned rate, unsigned size)
> > =A0{
> > - =A0 =A0 =A0 return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)=
size/rate));
> > + =A0 =A0 =A0 unsigned t;
> > + =A0 =A0 =A0 t =3D tc_core_time2tick(TIME_UNITS_PER_SEC*((double)s=
ize/rate));
> > + =A0 =A0 =A0 return t ? : 1;
> > =A0}
> >
> > =A0unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
> >
