From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Sat, 13 Nov 2010 10:13:20 -0800
Message-ID: <20101113101320.4b1c9ba7@nehalam>
References: <1289636128.2743.15.camel@edumazet-laptop>
	<20101113093545.6fe9c077@nehalam>
	<1289671130.2743.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58600 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754644Ab0KMSNg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Nov 2010 13:13:36 -0500
In-Reply-To: <1289671130.2743.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Nov 2010 18:58:50 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le samedi 13 novembre 2010 =E0 09:35 -0800, Stephen Hemminger a =E9cr=
it :
> > On Sat, 13 Nov 2010 09:15:28 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.=
h
> > > index 578debb..ffbd177 100644
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -996,7 +996,10 @@ struct net_device {
> > >  #endif
> > > =20
> > >  	rx_handler_func_t	*rx_handler;
> > > -	void			*rx_handler_data;
> > > +	union {
> > > +		void				*rx_handler_data;
> > > +		struct net_bridge_port __rcu	*br_port_rcu;
> > > +	};
> > > =20
> > >  	struct netdev_queue __rcu *ingress_queue;
> >=20
> > I don't like making the generic hook typed again.
> > We don't do this for other callbacks, timers, workqueues, ...
> > Why is it necessary for RCU notation.
> >=20
>=20
> because rcu_dereference() needs the type for __CHECKER__/sparse check=
s
>=20
> #define __rcu_dereference_check(p, c, space) \
>         ({ \
>                 typeof(*p) *_________p1 =3D (typeof(*p)*__force )ACCE=
SS_ONCE(p); \
>                 rcu_lockdep_assert(c); \
>                 rcu_dereference_sparse(p, space); \
>                 smp_read_barrier_depends(); \
>                 ((typeof(*p) __force __kernel *)(_________p1)); \
>         })
>=20
> So using a "void *ptr" is not an option
>=20
> Its also cleaner to use
>=20
> rcu_dereference(dev->br_port_rcu)
>=20
> instead of=20
>=20
> (struct net_bridge_port *)rcu_dereference(dev->rx_handler_data)

There must be a better way. What about use of that hook by macvlan and =
openvswitch?



--=20
