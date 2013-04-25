From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Thu, 25 Apr 2013 12:56:30 +0200
Message-ID: <51790BDE.7090500@canonical.com>
References: <516EB23B.3080504@canonical.com> <20130417213251.GA13790@electric-eye.fr.zoreil.com> <516FC218.3060002@canonical.com> <20130418215501.GB8944@electric-eye.fr.zoreil.com> <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw> <20130419061425.GA14843@electric-eye.fr.zoreil.com> <55FF74168B2A4152AD875C000535466F@realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig0488AD9D41E96E65C61D9148"
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	'nic_swsd' <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38560 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab3DYK4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 06:56:43 -0400
In-Reply-To: <55FF74168B2A4152AD875C000535466F@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0488AD9D41E96E65C61D9148
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 19.04.2013 09:49, hayeswang wrote:

>> I don't get it: arp aside, the normal trace in the capture=20
>> file exhibits no
>> sub-60 bytes packet. Could you reformulate ?
>>
>=20
> In brief, when the packet < 60, that is skb->len < 60, the hw should pa=
d the
> packet to 60 bytes automatically. However, in my memory, the rtl8168e-v=
l
> wouldn't do this, and the packet wouldn't be sent. Therefore, the patch=
 would be
> similar with the followings.
>=20
> --- r8169.c.org 2013-04-19 22:35:40.785759473 +0800
> +++ r8169.c     2013-04-19 22:38:24.227189535 +0800
> @@ -5760,12 +5760,29 @@ static inline void rtl8169_tso_csum(stru
>         } else if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>                 const struct iphdr *ip =3D ip_hdr(skb);
>=20
> +               if (unlikely(skb->len < ETH_ZLEN &&
> +                   (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34))) {
> +                       if (skb_padto(skb, ETH_ZLEN))
> +                               return false;
> +                       skb_checksum_help(skb);
> +                       skb_put(skb, ETH_ZLEN - skb->len);
> +                       return true;
> +               }
> +
>                 if (ip->protocol =3D=3D IPPROTO_TCP)
>                         opts[offset] |=3D info->checksum.tcp;
>                 else if (ip->protocol =3D=3D IPPROTO_UDP)
>                         opts[offset] |=3D info->checksum.udp;
>                 else
>                         WARN_ON_ONCE(1);
> +       } else {
> +               if (unlikely(skb->len < ETH_ZLEN &&
> +                   (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34))) {
> +                       if (skb_padto(skb, ETH_ZLEN))
> +                               return false;
> +                       skb_put(skb, ETH_ZLEN - skb->len);
> +                       return true;

Hardware is now back and I ran a couple of tests. First, the crash I ran =
into
previously was because I accidentally slipped in a skp_checksum_help into=
 the
else case that Hayes proposed. Sorry.

So with the right version and both hunks in rtl8169_tso_csum, I see the p=
roblem
go away. I do observe the else case being hit on other occasions (not onl=
y while
doing pxe boots) from time to time. So that may happen more often than it=
 causes
visible problems. I never saw the checksum case being hit.

Naively assuming that the checksum path never gets executed (which may be=
 wrong)
I condensed the changes to:

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/=
realtek
index 4ecbe64..1519a2f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5790,12 +5790,23 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_b=
uff *sk
        if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
                goto err_stop_0;

+       /*
+        * 8168E-VL hardware does not automatically pad to minimum
+        * length.
+        */
+       if (unlikely(skb->len < ETH_ZLEN &&
+           (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34))) {
+               if (skb_padto(skb, ETH_ZLEN))
+                       goto err_update_stats_0;
+               skb_put(skb, ETH_ZLEN - skb->len);
+       }
+
        len =3D skb_headlen(skb);
        mapping =3D dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
        if (unlikely(dma_mapping_error(d, mapping))) {
                if (net_ratelimit())
                        netif_err(tp, drv, dev, "Failed to map TX DMA!\n"=
);
-               goto err_dma_0;
+               goto err_free_skb_1;
        }

        tp->tx_skb[entry].len =3D len;
@@ -5808,7 +5819,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buf=
f *skb,

        frags =3D rtl8169_xmit_frags(tp, skb, opts);
        if (frags < 0)
-               goto err_dma_1;
+               goto err_unmap_dma_1;
        else if (frags)
                opts[0] |=3D FirstFrag;
        else {
@@ -5854,10 +5865,11 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_b=
uff *sk

        return NETDEV_TX_OK;

-err_dma_1:
+err_unmap_dma_1:
        rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
-err_dma_0:
+err_free_skb_1:
        dev_kfree_skb(skb);
+err_update_stats_0:
        dev->stats.tx_dropped++;
        return NETDEV_TX_OK;


This variant also seems to work (and does not drop the tftp packet). Whic=
hever
path looks more suitable to you, you could add my tested-by to both.
We should also flag whichever change results from this as stable material=
 as I
could see this happen even in v3.2 (just did not try further back).

Thanks,
Stefan

> +               }
>         }
>  }
>=20



--------------enig0488AD9D41E96E65C61D9148
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJReQvmAAoJEOhnXe7L7s6jxQEP/2q6pGRVWVyEqSNGY7SbukwS
bzJaNWOv4TOkYgGEVJbrlI+HWRFSPMAPDKlaGj/l0jAsgPWEUiKq+HUjFvqZvbDr
yJaTunT/NXlnPA/xlg9nmVjD/Q/UNKSOUTuvIGN5A4varDbK1zwkkseC9MZSBkPf
VRAGeIZOsroYiAz67ekL2EvL+YL/Ujr1jrNTQwIrzdENa0QZhWPjAG5o1cVSonO5
z/r5Jl/qUftdemmd5znORccTEOGPlZ9sUm3hQ2B/dRZei3A7GGk13ylzA6cvL+Jg
53bVA3/FUzV8bILZcP9qIHgFBwlznVfvRoc5BJBiOpdQ02Yd+2zC3VUVKls/4N6P
oRxAV2EqL/YPjqylbRD/Ma0hPx6igEUoa1qmdLVZOrvX5OJIZWNzifCwtN/A4ttg
5AO8Ytjg/nE4GfTFCWXItOWAVXC7RvROHfIyHwzS8jvHMYmsD1lcmdA3zY9WLGFr
NdHQcmTi1xNxG+gEokICImCML+tNsAMqqy3e+Oy7N3GTT/BV60eoRni+ORDxoxac
aBuA6PAf6VXB1R4E7kGfJeBKHRP+LJWVDOchVVuQQHXw89N5rHW1FE/QgBqrSmWp
Uw3heNIUKprbPpZvk/S6AkJRuP7ioIaGTE+DEXgjJ0YbBGF3OPhzZUK5WBQMkwg5
og0qIi+UdZMuS3lytyc6
=ouVD
-----END PGP SIGNATURE-----

--------------enig0488AD9D41E96E65C61D9148--
