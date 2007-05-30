From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH-2.4] Fix divide by 0 in vegas_cong_avoid()
Date: Wed, 30 May 2007 09:34:47 -0700
Message-ID: <20070530093447.35300699@freepuppy>
References: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
	<20070529080534.5692bad8@freepuppy>
	<a5bf86a80705291123r7aa753besbcb1de3f13dc1b3c@mail.gmail.com>
	<20070529150216.712e422b@freepuppy>
	<Pine.LNX.4.64.0705301010300.25173@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lior Dotan <liodot@gmail.com>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:57557 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812AbXE3QqS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:46:18 -0400
In-Reply-To: <Pine.LNX.4.64.0705301010300.25173@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 10:49:54 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Tue, 29 May 2007, Stephen Hemminger wrote:
>=20
> > On Tue, 29 May 2007 20:23:45 +0200
> > "Lior Dotan" <liodot@gmail.com> wrote:
> >=20
> > > NTP was not running. I'm not sure what do you mean by fixing the =
-1.
> > > The trace shows that vegas_cong_avoid() is called with -1, and th=
e
> > > only way it can happen is from tcp_clean_rtx_queue() and the patc=
h
> > > should eliminate this. Another way of solving this is by checking
> > > vegas_rtt_calc() and see if it gets -1 and handle it there.
> > > Another thing that I don't understand is that some places like
> > > tcp_ack() declare seq_rtt as signed and some vegas_cong_avoid()
> > > declare it as unsigned. Shouldn't it be declared always as signed=
?
> > >=20
> > > On 5/29/07, Stephen Hemminger <shemminger@linux-foundation.org> w=
rote:
> > > > On Tue, 29 May 2007 12:18:19 +0300
> > > > "Lior Dotan" <liodot@gmail.com> wrote:
> > > >
> > > > > Hi,
> > > > >
> > > > > I had a divide by zero on kernel 2.4.33 running with Vegas en=
abled.
> >=20
> > I don't think anyone has backported the other vegas fixes from 2.6.=
21
> > to 2.4.
> >=20
> >=20
> > For 2.6.22, rtt_calc doesn't exist, instead pkts_acked is called.
>=20
> I tried to figure this one out yesterday, and it seems to me that div=
ide=20
> by zero should not occur with 2.6.22 (nor with 2.6.21 code), no matte=
r
> how I try to approach vegas...
>=20
> > The following should be added to avoid getting bogus timestamp valu=
es=20
> > from retransmits.
>=20
> ...but this is unreliable timestamps problem is a real one that origi=
nates=20
> from API merge commit 164891aadf1721fca4dce473bb0e0998181537c6 of you=
rs=20
> (see some though about it below). I suppose there are now similar con=
cerns=20
> about timestamp validity in other cc modules than vegas too.
>=20
> > --- a/net/ipv4/tcp_vegas.c	2007-05-02 12:26:35.000000000 -0700
> > +++ b/net/ipv4/tcp_vegas.c	2007-05-29 14:06:26.000000000 -0700
> > @@ -117,6 +117,10 @@ void tcp_vegas_pkts_acked(struct sock *s
> >  	struct vegas *vegas =3D inet_csk_ca(sk);
> >  	u32 vrtt;
> > =20
> > +	/* Ignore retransmits */
> > +	if (unlikely(cnt =3D=3D 0))
> > +		return;
> > +
> >  	/* Never allow zero rtt or baseRTT */
> >  	vrtt =3D ktime_to_us(net_timedelta(last)) + 1;
>=20
> ...I don't think this works, because cnt won't be zero ever because t=
o=20
> make the call some skbs were cleaned from the queue (isn't that what=20
> pkts_acked stands for?). There is as if (acked&FLAG_ACKED) guard befo=
re=20
> making the pkts_acked call to cc modules, thus delta in packets_out w=
ill=20
> always be greater than 0. Hmm, now that I realize this, I would say t=
hat
> checks for > 0 in pkts_acked are entirely bogus (in the current code)=
,=20
> hmm, that means I have more things to cleanup in tcp-2.6, at least, b=
ic,=20
> cubic and westwood do them... :-).
>=20
> I think the code did a right thing before your api merge, since it ca=
lled=20
> rtt callback only if FLAG_RETRANS_DATA_ACKED was not set (and pkts_ac=
ked=20
> always), i.e., when TCP cannot know if it was the rexmission that=20
> triggered the cumulative ACK or any original transmission, no new RTT=
=20
> measurement should be made. Consider also the fact that, there might =
be a=20
> non rexmitted skb after rexmitted one, which Lior's patch doesn't do=20
> right way at all since the FLAG_DATA_ACKED would again get set (no=20
> div-by-zero would have occured then but an unreliable timestamp would
> have been givento vegas in 2.4).
>=20
> The number of packets that got cumulatively acked is never a right me=
tric=20
> to measure whether the cumulative ACK originated from rexmitted skbs =
or=20
> not. ...Perhaps the FLAG_RETRANS_DATA_ACKED flag needs to be passed=20
> somehow to cc modules?
>=20
>=20

What about the mixed case where some retransmitted data and new
data was covered by one ack.  I would rather keep the merge, but think
about the cases more carefully.

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
