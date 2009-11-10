From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 07/10] decnet: use RCU to find network devices
Date: Tue, 10 Nov 2009 10:50:53 -0800
Message-ID: <20091110105053.16687e93@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.615305929@vyatta.com>
	<4AF9B449.6040708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Steven Whitehouse <swhiteho@redhat.com>,
	netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54026 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757513AbZKJSvO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:51:14 -0500
In-Reply-To: <4AF9B449.6040708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 19:43:21 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > When showing device statistics use RCU rather than read_lock(&dev_b=
ase_lock)
> > Compile tested only.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > --- a/net/decnet/dn_dev.c	2009-11-10 09:30:55.557376454 -0800
> > +++ b/net/decnet/dn_dev.c	2009-11-10 09:40:03.847005394 -0800
> > @@ -856,9 +856,7 @@ int dn_dev_bind_default(__le16 *addr)
> >  	dev =3D dn_dev_get_default();
> >  last_chance:
> >  	if (dev) {
> > -		read_lock(&dev_base_lock);
> >  		rv =3D dn_dev_get_first(dev, addr);
> > -		read_unlock(&dev_base_lock);
> >  		dev_put(dev);
> >  		if (rv =3D=3D 0 || dev =3D=3D init_net.loopback_dev)
> >  			return rv;
> > @@ -1323,18 +1321,18 @@ static inline int is_dn_dev(struct net_d
>=20
>=20
> I dont understand this part. Why previous locking can be avoided ?

dn_dev_get_default acquires a reference on dev so the device can
not go away.

It could be the original author meant to ensure the address list
doesn't change. If so, then rtnl_lock() should have been used.
