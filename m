From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 10:36:55 +0200
Message-ID: <1248079015.4549.101.camel@violet>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36762 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbZGTIh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 04:37:27 -0400
In-Reply-To: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

isn't there are proper explaining commit message missing here?

> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.co=
m>
> ---
>  include/net/phonet/pn_dev.h |    2 +
>  net/phonet/pn_dev.c         |    7 +++
>  net/phonet/socket.c         |   97 +++++++++++++++++++++++++++++++++=
++++++++++
>  3 files changed, 106 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.=
h
> index 29d1267..44c923c 100644
> --- a/include/net/phonet/pn_dev.h
> +++ b/include/net/phonet/pn_dev.h
> @@ -49,4 +49,6 @@ void phonet_address_notify(int event, struct net_de=
vice *dev, u8 addr);
> =20
>  #define PN_NO_ADDR	0xff
> =20
> +extern const struct file_operations pn_sock_seq_fops;
> +
>  #endif
> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
> index b0d6ddd..5107b79 100644
> --- a/net/phonet/pn_dev.c
> +++ b/net/phonet/pn_dev.c
> @@ -218,6 +218,11 @@ static int phonet_init_net(struct net *net)
>  	if (!pnn)
>  		return -ENOMEM;
> =20
> +	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops)) {
> +		kfree(pnn);
> +		return -ENOMEM;
> +	}
> +
>  	INIT_LIST_HEAD(&pnn->pndevs.list);
>  	spin_lock_init(&pnn->pndevs.lock);
>  	net_assign_generic(net, phonet_net_id, pnn);
> @@ -233,6 +238,8 @@ static void phonet_exit_net(struct net *net)
>  	for_each_netdev(net, dev)
>  		phonet_device_destroy(dev);
>  	rtnl_unlock();
> +
> +	proc_net_remove(net, "phonet");
>  	kfree(pnn);
>  }
> =20
> diff --git a/net/phonet/socket.c b/net/phonet/socket.c
> index ada2a35..2a99851 100644
> --- a/net/phonet/socket.c
> +++ b/net/phonet/socket.c
> @@ -412,3 +412,100 @@ found:
>  	return 0;
>  }
>  EXPORT_SYMBOL(pn_sock_get_port);
> +
> +static struct sock *pn_sock_get_idx(struct seq_file *seq, loff_t pos=
)
> +{
> +	struct net *net =3D seq_file_net(seq);
> +	struct hlist_node *node;
> +	struct sock *sknode;
> +
> +	sk_for_each(sknode, node, &pnsocks.hlist) {
> +		if (!net_eq(net, sock_net(sknode)))
> +			continue;
> +		if (!pos)
> +			return sknode;
> +		pos--;
> +	}
> +	return NULL;
> +}
> +
> +static struct sock *pn_sock_get_next(struct seq_file *seq, struct so=
ck *sk)
> +{
> +	struct net *net =3D seq_file_net(seq);
> +
> +	do
> +		sk =3D sk_next(sk);
> +	while (sk && !net_eq(net, sock_net(sk)));
> +
> +	return sk;
> +}
> +
> +static void *pn_sock_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(pnsocks.lock)
> +{
> +	spin_lock_bh(&pnsocks.lock);
> +	return *pos ? pn_sock_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
> +}
> +
> +static void *pn_sock_seq_next(struct seq_file *seq, void *v, loff_t =
*pos)
> +{
> +	struct sock *sk;
> +
> +	if (v =3D=3D SEQ_START_TOKEN)
> +		sk =3D pn_sock_get_idx(seq, 0);
> +	else
> +		sk =3D pn_sock_get_next(seq, v);
> +	(*pos)++;
> +	return sk;
> +}
> +
> +static void pn_sock_seq_stop(struct seq_file *seq, void *v)
> +	__releases(pnsocks.lock)
> +{
> +	spin_unlock_bh(&pnsocks.lock);
> +}
> +
> +static int pn_sock_seq_show(struct seq_file *seq, void *v)
> +{
> +	int len;
> +
> +	if (v =3D=3D SEQ_START_TOKEN)
> +		seq_printf(seq, "%s%n", "pt  loc  rem rs st tx_queue rx_queue "
> +			"  uid inode ref pointer drops", &len);
> +	else {
> +		struct sock *sk =3D v;
> +		struct pn_sock *pn =3D pn_sk(sk);
> +
> +		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
> +			"%d %p %d%n",
> +			sk->sk_protocol, pn->sobject, 0, pn->resource,
> +			sk->sk_state,
> +			atomic_read(&sk->sk_wmem_alloc),
> +			atomic_read(&sk->sk_rmem_alloc),
> +			sock_i_uid(sk), sock_i_ino(sk),
> +			atomic_read(&sk->sk_refcnt), sk,
> +			atomic_read(&sk->sk_drops), &len);
> +	}
> +	seq_printf(seq, "%*s\n", 127 - len, "");
> +	return 0;
> +}

The more appropriate place for this would be debugfs.

Regards

Marcel


