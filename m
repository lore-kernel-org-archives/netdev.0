From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: sysctls below net.ipv[46].conf.all not working as expected
Date: Tue, 22 Feb 2011 10:34:25 +0100
Message-ID: <20110222093425.GX22310@pengutronix.de>
References: <20101229160607.GH14221@pengutronix.de>
 <20101230.123023.226775556.davem@davemloft.net>
 <20101230204319.GE14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Marco d'Itri <md@linux.it>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37961 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab1BVKlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 05:41:31 -0500
Content-Disposition: inline
In-Reply-To: <20101230204319.GE14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Thu, Dec 30, 2010 at 09:43:19PM +0100, Uwe Kleine-K=F6nig wrote:
> On Thu, Dec 30, 2010 at 12:30:23PM -0800, David Miller wrote:
> > From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> > Date: Wed, 29 Dec 2010 17:06:07 +0100
> >=20
> > > I did the following:
> > >=20
> > > 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> > > 	net.ipv6.conf.all.use_tempaddr =3D 0
> > >=20
> > > 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> > > 	net.ipv6.conf.eth0.use_tempaddr =3D 0
> > >=20
> > > 	cassiopeia:~# sysctl -w net.ipv6.conf.all.use_tempaddr=3D1
> > > 	net.ipv6.conf.all.use_tempaddr =3D 1
> > >=20
> > > 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> > > 	net.ipv6.conf.all.use_tempaddr =3D 1
> > >=20
> > > 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> > > 	net.ipv6.conf.eth0.use_tempaddr =3D 0
> > >=20
> > > Here I would have expected that eth0's use_tempaddr is 1, too.  T=
he
> > > problem is not that this entry isn't writeable:
> >=20
> > The "all" value is propagated at the first moment that the ipv6 dev=
ice
> > private is created, usually that is when the device is first brough=
t up
> > which means it can happen as early as the exact moment the device i=
s
> > registered.
> >=20
> > Therefore, if you want "all" to apply to "eth0", you must make sure
> > the sysctl is set properly before the device is registered.
> I thought this is what "default" was used for?!
I took the time now to dig into the source for ipv4/{all,default}.

Unless I'm mistaken I found:

 - inetdev_init copies dev_net(dev)->ipv4.devconf_dflt to &in_dev->cnf
   That's called from inetdev_event if there is no in_dev.

 - devinet_copy_dflt_conf copies to all devices that have !test_bit(i,
   in_dev->cnf.state)
   devinet_copy_dflt_conf is called when /proc/sys/net/ipv4/conf/defaul=
t
   is written to.  I didn't found where the in_dev->cnf.state bits are
   set.

 - net->ipv4.devconf_all is never propagated to the devices.

 - The data behind /proc/sys/net/ipv4/conf/all is used in registering
   net->ipv4.forw_hdr and seems only have to do with ip_forward

So I think that it's really "default" that propagates to a new device a=
s
I expected and the documentation suggests.

So IMHO a better name for "all" would be "global" ...

> If you are really right, the documentation is (IMHO) misleading.  e.g=
=2E
> Documentation/networking/ip-sysctl.txt tells:
>=20
> 	conf/default/*:
> 		Change the interface-specific default settings.
>=20
> 	conf/all/*:
> 		Change all the interface-specific settings.
=2E.. and this is misleading.  I wonder if it would be considered OK, t=
o
create a new config directory called "global" that acts like "all" now
and let "all" propagate all changes to all devices, "default" and
"global".  If not the documentation needs clearification.

I guess for ipv6 it's similar, though I didn't check that.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
