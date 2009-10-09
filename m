From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v2)
Date: Fri, 09 Oct 2009 23:31:26 +0200
Message-ID: <4ACFABAE.5050003@gmail.com>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <20091009193515.GA28196@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52192 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934202AbZJIVcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 17:32:13 -0400
In-Reply-To: <20091009193515.GA28196@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :

> =20
> +extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock=
 *sk,
> +	struct sk_buff *skb);

Surely you meant __sock_recv_drops() ? It only deals with drops.


> +	case SO_RXQ_OVFL:
> +		v.val =3D sock_flag(sk, SOCK_RXQ_OVFL);
> +		break;
> +

Hmm, I advise to use v.val =3D !!sock_flag(sk, SOCK_RXQ_OVFL);
So that application gets 0 or 1, not 0 or some big value.
Its better because it allows us to change internal SOCK_RXQ_OVFL if nec=
essary in the future.

>  drop_n_acct:
> -	spin_lock(&sk->sk_receive_queue.lock);
> -	po->stats.tp_drops++;
> -	spin_unlock(&sk->sk_receive_queue.lock);
> +	po->stats.tp_drops =3D atomic_inc_return(&sk->sk_drops);

Yes :)

>  EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
> =20
> +void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> +	struct sk_buff *skb)
> +{
> +	put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &skb->dropcou=
nt);
> +}
> +EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
> +

Just change the name.

And is it really too large to be inlined ?

In the contrary, sock_recv_timestamp() is so large that I suspect
your sock_recv_ts_and_drops should *not* be inlined, and include inline=
d versions only :

I suggest something more orthogonal like :

void inline sock_recv_drops(struct msghdr *msg, struct sock *sk, struct=
 sk_buff *skb)
{
	if (sock_flag(sk, SOCK_RXQ_OVFL) && skb && skb->dropcount)
		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL,
			 sizeof(__u32), &skb->dropcount);
}

void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk, struct=
 sk_buff *skb)
{
	sock_recv_timestamp(msg, sk, skb); // inlined
	sock_recv_drops(msg, sk, skb); // inlined
}
EXPORT_SYMBOL_GPL(sock_recv_ts_and_drops)

