From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
Date: Thu, 08 Oct 2009 03:05:12 +0200
Message-ID: <4ACD3AC8.608@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59156 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650AbZJHBGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 21:06:00 -0400
In-Reply-To: <20091007180835.GB20524@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 7626b6a..8bd366f 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -306,6 +306,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk=
_buff *skb)
>  	skb_len =3D skb->len;
> =20


>  	skb_queue_tail(&sk->sk_receive_queue, skb);
> +	skb->dropcount =3D atomic_read(&sk->sk_drops);

No, skb was given to skb_queue_tail(), you are not allowed to touch it =
now,
another cpu might already consume it.

You better do :

struct sk_buff_head *list =3D &sk->sk_receive_queue;

spin_lock_irqsave(&list->lock, flags);
skb->dropcount =3D atomic_read(&sk->sk_drops); // should be done under =
lock protection
__skb_queue_tail(list, newsk);
spin_unlock_irqrestore(&list->lock, flags);



> =20
>  	if (!sock_flag(sk, SOCK_DEAD))
>  		sk->sk_data_ready(sk, skb_len);
> @@ -702,6 +703,12 @@ set_rcvbuf:
> =20
>  		/* We implement the SO_SNDLOWAT etc to
>  		   not be settable (1003.1g 5.3) */
> +	case SO_RXQ_OVFL:
> +		if (valbool)
> +			set_bit(SOCK_RXQ_OVFL, &sock->flags);
> +		else
> +			clear_bit(SOCK_RXQ_OVFL, &sock->flags);
> +		break;
>  	default:
>  		ret =3D -ENOPROTOOPT;
>  		break;
> @@ -901,6 +908,10 @@ int sock_getsockopt(struct socket *sock, int lev=
el, int optname,
>  		v.val =3D sk->sk_mark;
>  		break;
> =20
> +	case SO_RXQ_OVFL:
> +		v.val =3D test_bit(SOCK_RXQ_OVFL, &sock->flags);
> +		break;
> +
>  	default:
>  		return -ENOPROTOOPT;
>  	}
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index d7ecca0..920ae1e 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -617,6 +617,7 @@ static int packet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
>  	if (pskb_trim(skb, snaplen))
>  		goto drop_n_acct;
> =20

> +	skb->dropcount =3D atomic_read(&sk->sk_drops);
This should be done a litle bit after, right before "__skb_queue_tail(&=
sk->sk_receive_queue, skb); "

>  	skb_set_owner_r(skb, sk);
>  	skb->dev =3D NULL;
>  	skb_dst_drop(skb);
> @@ -634,6 +635,7 @@ static int packet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
>  drop_n_acct:


>  	spin_lock(&sk->sk_receive_queue.lock);
>  	po->stats.tp_drops++;
> +	atomic_inc(&sk->sk_drops);
>  	spin_unlock(&sk->sk_receive_queue.lock);

You could replace this block of four lines by : po->stat.tp_drop =3D at=
omic_inc_return(&sk->sk_drops);

> =20
>  drop_n_restore:
> diff --git a/net/socket.c b/net/socket.c
> index 7565536..ad157a3 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -673,6 +673,12 @@ static inline int __sock_recvmsg(struct kiocb *i=
ocb, struct socket *sock,
>  {
>  	int err;
>  	struct sock_iocb *si =3D kiocb_to_siocb(iocb);
> +	struct sk_buff *skb;
> +	int rc;
> +	struct sock *sk =3D sock->sk;
> +	unsigned long cpu_flags;
> +	__u32 gap =3D 0;

> +	int check_drops =3D test_bit(SOCK_RXQ_OVFL, &sock->flags);
> =20
>  	si->sock =3D sock;
>  	si->scm =3D NULL;
> @@ -684,7 +690,21 @@ static inline int __sock_recvmsg(struct kiocb *i=
ocb, struct socket *sock,
>  	if (err)
>  		return err;
> =20
> -	return sock->ops->recvmsg(iocb, sock, msg, size, flags);




> +	if (check_drops) {
> +		skb =3D skb_recv_datagram(sk, flags|MSG_PEEK,
> +				flags & MSG_DONTWAIT, &err);

	Ouch, this is too expensive, please find another way :)

> +		if (skb) {
> +			gap =3D skb->dropcount;
> +			consume_skb(skb);
> +		}
> +	}
> +
> +	rc =3D sock->ops->recvmsg(iocb, sock, msg, size, flags);
> +
> +	if (check_drops && (rc > 0))

		&& gap !=3D 0

> +		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &gap);
> +

