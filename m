From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 1/2] sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
Date: Wed, 08 Feb 2017 10:55:50 +0100
Message-ID: <87inolropl.fsf@miraculix.mork.no>
References: <20170208014633.15438-1-stefan.bruens@rwth-aachen.de>
        <916d0ee7460a4fcfaa1a951cf39e8607@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Stefan =?utf-8?Q?Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <916d0ee7460a4fcfaa1a951cf39e8607@rwthex-w2-b.rwth-ad.de>
        ("Stefan =?utf-8?Q?Br=C3=BCns=22's?= message of "Wed, 8 Feb 2017 02:46:32
 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Br=C3=BCns <stefan.bruens@rwth-aachen.de> writes:

> If a context is configured as dualstack ("IPv4v6"), the modem indicates
> the context activation with a slightly different indication message.
> The dual-stack indication omits the link_type (IPv4/v6) and adds
> additional address fields.

Great!

> IPv6 LSIs are identical to IPv4 LSIs, but have a different link type.
> +struct lsi_umts_dual {
> +	struct lsi_umts lsi;
> +	u8 pdp_addr4_len; /* NW-supplied PDP IPv4 address len */
> +	u8 pdp_addr4[4];  /* NW-supplied PDP IPv4 address (bigendian)) */
> +	u8 pdp_addr6_len; /* NW-supplied PDP IPv6 address len */
> +	u8 pdp_addr6[16]; /* NW-supplied PDP IPv6 address (bigendian)) */


Maybe use "struct in_addr" and "struct in6_addr" for all the address
fields, making them a bit more accessible and avoiding having to define
endianness explicitly?

There is an extra ")" after "(bigendian)" here, BTW.
> -	/* Validate the link type */
> -	if (lsi->link_type !=3D SIERRA_NET_AS_LINK_TYPE_IPv4) {
> -		netdev_err(dev->net, "Link type unsupported: 0x%02x\n",
> -			lsi->link_type);
> +	if (be16_to_cpu(lsi->length) !=3D expected_length) {
> +		netdev_err(dev->net, "%s: LSI_UMTS_STATUS_LEN %d, exp %u\n",
> +			   __func__, be16_to_cpu(lsi->length), expected_length);
>  		return -1;
>  	}


Not that it really matters much, but you could make this ia tiny bit
more efficient on LE by making "expected_length" big endian
instead. Either by using cpu_to_be16() when setting it above, or
redefining the macros with cpu_to_be16().


> @@ -833,9 +859,14 @@ static int sierra_net_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb)
>=20=20
>  		skb_pull(skb, hh.hdrlen);
>=20=20
> -		/* We are going to accept this packet, prepare it */
> -		memcpy(skb->data, sierra_net_get_private(dev)->ethr_hdr_tmpl,
> -			ETH_HLEN);
> +		/* We are going to accept this packet, prepare it.
> +		 * In case protocol is IPv6, keep it, otherwise force IPv4.
> +		 */
> +		skb_reset_mac_header(skb);
> +		if (eth_hdr(skb)->h_proto !=3D cpu_to_be16(ETH_P_IPV6))
> +			eth_hdr(skb)->h_proto =3D cpu_to_be16(ETH_P_IP);
> +		eth_zero_addr(eth_hdr(skb)->h_source);
> +		memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
>=20=20
>  		/* Last packet in batch handled by usbnet */
>  		if (hh.payload_len.word =3D=3D skb->len)

Hmm, the old code would unconditionally overwrite the whole header
including the proto field.  Are you saying that this wasn't really
necessary, and that the proto is usually (always for IPv6) correct?

If so, then this makes sense.  But I think it might be worth a note
about what we replace here and why, in case you happen to know that...
I realise that this is inherited from the original driver.

Just minor nits.  Overall this looks very good to me, FWIW.


Reviewed-by: Bj=C3=B8rn Mork <bjorn@mork.no>



Bj=C3=B8rn
