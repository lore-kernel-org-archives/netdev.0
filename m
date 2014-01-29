From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 15:38:55 +0100
Message-ID: <52E9127F.9000908@pengutronix.de>
References: <52E905C8.1060408@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="6jisb4rA3I7JOW65WJrAKOaN2116mB9fl"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52E905C8.1060408@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6jisb4rA3I7JOW65WJrAKOaN2116mB9fl
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Please put linux-can on Cc for CAN related patches.

Marc

On 01/29/2014 02:44 PM, Oliver Hartkopp wrote:
> Commit 376c7311bdb6 (net: add a temporary sanity check in skb_orphan())=

> leads to a BUG in can_put_echo_skb() when skb_orphan() is executed.
>=20
> The use of skb->sk to detect the originating socket can lead to side ef=
fects
> in net/core and net/sched. Therefore the reference needed in net/can/ra=
w.c is
> now stored in a CAN private skbuff space in struct can_skb_priv.
>=20
> The reference which comes with the CAN frame is only needed in raw_rcv(=
) and
> checked against his own sock pointer and does only special things if it=

> matches. So removing the socket does not hurt as the in-flight skbs are=

> removed and the receive filters are purged anyway when the socket disap=
pears.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>=20
> ---
>=20
> Here's my idea to fix up the original skb->sk handling concept for dete=
cting
> the originating socket instance. The patch applies properly down to 3.1=
1.
>=20
> Eric please take a look if I used sock_alloc_send_skb() correctly in bc=
m.c.
> Andre please check if you see any functional differences on your machin=
e.
>=20
> Tnx & regards,
> Oliver
>=20
> ps. I would suggest to move the BUG() in WARN_ON_ONCE() to fulfill the
> requirement to detect a possible misuse but not kill the entire machine=
=2E
> BUG() is intended to be used when there's no way to continue any reason=
able
> operation. Detecting and fixing this issue half a year after the "tempo=
rary
> sanity check" has been integrated is a bad example for using BUG() IMO.=

>=20
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 13a9098..6d51fb7 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -323,7 +323,6 @@ void can_put_echo_skb(struct sk_buff *skb, struct n=
et_device *dev,
>  	}
> =20
>  	if (!priv->echo_skb[idx]) {
> -		struct sock *srcsk =3D skb->sk;
> =20
>  		if (atomic_read(&skb->users) !=3D 1) {
>  			struct sk_buff *old_skb =3D skb;
> @@ -335,8 +334,6 @@ void can_put_echo_skb(struct sk_buff *skb, struct n=
et_device *dev,
>  		} else
>  			skb_orphan(skb);
> =20
> -		skb->sk =3D srcsk;
> -
>  		/* make settings for echo to reduce code in irq context */
>  		skb->protocol =3D htons(ETH_P_CAN);
>  		skb->pkt_type =3D PACKET_BROADCAST;
> @@ -513,6 +510,7 @@ struct sk_buff *alloc_can_skb(struct net_device *de=
v, struct can_frame **cf)
> =20
>  	can_skb_reserve(skb);
>  	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> +	can_skb_prv(skb)->src_sk =3D NULL;
> =20
>  	*cf =3D (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
>  	memset(*cf, 0, sizeof(struct can_frame));
> diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.=
c
> index e24e669..d27a1c9 100644
> --- a/drivers/net/can/janz-ican3.c
> +++ b/drivers/net/can/janz-ican3.c
> @@ -1133,8 +1133,6 @@ static void ican3_handle_message(struct ican3_dev=
 *mod, struct ican3_msg *msg)
>   */
>  static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *=
skb)
>  {
> -	struct sock *srcsk =3D skb->sk;
> -
>  	if (atomic_read(&skb->users) !=3D 1) {
>  		struct sk_buff *old_skb =3D skb;
> =20
> @@ -1142,11 +1140,8 @@ static void ican3_put_echo_skb(struct ican3_dev =
*mod, struct sk_buff *skb)
>  		kfree_skb(old_skb);
>  		if (!skb)
>  			return;
> -	} else {
> +	} else
>  		skb_orphan(skb);
> -	}
> -
> -	skb->sk =3D srcsk;
> =20
>  	/* save this skb for tx interrupt echo handling */
>  	skb_queue_tail(&mod->echoq, skb);
> diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
> index 3fcdae2..44766c18 100644
> --- a/drivers/net/can/slcan.c
> +++ b/drivers/net/can/slcan.c
> @@ -215,6 +215,7 @@ static void slc_bump(struct slcan *sl)
> =20
>  	can_skb_reserve(skb);
>  	can_skb_prv(skb)->ifindex =3D sl->dev->ifindex;
> +	can_skb_prv(skb)->src_sk =3D NULL;
> =20
>  	memcpy(skb_put(skb, sizeof(struct can_frame)),
>  	       &cf, sizeof(struct can_frame));
> diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
> index 0a2a5ee..1a89116 100644
> --- a/drivers/net/can/vcan.c
> +++ b/drivers/net/can/vcan.c
> @@ -116,14 +116,11 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, s=
truct net_device *dev)
>  	/* perform standard echo handling for CAN network interfaces */
> =20
>  	if (loop) {
> -		struct sock *srcsk =3D skb->sk;
> -
>  		skb =3D skb_share_check(skb, GFP_ATOMIC);
>  		if (!skb)
>  			return NETDEV_TX_OK;
> =20
>  		/* receive with packet counting */
> -		skb->sk =3D srcsk;
>  		vcan_rx(skb, dev);
>  	} else {
>  		/* no looped packets =3D> no counting */
> diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
> index 2f0543f..a8dc078 100644
> --- a/include/linux/can/skb.h
> +++ b/include/linux/can/skb.h
> @@ -25,10 +25,12 @@
>  /**
>   * struct can_skb_priv - private additional data inside CAN sk_buffs
>   * @ifindex:	ifindex of the first interface the CAN frame appeared on
> + * @src_sk:	pointer to the originating sock to detect self generated s=
kbs
>   * @cf:		align to the following CAN frame at skb->data
>   */
>  struct can_skb_priv {
>  	int ifindex;
> +	struct sock *src_sk;
>  	struct can_frame cf[0];
>  };
> =20
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index d249874..6ed6a23 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -270,15 +270,6 @@ int can_send(struct sk_buff *skb, int loop)
>  		/* indication for the CAN driver: do loopback */
>  		skb->pkt_type =3D PACKET_LOOPBACK;
> =20
> -		/*
> -		 * The reference to the originating sock may be required
> -		 * by the receiving socket to check whether the frame is
> -		 * its own. Example: can_raw sockopt CAN_RAW_RECV_OWN_MSGS
> -		 * Therefore we have to ensure that skb->sk remains the
> -		 * reference to the originating sock by restoring skb->sk
> -		 * after each skb_clone() or skb_orphan() usage.
> -		 */
> -
>  		if (!(skb->dev->flags & IFF_ECHO)) {
>  			/*
>  			 * If the interface is not capable to do loopback
> @@ -290,7 +281,6 @@ int can_send(struct sk_buff *skb, int loop)
>  				return -ENOMEM;
>  			}
> =20
> -			newskb->sk =3D skb->sk;
>  			newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
>  			newskb->pkt_type =3D PACKET_BROADCAST;
>  		}
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 3fc737b..f10f521 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -245,7 +245,9 @@ static void bcm_can_tx(struct bcm_op *op)
>  {
>  	struct sk_buff *skb;
>  	struct net_device *dev;
> +	struct sock *sk =3D op->sk;
>  	struct can_frame *cf =3D &op->frames[op->currframe];
> +	int err;
> =20
>  	/* no target device? =3D> exit */
>  	if (!op->ifindex)
> @@ -257,18 +259,23 @@ static void bcm_can_tx(struct bcm_op *op)
>  		return;
>  	}
> =20
> -	skb =3D alloc_skb(CFSIZ + sizeof(struct can_skb_priv), gfp_any());
> +	/*
> +	 * we are probably in softirq context (timer, net-rx):
> +	 * get an unblocked skb
> +	 */
> +	sk->sk_allocation =3D GFP_ATOMIC;
> +	skb =3D sock_alloc_send_skb(sk, CFSIZ + sizeof(struct can_skb_priv),
> +				  1, &err);
>  	if (!skb)
>  		goto out;
> =20
>  	can_skb_reserve(skb);
> -	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> -
>  	memcpy(skb_put(skb, CFSIZ), cf, CFSIZ);
> =20
>  	/* send with loopback */
> +	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> +	can_skb_prv(skb)->src_sk =3D sk;
>  	skb->dev =3D dev;
> -	skb->sk =3D op->sk;
>  	can_send(skb, 1);
> =20
>  	/* update statistics */
> @@ -1203,12 +1210,13 @@ static int bcm_tx_send(struct msghdr *msg, int =
ifindex, struct sock *sk)
>  	if (!ifindex)
>  		return -ENODEV;
> =20
> -	skb =3D alloc_skb(CFSIZ + sizeof(struct can_skb_priv), GFP_KERNEL);
> +	/* get an unblocked skb */
> +	skb =3D sock_alloc_send_skb(sk, CFSIZ + sizeof(struct can_skb_priv),
> +				  1, &err);
>  	if (!skb)
>  		return -ENOMEM;
> =20
>  	can_skb_reserve(skb);
> -
>  	err =3D memcpy_fromiovec(skb_put(skb, CFSIZ), msg->msg_iov, CFSIZ);
>  	if (err < 0) {
>  		kfree_skb(skb);
> @@ -1221,10 +1229,11 @@ static int bcm_tx_send(struct msghdr *msg, int =
ifindex, struct sock *sk)
>  		return -ENODEV;
>  	}
> =20
> -	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> +	/* send with loopback */
> +	can_skb_prv(skb)->ifindex =3D ifindex;
> +	can_skb_prv(skb)->src_sk =3D sk;
>  	skb->dev =3D dev;
> -	skb->sk  =3D sk;
> -	err =3D can_send(skb, 1); /* send with loopback */
> +	err =3D can_send(skb, 1);
>  	dev_put(dev);
> =20
>  	if (err)
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 07d72d8..7e67560 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -113,12 +113,13 @@ static void raw_rcv(struct sk_buff *oskb, void *d=
ata)
>  {
>  	struct sock *sk =3D (struct sock *)data;
>  	struct raw_sock *ro =3D raw_sk(sk);
> +	struct sock *src_sk =3D can_skb_prv(oskb)->src_sk;
>  	struct sockaddr_can *addr;
>  	struct sk_buff *skb;
>  	unsigned int *pflags;
> =20
>  	/* check the received tx sock reference */
> -	if (!ro->recv_own_msgs && oskb->sk =3D=3D sk)
> +	if (!ro->recv_own_msgs && src_sk =3D=3D sk)
>  		return;
> =20
>  	/* do not pass frames with DLC > 8 to a legacy socket */
> @@ -150,9 +151,9 @@ static void raw_rcv(struct sk_buff *oskb, void *dat=
a)
>  	/* add CAN specific message flags for raw_recvmsg() */
>  	pflags =3D raw_flags(skb);
>  	*pflags =3D 0;
> -	if (oskb->sk)
> +	if (src_sk)
>  		*pflags |=3D MSG_DONTROUTE;
> -	if (oskb->sk =3D=3D sk)
> +	if (src_sk =3D=3D sk)
>  		*pflags |=3D MSG_CONFIRM;
> =20
>  	if (sock_queue_rcv_skb(sk, skb) < 0)
> @@ -705,17 +706,15 @@ static int raw_sendmsg(struct kiocb *iocb, struct=
 socket *sock,
>  		goto put_dev;
> =20
>  	can_skb_reserve(skb);
> -	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> -
>  	err =3D memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
>  	if (err < 0)
>  		goto free_skb;
> =20
>  	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
> =20
> +	can_skb_prv(skb)->ifindex =3D dev->ifindex;
> +	can_skb_prv(skb)->src_sk =3D sk;
>  	skb->dev =3D dev;
> -	skb->sk  =3D sk;
> -
>  	err =3D can_send(skb, ro->loopback);
> =20
>  	dev_put(dev);
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6jisb4rA3I7JOW65WJrAKOaN2116mB9fl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLpEn8ACgkQjTAFq1RaXHPb1QCfTfMJBz2p56kBQkPpGFohQOh7
XyUAniUCg8u0BG4ijXyPTklHkE/n67hK
=3aIp
-----END PGP SIGNATURE-----

--6jisb4rA3I7JOW65WJrAKOaN2116mB9fl--
