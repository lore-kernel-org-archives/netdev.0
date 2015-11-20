From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH 13/15] ixgbe: Convert to advertise NETIF_F_HW_CSUM
Date: Fri, 20 Nov 2015 23:56:41 +0000
Message-ID: <5F5C53CE-40BF-484B-96CC-A26BF789AE48@intel.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
 <1447962961-2106059-14-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3F86BAAB-8E45-40B5-A3E2-A80AD63623BA";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5759 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759434AbbKTX4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 18:56:42 -0500
In-Reply-To: <1447962961-2106059-14-git-send-email-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_3F86BAAB-8E45-40B5-A3E2-A80AD63623BA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Tom Herbert <tom@herbertland.com> wrote:

> The skb_csum_offload_chk is used to resolve checksums that are unable
> to be offloaded to the device.
>=20
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 41 =
+++++++++++++++++++--------
> 1 file changed, 29 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c =
b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 80823f5..26c1633 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c

<snip>

> static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
> -			  struct ixgbe_tx_buffer *first)
> +			  struct ixgbe_tx_buffer *first,
> +			  struct ixgbe_adapter *adapter)

This added parameter should not be needed. See below.

> {
> 	struct sk_buff *skb =3D first->skb;
> 	u32 vlan_macip_lens =3D 0;
> 	u32 mss_l4len_idx =3D 0;
> 	u32 type_tucmd =3D 0;
> +	bool csum_encapped;
>=20
> -	if (skb->ip_summed !=3D CHECKSUM_PARTIAL) {
> +	if (!skb_csum_offload_chk(skb, &csum_offl_spec, &csum_encapped, =
true)) {
> +no_csum:
> 		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
> 		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
> 			return;
> @@ -7025,7 +7038,15 @@ static void ixgbe_tx_csum(struct ixgbe_ring =
*tx_ring,
> 			u8 *raw;
> 		} transport_hdr;
>=20
> -		if (skb->encapsulation) {
> +		if (csum_encapped) {
> +			switch (adapter->hw.mac.type) {
> +			case ixgbe_mac_X550:
> +			case ixgbe_mac_X550EM_x:
> +				break;
> +			default:
> +				skb_checksum_help(skb);
> +				goto no_csum;
> +			}
> 			network_hdr.raw =3D =
skb_inner_network_header(skb);
> 			transport_hdr.raw =3D =
skb_inner_transport_header(skb);
> 			vlan_macip_lens =3D =
skb_inner_network_offset(skb) <<

The switch checking the mac type above is not needed. All of the ixgbe =
devices can handle encapsulated tx checksum offload. The X550 series
has the ability to offload the rx side as well, but is not a factor
here. That also means that the added adapter parameter would not be
needed.

> @@ -7602,7 +7623,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff =
*skb,
> 	if (tso < 0)
> 		goto out_drop;
> 	else if (!tso)
> -		ixgbe_tx_csum(tx_ring, first);
> +		ixgbe_tx_csum(tx_ring, first, adapter);
>=20
> 	/* add the ATR filter if ATR is on */
> 	if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))

<snip>

> @@ -8794,12 +8814,10 @@ skip_sriov:
>=20
> 	netdev->vlan_features |=3D NETIF_F_TSO;
> 	netdev->vlan_features |=3D NETIF_F_TSO6;
> -	netdev->vlan_features |=3D NETIF_F_IP_CSUM;
> -	netdev->vlan_features |=3D NETIF_F_IPV6_CSUM;
> +	netdev->vlan_features |=3D NETIF_F_HW_CSUM;
> 	netdev->vlan_features |=3D NETIF_F_SG;
>=20
> -	netdev->hw_enc_features |=3D NETIF_F_SG | NETIF_F_IP_CSUM |
> -				   NETIF_F_IPV6_CSUM;
> +	netdev->hw_enc_features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
>=20
> 	netdev->priv_flags |=3D IFF_UNICAST_FLT;
> 	netdev->priv_flags |=3D IFF_SUPP_NOFCS;
> @@ -8809,8 +8827,7 @@ skip_sriov:
> 	case ixgbe_mac_X550:
> 	case ixgbe_mac_X550EM_x:
> 		netdev->hw_enc_features |=3D NETIF_F_RXCSUM |
> -					   NETIF_F_IP_CSUM |
> -					   NETIF_F_IPV6_CSUM;
> +					   NETIF_F_HW_CSUM;

This is actually redundant, because the bit in hw_enc_features was set =
above. I already have a patch in queue that changes the statement above =
to only set the NETIF_F_RXCSUM for the X550 devices because the other =
bits were set just above. So once my patch is applied, this last hunk =
won't be needed here.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_3F86BAAB-8E45-40B5-A3E2-A80AD63623BA
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWT7M4AAoJEDwO/+eO4+5uSSYP/33zp804qfrneV1m8Fq4jr0B
K+DoNZzZS5Eu/8QW+2gJYFnEen1gpGMtKKSvqOR4DfbZdKqLOxStazDnd8WK/XBs
ooBwU695phfNe0QMtrDUNcc9DkErA7SjwL31XhvOOjb2tpCA6ZvnFZIvBKhdIx/r
UZC5Ri9s4ReyQtPzBTrsjwUhUY/kJW0r02Gthu7Hw8OMGDBueiCyfQgZVZo8sARH
Dydk0o6j1CXkN7fFH/kMUKnsqe5rZ+U2MRDkeFbISUYOeCXZPLODeadKjleGqZTM
VhGijwZmBWIzm/+wcfBDalhLzh+Cb7e3Md5ygyDesgFVhOJgWK1fCDs8QvaTwOvg
AD4kzgP2JlMT1NFfaSz8SZxdMNplTALcB9r7MDAlxqbnIlfDhXkR6wFIEISxnEks
xAgn9kFGQmHFlwELTsmuT5qUVxnsb6svWDLJ99yCuoOlK3r2usCob2hl7E7caf1o
Yny3cLQ+oLAy4B2hLcqkf5kzq+yY1/g+ig6dSWJZ9cu8h/FGXiSWS6ikQmPTZFyQ
YPzzTcHtJtp6K+/hQjgbhAauGEO8fZ3RPvkHoiJSit9XuuL+kh+x5Q0DLvYd8Oob
QEADZpUTtHJVTunHLA4hU0XJeOTAh8AmgG+LXiRtZXazkDLzr6nwKTCQsANbZIBs
FvqFFPRlQqQVqv/2D+Vi
=O+en
-----END PGP SIGNATURE-----

--Apple-Mail=_3F86BAAB-8E45-40B5-A3E2-A80AD63623BA--
