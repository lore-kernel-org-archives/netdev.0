From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 10/14] Phonet: Phonet datagram transport protocol
Date: Tue, 16 Sep 2008 14:06:44 -0300
Message-ID: <20080916170644.GM8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-10-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57795 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbYIPRP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 13:15:59 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-10-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:10PM +0300, R=E9mi Denis-Courmont escreve=
u:
> This provides the basic SOCK_DGRAM transport protocol for Phonet.
>=20
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/net/phonet/phonet.h |    6 ++
>  net/phonet/Makefile         |    1 +
>  net/phonet/af_phonet.c      |  108 +++++++++++++++++++++++
>  net/phonet/datagram.c       |  198 +++++++++++++++++++++++++++++++++=
++++++++++
>  4 files changed, 313 insertions(+), 0 deletions(-)
>  create mode 100644 net/phonet/datagram.c
>=20
> diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.=
h
> index 1131833..ead764d 100644
> --- a/include/net/phonet/phonet.h
> +++ b/include/net/phonet/phonet.h
> @@ -49,6 +49,9 @@ void pn_sock_hash(struct sock *sk);
>  void pn_sock_unhash(struct sock *sk);
>  int pn_sock_get_port(struct sock *sk, unsigned short sport);
> =20
> +int pn_skb_send(struct sock *sk, struct sk_buff *skb,
> +		const struct sockaddr_pn *target);
> +
>  #define pn_hdr(skb) ((struct phonethdr *)skb_network_header(skb))
> =20
>  /*
> @@ -91,4 +94,7 @@ void phonet_proto_unregister(int protocol, struct p=
honet_protocol *pp);
> =20
>  void phonet_socket_init(void);
>  void phonet_netlink_register(void);
> +int isi_register(void);
> +void isi_unregister(void);
> +
>  #endif
> diff --git a/net/phonet/Makefile b/net/phonet/Makefile
> index c1d671d..d218abc 100644
> --- a/net/phonet/Makefile
> +++ b/net/phonet/Makefile
> @@ -4,4 +4,5 @@ phonet-objs :=3D \
>  	pn_dev.o \
>  	pn_netlink.o \
>  	socket.o \
> +	datagram.o \
>  	af_phonet.o
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 1628e7c..ec99413 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -101,6 +101,107 @@ static struct net_proto_family phonet_proto_fam=
ily =3D {
>  	.owner =3D THIS_MODULE,
>  };
> =20
> +/*
> + * Prepends an ISI header and sends a datagram.
> + */
> +static int pn_send(struct sk_buff *skb, struct net_device *dev,
> +			u16 dst, u16 src, u8 res)
> +{
> +	struct phonethdr *ph;
> +	int err;
> +
> +	if (skb->len > 0xfffd) {

wow, what a magic number! :-)

> +		err =3D -EMSGSIZE;
> +		goto drop;
> +	}
> +
> +	skb_reset_transport_header(skb);
> +	WARN_ON(skb_headroom(skb) & 1); /* HW assumes word alignment */
> +	ph =3D (struct phonethdr *)skb_push(skb, sizeof(struct phonethdr));
> +	skb_reset_network_header(skb);

Here you could just use:

	ph =3D (struct phonethdr *)skb_network_header(skb);

	or even just:

	ph =3D pn_hdr(skb);

	as other protocols such as IP do (see ip_hdr())

> +	ph->rdev =3D pn_dev(dst);
> +	ph->sdev =3D pn_dev(src);
> +	ph->function =3D res;
> +	ph->length =3D __cpu_to_be16(skb->len + 2 - sizeof(*ph));
> +	ph->robj =3D pn_obj(dst);
> +	ph->sobj =3D pn_obj(src);
> +
> +	skb->protocol =3D __constant_htons(ETH_P_PHONET);

No need for __constant_htons(CONSTANT), htons will do the right thing
and the code will be shorter, clearer.

> +	skb->priority =3D 0;
> +	skb->dev =3D dev;
> +
> +	if (pn_addr(src) =3D=3D pn_addr(dst)) {
> +		skb_reset_mac_header(skb);
> +		skb->pkt_type =3D PACKET_LOOPBACK;
> +		skb_orphan(skb);
> +		netif_rx_ni(skb);
> +		err =3D 0;
> +	} else {
> +		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
> +					NULL, NULL, skb->len);
> +		if (err < 0) {
> +			err =3D -EHOSTUNREACH;
> +			goto drop;
> +		}
> +		err =3D dev_queue_xmit(skb);
> +	}
> +
> +	return err;
> +drop:
> +	kfree_skb(skb);
> +	return err;
> +}
> +
> +/*
> + * Create a Phonet header for the skb and send it out. Returns
> + * non-zero error code if failed. The skb is freed then.
> + */
> +int pn_skb_send(struct sock *sk, struct sk_buff *skb,
> +		const struct sockaddr_pn *target)
> +{
> +	struct net_device *dev;
> +	struct phonet_address *pna =3D NULL;
> +	struct pn_sock *pn =3D pn_sk(sk);
> +	int err;
> +	uint16_t src;
> +	uint8_t addr =3D pn_sockaddr_get_addr(target);
> +
> +	spin_lock_bh(&pndevs.lock);
> +	if (sk->sk_bound_dev_if) {
> +		struct phonet_device *pnd;
> +
> +		pnd =3D __phonet_get_by_index(sk->sk_bound_dev_if);
> +		if (pnd && (pnd->netdev->flags & IFF_UP))
> +			pna =3D phonet_dev2addr(pnd, addr, 0);
> +	} else {
> +		pna =3D phonet_addr2addr(pn_sockaddr_get_addr(target), 0);
> +	}
> +
> +	if (pna =3D=3D NULL) {
> +		spin_unlock_bh(&pndevs.lock);
> +		err =3D -EHOSTUNREACH;
> +		goto drop;
> +	}
> +
> +	src =3D pn->sobject;
> +	if (!pn_addr(src))
> +		src =3D pn_object(pna->addr, pn_obj(src));
> +
> +	dev =3D pna->pnd->netdev;
> +	dev_hold(dev);
> +	spin_unlock_bh(&pndevs.lock);
> +
> +	err =3D pn_send(skb, dev, pn_sockaddr_get_object(target),
> +			src, pn_sockaddr_get_resource(target));
> +	dev_put(dev);
> +	return err;
> +
> +drop:
> +	kfree_skb(skb);
> +	return err;
> +}
> +EXPORT_SYMBOL(pn_skb_send);
> +
>  /* packet type functions */
> =20
>  /*
> @@ -238,8 +339,14 @@ static int __init phonet_init(void)
> =20
>  	dev_add_pack(&phonet_packet_type);
>  	phonet_netlink_register();
> +
> +	err =3D isi_register();
> +	if (err)
> +		goto err2;
>  	return 0;
> =20
> +err2:
> +	phonet_device_exit();
>  unregister:
>  	sock_unregister(AF_PHONET);
>  	return err;
> @@ -247,6 +354,7 @@ unregister:
> =20
>  static void __exit phonet_exit(void)
>  {
> +	isi_unregister();
>  	sock_unregister(AF_PHONET);
>  	dev_remove_pack(&phonet_packet_type);
>  	phonet_device_exit();
> diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
> new file mode 100644
> index 0000000..5d8e701
> --- /dev/null
> +++ b/net/phonet/datagram.c
> @@ -0,0 +1,198 @@
> +/*
> + * File: datagram.c
> + *
> + * Datagram (ISI) Phonet sockets
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
> +#include <linux/socket.h>
> +#include <asm/ioctls.h>
> +#include <net/sock.h>
> +
> +#include <linux/phonet.h>
> +#include <net/phonet/phonet.h>
> +
> +static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb);
> +
> +/* associated socket ceases to exist */
> +static void pn_sock_close(struct sock *sk, long timeout)
> +{
> +	sk_common_release(sk);
> +}
> +
> +static int pn_ioctl(struct sock *sk, int cmd, unsigned long arg)
> +{
> +	struct sk_buff *skb;
> +	int answ;
> +
> +	switch (cmd) {
> +	case SIOCINQ:
> +		spin_lock_bh(&sk->sk_receive_queue.lock);
> +		skb =3D skb_peek(&sk->sk_receive_queue);
> +		answ =3D skb ? skb->len : 0;
> +		spin_unlock_bh(&sk->sk_receive_queue.lock);
> +		return put_user(answ, (int __user *)arg);

Why not use lock_sock/release_sock as tcp?

> +	}
> +
> +	return -ENOIOCTLCMD;
> +}
> +
> +/* Destroy socket. All references are gone. */
> +static void pn_destruct(struct sock *sk)
> +{
> +	skb_queue_purge(&sk->sk_receive_queue);
> +}
> +
> +static int pn_init(struct sock *sk)
> +{
> +	sk->sk_destruct =3D pn_destruct;
> +	pn_sk(sk)->handler =3D pn_backlog_rcv;

Humm, why not use sk_receive_skb/ sk_backlog_rcv?

> +	return 0;
> +}
> +
> +static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
> +			struct msghdr *msg, size_t len)
> +{
> +	struct sockaddr_pn *target;
> +	struct sk_buff *skb;
> +	int err;
> +
> +	if (msg->msg_flags & MSG_OOB)
> +		return -EOPNOTSUPP;
> +
> +	if (msg->msg_name =3D=3D NULL)
> +		return -EDESTADDRREQ;
> +
> +	if (msg->msg_namelen < sizeof(struct sockaddr_pn))
> +		return -EINVAL;
> +
> +	target =3D (struct sockaddr_pn *)msg->msg_name;
> +	if (target->spn_family !=3D AF_PHONET)
> +		return -EAFNOSUPPORT;
> +
> +	skb =3D sock_alloc_send_skb(sk, MAX_PHONET_HEADER + len,
> +					msg->msg_flags & MSG_DONTWAIT, &err);
> +	if (skb =3D=3D NULL)
> +		return err;
> +	skb_reserve(skb, MAX_PHONET_HEADER);
> +
> +	err =3D memcpy_fromiovec((void *)skb_put(skb, len), msg->msg_iov, l=
en);
> +	if (err < 0) {
> +		kfree_skb(skb);
> +		return err;
> +	}
> +
> +	/*
> +	 * Fill in the Phonet header and
> +	 * finally pass the packet forwards.
> +	 */
> +	err =3D pn_skb_send(sk, skb, target);
> +
> +	/* If ok, return len. */
> +	return (err >=3D 0) ? len : err;
> +}
> +
> +static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
> +			struct msghdr *msg, size_t len, int noblock,
> +			int flags, int *addr_len)
> +{
> +	struct sk_buff *skb =3D NULL;
> +	struct sockaddr_pn sa;
> +	int rval =3D -EOPNOTSUPP;
> +	int copylen;
> +
> +	if (flags & MSG_OOB)
> +		goto out_nofree;
> +
> +	if (addr_len)
> +		*addr_len =3D sizeof(sa);
> +
> +	skb =3D skb_recv_datagram(sk, flags, noblock, &rval);
> +	if (skb =3D=3D NULL)
> +		goto out_nofree;
> +
> +	pn_skb_get_src_sockaddr(skb, &sa);
> +
> +	copylen =3D skb->len;
> +	if (len < copylen) {
> +		msg->msg_flags |=3D MSG_TRUNC;
> +		copylen =3D len;
> +	}
> +
> +	rval =3D skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copylen);
> +	if (rval) {
> +		rval =3D -EFAULT;
> +		goto out;
> +	}
> +
> +	rval =3D (flags & MSG_TRUNC) ? skb->len : copylen;
> +
> +	if (msg->msg_name !=3D NULL)
> +		memcpy(msg->msg_name, &sa, sizeof(struct sockaddr_pn));
> +
> +out:
> +	skb_free_datagram(sk, skb);
> +
> +out_nofree:
> +	return rval;
> +}
> +
> +/* Queue an skb for a sock. */
> +static int pn_backlog_rcv(struct sock *sk, struct sk_buff *skb)
> +{
> +	int err =3D sock_queue_rcv_skb(sk, skb);
> +	if (err < 0)
> +		kfree_skb(skb);
> +	return err;
> +}
> +
> +/* Module registration */
> +static struct proto pn_proto =3D {
> +	.close		=3D pn_sock_close,
> +	.ioctl		=3D pn_ioctl,
> +	.init		=3D pn_init,
> +	.sendmsg	=3D pn_sendmsg,
> +	.recvmsg	=3D pn_recvmsg,
> +	.backlog_rcv	=3D pn_backlog_rcv,

And here you even seem to use it :-)

> +	.hash		=3D pn_sock_hash,
> +	.unhash		=3D pn_sock_unhash,
> +	.get_port	=3D pn_sock_get_port,
> +	.obj_size	=3D sizeof(struct pn_sock),
> +	.owner		=3D THIS_MODULE,
> +	.name		=3D "PHONET",
> +};
> +
> +static struct phonet_protocol pn_dgram_proto =3D {
> +	.ops		=3D &phonet_dgram_ops,
> +	.prot		=3D &pn_proto,
> +	.sock_type	=3D SOCK_DGRAM,
> +};
> +
> +int __init isi_register(void)
> +{
> +	return phonet_proto_register(PN_PROTO_PHONET, &pn_dgram_proto);
> +}
> +
> +void __exit isi_unregister(void)
> +{
> +	phonet_proto_unregister(PN_PROTO_PHONET, &pn_dgram_proto);
> +}
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
