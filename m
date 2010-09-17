From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable-2.6.32] Phonet: disable network namespace support
Date: Fri, 17 Sep 2010 16:04:47 -0700 (PDT)
Message-ID: <20100917.160447.146098756.davem@davemloft.net>
References: <1284763006-22075-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	remi.denis-courmont@nokia.com, ebiederm@xmission.com,
	stable@kernel.org
To: remi@remlab.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284763006-22075-1-git-send-email-remi@remlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Sat, 18 Sep 2010 01:36:46 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Network namespace in the Phonet socket stack causes an OOPS when a
> namespace is destroyed. This occurs as the loopback exit_net handler =
is
> called after the Phonet exit_net handler, and re-enters the Phonet
> stack. I cannot think of any nice way to fix this in kernel <=3D 2.6.=
32.
>=20
> For lack of a better solution, disable namespace support completely.
> If you need that, upgrade to a newer kernel.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>

"lkml" address fixed, and -stable CC: added this time, please don't
omit that if you want to submit stable networking patches that have no
upstream counterpart.

Acked-by: David S. Miller <davem@davemloft.net>

> ---
>  net/phonet/af_phonet.c  |    4 ++++
>  net/phonet/pn_dev.c     |   12 ++++++++++--
>  net/phonet/pn_netlink.c |    9 ++++++++-
>  3 files changed, 22 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index f60c0c2..519ff9d 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -67,6 +67,8 @@ static int pn_socket_create(struct net *net, struct=
 socket *sock, int protocol)
>  	struct phonet_protocol *pnp;
>  	int err;
> =20
> +	if (!net_eq(net, &init_net))
> +		return -EAFNOSUPPORT;
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> =20
> @@ -353,6 +355,8 @@ static int phonet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
>  	struct sockaddr_pn sa;
>  	u16 len;
> =20
> +	if (!net_eq(net, &init_net))
> +		goto out;
>  	/* check we have at least a full Phonet header */
>  	if (!pskb_pull(skb, sizeof(struct phonethdr)))
>  		goto out;
> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
> index 5f42f30..5a2275c 100644
> --- a/net/phonet/pn_dev.c
> +++ b/net/phonet/pn_dev.c
> @@ -246,7 +246,11 @@ static struct notifier_block phonet_device_notif=
ier =3D {
>  /* Per-namespace Phonet devices handling */
>  static int phonet_init_net(struct net *net)
>  {
> -	struct phonet_net *pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
> +	struct phonet_net *pnn;
> +
> +	if (!net_eq(net, &init_net))
> +		return 0;
> +	pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
>  	if (!pnn)
>  		return -ENOMEM;
> =20
> @@ -263,9 +267,13 @@ static int phonet_init_net(struct net *net)
> =20
>  static void phonet_exit_net(struct net *net)
>  {
> -	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
> +	struct phonet_net *pnn;
>  	struct net_device *dev;
> =20
> +	if (!net_eq(net, &init_net))
> +		return;
> +	pnn =3D net_generic(net, phonet_net_id);
> +
>  	rtnl_lock();
>  	for_each_netdev(net, dev)
>  		phonet_device_destroy(dev);
> diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
> index d21fd35..7acab1e 100644
> --- a/net/phonet/pn_netlink.c
> +++ b/net/phonet/pn_netlink.c
> @@ -68,6 +68,8 @@ static int addr_doit(struct sk_buff *skb, struct nl=
msghdr *nlh, void *attr)
>  	int err;
>  	u8 pnaddr;
> =20
> +	if (!net_eq(net, &init_net))
> +		return -EOPNOTSUPP;
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> =20
> @@ -124,12 +126,16 @@ nla_put_failure:
> =20
>  static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callba=
ck *cb)
>  {
> +	struct net *net =3D sock_net(skb->sk);
>  	struct phonet_device_list *pndevs;
>  	struct phonet_device *pnd;
>  	int dev_idx =3D 0, dev_start_idx =3D cb->args[0];
>  	int addr_idx =3D 0, addr_start_idx =3D cb->args[1];
> =20
> -	pndevs =3D phonet_device_list(sock_net(skb->sk));
> +	if (!net_eq(net, &init_net))
> +		goto skip;
> +
> +	pndevs =3D phonet_device_list(net);
>  	spin_lock_bh(&pndevs->lock);
>  	list_for_each_entry(pnd, &pndevs->list, list) {
>  		u8 addr;
> @@ -154,6 +160,7 @@ static int getaddr_dumpit(struct sk_buff *skb, st=
ruct netlink_callback *cb)
> =20
>  out:
>  	spin_unlock_bh(&pndevs->lock);
> +skip:
>  	cb->args[0] =3D dev_idx;
>  	cb->args[1] =3D addr_idx;
> =20
> --=20
> 1.7.0.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
