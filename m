From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Sat, 13 Nov 2010 18:58:50 +0100
Message-ID: <1289671130.2743.28.camel@edumazet-laptop>
References: <1289636128.2743.15.camel@edumazet-laptop>
	 <20101113093545.6fe9c077@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53413 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab0KMR7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 12:59:01 -0500
Received: by wwb28 with SMTP id 28so267654wwb.1
        for <netdev@vger.kernel.org>; Sat, 13 Nov 2010 09:59:00 -0800 (PST)
In-Reply-To: <20101113093545.6fe9c077@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 13 novembre 2010 =C3=A0 09:35 -0800, Stephen Hemminger a =C3=A9=
crit :
> On Sat, 13 Nov 2010 09:15:28 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 578debb..ffbd177 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -996,7 +996,10 @@ struct net_device {
> >  #endif
> > =20
> >  	rx_handler_func_t	*rx_handler;
> > -	void			*rx_handler_data;
> > +	union {
> > +		void				*rx_handler_data;
> > +		struct net_bridge_port __rcu	*br_port_rcu;
> > +	};
> > =20
> >  	struct netdev_queue __rcu *ingress_queue;
>=20
> I don't like making the generic hook typed again.
> We don't do this for other callbacks, timers, workqueues, ...
> Why is it necessary for RCU notation.
>=20

because rcu_dereference() needs the type for __CHECKER__/sparse checks

#define __rcu_dereference_check(p, c, space) \
        ({ \
                typeof(*p) *_________p1 =3D (typeof(*p)*__force )ACCESS=
_ONCE(p); \
                rcu_lockdep_assert(c); \
                rcu_dereference_sparse(p, space); \
                smp_read_barrier_depends(); \
                ((typeof(*p) __force __kernel *)(_________p1)); \
        })

So using a "void *ptr" is not an option

Its also cleaner to use

rcu_dereference(dev->br_port_rcu)

instead of=20

(struct net_bridge_port *)rcu_dereference(dev->rx_handler_data)



