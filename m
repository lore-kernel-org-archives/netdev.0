From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v3 3/6] can: make struct proto const
Date: Mon, 14 Mar 2011 15:09:15 +0100
Message-ID: <1300111755.3423.20.camel@edumazet-laptop>
References: <20110314132004.GA333@e-circ.dyndns.org>
	 <20110314134721.GD333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39846 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab1CNOJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:09:50 -0400
Received: by fxm17 with SMTP id 17so2925578fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 07:09:49 -0700 (PDT)
In-Reply-To: <20110314134721.GD333@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 14:47 +0100, Kurt Van Dijck a =C3=A9crit :
> can_ioctl is the only reason for struct proto to be non-const.
> script/check-patch.pl suggests struct proto be const.
> This patch performs the necessary change.
>=20
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> ---
> diff --git a/include/linux/can/core.h b/include/linux/can/core.h
> index 430c446..0767cc6 100644
> --- a/include/linux/can/core.h
> +++ b/include/linux/can/core.h
> @@ -39,7 +39,7 @@
>  struct can_proto {
>  	int              type;
>  	int              protocol;
> -	struct proto_ops *ops;
> +	const struct proto_ops *ops;
>  	struct proto     *prot;
> =20
>  	const struct rtnl_af_ops *rtnl_link_ops;
> @@ -78,6 +78,8 @@ struct rtgencanmsg {
> =20
>  extern int  can_proto_register(const struct can_proto *cp);
>  extern void can_proto_unregister(const struct can_proto *cp);
> +extern int can_sock_ioctl(struct socket *sock, unsigned int cmd,
> +		unsigned long arg);
> =20
>  extern int  can_rx_register(struct net_device *dev, canid_t can_id,
>  			    canid_t mask,
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index db59c6e..c1f8c05 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -139,7 +139,7 @@ static inline void can_put_proto(const struct can=
_proto *cp)
>   * af_can socket functions
>   */
> =20
> -static int can_ioctl(struct socket *sock, unsigned int cmd, unsigned=
 long arg)
> +int can_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned l=
ong arg)
>  {
>  	struct sock *sk =3D sock->sk;
> =20
> @@ -152,6 +152,7 @@ static int can_ioctl(struct socket *sock, unsigne=
d int cmd, unsigned long arg)
>  		return -ENOIOCTLCMD;
>  	}
>  }
> +EXPORT_SYMBOL(can_sock_ioctl);
> =20
>  static void can_sock_destruct(struct sock *sk)
>  {
> @@ -720,10 +721,6 @@ int can_proto_register(const struct can_proto *c=
p)
>  		err =3D -EBUSY;
>  	} else {
>  		proto_tab[proto] =3D cp;
> -
> -		/* use generic ioctl function if not defined by module */
> -		if (!cp->ops->ioctl)
> -			cp->ops->ioctl =3D can_ioctl;

Hmm, you actually fixed a race / bug, since we installed in proto_tab[]
a pointer to a not yet initted ops structure.

I suggest you change patch title and changelog to properly describe the
bug fix.



