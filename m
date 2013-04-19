From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Fri, 19 Apr 2013 14:54:42 +0200
Message-ID: <51713E92.3050803@canonical.com>
References: <516EB23B.3080504@canonical.com> <20130417213251.GA13790@electric-eye.fr.zoreil.com> <516FC218.3060002@canonical.com> <20130418215501.GB8944@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigED1DA34A7F3501F6BBDFC9D1"
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50011 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030311Ab3DSMyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:54:47 -0400
In-Reply-To: <20130418215501.GB8944@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigED1DA34A7F3501F6BBDFC9D1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 18.04.2013 23:55, Francois Romieu wrote:
> Stefan Bader <stefan.bader@canonical.com> :
> [...]
>> This was taken with a 3.9-rc7 kernel running on the Xen host, listenin=
g on the
>> tftp server. First run is with the kernel driver and the second pass w=
ith
>=20
> Please try the patch below with current kernel and capture traffic on
> both the tftp server and r8169 interfaces.
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
> index 4ecbe64..c1cd9f6 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5747,7 +5747,7 @@ err_out:
>  	return -EIO;
>  }
> =20
> -static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
> +static inline bool rtl8169_tso_csum(struct rtl8169_private *tp,
>  				    struct sk_buff *skb, u32 *opts)
>  {
>  	const struct rtl_tx_desc_info *info =3D tx_desc_info + tp->txd_versio=
n;
> @@ -5760,6 +5760,15 @@ static inline void rtl8169_tso_csum(struct rtl81=
69_private *tp,
>  	} else if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>  		const struct iphdr *ip =3D ip_hdr(skb);
> =20
> +		if (unlikely(skb->len < ETH_ZLEN &&
> +		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34))) {
> +			if (skb_padto(skb, ETH_ZLEN))
> +				return false;
> +			skb_checksum_help(skb);
> +			skb_put(skb, ETH_ZLEN - skb->len);
> +			return true;
> +		}
> +
>  		if (ip->protocol =3D=3D IPPROTO_TCP)
>  			opts[offset] |=3D info->checksum.tcp;
>  		else if (ip->protocol =3D=3D IPPROTO_UDP)
> @@ -5767,6 +5776,7 @@ static inline void rtl8169_tso_csum(struct rtl816=
9_private *tp,
>  		else
>  			WARN_ON_ONCE(1);
>  	}
> +	return true;
>  }
> =20
>  static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
> @@ -5790,25 +5800,26 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
>  	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
>  		goto err_stop_0;
> =20
> +	opts[1] =3D cpu_to_le32(rtl8169_tx_vlan_tag(skb));
> +	opts[0] =3D DescOwn;
> +
> +	if (!rtl8169_tso_csum(tp, skb, opts))
> +		goto err_update_stats_0;
> +
>  	len =3D skb_headlen(skb);
>  	mapping =3D dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
>  	if (unlikely(dma_mapping_error(d, mapping))) {
>  		if (net_ratelimit())
>  			netif_err(tp, drv, dev, "Failed to map TX DMA!\n");
> -		goto err_dma_0;
> +		goto err_free_skb_1;
>  	}
> =20
>  	tp->tx_skb[entry].len =3D len;
>  	txd->addr =3D cpu_to_le64(mapping);
> =20
> -	opts[1] =3D cpu_to_le32(rtl8169_tx_vlan_tag(skb));
> -	opts[0] =3D DescOwn;
> -
> -	rtl8169_tso_csum(tp, skb, opts);
> -
>  	frags =3D rtl8169_xmit_frags(tp, skb, opts);
>  	if (frags < 0)
> -		goto err_dma_1;
> +		goto err_unmap_2;
>  	else if (frags)
>  		opts[0] |=3D FirstFrag;
>  	else {
> @@ -5854,10 +5865,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
> =20
>  	return NETDEV_TX_OK;
> =20
> -err_dma_1:
> +err_unmap_2:
>  	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
> -err_dma_0:
> +err_free_skb_1:
>  	dev_kfree_skb(skb);
> +err_update_stats_0:
>  	dev->stats.tx_dropped++;
>  	return NETDEV_TX_OK;
> =20
>=20

Might be a while till I will be able to run any tests since msi was so ge=
nerous
to provide an uefi bios that can brick itself from their efi shell. *sigh=
*
I had tried the combination of your change and Hayes' but that would caus=
e
panics in skb_checksum_help (not sure which of the two) on boot.

-Stefan


--------------enigED1DA34A7F3501F6BBDFC9D1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRcT6SAAoJEOhnXe7L7s6jKWIP/RgiFuhFC1UWVDU80NrNDs8c
M4XZkjabtedUnBZlNPu+SP7xPo46bB3SEtzhKJ7sTDi0EAFONWSshI7kmF55voZ4
smmLoC340yY1KSTJSlomLIBHlcRK6np8uOkshVqrrKUpX/VtIzMvL8ukF7XrHGN5
cVYHtMMkhiU8xOeb61DXpbdHghFxRpDRk/TBWC+/rj01YZfXjnoVBdzX0BWvuER/
3KKJ4NFJAUpCBoCBJcnkGPaxIlRxItjE5ZEWaYGE4k5MI5+ntHJDb4wNSPQRmuK/
4i+Hgu6y6LYlkWvzgitfRiB22Ybj3FHYTFm9xTyHfmLM0WrX4b1kS9dxyNsE0eBw
zZEZ1bDS6D2cgqzUKoHexXtPZrAKQ6slfHqt0LZYjFPeVspIl5fbT0fzD/dh+ZEo
NvEiHI+BWAnEHvIx44WpCKZpcQB50rseYA2CMw/7/C2FOVkdXP8Bt17htrFvqVHL
pDAtlY/P5+pwF7XRDurXqobv+BlWb6uA9Cmde8j6sjIClvFm0r/Dl8Ve1WxcWc/j
lIhGmUU5wnIqIurf6Ej3vVao28dXpLdCj1pYF3J0iZGF0orMO6R3CBx7QihyjyZe
Oaz8UIu4gTssAqCrwO+MEQtAOVYF373zufX91tqhSPczF1U9K3BWNnaKPCXS1/tt
vYMV9WHRKK6Jfvni3IWN
=p9Kl
-----END PGP SIGNATURE-----

--------------enigED1DA34A7F3501F6BBDFC9D1--
