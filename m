From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/14][NETNS]: Introduce the net-subsys id generator.
Date: Thu, 10 Apr 2008 22:52:44 +0200
Message-ID: <47FE7E1C.50403@fr.ibm.com>
References: <47FE2AD4.9080609@openvz.org> <47FE2BB5.4070708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:54636 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419AbYDJU5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 16:57:21 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3AKvJFd386608
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 20:57:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3AKvJX82437284
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 22:57:19 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3AKvJHh021724
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 22:57:19 +0200
In-Reply-To: <47FE2BB5.4070708@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> To make some per-net generic pointers, we need some way to
> address them, i.e. - IDs. This is simple IDA-based IDs
> generator for pernet subsystems. They will be used in the
> next patches.
>=20
> Since it will be used by devices only (tun and vlan), I make
> it resemble the register_pernet_device functionality.
>=20
> The new ids is stored in the *id pointer _before_ calling the
> init callback to make this id available in this callback.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>=20
> ---
>  include/net/net_namespace.h |    2 ++
>  net/core/net_namespace.c    |   36 +++++++++++++++++++++++++++++++++=
+++
>  2 files changed, 38 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.=
h
> index 0ab62ed..6971fdb 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -181,6 +181,8 @@ extern int register_pernet_subsys(struct pernet_o=
perations *);
>  extern void unregister_pernet_subsys(struct pernet_operations *);
>  extern int register_pernet_device(struct pernet_operations *);
>  extern void unregister_pernet_device(struct pernet_operations *);
> +extern int register_pernet_gen_device(int *id, struct pernet_operati=
ons *);
> +extern void unregister_pernet_gen_device(int id, struct pernet_opera=
tions *);
>=20
>  struct ctl_path;
>  struct ctl_table;
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 7b66083..7ef3bac 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -5,6 +5,7 @@
>  #include <linux/list.h>
>  #include <linux/delay.h>
>  #include <linux/sched.h>
> +#include <linux/idr.h>
>  #include <net/net_namespace.h>
>=20
>  /*
> @@ -253,6 +254,8 @@ static void unregister_pernet_operations(struct p=
ernet_operations *ops)
>  }
>  #endif
>=20
> +static DEFINE_IDA(net_generic_ids);
> +
>  /**
>   *      register_pernet_subsys - register a network namespace subsys=
tem
>   *	@ops:  pernet operations structure for the subsystem
> @@ -330,6 +333,28 @@ int register_pernet_device(struct pernet_operati=
ons *ops)
>  }
>  EXPORT_SYMBOL_GPL(register_pernet_device);
>=20
> +int register_pernet_gen_device(int *id, struct pernet_operations *op=
s)
> +{
> +	int error;
> +	mutex_lock(&net_mutex);
> +again:
> +	error =3D ida_get_new_above(&net_generic_ids, 1, id);
> +	if (error) {
> +		if (error =3D=3D -EAGAIN) {
> +			ida_pre_get(&net_generic_ids, GFP_KERNEL);
> +			goto again;
> +		}

		goto out;

> +	}
> +	error =3D register_pernet_operations(first_device, ops);
> +	if (error)
> +		ida_remove(&net_generic_ids, *id);
> +	else if (first_device =3D=3D &pernet_list)
> +		first_device =3D &ops->list;

out:

> +	mutex_unlock(&net_mutex);
> +	return error;
> +}
> +EXPORT_SYMBOL_GPL(register_pernet_gen_device);
> +
>  /**
>   *      unregister_pernet_device - unregister a network namespace ne=
tdevice
>   *	@ops: pernet operations structure to manipulate
> @@ -348,3 +373,14 @@ void unregister_pernet_device(struct pernet_oper=
ations *ops)
>  	mutex_unlock(&net_mutex);
>  }
>  EXPORT_SYMBOL_GPL(unregister_pernet_device);
> +
> +void unregister_pernet_gen_device(int id, struct pernet_operations *=
ops)
> +{
> +	mutex_lock(&net_mutex);
> +	if (&ops->list =3D=3D first_device)
> +		first_device =3D first_device->next;
> +	unregister_pernet_operations(ops);
> +	ida_remove(&net_generic_ids, id);
> +	mutex_unlock(&net_mutex);
> +}
> +EXPORT_SYMBOL_GPL(unregister_pernet_gen_device);


--=20






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
