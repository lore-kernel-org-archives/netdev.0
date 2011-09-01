From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Thu, 1 Sep 2011 02:16:43 +0200
Message-ID: <20110901001643.GB1349731@jupiter.n2.diac24.net>
References: <20110712113643.GC616804@jupiter.n2.diac24.net>
 <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
 <20110715160357.GC1407585@jupiter.n2.diac24.net>
 <20110715163345.GD1407585@jupiter.n2.diac24.net>
 <20110727111714.GA2027462@jupiter.n2.diac24.net>
 <20110728084106.22166324@nehalam.ftrdhcpuser.net>
 <CAEJpZP3PHC32i8m74-ML6DDGii8ojJ6v12CqQ+v2MKEMSDU=7A@mail.gmail.com>
 <20110815112501.3a3c01ad@nehalam.ftrdhcpuser.net>
 <CAEJpZP0riOx=7umYgr3fV4JF31+8Jv8m6DRTkyyuiDnioff4Vw@mail.gmail.com>
 <20110831134904.1a050924@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>, eswierk@bigswitch.com,
	netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52372 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755940Ab1IAAQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 20:16:56 -0400
Content-Disposition: inline
In-Reply-To: <20110831134904.1a050924@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2011 at 01:49:04PM -0700, Stephen Hemminger wrote:
> On Wed, 31 Aug 2011 21:41:26 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
>=20
> > On 15 August 2011 19:25, Stephen Hemminger
> > <shemminger@linux-foundation.org> wrote:
> > > On Mon, 15 Aug 2011 17:27:12 +0100
> > > Nick Carter <ncarter100@gmail.com> wrote:
> > >
> > >> On 28 July 2011 16:41, Stephen Hemminger
> > >> <shemminger@linux-foundation.org> wrote:
> > >> > On Wed, 27 Jul 2011 13:17:15 +0200
> > >> > David Lamparter <equinox@diac24.net> wrote:
> > >> >
> > >> >> On Fri, Jul 15, 2011 at 06:33:45PM +0200, David Lamparter wro=
te:
> > >> >> > On Fri, Jul 15, 2011 at 06:03:57PM +0200, David Lamparter w=
rote:
> > >> >> > > On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wro=
te:
> > >> >> > > > On 12 July 2011 12:36, David Lamparter <equinox@diac24.=
net> wrote:
> > >> >> > > > > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hem=
minger wrote:
> > >> >> > > > >> I am still undecided on this. Understand the need, b=
ut don't like idea
> > >> >> > > > >> of bridge behaving in non-conforming manner. Will se=
e if IEEE 802 committee
> > >> >> > > > >> has any input.
> > >> >> > > > >
> > >> >> > > > > The patch doesn't make the bridge behave nonconforman=
t. The default mask
> > >> >> > > > > is 0, which just keeps the old behaviour.
> > >> >> >
> > >> >> > P.S.: I'd like to once more stress this. In my opinion the =
patch should
> > >> >> > be merged because it provides desireable functionality at a=
 small cost
> > >> >> > (one test, one knob) and __does not change any default beha=
viour__.
> > >> >>
> > >> >> Stephen, anything new on this?
> > >> >
> > >> > No.
> > >> > Don't like adding yet another hack user visible API which will=
 have
> > >> > to be maintained for too long. But on the other hand I don't h=
ave
> > >> > a better solution at my finger tips. If better idea doesn't co=
me
> > >> > along, then we can go with yours.
> > >> >
> > >> I have not noticed any other proposals and this thread has been =
open
> > >> for quite a while. =C2=A0Have we waited long enough ? If so can =
this patch
> > >> be taken ?
> > >>
> > >
> > > I am testing an alternative. The problem with your proposal is th=
at
> > > it relies on the multicast address. It turns out there are people=
 using
> > > other addresses for the STP group address, so using that as a ide=
ntifier
> > > is incorrect.
> > If the chosen STP group address is in the local multicast group ran=
ge
> > this patch will handle it.
> >=20
> > David Lamparter has reviewed this patch and asked for it to be merg=
ed.
> >  This patch has at least two real world uses.  Ed needs this patch =
to
> > forward LLDP frames and I need this patch to forward 802.1X frames.
> >=20
> > This patch has been out for review for 9 weeks and it still looks l=
ike
> > the best solution.
>=20
> I prefer the netfilter solution because it is more general. We alread=
y have
> a firewall solution why shouldn't this case be part of it?

Nick's patch *IS* the netfilter solution. Check where it jumps to:

forward:
	switch (p->state) {
	case BR_STATE_FORWARDING:
		rhook =3D rcu_dereference(br_should_route_hook);
		if (rhook) {
			if ((*rhook)(skb)) {
				*pskb =3D skb;
				return RX_HANDLER_PASS;

This calls ebt_broute, which returns true if the BROUTING chain says
"DROP", which means "don't bridge, deliver on physdev" in this context.

Your patch reinvents the wheel - new ebtables chain - and does not
allow any control without bridge-netfilter in kernel.

Nick's patch allows rudimentary control (enough for most cases i'd say)
when bridge-netfilter is disabled and full same-as-other-multicast
control when bridge-netfilter is enabled/loaded.


-David
