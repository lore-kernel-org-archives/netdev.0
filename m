From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Sun, 14 Nov 2010 10:47:56 -0800
Message-ID: <20101114104756.1b21deb1@nehalam>
References: <1289636128.2743.15.camel@edumazet-laptop>
	<20101113093545.6fe9c077@nehalam>
	<1289671130.2743.28.camel@edumazet-laptop>
	<20101113101320.4b1c9ba7@nehalam>
	<1289685861.2743.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33454 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756779Ab0KNSsK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 13:48:10 -0500
In-Reply-To: <1289685861.2743.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 13 Nov 2010 23:04:21 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le samedi 13 novembre 2010 =E0 10:13 -0800, Stephen Hemminger a =E9cr=
it :
> > On Sat, 13 Nov 2010 18:58:50 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > Le samedi 13 novembre 2010 =E0 09:35 -0800, Stephen Hemminger a =E9=
crit :
> > > > On Sat, 13 Nov 2010 09:15:28 +0100
> > > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >=20
> > > > > diff --git a/include/linux/netdevice.h b/include/linux/netdev=
ice.h
> > > > > index 578debb..ffbd177 100644
> > > > > --- a/include/linux/netdevice.h
> > > > > +++ b/include/linux/netdevice.h
> > > > > @@ -996,7 +996,10 @@ struct net_device {
> > > > >  #endif
> > > > > =20
> > > > >  	rx_handler_func_t	*rx_handler;
> > > > > -	void			*rx_handler_data;
> > > > > +	union {
> > > > > +		void				*rx_handler_data;
> > > > > +		struct net_bridge_port __rcu	*br_port_rcu;
> > > > > +	};
> > > > > =20
> > > > >  	struct netdev_queue __rcu *ingress_queue;
> > > >=20
> > > > I don't like making the generic hook typed again.
> > > > We don't do this for other callbacks, timers, workqueues, ...
> > > > Why is it necessary for RCU notation.
> > > >=20
> > >=20
> > > because rcu_dereference() needs the type for __CHECKER__/sparse c=
hecks
> > >=20
> > > #define __rcu_dereference_check(p, c, space) \
> > >         ({ \
> > >                 typeof(*p) *_________p1 =3D (typeof(*p)*__force )=
ACCESS_ONCE(p); \
> > >                 rcu_lockdep_assert(c); \
> > >                 rcu_dereference_sparse(p, space); \
> > >                 smp_read_barrier_depends(); \
> > >                 ((typeof(*p) __force __kernel *)(_________p1)); \
> > >         })
> > >=20
> > > So using a "void *ptr" is not an option
> > >=20
> > > Its also cleaner to use
> > >=20
> > > rcu_dereference(dev->br_port_rcu)
> > >=20
> > > instead of=20
> > >=20
> > > (struct net_bridge_port *)rcu_dereference(dev->rx_handler_data)
> >=20
> > There must be a better way. What about use of that hook by macvlan =
and openvswitch?
>=20
> macvlan and openvswitch (is it part of linux yet ???)
>=20
> I honestly dont understand your point Stephen, maybe you could explai=
n a
> bit more what is the problem ?
>=20
> I use a union, like many other ones in the kernel. This is the first
> time I ear this is not good to add type safety.
>=20
> You can use either one or other field at your convenience.
>=20
> If you are talking about stacking hooks, that has nothing to do with
> this (cleanup) rcu patch, but previous introduction of
> rx_handler_data/rx_handler ?
>=20
> Please run sparse on x86_64 machine and watch all the warnings in bri=
dge
> code. (with CONFIG_SPARSE_RCU_POINTER=3Dy)
>=20
> Me confused.
>=20
>=20

You combined three different sets of changes and introduced a needless
union. I will split them up and show you what I want.


--=20
