From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC 1/3] vsockmon: Add tap functions.
Date: Wed, 1 Jun 2016 14:07:03 -0700
Message-ID: <20160601210703.GF15594@stefanha-x1.localdomain>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MZf7D3rAEoQgPanC"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbcFAVHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 17:07:10 -0400
Content-Disposition: inline
In-Reply-To: <20160528162907.14809-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MZf7D3rAEoQgPanC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 28, 2016 at 06:29:05PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  include/net/af_vsock.h      |  13 ++++++
>  include/uapi/linux/if_arp.h |   1 +
>  net/vmw_vsock/af_vsock.c    | 105 ++++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 119 insertions(+)
>=20
> diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
> index 15694c9..c4593d8 100644
> --- a/include/net/af_vsock.h
> +++ b/include/net/af_vsock.h
> @@ -187,4 +187,17 @@ struct sock *vsock_find_connected_socket(struct sock=
addr_vm *src,
>  					 struct sockaddr_vm *dst);
>  void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
> =20
> +/**** TAP ****/
> +
> +struct vsock_tap {
> +	struct net_device *dev;
> +	struct module *module;
> +	struct list_head list;
> +};
> +
> +extern int vsock_init_tap(void);
> +extern int vsock_add_tap(struct vsock_tap *vt);
> +extern int vsock_remove_tap(struct vsock_tap *vt);
> +extern void vsock_deliver_tap(struct sk_buff *skb);

The other function prototypes in this header don't use "extern" either.
Please drop for consistency.

> +
>  #endif /* __AF_VSOCK_H__ */
> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
> index 4d024d7..869262a 100644
> --- a/include/uapi/linux/if_arp.h
> +++ b/include/uapi/linux/if_arp.h
> @@ -95,6 +95,7 @@
>  #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
>  #define ARPHRD_NETLINK	824		/* Netlink header		*/
>  #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
> +#define ARPHRD_VSOCKMON 826		/* Vsock monitor header		*/

Previous lines use a tab character (^I) before the numeric constant.
Please follow that style for consistency.

I suggest calling it just ARPHRD_VSOCK.  Netlink also uses
ARPHRD_NETLINK instead of ARPHRD_NLMON.

> =20
>  #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
>  #define ARPHRD_NONE	  0xFFFE	/* zero header length */
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index 6b158ab..ec7a05d 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -96,6 +96,7 @@
>  #include <linux/unistd.h>
>  #include <linux/wait.h>
>  #include <linux/workqueue.h>
> +#include <linux/if_arp.h>
>  #include <net/sock.h>
>  #include <net/af_vsock.h>
> =20
> @@ -2012,6 +2013,110 @@ const struct vsock_transport *vsock_core_get_tran=
sport(void)
>  }
>  EXPORT_SYMBOL_GPL(vsock_core_get_transport);
> =20
> +/**** TAP ****/

Feel free to put this in a separate source file.  The Kbuild can link
multiple objects into a single kernel module.  That would be cleaner
than using a big comment to separate it from af_vsock.c code.

I wonder whether this tap mechanism should be generic so that netlink,
vsock, and other address families can reuse the code.  This is basically
copied from netlink.

> +static DEFINE_SPINLOCK(vsock_tap_lock);
> +static struct list_head vsock_tap_all __read_mostly;
> +
> +int vsock_init_tap(void) {
> +	INIT_LIST_HEAD(&vsock_tap_all);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(vsock_init_tap);

Can you use LIST_HEAD_INIT() on the vsock_tap_all declaration line to
eliminate the need for vsock_init_tap() completely?

> +
> +int vsock_add_tap(struct vsock_tap *vt) {
> +	if (unlikely(vt->dev->type !=3D ARPHRD_VSOCKMON))
> +		return -EINVAL;
> +
> +	spin_lock(&vsock_tap_lock);
> +	list_add_rcu(&vt->list, &vsock_tap_all);
> +	spin_unlock(&vsock_tap_lock);
> +
> +	__module_get(vt->module);

It's slightly safer to get the module before publishing it on the list.
But in practice I guess the caller is the module so the module won't
disappear underneath us.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(vsock_add_tap);
> +
> +int __vsock_remove_tap(struct vsock_tap *vt) {
> +	bool found =3D false;
> +	struct vsock_tap *tmp;
> +
> +	spin_lock(&vsock_tap_lock);
> +
> +	list_for_each_entry(tmp, &vsock_tap_all, list) {
> +		if (vt =3D=3D tmp) {
> +			list_del_rcu(&vt->list);
> +			found =3D true;
> +			goto out;
> +		}
> +	}
> +
> +	pr_warn("__vsock_remove_tap: %p not found\n", vt);
> +out:
> +	spin_unlock(&vsock_tap_lock);
> +
> +	if (found)
> +		module_put(vt->module);
> +
> +	return found ? 0 : -ENODEV;
> +}
> +
> +int vsock_remove_tap(struct vsock_tap *vt)
> +{
> +	int ret;
> +
> +	ret =3D __vsock_remove_tap(vt);
> +	synchronize_net();

module_put() should be called after synchronize_net().  That way we
guarantee that no one is still accessing vt when the module is put.  The
caller is probably the module though, so maybe there is an implicit
reference...

> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(vsock_remove_tap);
> +
> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
> +				     struct net_device *dev)
> +{
> +	struct sk_buff *vskb;
> +	int ret =3D 0;
> +
> +	if (skb) {
> +		dev_hold(dev);
> +		vskb =3D skb_clone(skb, GFP_ATOMIC);

You must handle the case where skb_clone() returns NULL.  In other
words, we don't have enough memory to capture the packet and just return
-ENOMEM.

> +		vskb->dev =3D dev;
> +		vskb->pkt_type =3D PACKET_USER;

I'm not sure if PACKET_USER is correct (or if pkt_type matters at all).

PACKET_USER/PACKET_KERNEL seems to be purely a netlink concept to
distinguish netlink packets originating from the kernel or userspace.

AF_VSOCK is more like Ethernet where packets come from the host itself
or from a VM.  I would consider PACKET_HOST and PACKET_OTHERHOST.

> +		ret =3D dev_queue_xmit(vskb);
> +		if (unlikely(ret > 0))
> +			ret =3D net_xmit_errno(ret);
> +
> +		dev_put(dev);
> +	}
> +
> +	return ret;
> +}
> +
> +static void __vsock_deliver_tap(struct sk_buff *skb)
> +{
> +	int ret;
> +	struct vsock_tap *tmp;
> +
> +	list_for_each_entry_rcu(tmp, &vsock_tap_all, list) {
> +		ret =3D __vsock_deliver_tap_skb(skb, tmp->dev);
> +		if (unlikely(ret))
> +			break;
> +	}
> +}
> +
> +void vsock_deliver_tap(struct sk_buff *skb)
> +{
> +	rcu_read_lock();
> +
> +	if (unlikely(!list_empty(&vsock_tap_all)))
> +		__vsock_deliver_tap(skb);
> +
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL_GPL(vsock_deliver_tap);
> +
>  MODULE_AUTHOR("VMware, Inc.");
>  MODULE_DESCRIPTION("VMware Virtual Socket Family");
>  MODULE_VERSION("1.0.1.0-k");
> --=20
> 2.8.3
>=20

--MZf7D3rAEoQgPanC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXT053AAoJEJykq7OBq3PIFHsH/RjRdIeRJ2xKUgl2eZ4gZEzr
ocYD0gyMCtkYUD7MfmddXk0gCSQxj5NsigTV08SBzjd8FRuxvp31YC6zMGrp5lxg
tT3VXKpzQjVrlHqPAreytg2MlMVf6RI0QZTXUeBm6EFNaBVV3ELiqOX1IOiu7om0
YN56e3BUZjmHRLiYMUgffU93Y5tnx5MCaRaXyQmwoDdDRV1jYsVhnmEb6KuHCnDt
nAdMlBAFn/HGd1d1QEut54FAN1fO6XNzc1mE9liSslzWG0sgUi+ZFLd3bbjWuz+p
erl8VXppf+2zLg5hwTZMo5nBiRnspmGSu559PRDeEBJpO0QrM0TVVHBuCWsMNTc=
=+7ZD
-----END PGP SIGNATURE-----

--MZf7D3rAEoQgPanC--
