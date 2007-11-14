From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] SOCK: add raw6 drops counter
Date: Wed, 14 Nov 2007 06:48:27 +0100
Message-ID: <473A8C2B.2040709@cosmosbay.com>
References: <47397514.2070002@cn.fujitsu.com> <473A6792.10405@cn.fujitsu.com> <473A686D.9020200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50647 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759095AbXKNFtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:49:05 -0500
In-Reply-To: <473A686D.9020200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wang Chen a =C3=A9crit :
> Add raw drops counter for IPv6 in /proc/net/raw6 .
>=20
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  raw.c |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
>=20
> diff -Nurp linux-2.6.24-rc2.org/net/ipv6/raw.c linux-2.6.24-rc2/net/i=
pv6/raw.c
> --- linux-2.6.24-rc2.org/net/ipv6/raw.c	2007-11-09 16:38:05.000000000=
 +0800
> +++ linux-2.6.24-rc2/net/ipv6/raw.c	2007-11-14 09:46:54.000000000 +08=
00
> @@ -354,14 +354,14 @@ static inline int rawv6_rcv_skb(struct s
>  {
>  	if ((raw6_sk(sk)->checksum || sk->sk_filter) &&
>  	    skb_checksum_complete(skb)) {
> -		/* FIXME: increment a raw6 drops counter here */
> +		atomic_inc(&sk->sk_drops);=09

I am not sure the comment was refering to a per socket counter here.

If the frame checksum is bad, we can not be sure the socket is OK, sinc=
e the=20
garbaged bits could be in the tuple that identify the socket.

Maybe here we want to increment a global raw6 drop counter (well, for t=
he=20
given ipv6 instance)

>  		kfree_skb(skb);
>  		return 0;
>  	}
> =20
>  	/* Charge it to the socket. */
>  	if (sock_queue_rcv_skb(sk,skb)<0) {
> -		/* FIXME: increment a raw6 drops counter here */
> +		atomic_inc(&sk->sk_drops);
>  		kfree_skb(skb);
>  		return 0;
>  	}
> @@ -382,6 +382,7 @@ int rawv6_rcv(struct sock *sk, struct sk
>  	struct raw6_sock *rp =3D raw6_sk(sk);
> =20
>  	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb)) {
> +		atomic_inc(&sk->sk_drops);
>  		kfree_skb(skb);
>  		return NET_RX_DROP;
>  	}
> @@ -405,7 +406,7 @@ int rawv6_rcv(struct sock *sk, struct sk
> =20
>  	if (inet->hdrincl) {
>  		if (skb_checksum_complete(skb)) {
> -			/* FIXME: increment a raw6 drops counter here */
> +			atomic_inc(&sk->sk_drops);

Same remark here.

