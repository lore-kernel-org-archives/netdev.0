From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 13/14] Phonet: emit errors when a packet cannot be
	delivered locally
Date: Tue, 16 Sep 2008 14:11:05 -0300
Message-ID: <20080916171105.GN8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-13-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55860 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbYIPRUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 13:20:08 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-13-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:13PM +0300, R=E9mi Denis-Courmont escreve=
u:
> When there is no listener socket for a received packet, send an error
> back to the sender.
>=20
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/af_phonet.c |   82 ++++++++++++++++++++++++++++++++++++++=
+++++++--
>  1 files changed, 78 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index c18664d..3962969 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -134,7 +134,7 @@ EXPORT_SYMBOL(phonet_header_ops);
>   * Prepends an ISI header and sends a datagram.
>   */
>  static int pn_send(struct sk_buff *skb, struct net_device *dev,
> -			u16 dst, u16 src, u8 res)
> +			u16 dst, u16 src, u8 res, u8 irq)
>  {
>  	struct phonethdr *ph;
>  	int err;
> @@ -163,7 +163,10 @@ static int pn_send(struct sk_buff *skb, struct n=
et_device *dev,
>  		skb_reset_mac_header(skb);
>  		skb->pkt_type =3D PACKET_LOOPBACK;
>  		skb_orphan(skb);
> -		netif_rx_ni(skb);
> +		if (irq)
> +			netif_rx(skb);
> +		else
> +			netif_rx_ni(skb);
>  		err =3D 0;
>  	} else {
>  		err =3D dev_hard_header(skb, dev, ntohs(skb->protocol),
> @@ -181,6 +184,18 @@ drop:
>  	return err;
>  }
> =20
> +static int pn_raw_send(const void *data, int len, struct net_device =
*dev,
> +			u16 dst, u16 src, u8 res)
> +{
> +	struct sk_buff *skb =3D alloc_skb(MAX_PHONET_HEADER + len, GFP_ATOM=
IC);
> +	if (skb =3D=3D NULL)
> +		return -ENOMEM;
> +
> +	skb_reserve(skb, MAX_PHONET_HEADER);
> +	memcpy(skb_put(skb, len), data, len);

Check if you shouldn't be using skb_copy_to_linear_data

> +	return pn_send(skb, dev, dst, src, res, 1);
> +}
> +
>  /*
>   * Create a Phonet header for the skb and send it out. Returns
>   * non-zero error code if failed. The skb is freed then.
> @@ -221,7 +236,7 @@ int pn_skb_send(struct sock *sk, struct sk_buff *=
skb,
>  	spin_unlock_bh(&pndevs.lock);
> =20
>  	err =3D pn_send(skb, dev, pn_sockaddr_get_object(target),
> -			src, pn_sockaddr_get_resource(target));
> +			src, pn_sockaddr_get_resource(target), 0);
>  	dev_put(dev);
>  	return err;
> =20
> @@ -231,6 +246,60 @@ drop:
>  }
>  EXPORT_SYMBOL(pn_skb_send);
> =20
> +static inline int can_respond(struct sk_buff *skb)
> +{
> +	const struct phonethdr *ph =3D pn_hdr(skb);
> +	struct phonet_device *pnd;
> +
> +	if (!pskb_may_pull(skb, 3))
> +		return 0;
> +	if (skb->data[1] =3D=3D 0xF0)
> +		return 0;
> +	if (skb->data[2] =3D=3D 0x01 || skb->data[2] =3D=3D 0x14)
> +		return 0;

Try not to access skb->data directly, probably you would be better off
using some pn_hdr() like accessor that peeked at the mac_header, etc

> +	spin_lock(&pndevs.lock);
> +	pnd =3D __phonet_get_by_index(skb->dev->ifindex);
> +	if (!pnd
> +	 || !phonet_dev2addr(pnd, ph->rdev & 0xFC, PN_FIND_EXACT)) {
> +		spin_unlock(&pndevs.lock);
> +		return 0;
> +	}
> +	spin_unlock(&pndevs.lock);
> +	return 1;
> +}
> +
> +static int send_obj_unreachable(struct sk_buff *rskb)
> +{
> +	struct phonethdr *oph =3D pn_hdr(rskb);
> +	uint8_t data[8];
> +
> +	BUG_ON(skb_headlen(rskb) < 2);
> +	data[0] =3D rskb->data[0];
> +	data[1] =3D 0xF0;
> +	data[2] =3D 0x14;
> +	data[3] =3D rskb->data[1];
> +	data[4] =3D 0x00;
> +	data[5] =3D 0x00;
> +	data[6] =3D 0x00;
> +	data[7] =3D 0x00;

Couldn't this be built using some relevant struct, etc?

> +	return pn_raw_send(data, sizeof(data), rskb->dev,
> +				pn_object(oph->sdev, oph->sobj),
> +				pn_object(oph->rdev, oph->robj),
> +				oph->function);
> +}
> +
> +static int send_reset_indications(struct sk_buff *rskb)
> +{
> +	struct phonethdr *oph =3D pn_hdr(rskb);
> +	uint8_t data[4] =3D { 0x00, 0x10, 0x00, 0x00 };
> +
> +	return pn_raw_send(data, sizeof(data), rskb->dev,
> +				pn_object(oph->sdev, 0x00),
> +				pn_object(oph->rdev, oph->robj), 0x10);
> +}
> +
> +
>  /* packet type functions */
> =20
>  /*
> @@ -269,8 +338,13 @@ static int phonet_rcv(struct sk_buff *skb, struc=
t net_device *dev,
>  		goto out; /* currently, we cannot be device 0 */
> =20
>  	sk =3D pn_find_sock_by_sa(&sa);
> -	if (sk =3D=3D NULL)
> +	if (sk =3D=3D NULL) {
> +		if (can_respond(skb)) {
> +			send_obj_unreachable(skb);
> +			send_reset_indications(skb);
> +		}
>  		goto out;
> +	}
> =20
>  	/* Push data to the socket (or other sockets connected to it). */
>  	err =3D pn_sk(sk)->handler(sk, skb);
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
