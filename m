From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netdev: handle setting transmit queue length on active
 device.
Date: Wed, 18 Mar 2009 11:00:48 -0700
Message-ID: <20090318110048.4f51bb25@nehalam>
References: <20090318100237.06e974c9@nehalam>
	<49C12CF4.1000609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60839 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757240AbZCRSA4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 14:00:56 -0400
In-Reply-To: <49C12CF4.1000609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2009 18:18:44 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Some virtual devices like VLAN's or bridges by default have not tra=
nsmit queue.
> > In order to do queuing disciplines on these devices a queue must be=
 added
> > by setting transmit queue length. The kernel allows doing this at a=
ny time, but
> > setting the queue length value is not enough. Setting the queue len=
gth does
> > not create the transmit queue (going from 0 to non-zero) or destroy=
 it
> > (setting to zero); the queue is only created (or destroyed) when de=
vice
> > comes up (or goes down).
> >=20
> > This patch handles this be doing the necessary activations.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> >  include/linux/netdevice.h |    2 ++
> >  net/core/dev.c            |   19 +++++++++++++++++--
> >  net/core/net-sysfs.c      |    5 ++---
> >  net/core/rtnetlink.c      |    2 +-
> >  4 files changed, 22 insertions(+), 6 deletions(-)
> >=20
> > --- a/include/linux/netdevice.h	2009-03-17 11:06:40.358479573 -0700
> > +++ b/include/linux/netdevice.h	2009-03-17 11:13:55.243604979 -0700
> > @@ -1436,6 +1436,8 @@ extern int		dev_change_net_namespace(str
> >  extern int		dev_set_mtu(struct net_device *, int);
> >  extern int		dev_set_mac_address(struct net_device *,
> >  					    struct sockaddr *);
> > +extern int		dev_set_tx_queue_len(struct net_device *dev,
> > +					     unsigned long len);
> >  extern int		dev_hard_start_xmit(struct sk_buff *skb,
> >  					    struct net_device *dev,
> >  					    struct netdev_queue *txq);
> > --- a/net/core/dev.c	2009-03-17 11:05:54.919541341 -0700
> > +++ b/net/core/dev.c	2009-03-17 11:16:25.717479320 -0700
> > @@ -983,6 +983,22 @@ int dev_set_alias(struct net_device *dev
> >  	return len;
> >  }
> > =20
> > +/**
> > + *
> > + *	@dev: device
> > + *	@len: limit of frames in transmit queue
> > + *
> > + *	Set ifalias for a device,
>=20
> copy/pasted from "dev_set_alias - change ifalias of a device" ? ;)
>=20
> > + */
> > +int dev_set_tx_queue_len(struct net_device *dev, unsigned long len=
)
> > +{
>=20
> if (dev->tx_queue_len =3D=3D len)
> 	return 0;

Also could do:
        =20
if ((dev->tx_queue_len !=3D 0) && (len !=3D 0)) {
      dev->tx_queue_len =3D len;
      return 0;
}
