From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive slaves
Date: Wed, 05 Aug 2009 18:57:37 +0200
Message-ID: <4A79BA01.502@gmail.com>
References: <20090805162429.GD16093@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44279 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934404AbZHEQ5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 12:57:55 -0400
In-Reply-To: <20090805162429.GD16093@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac a =E9crit :
> Applications exist that broadcast/multicast packets on all
> devices in the system (e.g. avahi-mdns).
>=20
> When a device is an inactive slave of a bond in active-backup
> mode, its MAC address may be set identical to other divecies in
> the bond. The broadcast/multicast packets may then confuse
> switches to direct packets to the inactive slave, rather than the
> active one.
>=20
> This patch makes sure the TX queues on inactive slaves are
> deactivated.
>=20

Wont this break ARP link monitoring ?

> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>=20
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -20,6 +20,7 @@
>  #include <linux/if_bonding.h>
>  #include <linux/kobject.h>
>  #include <linux/in6.h>
> +#include <net/sch_generic.h>
>  #include "bond_3ad.h"
>  #include "bond_alb.h"
> =20
> @@ -291,12 +292,21 @@ static inline void bond_set_slave_inactive_flag=
s(struct slave *slave)
>  	slave->dev->priv_flags |=3D IFF_SLAVE_INACTIVE;
>  	if (slave_do_arp_validate(bond, slave))
>  		slave->dev->priv_flags |=3D IFF_SLAVE_NEEDARP;
> +
> +	/* prevent outgoing frames on inactive slaves from confusing switch=
es */
> +	if (bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP)
> +		dev_deactivate_tx(slave->dev);
>  }
> =20
>  static inline void bond_set_slave_active_flags(struct slave *slave)
>  {
> +	struct bonding *bond =3D netdev_priv(slave->dev->master);
> +
>  	slave->state =3D BOND_STATE_ACTIVE;
>  	slave->dev->priv_flags &=3D ~(IFF_SLAVE_INACTIVE | IFF_SLAVE_NEEDAR=
P);
> +
> +	if (bond->params.mode =3D=3D BOND_MODE_ACTIVEBACKUP)
> +		dev_activate_tx(slave->dev);
>  }
> =20
>  static inline void bond_set_master_3ad_flags(struct bonding *bond)
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 964ffa0..eee006a 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -296,6 +296,8 @@ extern void dev_init_scheduler(struct net_device =
*dev);
>  extern void dev_shutdown(struct net_device *dev);
>  extern void dev_activate(struct net_device *dev);
>  extern void dev_deactivate(struct net_device *dev);
> +extern void dev_activate_tx(struct net_device *dev);
> +extern void dev_deactivate_tx(struct net_device *dev);
>  extern void qdisc_reset(struct Qdisc *qdisc);
>  extern void qdisc_destroy(struct Qdisc *qdisc);
>  extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned i=
nt n);
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 27d0381..514c73d 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -628,7 +628,7 @@ static void transition_one_qdisc(struct net_devic=
e *dev,
>  	}
>  }
> =20
> -void dev_activate(struct net_device *dev)
> +void dev_activate_tx(struct net_device *dev)
>  {
>  	int need_watchdog;
> =20
> @@ -647,13 +647,19 @@ void dev_activate(struct net_device *dev)
> =20
>  	need_watchdog =3D 0;
>  	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog)=
;
> -	transition_one_qdisc(dev, &dev->rx_queue, NULL);
> =20
>  	if (need_watchdog) {
>  		dev->trans_start =3D jiffies;
>  		dev_watchdog_up(dev);
>  	}
>  }
> +EXPORT_SYMBOL(dev_activate_tx);
> +
> +void dev_activate(struct net_device *dev)
> +{
> +	dev_activate_tx(dev);
> +	transition_one_qdisc(dev, &dev->rx_queue, NULL);
> +}
> =20
>  static void dev_deactivate_queue(struct net_device *dev,
>  				 struct netdev_queue *dev_queue,
> @@ -703,12 +709,18 @@ static bool some_qdisc_is_busy(struct net_devic=
e *dev)
>  	return false;
>  }
> =20
> -void dev_deactivate(struct net_device *dev)
> +void dev_deactivate_tx(struct net_device *dev)
>  {
>  	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
> -	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
> =20
>  	dev_watchdog_down(dev);
> +}
> +EXPORT_SYMBOL(dev_deactivate_tx);
> +
> +void dev_deactivate(struct net_device *dev)
> +{
> +	dev_deactivate_tx(dev);
> +	dev_deactivate_queue(dev, &dev->rx_queue, &noop_qdisc);
> =20
>  	/* Wait for outstanding qdisc-less dev_queue_xmit calls. */
>  	synchronize_rcu();
>=20
>=20
>=20

