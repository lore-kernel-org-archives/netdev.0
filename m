From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: Re: [PATCH] Revert "ip_gre: make ipgre_tunnel_xmit() not parse
	network header as IP unconditionally"
Date: Thu, 14 Mar 2013 00:05:10 +0900
Message-ID: <20130313150510.GF19577@valinux.co.jp>
References: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:55790 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3CMPFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:05:12 -0400
Content-Disposition: inline
In-Reply-To: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Mar 13, 2013 at 02:37:49PM +0200, Timo Ter=C3=A4s wrote:
> This reverts commit 412ed94744d16806fbec3bd250fd94e71cde5a1f.
>=20
> The commit is wrong as tiph points to the outer IPv4 header which is
> installed at ipgre_header() and not the inner one which is protocol d=
ependant.
>=20
> This commit broke succesfully opennhrp which use PF_PACKET socket wit=
h
> ETH_P_NHRP protocol. Additionally ssl_addr is set to the link-layer
> IPv4 address. This address is written by ipgre_header() to the skb
> earlier, and this is the IPv4 header tiph should point to - regardles=
s
> of the inner protocol payload.

Is this the case only for ETH_P_HNRP?
I wrote the patch having MPLS over GRE in mind.
Should it be something like this?
  if (protocol =3D=3D htons(ETH_P_IP) || protocol =3D=3D htons(ETH_P_NH=
RP))
    ....
thanks,

>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
>  net/ipv4/ip_gre.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> =20
> This commit appeared in 3.8.x. So should go to 3.8.x-stable.
>=20
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index d0ef0e6..91d66db 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -798,10 +798,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_b=
uff *skb, struct net_device *dev
> =20
>  	if (dev->header_ops && dev->type =3D=3D ARPHRD_IPGRE) {
>  		gre_hlen =3D 0;
> -		if (skb->protocol =3D=3D htons(ETH_P_IP))
> -			tiph =3D (const struct iphdr *)skb->data;
> -		else
> -			tiph =3D &tunnel->parms.iph;
> +		tiph =3D (const struct iphdr *)skb->data;
>  	} else {
>  		gre_hlen =3D tunnel->hlen;
>  		tiph =3D &tunnel->parms.iph;
> --=20
> 1.8.1.5
>=20

--=20
yamahata
