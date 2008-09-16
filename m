From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 04/14] Phonet: PF_PHONET protocol family support
Date: Tue, 16 Sep 2008 13:17:47 -0300
Message-ID: <20080916161747.GH8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-4-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49797 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755188AbYIPQ0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 12:26:44 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-4-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:04PM +0300, R=E9mi Denis-Courmont escreve=
u:
> This is the basis for the Phonet protocol families, and introduces
> the ETH_P_PHONET packet type and the PF_PHONET socket family.
>=20
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/net/phonet/phonet.h |   71 ++++++++++++++
>  net/phonet/Makefile         |    3 +-
>  net/phonet/af_phonet.c      |  218 +++++++++++++++++++++++++++++++++=
++++++++++
>  3 files changed, 291 insertions(+), 1 deletions(-)
>  create mode 100644 include/net/phonet/phonet.h
>  create mode 100644 net/phonet/af_phonet.c
>=20
> diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.=
h
> new file mode 100644
> index 0000000..be02ee9
> --- /dev/null
> +++ b/include/net/phonet/phonet.h
> @@ -0,0 +1,71 @@
> +/*
> + * File: af_phonet.h
> + *
> + * Phonet sockets kernel definitions
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
> +#ifndef AF_PHONET_H
> +#define AF_PHONET_H
> +
> +/*
> + * The lower layers may not require more space, ever. Make sure it's
> + * enough.
> + */
> +#define MAX_PHONET_HEADER	8
> +
> +#define pn_hdr(skb) ((struct phonethdr *)skb_network_header(skb))
> +
> +/*
> + * Get the other party's sockaddr from received skb. The skb begins
> + * with a Phonet header.
> + */
> +static inline
> +void pn_skb_get_src_sockaddr(struct sk_buff *skb, struct sockaddr_pn=
 *sa)
> +{
> +	struct phonethdr *ph =3D pn_hdr(skb);
> +	uint16_t obj =3D pn_object(ph->sdev, ph->sobj);
> +
> +	sa->spn_family =3D AF_PHONET;
> +	pn_sockaddr_set_object(sa, obj);
> +	pn_sockaddr_set_resource(sa, ph->function);
> +	memset(sa->spn_zero, 0, sizeof(sa->spn_zero));
> +}
> +
> +static inline
> +void pn_skb_get_dst_sockaddr(struct sk_buff *skb, struct sockaddr_pn=
 *sa)
> +{
> +	struct phonethdr *ph =3D pn_hdr(skb);
> +	uint16_t obj =3D pn_object(ph->rdev, ph->robj);
> +
> +	sa->spn_family =3D AF_PHONET;
> +	pn_sockaddr_set_object(sa, obj);
> +	pn_sockaddr_set_resource(sa, ph->function);
> +	memset(sa->spn_zero, 0, sizeof(sa->spn_zero));
> +}
> +
> +/* Protocols in Phonet protocol family. */
> +struct phonet_protocol {
> +	struct proto		*prot;
> +	int			sock_type;
> +};

Without looking in detail, first reaction is: don't we have sk_type in
struct sock? Can't it be used or what you would have in
ponet_protocol->sock_type be mapped to it?

Lemme continue, perhaps phonet_proto_register can tell me...

> +int phonet_proto_register(int protocol, struct phonet_protocol *pp);
> +void phonet_proto_unregister(int protocol, struct phonet_protocol *p=
p);
> +
> +#endif
> diff --git a/net/phonet/Makefile b/net/phonet/Makefile
> index 4ced746..5dbff68 100644
> --- a/net/phonet/Makefile
> +++ b/net/phonet/Makefile
> @@ -1,3 +1,4 @@
>  obj-$(CONFIG_PHONET) +=3D phonet.o
> =20
> -phonet-objs :=3D
> +phonet-objs :=3D \
> +	af_phonet.o
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> new file mode 100644
> index 0000000..ed66a81
> --- /dev/null
> +++ b/net/phonet/af_phonet.c
> @@ -0,0 +1,218 @@
> +/*
> + * File: af_phonet.c
> + *
> + * Phonet protocols family
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
> +#include <linux/module.h>
> +#include <asm/unaligned.h>
> +#include <net/sock.h>
> +
> +#include <linux/if_phonet.h>
> +#include <linux/phonet.h>
> +#include <net/phonet/phonet.h>
> +
> +static struct net_proto_family phonet_proto_family;
> +static struct phonet_protocol *phonet_proto_get(int protocol);
> +static inline void phonet_proto_put(struct phonet_protocol *pp);
> +
> +/* protocol family functions */
> +
> +static int pn_socket_create(struct net *net, struct socket *sock, in=
t protocol)
> +{
> +	struct phonet_protocol *pnp;
> +	int err;
> +
> +	if (net !=3D &init_net)
> +		return -EAFNOSUPPORT;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	if (protocol =3D=3D 0) {
> +		/* Default protocol selection */
> +		switch (sock->type) {
> +		case SOCK_RDM:
> +		case SOCK_DGRAM:
> +			protocol =3D PN_PROTO_PHONET;
> +			break;

Here, the mapping, and we even have struct socket sock->type in additio=
n
to struct sock->sk_type

> +		default:
> +			return -EPROTONOSUPPORT;
> +		}
> +	}
> +
> +	pnp =3D phonet_proto_get(protocol);
> +	if (pnp =3D=3D NULL)
> +		return -EPROTONOSUPPORT;
> +	if (sock->type !=3D pnp->sock_type &&
> +	    (protocol !=3D PN_PROTO_PHONET || sock->type !=3D SOCK_RDM)) {
> +		err =3D -EPROTONOSUPPORT;
> +		goto out;
> +	}
> +
> +	/* TODO: create and init the struct sock */

I see, you're ot using struct sock at all :-)

> +	err =3D -EPROTONOSUPPORT;
> +
> +out:
> +	phonet_proto_put(pnp);
> +	return err;
> +}
> +
> +static struct net_proto_family phonet_proto_family =3D {
> +	.family =3D AF_PHONET,
> +	.create =3D pn_socket_create,
> +	.owner =3D THIS_MODULE,
> +};
> +
> +/* packet type functions */
> +
> +/*
> + * Stuff received packets to associated sockets.
> + * On error, returns non-zero and releases the skb.
> + */
> +static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
> +			struct packet_type *pkttype,
> +			struct net_device *orig_dev)
> +{
> +	struct phonethdr *ph;
> +	struct sockaddr_pn sa;
> +	u16 len;
> +
> +	if (dev_net(dev) !=3D &init_net)
> +		goto out;
> +
> +	/* check we have at least a full Phonet header */
> +	if (!pskb_pull(skb, sizeof(struct phonethdr)))
> +		goto out;
> +
> +	/* check that the advertised length is correct */
> +	ph =3D pn_hdr(skb);
> +	len =3D get_unaligned_be16(&ph->length);
> +	if (len < 2)
> +		goto out;
> +	len -=3D 2;
> +	if ((len > skb->len) || pskb_trim(skb, len))
> +		goto out;
> +	skb_reset_transport_header(skb);
> +
> +	pn_skb_get_dst_sockaddr(skb, &sa);
> +	if (pn_sockaddr_get_addr(&sa) =3D=3D 0)
> +		goto out; /* currently, we cannot be device 0 */
> +
> +	/* TODO: put packets to sockets backlog */

I guess this will be done in the next patches, interesting way of
breaking up the patches...

> +out:
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +
> +static struct packet_type phonet_packet_type =3D {
> +	.type =3D __constant_htons(ETH_P_PHONET),
> +	.dev =3D NULL,
> +	.func =3D phonet_rcv,
> +};
> +
> +/* Transport protocol registration */
> +static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostl=
y;
> +static DEFINE_SPINLOCK(proto_tab_lock);
> +
> +int __init_or_module phonet_proto_register(int protocol,
> +						struct phonet_protocol *pp)
> +{
> +	int err =3D 0;
> +
> +	if (protocol >=3D PHONET_NPROTO)
> +		return -EINVAL;
> +
> +	err =3D proto_register(pp->prot, 1);

Cool, it uses proto_register :-)

> +	if (err)
> +		return err;
> +
> +	spin_lock(&proto_tab_lock);
> +	if (proto_tab[protocol])
> +		err =3D -EBUSY;
> +	else
> +		proto_tab[protocol] =3D pp;
> +	spin_unlock(&proto_tab_lock);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(phonet_proto_register);
> +
> +void phonet_proto_unregister(int protocol, struct phonet_protocol *p=
p)
> +{
> +	spin_lock(&proto_tab_lock);
> +	BUG_ON(proto_tab[protocol] !=3D pp);
> +	proto_tab[protocol] =3D NULL;
> +	spin_unlock(&proto_tab_lock);
> +	proto_unregister(pp->prot);
> +}
> +EXPORT_SYMBOL(phonet_proto_unregister);
> +
> +static struct phonet_protocol *phonet_proto_get(int protocol)
> +{
> +	struct phonet_protocol *pp;
> +
> +	if (protocol >=3D PHONET_NPROTO)
> +		return NULL;
> +
> +	spin_lock(&proto_tab_lock);
> +	pp =3D proto_tab[protocol];
> +	if (pp && !try_module_get(pp->prot->owner))
> +		pp =3D NULL;
> +	spin_unlock(&proto_tab_lock);
> +
> +	return pp;
> +}
> +
> +static inline void phonet_proto_put(struct phonet_protocol *pp)
> +{
> +	module_put(pp->prot->owner);
> +}
> +
> +/* Module registration */
> +static int __init phonet_init(void)
> +{
> +	int err;
> +
> +	err =3D sock_register(&phonet_proto_family);
> +	if (err) {
> +		printk(KERN_ALERT
> +			"phonet protocol family initialization failed\n");
> +		return err;
> +	}
> +
> +	dev_add_pack(&phonet_packet_type);
> +	return 0;
> +}
> +
> +static void __exit phonet_exit(void)
> +{
> +	sock_unregister(AF_PHONET);
> +	dev_remove_pack(&phonet_packet_type);
> +}
> +
> +module_init(phonet_init);
> +module_exit(phonet_exit);
> +MODULE_DESCRIPTION("Phonet protocol stack for Linux");
> +MODULE_LICENSE("GPL");
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
