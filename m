From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [RFC] ehea: kdump support using new shutdown hook
Date: Thu, 13 Dec 2007 06:41:52 +0000
Message-ID: <1197528112.7695.54.camel@concordia>
References: <200712121753.43543.osstklei@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3TULCC3kdzQcbgSdk0py"
Cc: Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Neuling <mikey@neuling.org>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35681 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760407AbXLMGlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 01:41:53 -0500
In-Reply-To: <200712121753.43543.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3TULCC3kdzQcbgSdk0py
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-12-12 at 17:53 +0100, Thomas Klein wrote:
> This patch adds kdump support using the new PPC crash shutdown hook to th=
e
> ehea driver. The driver now keeps a list of firmware handles which have t=
o
> be freed in case of a crash. The crash handler does the minimum required:=
 it
> frees the firmware resource handles plus broadcast/multicast registration=
s.
>=20
> Please comment.

Hi Thomas,

Here's a few ..

> ---
> diff -Nurp -X dontdiff linux-2.6.24-rc5/drivers/net/ehea/ehea.h patched_k=
ernel/drivers/net/ehea/ehea.h
> --- linux-2.6.24-rc5/drivers/net/ehea/ehea.h	2007-12-11 04:48:43.00000000=
0 +0100
> +++ patched_kernel/drivers/net/ehea/ehea.h	2007-12-12 17:30:53.000000000 =
+0100
> @@ -386,6 +386,7 @@ struct ehea_port_res {
> =20
>=20
>  #define EHEA_MAX_PORTS 16
> +#define EHEA_MAX_RES_HANDLES (100 * EHEA_MAX_PORTS + 10)
>  struct ehea_adapter {
>  	u64 handle;
>  	struct of_device *ofdev;
> @@ -397,6 +398,7 @@ struct ehea_adapter {
>  	u64 max_mc_mac;            /* max number of multicast mac addresses */
>  	int active_ports;
>  	struct list_head list;
> +	u64 res_handles[EHEA_MAX_RES_HANDLES];
>  };

I don't like this ..

> diff -Nurp -X dontdiff linux-2.6.24-rc5/drivers/net/ehea/ehea_main.c patc=
hed_kernel/drivers/net/ehea/ehea_main.c
> --- linux-2.6.24-rc5/drivers/net/ehea/ehea_main.c	2007-12-11 04:48:43.000=
000000 +0100
> +++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-12-12 17:30:53.00000=
0000 +0100
> @@ -35,6 +35,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/notifier.h>
>  #include <linux/reboot.h>
> +#include <asm-powerpc/kexec.h>

Just <asm/kexec.h>

> @@ -3302,6 +3333,71 @@ static int __devexit ehea_remove(struct=20
>  	return 0;
>  }
> =20
> +void ehea_crash_deregister(void)
> +{
> +	struct ehea_adapter *adapter;
> +	int i;
> +	u64 hret;
> +	u8 reg_type;
> +
> +	list_for_each_entry(adapter, &adapter_list, list) {
> +		for (i =3D 0; i < EHEA_MAX_PORTS; i++) {
> +			struct ehea_port *port =3D adapter->port[i];
> +			if (port->state =3D=3D EHEA_PORT_UP) {
> +				struct ehea_mc_list *mc_entry =3D port->mc_list;
> +				struct list_head *pos;
> +				struct list_head *temp;
> +
> +				/* Undo multicast registrations */
> +				list_for_each_safe(pos, temp,
> +						   &(port->mc_list->list)) {
> +					mc_entry =3D list_entry(pos,
> +							    struct ehea_mc_list,
> +							    list);
> +					ehea_multicast_reg_helper(port,
> +							      mc_entry->macaddr,
> +							      H_DEREG_BCMC);
> +				}
> +
> +				/* Undo broad registration */
> +				reg_type =3D EHEA_BCMC_BROADCAST |
> +					   EHEA_BCMC_UNTAGGED;
> +				ehea_h_reg_dereg_bcmc(port->adapter->handle,
> +						      port->logical_port_id,
> +						      reg_type, port->mac_addr,
> +						      0, H_DEREG_BCMC);
> +
> +				reg_type =3D EHEA_BCMC_BROADCAST |
> +					   EHEA_BCMC_VLANID_ALL;
> +				ehea_h_reg_dereg_bcmc(port->adapter->handle,
> +						      port->logical_port_id,
> +						      reg_type, port->mac_addr,
> +						      0, H_DEREG_BCMC);
> +			}
> +		}
> +		for (i =3D 0; i < EHEA_MAX_RES_HANDLES; i++) {
> +			u64 handle =3D adapter->res_handles[i];
> +			if (handle) {
> +				hret =3D ehea_h_free_resource(adapter->handle,
> +							    handle,
> +							    FORCE_FREE);
> +			}
> +		}
> +
> +		if (adapter->neq) {
> +			hret =3D ehea_h_free_resource(adapter->handle,
> +						    adapter->neq->fw_handle,
> +						    FORCE_FREE);
> +		}
> +
> +		if (adapter->mr.handle) {
> +			hret =3D ehea_h_free_resource(adapter->handle,
> +						    adapter->mr.handle,
> +						    FORCE_FREE);
> +		}
> +	}
> +}

This is sort of on the right track, I like that the ehea_h_.. routines
are basically just hypercalls, but there's a few things wrong. You're
walking a linked list, which is asking for trouble, if a single pointer
is corrupted you'll walk off into lala land. Then you're pulling fields
out of structs via pointers, again hoping that they're all valid. Then
you walk another linked list ..  And then you're pulling bits out of the
adapter again.

Ideally it would look like this:

static u64 things_to_free[];

void ehea_crash_deregister(void)
{
	for (i =3D 0; i < num_things_to_free; i++)
		h_call_free_a_thing(things_to_free[i]);
}

>  static int ehea_reboot_notifier(struct notifier_block *nb,
>  				unsigned long action, void *unused)
>  {
> @@ -3373,6 +3469,9 @@ int __init ehea_module_init(void)
>  		goto out;
> =20
>  	register_reboot_notifier(&ehea_reboot_nb);
> +	ret =3D crash_shutdown_register(&ehea_crash_deregister);
> +	if (ret)
> +		ehea_info("failed registering crash handler");

Your naming is a little confusing here, you're registering the
deregister function. I think I get it, you're unregistering the fw
handles, but perhaps ehea_crash_shutdown() would be clearer.

> @@ -3396,10 +3496,15 @@ out:
> =20
>  static void __exit ehea_module_exit(void)
>  {
> +	int ret;
> +
>  	flush_scheduled_work();
>  	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
>  	ibmebus_unregister_driver(&ehea_driver);
>  	unregister_reboot_notifier(&ehea_reboot_nb);
> +	ret =3D crash_shutdown_unregister(&ehea_crash_deregister);
> +	if (ret)
> +		ehea_info("failed unregistering crash handler");

You don't need ret if that's all you're going to do with it.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-3TULCC3kdzQcbgSdk0py
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHYNQwdSjSd0sB4dIRArpyAKDLIcJB5gaK3prGLG3z6Kr1fBibUgCgxVOb
TXg7wBVSy7QhNGZ8SaWKpDs=
=Ze4r
-----END PGP SIGNATURE-----

--=-3TULCC3kdzQcbgSdk0py--

