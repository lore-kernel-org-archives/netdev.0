From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 10:14:24 -0700
Message-ID: <20100828101424.69c4c782@s6510>
References: <20100827205042.GA13844@del.dom.local>
	<20100828001337.GA1955@gondor.apana.org.au>
	<20100828094433.GA3110@del.dom.local>
	<1282992846.2277.15.camel@edumazet-laptop>
	<20100828143132.GA3211@del.dom.local>
	<1283006909.2277.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55535 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab0H1RO2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 13:14:28 -0400
In-Reply-To: <1283006909.2277.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Aug 2010 16:48:29 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le samedi 28 ao=FBt 2010 =E0 16:31 +0200, Jarek Poplawski a =E9crit :
> > On Sat, Aug 28, 2010 at 12:54:06PM +0200, Eric Dumazet wrote:
> > > In commit f2bde7328633269ee935d9ed96535ade15cc348f
> > > Author: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> > >     net: allow multiple dev per napi with GRO
> > >    =20
> > >     GRO assumes that there is a one-to-one relationship between N=
API
> > >     structure and network device. Some devices like sky2 share mu=
ltiple
> > >     devices on a single interrupt so only have one NAPI handler. =
Rather than
> > >     split GRO from NAPI, just have GRO assume if device changes t=
hat
> > >     it is a different flow.
> > >   =20
> > >=20
> > > It was assumed a napi could be shared by several devs, but I dont=
 really
> > > understand, since we have an unique ->dev pointer inside "napi_st=
ruct",
> > > this one is set once, and never change.
> > >=20
> > > This pointer is currently used from napi_get_frags() [but that co=
uld be
> > > avoided], and from netpoll_poll_lock().
> > >=20
> > > The netpoll_poll_lock() case is problematic.
> > >=20
> > > static inline void *netpoll_poll_lock(struct napi_struct *napi)
> > > {
> > >         struct net_device *dev =3D napi->_dev;
> > >=20
> > >         if (dev && dev->npinfo) {
> > >                 spin_lock(&napi->poll_lock);
> > >=20
> > > Maybe we should remove 'dev' field from napi_struct and replace i=
t by a
> > > npinfo pointer ?
> >=20
> > Sky2 seems to work like a single netdev (with an internal sub-netde=
v),
> > so I can't see your concern: what is the main aim of this replaceme=
nt?
>=20
> I am trying to understand why this commit was needed then.
>=20
> It adds an extra test in the main loop, testing skb->dev against p->d=
ev,
> it must me for something...
>=20
> I am trying to say that the one to one relationship between NAPI
> structure and a device is not only a GRO thing, but also a netpoll on=
e.
>=20
> So either we completely remove this one to one relationship, either
> Stephen commit was not needed.
>=20
> Some clarification is needed.
>=20
>=20

The Marvell Yukon2 hardware supports two interfaces sharing a common in=
terrupt.
Therfore the sky2 driver has up to two net devices and a single NAPI pe=
r board.
It is possible in a single invocation of the poll loop to process frame=
s
for both ports.  GRO works by combining received packets from identical
flows over one NAPI interval. It is possible on sky2 that one packet
could be processed for the first port, and the next packet processed wa=
s for
second port and the two packets were related so that GRO would combine =
them.
The check for the same dev is required to prevent this. Yes it is an un=
likely
corner case, but the purpose of GRO is to do aggregation but preserve t=
he
flow characteristics of the incoming traffic.
