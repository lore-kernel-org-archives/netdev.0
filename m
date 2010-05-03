From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon, 03 May 2010 16:44:46 +0200
Message-ID: <1272897886.2226.38.camel@edumazet-laptop>
References: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51699 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab0ECOox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 10:44:53 -0400
Received: by bwz19 with SMTP id 19so1343822bwz.21
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 07:44:51 -0700 (PDT)
In-Reply-To: <1272895972-13799-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 mai 2010 =C3=A0 22:12 +0800, Changli Gao a =C3=A9crit :
> call __skb_pull() in eth_type_trans().
>=20
> The callers of eth_type_trans() should always feed it long enough pac=
kets. When
> the length of the packet is less than ETH_ZLEN, a warning message wil=
l be shown,
> and the later behaviors are undefined.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/ethernet/eth.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 61ec032..1df31cc 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -162,7 +162,10 @@ __be16 eth_type_trans(struct sk_buff *skb, struc=
t net_device *dev)
> =20
>  	skb->dev =3D dev;
>  	skb_reset_mac_header(skb);
> -	skb_pull_inline(skb, ETH_HLEN);
> +	if (unlikely(skb->len < ETH_ZLEN))
> +		dev_warn(&dev->dev, "too small ethernet packet: %u bytes\n",
> +			 skb->len);
> +	__skb_pull(skb, ETH_HLEN);
>  	eth =3D eth_hdr(skb);
> =20
>  	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {


Hmm, I feel very uncompfortable with this patch.

I am pretty sure some callers dont check minimum ethernet frame length.

At least a WARN_ON_ONCE() is needed, just in case...
In fact our stack has different requirements.

Check net/ipv4/ip_gre.c for example.

                if (tunnel->dev->type =3D=3D ARPHRD_ETHER) {
                        if (!pskb_may_pull(skb, ETH_HLEN)) {
                                stats->rx_length_errors++;
                                stats->rx_errors++;
                                goto drop;
                        }

                        iph =3D ip_hdr(skb);
                        skb->protocol =3D eth_type_trans(skb, tunnel->d=
ev);
                        skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN)=
;
                }


