From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 12/21] [TCP]: Introduce per skb fack_counts to retransmit queue
Date: Sun, 2 Dec 2007 17:27:51 +1100
Message-ID: <20071202062751.GA30937@gondor.apana.org.au>
References: <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2319 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750706AbXLBG2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 01:28:02 -0500
Content-Disposition: inline
In-Reply-To: <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 12:48:07AM +0200, Ilpo J=E4rvinen wrote:
>
> @@ -1220,6 +1221,11 @@ static inline struct sk_buff *tcp_write_queue_=
next(struct sock *sk, struct sk_bu
>  	return skb->next;
>  }
>=20
> +static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, =
struct sk_buff *skb)
> +{
> +	return skb->prev;
> +}
> +
>  #define tcp_for_write_queue(skb, sk)					\
>  		for (skb =3D (sk)->sk_write_queue.next;			\
>  		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
> @@ -1241,6 +1247,11 @@ static inline struct sk_buff *tcp_send_head(st=
ruct sock *sk)
>=20
>  static inline void tcp_advance_send_head(struct sock *sk, struct sk_=
buff *skb)
>  {
> +	struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
> +
> +	TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_count +
> +				      tcp_skb_pcount(prev);
> +
>  	sk->sk_send_head =3D skb->next;
>  	if (sk->sk_send_head =3D=3D (struct sk_buff *)&sk->sk_write_queue)
>  		sk->sk_send_head =3D NULL;

This crashed my machine on boot.  The reason is that prev was empty.
I've added this fix to net-2.6.25.

[TCP]: Fix crash in tcp_advance_send_head

We need to check whether there is a prev in tcp_advance_send_head
before dereferencing it.  This patch does just that and leaves the
fack count at zero if there is no prev.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7ae72c3..b3878ca 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1338,8 +1338,9 @@ static inline void tcp_advance_send_head(struct s=
ock *sk, struct sk_buff *skb)
 {
 	struct sk_buff *prev =3D tcp_write_queue_prev(sk, skb);
=20
-	TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_count +
-				      tcp_skb_pcount(prev);
+	if (prev !=3D (struct sk_buff *)&sk->sk_write_queue)
+		TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_count +
+					      tcp_skb_pcount(prev);
=20
 	sk->sk_send_head =3D tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head =3D=3D (struct sk_buff *)&sk->sk_write_queue)
