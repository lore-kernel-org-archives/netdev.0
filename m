From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 06/10] s390: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 10:29:02 -0800
Message-ID: <20091110102902.600b64f2@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.547660685@vyatta.com>
	<4AF9B07F.6070606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org, linux390@de.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52802 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbZKJS3X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:29:23 -0500
In-Reply-To: <4AF9B07F.6070606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 19:27:11 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > This is similar to other cases where for_each_netdev_rcu
> > can be used when gathering information.
> >=20
> > By inspection, don't have platform or cross-build environment
> > to validate.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> >=20
> > --- a/arch/s390/appldata/appldata_net_sum.c	2009-11-09 22:19:05.593=
480476 -0800
> > +++ b/arch/s390/appldata/appldata_net_sum.c	2009-11-10 09:28:38.335=
438652 -0800
> > @@ -83,8 +83,9 @@ static void appldata_get_net_sum_data(vo
> >  	rx_dropped =3D 0;
> >  	tx_dropped =3D 0;
> >  	collisions =3D 0;
> > -	read_lock(&dev_base_lock);
> > -	for_each_netdev(&init_net, dev) {
> > +
> > +	rcu_read_lock();
> > +	for_each_netdev_rcu(&init_net, dev) {
> >  		const struct net_device_stats *stats =3D dev_get_stats(dev);
> > =20
> >  		rx_packets +=3D stats->rx_packets;
> > @@ -98,7 +99,8 @@ static void appldata_get_net_sum_data(vo
> >  		collisions +=3D stats->collisions;
> >  		i++;
> >  	}
> > -	read_unlock(&dev_base_lock);
> > +	rcu_read_unlock();
> > +
> >  	net_data->nr_interfaces =3D i;
> >  	net_data->rx_packets =3D rx_packets;
> >  	net_data->tx_packets =3D tx_packets;
> >=20
>=20
> Not sure if dev_get_stats(dev) could sleep on some devices...
>=20

It would have already been broken since dev_get_stats is previously
called with read_lock(), and sleeping with any lock held causes warning=
=2E

--=20
