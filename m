From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH v5 1/3] VSOCK: Add vsockmon tap functions
Date: Fri, 21 Apr 2017 14:40:39 +0000
Message-ID: <84E8B4A9-6CDF-460A-B093-233FE28462D8@vmware.com>
References: <20170421091046.5599-1-stefanha@redhat.com>
 <20170421091046.5599-2-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0072.outbound.protection.outlook.com ([104.47.34.72]:53366
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1038475AbdDUQjk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 12:39:40 -0400
In-Reply-To: <20170421091046.5599-2-stefanha@redhat.com>
Content-Language: en-US
Content-ID: <1AED7DD6BDE07644B5B92B4722639F0D@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Apr 21, 2017, at 11:10 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote=
:
>=20
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Add tap functions that can be used by the vsock transports to
> deliver packets to vsockmon virtual network devices.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> v5:
> * Change vsock_deliver_tap() API to avoid unnecessary skb creation
>   [Jorgen]
> * Fix skb leak when no taps are registered [Jorgen]
> * Add af_vsock_tap.c entry in MAINTAINERS
> * checkpatch.pl fixes
> v4:
> * Call synchronize_net() before module_put() [Michael]
> v3:
> * Include missing <linux/module.h> header in af_vsock_tap.c
> ---
> MAINTAINERS                  |   1 +
> net/vmw_vsock/Makefile       |   2 +-
> include/net/af_vsock.h       |  13 +++++
> include/uapi/linux/if_arp.h  |   1 +
> net/vmw_vsock/af_vsock_tap.c | 114 ++++++++++++++++++++++++++++++++++++++=
+++++
> 5 files changed, 130 insertions(+), 1 deletion(-)
> create mode 100644 net/vmw_vsock/af_vsock_tap.c
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index fdd5350..449e55f 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -13276,6 +13276,7 @@ L:	netdev@vger.kernel.org
> S:	Maintained
> F:	include/linux/virtio_vsock.h
> F:	include/uapi/linux/virtio_vsock.h
> +F:	net/vmw_vsock/af_vsock_tap.c
> F:	net/vmw_vsock/virtio_transport_common.c
> F:	net/vmw_vsock/virtio_transport.c
> F:	drivers/vhost/vsock.c
> diff --git a/net/vmw_vsock/Makefile b/net/vmw_vsock/Makefile
> index bc27c70..09fc2eb 100644
> --- a/net/vmw_vsock/Makefile
> +++ b/net/vmw_vsock/Makefile
> @@ -3,7 +3,7 @@ obj-$(CONFIG_VMWARE_VMCI_VSOCKETS) +=3D vmw_vsock_vmci_tr=
ansport.o
> obj-$(CONFIG_VIRTIO_VSOCKETS) +=3D vmw_vsock_virtio_transport.o
> obj-$(CONFIG_VIRTIO_VSOCKETS_COMMON) +=3D vmw_vsock_virtio_transport_comm=
on.o
>=20
> -vsock-y +=3D af_vsock.o vsock_addr.o
> +vsock-y +=3D af_vsock.o af_vsock_tap.o vsock_addr.o
>=20
> vmw_vsock_vmci_transport-y +=3D vmci_transport.o vmci_transport_notify.o =
\
> 	vmci_transport_notify_qstate.o
> diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
> index f32ed9a..f9fb566 100644
> --- a/include/net/af_vsock.h
> +++ b/include/net/af_vsock.h
> @@ -188,4 +188,17 @@ struct sock *vsock_find_connected_socket(struct sock=
addr_vm *src,
> void vsock_remove_sock(struct vsock_sock *vsk);
> void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
>=20
> +/**** TAP ****/
> +
> +struct vsock_tap {
> +	struct net_device *dev;
> +	struct module *module;
> +	struct list_head list;
> +};
> +
> +int vsock_init_tap(void);
> +int vsock_add_tap(struct vsock_tap *vt);
> +int vsock_remove_tap(struct vsock_tap *vt);
> +void vsock_deliver_tap(struct sk_buff *build_skb(void *opaque), void *op=
aque);
> +
> #endif /* __AF_VSOCK_H__ */
> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
> index 4d024d7..cf73510 100644
> --- a/include/uapi/linux/if_arp.h
> +++ b/include/uapi/linux/if_arp.h
> @@ -95,6 +95,7 @@
> #define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
> #define ARPHRD_NETLINK	824		/* Netlink header		*/
> #define ARPHRD_6LOWPAN	825		/* IPv6 over LoWPAN             */
> +#define ARPHRD_VSOCKMON	826		/* Vsock monitor header		*/
>=20
> #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
> #define ARPHRD_NONE	  0xFFFE	/* zero header length */
> diff --git a/net/vmw_vsock/af_vsock_tap.c b/net/vmw_vsock/af_vsock_tap.c
> new file mode 100644
> index 0000000..98f09b5
> --- /dev/null
> +++ b/net/vmw_vsock/af_vsock_tap.c
> @@ -0,0 +1,114 @@
> +/*
> + * Tap functions for AF_VSOCK sockets.
> + *
> + * Code based on net/netlink/af_netlink.c tap functions.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version
> + * 2 of the License, or (at your option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <net/sock.h>
> +#include <net/af_vsock.h>
> +#include <linux/if_arp.h>
> +
> +static DEFINE_SPINLOCK(vsock_tap_lock);
> +static struct list_head vsock_tap_all __read_mostly =3D
> +				LIST_HEAD_INIT(vsock_tap_all);
> +
> +int vsock_add_tap(struct vsock_tap *vt)
> +{
> +	if (unlikely(vt->dev->type !=3D ARPHRD_VSOCKMON))
> +		return -EINVAL;
> +
> +	__module_get(vt->module);
> +
> +	spin_lock(&vsock_tap_lock);
> +	list_add_rcu(&vt->list, &vsock_tap_all);
> +	spin_unlock(&vsock_tap_lock);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(vsock_add_tap);
> +
> +int vsock_remove_tap(struct vsock_tap *vt)
> +{
> +	struct vsock_tap *tmp;
> +	bool found =3D false;
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
> +	pr_warn("vsock_remove_tap: %p not found\n", vt);
> +out:
> +	spin_unlock(&vsock_tap_lock);
> +
> +	synchronize_net();
> +
> +	if (found)
> +		module_put(vt->module);
> +
> +	return found ? 0 : -ENODEV;
> +}
> +EXPORT_SYMBOL_GPL(vsock_remove_tap);
> +
> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
> +				   struct net_device *dev)
> +{
> +	int ret =3D 0;
> +	struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
> +
> +	if (nskb) {
> +		dev_hold(dev);
> +
> +		nskb->dev =3D dev;
> +		ret =3D dev_queue_xmit(nskb);
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
> +void vsock_deliver_tap(struct sk_buff *build_skb(void *opaque), void *op=
aque)
> +{
> +	struct sk_buff *skb;
> +
> +	rcu_read_lock();
> +
> +	if (likely(list_empty(&vsock_tap_all)))
> +		goto out;
> +
> +	skb =3D build_skb(opaque);
> +	if (skb) {
> +		__vsock_deliver_tap(skb);
> +		consume_skb(skb);
> +	}
> +
> +out:
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL_GPL(vsock_deliver_tap);
> --=20
> 2.9.3
>=20

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
