From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Thu, 10 Sep 2009 15:19:21 +0200
Message-ID: <4AA8FCD9.3040600@gmail.com>
References: <20090910125929.GA32593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, m.s.tsirkin@gmail.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60735 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbZIJNTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 09:19:42 -0400
In-Reply-To: <20090910125929.GA32593@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin a =E9crit :
> Tun device looks similar to a packet socket
> in that both pass complete frames from/to userspace.
>=20
> This patch fills in enough fields in the socket underlying tun driver
> to support sendmsg/recvmsg operations, and exports access to this soc=
ket
> to modules.
>=20
> This way, code using raw sockets to inject packets
> into a physical device, can support injecting
> packets into host network stack almost without modification.
>=20
> First user of this interface will be vhost virtualization
> accelerator.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>=20
> This patch is on top of net-next master.
> An alternative approach would be to add an ioctl to tun, to export th=
e
> underlying socket to userspace: a uniform way to work with a network
> device and the host stack might be useful there, as well.
> Kernel users could then do sockfd_lookup to get the socket.
> I decided against it for now as it requires more code.
> Please comment.
>=20
>  drivers/net/tun.c      |   78 ++++++++++++++++++++++++++++++++++++++=
+++++----
>  include/linux/if_tun.h |   14 ++++++++
>  2 files changed, 85 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 589a44a..76f5faa 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -151,6 +151,7 @@ static int tun_attach(struct tun_struct *tun, str=
uct file *file)
>  	err =3D 0;
>  	tfile->tun =3D tun;
>  	tun->tfile =3D tfile;
> +	tun->socket.file =3D file;
>  	dev_hold(tun->dev);
>  	sock_hold(tun->socket.sk);
>  	atomic_inc(&tfile->count);
> @@ -165,6 +166,7 @@ static void __tun_detach(struct tun_struct *tun)
>  	/* Detach from net device */
>  	netif_tx_lock_bh(tun->dev);
>  	tun->tfile =3D NULL;
> +	tun->socket.file =3D NULL;
>  	netif_tx_unlock_bh(tun->dev);
> =20
>  	/* Drop read queue */
> @@ -750,7 +752,7 @@ static __inline__ ssize_t tun_put_user(struct tun=
_struct *tun,
>  	len =3D min_t(int, skb->len, len);
> =20
>  	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
> -	total +=3D len;
> +	total +=3D skb->len;

Why are you changing this ? This is very strange that read() can return
a bigger length than what was asked by user...

> =20
>  	tun->dev->stats.tx_packets++;
>  	tun->dev->stats.tx_bytes +=3D len;
> @@ -758,12 +760,10 @@ static __inline__ ssize_t tun_put_user(struct t=
un_struct *tun,
>  	return total;
>  }
> =20
> -static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iov=
ec *iv,
> -			    unsigned long count, loff_t pos)
> +static ssize_t tun_do_read(struct tun_struct *tun,
> +			   struct kiocb *iocb, const struct iovec *iv,
> +			   unsigned long count, int noblock)
>  {
> -	struct file *file =3D iocb->ki_filp;
> -	struct tun_file *tfile =3D file->private_data;
> -	struct tun_struct *tun =3D __tun_get(tfile);
>  	DECLARE_WAITQUEUE(wait, current);
>  	struct sk_buff *skb;
>  	ssize_t len, ret =3D 0;
> @@ -785,7 +785,7 @@ static ssize_t tun_chr_aio_read(struct kiocb *ioc=
b, const struct iovec *iv,
> =20
>  		/* Read frames from the queue */
>  		if (!(skb=3Dskb_dequeue(&tun->socket.sk->sk_receive_queue))) {
> -			if (file->f_flags & O_NONBLOCK) {
> +			if (noblock) {
>  				ret =3D -EAGAIN;
>  				break;
>  			}
> @@ -813,6 +813,21 @@ static ssize_t tun_chr_aio_read(struct kiocb *io=
cb, const struct iovec *iv,
>  	remove_wait_queue(&tun->socket.wait, &wait);
> =20
>  out:
> +	return ret;
> +}
> +
> +static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iov=
ec *iv,
> +			    unsigned long count, loff_t pos)
> +{
> +	struct file *file =3D iocb->ki_filp;
> +	struct tun_file *tfile =3D file->private_data;
> +	struct tun_struct *tun =3D __tun_get(tfile);
> +	ssize_t ret;
> +
> +	if (!tun)
> +		return -EBADFD;
> +	ret =3D tun_do_read(tun, iocb, iv, count, file->f_flags & O_NONBLOC=
K);
> +	ret =3D min_t(ssize_t, ret, count);
>  	tun_put(tun);
>  	return ret;
>  }
> @@ -865,6 +880,37 @@ static void tun_sock_destruct(struct sock *sk)
>  	free_netdev(container_of(sk, struct tun_sock, sk)->tun->dev);
>  }
> =20
> +static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
> +		       struct msghdr *m, size_t total_len)
> +{
> +	struct tun_struct *tun =3D container_of(sock, struct tun_struct, so=
cket);
> +	return tun_get_user(tun, m->msg_iov, total_len,
> +			    m->msg_flags & MSG_DONTWAIT);
> +}
> +
> +static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
> +		       struct msghdr *m, size_t total_len,
> +		       int flags)
> +{
> +	struct tun_struct *tun =3D container_of(sock, struct tun_struct, so=
cket);
> +	int ret;
> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
> +		return -EINVAL;
> +	ret =3D tun_do_read(tun, iocb, m->msg_iov, total_len,
> +			  flags & MSG_DONTWAIT);
> +	if (ret > total_len) {
> +		m->msg_flags |=3D MSG_TRUNC;
> +		ret =3D flags & MSG_TRUNC ? ret : total_len;
> +	}
> +	return ret;
> +}
> +
> +/* Ops structure to mimic raw sockets with tun */
> +static const struct proto_ops tun_socket_ops =3D {
> +	.sendmsg =3D tun_sendmsg,
> +	.recvmsg =3D tun_recvmsg,
> +};
> +
>  static struct proto tun_proto =3D {
>  	.name		=3D "tun",
>  	.owner		=3D THIS_MODULE,
> @@ -982,6 +1028,7 @@ static int tun_set_iff(struct net *net, struct f=
ile *file, struct ifreq *ifr)
>  			goto err_free_dev;
> =20
>  		init_waitqueue_head(&tun->socket.wait);
> +		tun->socket.ops =3D &tun_socket_ops;
>  		sock_init_data(&tun->socket, sk);
>  		sk->sk_write_space =3D tun_sock_write_space;
>  		sk->sk_sndbuf =3D INT_MAX;
> @@ -1483,6 +1530,23 @@ static void tun_cleanup(void)
>  	rtnl_link_unregister(&tun_link_ops);
>  }
> =20
> +/* Get an underlying socket object from tun file.  Returns error unl=
ess file is
> + * attached to a device.  The returned object works like a packet so=
cket, it
> + * can be used for sock_sendmsg/sock_recvmsg.  The caller is respons=
ible for
> + * holding a reference to the file for as long as the socket is in u=
se. */
> +struct socket *tun_get_socket(struct file *file)
> +{
> +	struct tun_struct *tun;
> +	if (file->f_op !=3D &tun_fops)
> +		return ERR_PTR(-EINVAL);
> +	tun =3D tun_get(file);
> +	if (!tun)
> +		return ERR_PTR(-EBADFD);
> +	tun_put(tun);
> +	return &tun->socket;
> +}
> +EXPORT_SYMBOL_GPL(tun_get_socket);
> +
>  module_init(tun_init);
>  module_exit(tun_cleanup);
>  MODULE_DESCRIPTION(DRV_DESCRIPTION);
> diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
> index 3f5fd52..404abe0 100644
> --- a/include/linux/if_tun.h
> +++ b/include/linux/if_tun.h
> @@ -86,4 +86,18 @@ struct tun_filter {
>  	__u8   addr[0][ETH_ALEN];
>  };
> =20
> +#ifdef __KERNEL__
> +#if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
> +struct socket *tun_get_socket(struct file *);
> +#else
> +#include <linux/err.h>
> +#include <linux/errno.h>
> +struct file;
> +struct socket;
> +static inline struct socket *tun_get_socket(struct file *f)
> +{
> +	return ERR_PTR(-EINVAL);
> +}
> +#endif /* CONFIG_TUN */
> +#endif /* __KERNEL__ */
>  #endif /* __IF_TUN_H */

