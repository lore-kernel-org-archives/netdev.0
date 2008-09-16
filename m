From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 05/14] Phonet: network device and address handling
Date: Tue, 16 Sep 2008 13:41:26 -0300
Message-ID: <20080916164126.GI8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-5-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41259 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754653AbYIPQuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 12:50:20 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-5-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:05PM +0300, R=E9mi Denis-Courmont escreve=
u:
> This provides support for adding Phonet addresses to and removing
> Phonet addresses from network devices.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/net/phonet/pn_dev.h |   63 ++++++++++++
>  net/phonet/Makefile         |    1 +
>  net/phonet/af_phonet.c      |   12 ++
>  net/phonet/pn_dev.c         |  233 +++++++++++++++++++++++++++++++++=
++++++++++
>  4 files changed, 309 insertions(+), 0 deletions(-)
>  create mode 100644 include/net/phonet/pn_dev.h
>  create mode 100644 net/phonet/pn_dev.c
>=20
> diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.=
h
> new file mode 100644
> index 0000000..c53d364
> --- /dev/null
> +++ b/include/net/phonet/pn_dev.h
> @@ -0,0 +1,63 @@
> +/*
> + * File: pn_dev.h
> + *
> + * Phonet network device
> + *
> + * Copyright (C) 2008 Nokia Corporation.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
> + * 02110-1301 USA
> + */
> +
> +#ifndef PN_DEV_H
> +#define PN_DEV_H
> +
> +struct phonet_device_list {
> +	struct list_head list;
> +	spinlock_t lock;
> +};
> +
> +extern struct phonet_device_list pndevs;
> +
> +struct phonet_device {
> +	struct list_head list;
> +	struct net_device *netdev;
> +	struct list_head own;
> +};
> +
> +struct phonet_address {
> +	struct list_head list;
> +	struct phonet_device *pnd;
> +	uint8_t addr;
> +	unsigned char prefix;
> +};
> +
> +int phonet_device_init(void);
> +void phonet_device_exit(void);
> +struct phonet_device *phonet_device_alloc(struct net_device *dev);
> +struct phonet_device *__phonet_get_by_index(unsigned ifindex);
> +void phonet_device_free(struct phonet_device *pnd);
> +
> +struct phonet_address *phonet_address_alloc(void);
> +void phonet_address_add(struct list_head *list, struct phonet_addres=
s *pna);
> +void phonet_address_free(struct phonet_address *pna);
> +struct phonet_address *phonet_addr2addr(uint8_t addr, int mode);
> +struct phonet_address *phonet_dev2addr(struct phonet_device *pnd, ui=
nt8_t addr,
> +					int mode);
> +
> +#define PN_FIND_EXACT	(1 << 0)
> +
> +#define MKMASK(a)	((1 << (a)) - 1)
> +
> +#endif
> diff --git a/net/phonet/Makefile b/net/phonet/Makefile
> index 5dbff68..980a386 100644
> --- a/net/phonet/Makefile
> +++ b/net/phonet/Makefile
> @@ -1,4 +1,5 @@
>  obj-$(CONFIG_PHONET) +=3D phonet.o
> =20
>  phonet-objs :=3D \
> +	pn_dev.o \
>  	af_phonet.o
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index ed66a81..744b47f 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -31,6 +31,7 @@
>  #include <linux/if_phonet.h>
>  #include <linux/phonet.h>
>  #include <net/phonet/phonet.h>
> +#include <net/phonet/pn_dev.h>
> =20
>  static struct net_proto_family phonet_proto_family;
>  static struct phonet_protocol *phonet_proto_get(int protocol);
> @@ -202,14 +203,25 @@ static int __init phonet_init(void)
>  		return err;
>  	}
> =20
> +	err =3D phonet_device_init();
> +	if (err) {
> +		printk(KERN_ALERT "phonet devices initialization failed\n");
> +		goto unregister;
> +	}
> +
>  	dev_add_pack(&phonet_packet_type);
>  	return 0;
> +
> +unregister:
> +	sock_unregister(AF_PHONET);
> +	return err;
>  }
> =20
>  static void __exit phonet_exit(void)
>  {
>  	sock_unregister(AF_PHONET);
>  	dev_remove_pack(&phonet_packet_type);
> +	phonet_device_exit();
>  }
> =20
>  module_init(phonet_init);
> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
> new file mode 100644
> index 0000000..cae37a6
> --- /dev/null
> +++ b/net/phonet/pn_dev.c
> @@ -0,0 +1,233 @@
> +/*
> + * File: pn_dev.c
> + *
> + * Phonet network device
> + *
> + * Copyright (C) 2008 Nokia Corporation.
> + *
> + * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> + * Original author: Sakari Ailus <sakari.ailus@nokia.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
> + * 02110-1301 USA
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/net.h>
> +#include <linux/netdevice.h>
> +#include <linux/phonet.h>
> +#include <net/sock.h>
> +#include <net/phonet/pn_dev.h>
> +
> +static int phonet_device_notify(struct notifier_block *self, unsigne=
d long what,
> +				void *dev);
> +
> +/* when accessing, remember to lock with spin_lock(&pndevs.lock); */
> +struct phonet_device_list pndevs;

Please look at net/ipv4/tcp_minisocks.c to see how tcp_death_row is
initialized, that way you don't have to first initialize it to zeros
(BSS as it is static and uninitialized) and then, at phonet_device_init
time, again.

> +static struct notifier_block phonet_device_notifier =3D {
> +	.notifier_call =3D &phonet_device_notify,
> +	.priority =3D 0,
> +};
> +
> +/* initialise Phonet device list */
> +int phonet_device_init(void)
> +{
> +	INIT_LIST_HEAD(&pndevs.list);
> +	spin_lock_init(&pndevs.lock);
> +	register_netdevice_notifier(&phonet_device_notifier);
> +
> +	return 0;
> +}
> +
> +void phonet_device_exit(void)
> +{
> +	struct list_head *ptr;
> +
> +	rtnl_unregister_all(PF_PHONET);
> +	rtnl_lock();
> +	spin_lock_bh(&pndevs.lock);
> +
> +	for (ptr =3D pndevs.list.next; ptr !=3D &pndevs.list;
> +		ptr =3D pndevs.list.next) {

Perhaps a phone_for_each_dev() macro like for_each_netdev() in
linux/netdevice.h?

> +		struct phonet_device *pnd =3D list_entry(ptr,
> +						struct phonet_device, list);
> +		phonet_device_free(pnd);
> +	}
> +
> +	spin_unlock_bh(&pndevs.lock);
> +	rtnl_unlock();
> +	unregister_netdevice_notifier(&phonet_device_notifier);
> +}
> +
> +struct phonet_address *phonet_address_alloc(void)
> +{
> +	struct phonet_address *pna;
> +
> +	pna =3D kmalloc(sizeof(struct phonet_address), GFP_KERNEL);
> +
> +	if (pna =3D=3D NULL)
> +		return NULL;
> +
> +	INIT_LIST_HEAD(&pna->list);


minor nitpick:

	if (pna !=3D NULL)
		INIT_LIST_HEAD(&pna->list);

shorter :)

> +
> +	return pna;
> +}
> +
> +/* add Phonet address to list */
> +void phonet_address_add(struct list_head *list, struct phonet_addres=
s *pna)
> +{
> +	list_add(&pna->list, list);
> +}
> +
> +/* remove Phonet address from list and free it */
> +void phonet_address_free(struct phonet_address *pna)
> +{
> +	list_del(&pna->list);
> +	kfree(pna);
> +}

Not symetric, i.e. you have a list_add operation and not a list_del,
only one that in addition to removing from the list also destroys the
address, confusing.

> +/* Allocate new Phonet device. */
> +struct phonet_device *phonet_device_alloc(struct net_device *dev)
> +{
> +	struct phonet_device *pnd;
> +
> +	pnd =3D kmalloc(sizeof(struct phonet_device), GFP_ATOMIC);
> +
> +	if (pnd =3D=3D NULL)
> +		return NULL;
> +
> +	INIT_LIST_HEAD(&pnd->own);
> +	pnd->netdev =3D dev;
> +	list_add(&pnd->list, &pndevs.list);
> +	return pnd;
> +}
> +
> +struct phonet_device *__phonet_get_by_index(unsigned ifindex)
> +{
> +	struct list_head *p;
> +
> +	list_for_each(p, &pndevs.list) {
> +		struct phonet_device *pnd;
> +
> +		pnd =3D list_entry(p, struct phonet_device, list);
> +		BUG_ON(!pnd->netdev);
> +
> +		if (pnd->netdev->ifindex =3D=3D ifindex)
> +			return pnd;
> +	}
> +	return NULL;
> +}
> +
> +void phonet_device_free(struct phonet_device *pnd)
> +{
> +	struct list_head *ptr;
> +
> +	/* remove device from list */
> +	list_del(&pnd->list);
> +
> +	for (ptr =3D pnd->own.next; ptr !=3D &pnd->own; ptr =3D pnd->own.ne=
xt) {
> +		struct phonet_address *pna =3D
> +			list_entry(ptr, struct phonet_address, list);
> +		phonet_address_free(pna);

Why not use list_for_each_entry()? _safe() even, since
phonet_address_free also messes with this list, no?

> +	}
> +
> +	kfree(pnd);
> +}
> +
> +/*
> + * Find the address from the device's address list having the given =
address
> + */
> +struct phonet_address *phonet_dev2addr(struct phonet_device *pnd,
> +					uint8_t addr, int mode)
> +{
> +	struct list_head *list =3D &pnd->own, *ptr;
> +	struct phonet_address *best =3D NULL;
> +
> +	for (ptr =3D list->next; ptr !=3D list; ptr =3D ptr->next) {
> +		struct phonet_address *pna =3D
> +			list_entry(ptr, struct phonet_address, list);

list_for_each_entry()

> +		if (mode & PN_FIND_EXACT) {
> +			/* try to find exact address */
> +			if (pna->addr =3D=3D addr) {
> +				best =3D pna;
> +				break;
> +			}
> +		} else if (best =3D=3D NULL ||
> +			   best->prefix < pna->prefix) {
> +			if ((pna->addr & MKMASK(pna->prefix)) =3D=3D
> +					(addr & MKMASK(pna->prefix))) {
> +				best =3D pna;
> +			}
> +		}
> +	}
> +
> +	return best;
> +}
> +
> +/*
> + * Find the device having a given address (remember locking!!)
> + */
> +struct phonet_address *phonet_addr2addr(uint8_t addr, int mode)
> +{
> +	struct list_head *ptr;
> +	struct phonet_address *best =3D NULL;
> +
> +	for (ptr =3D pndevs.list.next; ptr !=3D &pndevs.list; ptr =3D ptr->=
next) {
> +		struct phonet_address *pna =3D NULL;
> +		struct phonet_device *pnd =3D
> +		    list_entry(ptr, struct phonet_device, list);

Ditto

> +
> +		/* Don't allow unregistering devices! */
> +		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
> +			((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
> +			continue;
> +
> +		pna =3D phonet_dev2addr(pnd, addr, mode);
> +
> +		if (pna !=3D NULL) {
> +			if (best =3D=3D NULL || best->prefix < pna->prefix)
> +				best =3D pna;
> +		}
> +	}
> +
> +	return best;
> +}
> +
> +/* notify Phonet of device events */
> +static int phonet_device_notify(struct notifier_block *self, unsigne=
d long what,
> +				void *_dev)
> +{
> +	struct net_device *dev =3D _dev;
> +	struct phonet_device *pnd;
> +
> +	spin_lock_bh(&pndevs.lock);
> +	pnd =3D __phonet_get_by_index(dev->ifindex);
> +
> +	switch (what) {
> +	case NETDEV_UNREGISTER:
> +		if (pnd =3D=3D NULL)
> +			break;
> +		phonet_device_free(pnd);
> +		break;
> +	default:
> +		break;
> +	}

	if (what =3D=3D NETDEV_UNREGISTER && pnd !=3D NULL)
		phonet_device_free(pnd);

Shorter, no? :)

> +
> +	spin_unlock_bh(&pndevs.lock);
> +
> +	return 0;
> +
> +}
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
