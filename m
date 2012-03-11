From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: don't hold network namespace by tun sockets
Date: Sun, 11 Mar 2012 10:29:29 -0700
Message-ID: <1331486969.2449.15.camel@edumazet-laptop>
References: <20120311152053.30481.29572.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ebiederm@aristanetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xemul@parallel.com, shemminger@vyatta.com, devel@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120311152053.30481.29572.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 11 mars 2012 =C3=A0 19:21 +0400, Stanislav Kinsbursky a =C3=
=A9crit :
> TUN was designed to destroy it's socket on network namesapce shutdown=
=2E But this
> will never happen for persistent device, because it's socket holds ne=
twork
> namespace.
> This patch removes of holding network namespace by TUN socket and rep=
laces it
> by creating socket in init_net and then changing it's net it to desir=
ed one. On
> shutdown socket is moved back to init_net prior to final put.
>=20
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>=20
> ---
>  drivers/net/tun.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 2c5d349..92ef539 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -358,8 +358,11 @@ static void tun_net_uninit(struct net_device *de=
v)
>  static void tun_free_netdev(struct net_device *dev)
>  {
>  	struct tun_struct *tun =3D netdev_priv(dev);
> +	struct sock *sk =3D tun->socket.sk;
> =20
> -	sock_put(tun->socket.sk);
> +	release_net(sock_net(sk));
> +	sock_net_set(sk, get_net(&init_net));
> +	sock_put(sk);


Hmm, maybe use sk_release_kernel(), as its should be the thing
associated with sk_change_net().

Or at least make intent clear, since its not obvious.
