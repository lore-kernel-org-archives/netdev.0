From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] [PATCH]  bridge: per-cpu packet statistics
Date: Tue, 2 Mar 2010 09:22:09 -0800
Message-ID: <20100302092209.048f5682@nehalam>
References: <20100301161658.5a61143b@nehalam>
	<1267509690.2843.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35844 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391Ab0CBRWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 12:22:20 -0500
In-Reply-To: <1267509690.2843.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Mar 2010 07:01:30 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 01 mars 2010 =C3=A0 16:16 -0800, Stephen Hemminger a =C3=A9c=
rit :
> > The shared packet statistics are a potential source of slow down
> > on bridged traffic. Convert to per-cpu array, but only keep those
> > statistics which change per-packet.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> >=20
> >  net/bridge/br_device.c  |   43 +++++++++++++++++++++++++++++++++++=
+++-----
> >  net/bridge/br_if.c      |    6 ++++++
> >  net/bridge/br_input.c   |    5 +++--
> >  net/bridge/br_private.h |    8 ++++++++
> >  4 files changed, 55 insertions(+), 7 deletions(-)
> >=20
> > --- a/net/bridge/br_device.c	2010-03-01 08:22:23.476657998 -0800
> > +++ b/net/bridge/br_device.c	2010-03-01 15:31:36.737227465 -0800
> > @@ -26,11 +26,12 @@ netdev_tx_t br_dev_xmit(struct sk_buff *
> >  	const unsigned char *dest =3D skb->data;
> >  	struct net_bridge_fdb_entry *dst;
> >  	struct net_bridge_mdb_entry *mdst;
> > +	struct br_cpu_netstats *brstats =3D this_cpu_ptr(br->stats);
> > =20
> > -	BR_INPUT_SKB_CB(skb)->brdev =3D dev;
> > +	brstats->tx_packets++;
> > +	brstats->tx_bytes +=3D skb->len;
>=20
>=20
> On TX path, this is not really necessary, since we already dirtied
> txq->lock before calling br_dev_xmit(), we can use txq->tx_packets an=
d
> txq->tx_bytes for free ?

Bridge is already using lockless transmit LLTX, so tx_lock is not touch=
ed.
