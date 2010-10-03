From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Sun, 3 Oct 2010 11:42:21 +0200
Message-ID: <20101003094221.GA2028@del.dom.local>
References: <1285689517.3154.76.camel@edumazet-laptop>
 <20100928180447.GA1880@del.dom.local>
 <1285757817.3561.2.camel@bigi>
 <1285887509.2705.33.camel@edumazet-laptop>
 <1285933506.3553.176.camel@bigi>
 <1285941388.2641.175.camel@edumazet-laptop>
 <20101002093255.GA2049@del.dom.local>
 <1286035915.2582.2472.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60064 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab0JCJm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 05:42:28 -0400
Received: by wwj40 with SMTP id 40so2988550wwj.1
        for <netdev@vger.kernel.org>; Sun, 03 Oct 2010 02:42:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1286035915.2582.2472.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 02, 2010 at 06:11:55PM +0200, Eric Dumazet wrote:
> Le samedi 02 octobre 2010 ?? 11:32 +0200, Jarek Poplawski a =E9crit :
> > On Fri, Oct 01, 2010 at 03:56:28PM +0200, Eric Dumazet wrote:
=2E..
> > > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > > index b802078..8635110 100644
> > > --- a/net/sched/sch_api.c
> > > +++ b/net/sched/sch_api.c
=2E..
> > > @@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev=
, struct Qdisc *parent,
> > >  		    (new && new->flags & TCQ_F_INGRESS)) {
> > >  			num_q =3D 1;
> > >  			ingress =3D 1;
> > > +			if (!dev_ingress_queue(dev))
> > > +				return -ENOENT;
> >=20
> > Is this test really needed here?
>=20
> To avoid a NULL dereference some lines later.
> Do I have a guarantee its not NULL here ?

Do you have any scenario for NULL here? ;-)

Of course, it's your patch and responsibility, and I'll not guarantee,
but you could at least add a TODO comment, to check it later.

> > > @@ -1044,7 +1050,8 @@ replay:
> > >  					return -ENOENT;
> > >  				q =3D qdisc_leaf(p, clid);
> > >  			} else { /*ingress */
> > > -				q =3D dev->ingress_queue.qdisc_sleeping;
> > > +				if (dev_ingress_queue_create(dev))
> > > +					q =3D dev_ingress_queue(dev)->qdisc_sleeping;
> >=20
> > I wonder if doing dev_ingress_queue_create() just before qdisc_crea=
te()
> > (and the test here) isn't more readable.
>=20
> Sorry, I dont understand. I want to create ingress_queue only if user
> wants it. If we setup (egress) trafic shaping, no need to setup
> ingress_queue.

I mean doing both creates in one place:

> @@ -1123,11 +1130,14 @@ replay:
>  create_n_graft:
=2E..
> +	if (clid =3D=3D TC_H_INGRESS) {
 +		if (dev_ingress_queue_create(dev))
> +			q =3D qdisc_create(dev, dev_ingress_queue(dev), p,
> +					 tcm->tcm_parent, tcm->tcm_parent,
> +					 tca, &err);
> +		else
> +			err =3D -ENOENT;
> +	} else {
>  		struct netdev_queue *dev_queue;
=2E..

> Here is the V3 then.
>=20
> [PATCH net-next V3] net: dynamic ingress_queue allocation
>=20
> ingress being not used very much, and net_device->ingress_queue being
> quite a big object (128 or 256 bytes), use a dynamic allocation if
> needed (tc qdisc add dev eth0 ingress ...)
>=20
> dev_ingress_queue(dev) helper should be used only with RTNL taken.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> V3: add rcu notations & address Jarek comments
>  include/linux/netdevice.h |    2 -
>  include/linux/rtnetlink.h |    8 ++++++
>  net/core/dev.c            |   34 ++++++++++++++++++++++-------
>  net/sched/sch_api.c       |   42 ++++++++++++++++++++++++-----------=
-
>  net/sched/sch_generic.c   |   12 ++++++----
>  5 files changed, 71 insertions(+), 27 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ceed347..92d81ed 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -986,7 +986,7 @@ struct net_device {
>  	rx_handler_func_t	*rx_handler;
>  	void			*rx_handler_data;
> =20
> -	struct netdev_queue	ingress_queue; /* use two cache lines */
> +	struct netdev_queue __rcu *ingress_queue;
> =20
>  /*
>   * Cache lines mostly used on transmit path
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 68c436b..0bb7b48 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -6,6 +6,7 @@
>  #include <linux/if_link.h>
>  #include <linux/if_addr.h>
>  #include <linux/neighbour.h>
> +#include <linux/netdevice.h>
> =20
>  /* rtnetlink families. Values up to 127 are reserved for real addres=
s
>   * families, values above 128 may be used arbitrarily.
> @@ -769,6 +770,13 @@ extern int lockdep_rtnl_is_held(void);
>  #define rtnl_dereference(p)					\
>  	rcu_dereference_check(p, lockdep_rtnl_is_held())
> =20
> +static inline struct netdev_queue *dev_ingress_queue(struct net_devi=
ce *dev)
> +{
> +	return rtnl_dereference(dev->ingress_queue);

I'd consider rcu_dereference_rtnl(). Btw, technically qdisc_lookup()
doesn't require rtnl, and there was time it was used without it
(on xmit path).

I think you should also add a comment here why this rcu is used, and
that it changes only once in dev's liftime.

Jarek P.

PS: checkpatched or not checkpatched, that is the question... ;-)
