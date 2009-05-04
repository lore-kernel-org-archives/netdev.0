From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: skb_tx_hash() improvements
Date: Mon, 04 May 2009 08:12:31 +0200
Message-ID: <49FE874F.8000503@cosmosbay.com>
References: <49FAB831.6020700@cosmosbay.com>	<49FAC112.6090808@cosmosbay.com>	<20090501.091747.240476627.davem@davemloft.net> <20090503.144418.255531526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@whydna.net, jelaas@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44627 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbZEDGMk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 02:12:40 -0400
In-Reply-To: <20090503.144418.255531526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Fri, 01 May 2009 09:17:47 -0700 (PDT)
>=20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Fri, 01 May 2009 11:29:54 +0200
>>
>>> -	} else if (skb->sk && skb->sk->sk_hash) {
>>> +		/*
>>> +		 * Try to avoid an expensive divide, for symmetric setups :
>>> +		 *   number of tx queues of output device =3D=3D
>>> +		 *   number of rx queues of incoming device
>>> +		 */
>>> +		if (hash >=3D dev->real_num_tx_queues)
>>> +			hash %=3D dev->real_num_tx_queues;
>>> +		return hash;
>>> +	}
>> Subtraction in a while() loop is almost certainly a lot
>> faster.
>=20
> To move forward on this, I've commited the following to
> net-next-2.6, thanks!
>=20
> net: Avoid modulus in skb_tx_hash() for forwarding case.
>=20
> Based almost entirely upon a patch by Eric Dumazet.
>=20
> The common case is to have num-tx-queues <=3D num_rx_queues
> and even if num_tx_queues is larger it will not be significantly
> larger.
>=20
> Therefore, a subtraction loop is always going to be faster than
> modulus.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dev.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8144295..3c8073f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1735,8 +1735,12 @@ u16 skb_tx_hash(const struct net_device *dev, =
const struct sk_buff *skb)
>  {
>  	u32 hash;
> =20
> -	if (skb_rx_queue_recorded(skb))
> -		return skb_get_rx_queue(skb) % dev->real_num_tx_queues;
> +	if (skb_rx_queue_recorded(skb)) {
> +		hash =3D skb_get_rx_queue(skb);
> +		while (unlikely (hash >=3D dev->real_num_tx_queues))
> +			hash -=3D dev->real_num_tx_queues;
> +		return hash;
> +	}
> =20
>  	if (skb->sk && skb->sk->sk_hash)
>  		hash =3D skb->sk->sk_hash;

Yes, I checked that compiler did not use a divide instruction here
(I remember it did on a similar loop in kernel, related to time)

Thank you

