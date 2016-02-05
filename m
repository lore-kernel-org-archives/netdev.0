From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] sfc: implement IPv6 NFC (and
 IPV4_USER_FLOW)
Date: Fri, 05 Feb 2016 16:57:36 +0000
Message-ID: <1454691456.20702.62.camel@decadent.org.uk>
References: <56B483A1.4070901@solarflare.com>
	 <56B484A2.60609@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vDCL9YKXZ89G2zGwr7rL"
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38929 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729AbcBEQ5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 11:57:43 -0500
In-Reply-To: <56B484A2.60609@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vDCL9YKXZ89G2zGwr7rL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-05 at 11:16 +0000, Edward Cree wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> =C2=A0drivers/net/ethernet/sfc/ethtool.c | 184 ++++++++++++++++++++++++++=
+++++++++++
> =C2=A01 file changed, 184 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sf=
c/ethtool.c
> index 0347976..445ccdb 100644
> --- a/drivers/net/ethernet/sfc/ethtool.c
> +++ b/drivers/net/ethernet/sfc/ethtool.c
> @@ -783,14 +783,26 @@ static int efx_ethtool_reset(struct net_device *net=
_dev, u32 *flags)
> =C2=A0static const u8 mac_addr_ig_mask[ETH_ALEN] __aligned(2) =3D {0x01, =
0, 0, 0, 0, 0};
> =C2=A0
> =C2=A0#define IP4_ADDR_FULL_MASK	((__force __be32)~0)
> +#define IP_PROTO_FULL_MASK	0xFF
> =C2=A0#define PORT_FULL_MASK		((__force __be16)~0)
> =C2=A0#define ETHER_TYPE_FULL_MASK	((__force __be16)~0)
> =C2=A0
> +static inline void ip6_fill_mask(__be32 *mask)
> +{
> +	mask[0] =3D mask[1] =3D mask[2] =3D mask[3] =3D ~(__be32)0;
> +}
> +
> =C2=A0static int efx_ethtool_get_class_rule(struct efx_nic *efx,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_rx_flow_spec=
 *rule)
> =C2=A0{
> =C2=A0	struct ethtool_tcpip4_spec *ip_entry =3D &rule->h_u.tcp_ip4_spec;
> =C2=A0	struct ethtool_tcpip4_spec *ip_mask =3D &rule->m_u.tcp_ip4_spec;
> +	struct ethtool_usrip4_spec *uip_entry =3D &rule->h_u.usr_ip4_spec;
> +	struct ethtool_usrip4_spec *uip_mask =3D &rule->m_u.usr_ip4_spec;
> +	struct ethtool_tcpip6_spec *ip6_entry =3D &rule->h_u.tcp_ip6_spec;
> +	struct ethtool_tcpip6_spec *ip6_mask =3D &rule->m_u.tcp_ip6_spec;
> +	struct ethtool_usrip6_spec *uip6_entry =3D &rule->h_u.usr_ip6_spec;
> +	struct ethtool_usrip6_spec *uip6_mask =3D &rule->m_u.usr_ip6_spec;
> =C2=A0	struct ethhdr *mac_entry =3D &rule->h_u.ether_spec;
> =C2=A0	struct ethhdr *mac_mask =3D &rule->m_u.ether_spec;
> =C2=A0	struct efx_filter_spec spec;
> @@ -833,6 +845,35 @@ static int efx_ethtool_get_class_rule(struct efx_nic=
 *efx,
> =C2=A0			ip_entry->psrc =3D spec.rem_port;
> =C2=A0			ip_mask->psrc =3D PORT_FULL_MASK;
> =C2=A0		}
> +	} else if ((spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0spec.ether_type =3D=3D htons(ETH_P_IPV6) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) =
&&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(spec.ip_proto =3D=3D IPPROTO_TCP || spec.ip_pr=
oto =3D=3D IPPROTO_UDP) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0!(spec.match_flags &
> +	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0~(EFX_FILTER_MATCH_ETHER_TYPE | EFX=
_FILTER_MATCH_OUTER_VID |
> +		EFX_FILTER_MATCH_LOC_HOST | EFX_FILTER_MATCH_REM_HOST |
> +		EFX_FILTER_MATCH_IP_PROTO |
> +		EFX_FILTER_MATCH_LOC_PORT | EFX_FILTER_MATCH_REM_PORT))) {
> +		rule->flow_type =3D ((spec.ip_proto =3D=3D IPPROTO_TCP) ?
> +				=C2=A0=C2=A0=C2=A0TCP_V6_FLOW : UDP_V6_FLOW);
> +		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
> +			memcpy(ip6_entry->ip6dst, spec.loc_host,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sizeof(ip6_entry->ip6dst));
> +			ip6_fill_mask(ip6_mask->ip6dst);
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
> +			memcpy(ip6_entry->ip6src, spec.rem_host,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sizeof(ip6_entry->ip6src));
> +			ip6_fill_mask(ip6_mask->ip6src);
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_LOC_PORT) {
> +			ip6_entry->pdst =3D spec.loc_port;
> +			ip6_mask->pdst =3D PORT_FULL_MASK;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_REM_PORT) {
> +			ip6_entry->psrc =3D spec.rem_port;
> +			ip6_mask->psrc =3D PORT_FULL_MASK;
> +		}
> =C2=A0	} else if (!(spec.match_flags &
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0~(EFX_FILTER_MATCH_LOC_MAC | EFX_FI=
LTER_MATCH_LOC_MAC_IG |
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_REM_MA=
C | EFX_FILTER_MATCH_ETHER_TYPE |
> @@ -855,6 +896,47 @@ static int efx_ethtool_get_class_rule(struct efx_nic=
 *efx,
> =C2=A0			mac_entry->h_proto =3D spec.ether_type;
> =C2=A0			mac_mask->h_proto =3D ETHER_TYPE_FULL_MASK;
> =C2=A0		}
> +	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
> +		=C2=A0=C2=A0=C2=A0spec.ether_type =3D=3D htons(ETH_P_IP) &&
> +		=C2=A0=C2=A0=C2=A0!(spec.match_flags &
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0~(EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILT=
ER_MATCH_OUTER_VID |
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_LOC_HOST | =
EFX_FILTER_MATCH_REM_HOST |
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_IP_PROTO)))=
 {
> +		rule->flow_type =3D IPV4_USER_FLOW;
> +		uip_entry->ip_ver =3D ETH_RX_NFC_IP4;
> +		if (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) {
> +			uip_mask->proto =3D IP_PROTO_FULL_MASK;
> +			uip_entry->proto =3D spec.ip_proto;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
> +			uip_entry->ip4dst =3D spec.loc_host[0];
> +			uip_mask->ip4dst =3D IP4_ADDR_FULL_MASK;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
> +			uip_entry->ip4src =3D spec.rem_host[0];
> +			uip_mask->ip4src =3D IP4_ADDR_FULL_MASK;
> +		}
> +	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
> +		=C2=A0=C2=A0=C2=A0spec.ether_type =3D=3D htons(ETH_P_IPV6) &&
> +		=C2=A0=C2=A0=C2=A0!(spec.match_flags &
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0~(EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILT=
ER_MATCH_OUTER_VID |
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_LOC_HOST | =
EFX_FILTER_MATCH_REM_HOST |
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_IP_PROTO)))=
 {
> +		rule->flow_type =3D IPV6_USER_FLOW;
> +		if (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) {
> +			uip6_mask->l4_proto =3D IP_PROTO_FULL_MASK;
> +			uip6_entry->l4_proto =3D spec.ip_proto;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
> +			memcpy(uip6_entry->ip6dst, spec.loc_host,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sizeof(uip6_entry->ip6dst))=
;
> +			ip6_fill_mask(uip6_mask->ip6dst);
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
> +			memcpy(uip6_entry->ip6src, spec.rem_host,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0sizeof(uip6_entry->ip6src))=
;
> +			ip6_fill_mask(uip6_mask->ip6src);
> +		}
> =C2=A0	} else {
> =C2=A0		/* The above should handle all filters that we insert */
> =C2=A0		WARN_ON(1);
> @@ -946,11 +1028,27 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
> =C2=A0	}
> =C2=A0}
> =C2=A0
> +static inline bool ip6_mask_is_full(__be32 mask[4])
> +{
> +	return !~(mask[0] & mask[1] & mask[2] & mask[3]);
> +}
> +
> +static inline bool ip6_mask_is_empty(__be32 mask[4])
> +{
> +	return !(mask[0] | mask[1] | mask[2] | mask[3]);
> +}
> +
> =C2=A0static int efx_ethtool_set_class_rule(struct efx_nic *efx,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_rx_flow_spec=
 *rule)
> =C2=A0{
> =C2=A0	struct ethtool_tcpip4_spec *ip_entry =3D &rule->h_u.tcp_ip4_spec;
> =C2=A0	struct ethtool_tcpip4_spec *ip_mask =3D &rule->m_u.tcp_ip4_spec;
> +	struct ethtool_usrip4_spec *uip_entry =3D &rule->h_u.usr_ip4_spec;
> +	struct ethtool_usrip4_spec *uip_mask =3D &rule->m_u.usr_ip4_spec;
> +	struct ethtool_tcpip6_spec *ip6_entry =3D &rule->h_u.tcp_ip6_spec;
> +	struct ethtool_tcpip6_spec *ip6_mask =3D &rule->m_u.tcp_ip6_spec;
> +	struct ethtool_usrip6_spec *uip6_entry =3D &rule->h_u.usr_ip6_spec;
> +	struct ethtool_usrip6_spec *uip6_mask =3D &rule->m_u.usr_ip6_spec;
> =C2=A0	struct ethhdr *mac_entry =3D &rule->h_u.ether_spec;
> =C2=A0	struct ethhdr *mac_mask =3D &rule->m_u.ether_spec;
> =C2=A0	struct efx_filter_spec spec;
> @@ -1012,6 +1110,92 @@ static int efx_ethtool_set_class_rule(struct efx_n=
ic *efx,
> =C2=A0			return -EINVAL;
> =C2=A0		break;
> =C2=A0
> +	case TCP_V6_FLOW:
> +	case UDP_V6_FLOW:
> +		spec.match_flags =3D (EFX_FILTER_MATCH_ETHER_TYPE |
> +				=C2=A0=C2=A0=C2=A0=C2=A0EFX_FILTER_MATCH_IP_PROTO);
> +		spec.ether_type =3D htons(ETH_P_IPV6);
> +		spec.ip_proto =3D ((rule->flow_type & ~FLOW_EXT) =3D=3D TCP_V6_FLOW ?
> +				=C2=A0IPPROTO_TCP : IPPROTO_UDP);
> +		if (!ip6_mask_is_empty(ip6_mask->ip6dst)) {
> +			if (!ip6_mask_is_full(ip6_mask->ip6dst))
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_LOC_HOST;
> +			memcpy(spec.loc_host, ip6_entry->ip6dst, sizeof(spec.loc_host));
> +		}
> +		if (!ip6_mask_is_empty(ip6_mask->ip6src)) {
> +			if (!ip6_mask_is_full(ip6_mask->ip6src))
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_REM_HOST;
> +			memcpy(spec.rem_host, ip6_entry->ip6src, sizeof(spec.rem_host));
> +		}
> +		if (ip6_mask->pdst) {
> +			if (ip6_mask->pdst !=3D PORT_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_LOC_PORT;
> +			spec.loc_port =3D ip6_entry->pdst;
> +		}
> +		if (ip6_mask->psrc) {
> +			if (ip6_mask->psrc !=3D PORT_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_REM_PORT;
> +			spec.rem_port =3D ip6_entry->psrc;
> +		}
> +		if (ip6_mask->tclass)
> +			return -EINVAL;
> +		break;
> +
> +	case IPV4_USER_FLOW:
> +		if (uip_mask->l4_4_bytes || uip_mask->tos || uip_mask->ip_ver ||
> +		=C2=A0=C2=A0=C2=A0=C2=A0uip_entry->ip_ver !=3D ETH_RX_NFC_IP4)
> +			return -EINVAL;
> +		spec.match_flags =3D EFX_FILTER_MATCH_ETHER_TYPE;
> +		spec.ether_type =3D htons(ETH_P_IP);
> +		if (uip_mask->ip4dst) {
> +			if (uip_mask->ip4dst !=3D IP4_ADDR_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_LOC_HOST;
> +			spec.loc_host[0] =3D uip_entry->ip4dst;
> +		}
> +		if (uip_mask->ip4src) {
> +			if (uip_mask->ip4src !=3D IP4_ADDR_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_REM_HOST;
> +			spec.rem_host[0] =3D uip_entry->ip4src;
> +		}
> +		if (uip_mask->proto) {
> +			if (uip_mask->proto !=3D IP_PROTO_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_IP_PROTO;
> +			spec.ip_proto =3D uip_entry->proto;
> +		}
> +		break;
> +
> +	case IPV6_USER_FLOW:
> +		if (uip6_mask->l4_4_bytes || uip6_mask->tclass)
> +			return -EINVAL;
> +		spec.match_flags =3D EFX_FILTER_MATCH_ETHER_TYPE;
> +		spec.ether_type =3D htons(ETH_P_IPV6);
> +		if (!ip6_mask_is_empty(uip6_mask->ip6dst)) {
> +			if (!ip6_mask_is_full(uip6_mask->ip6dst))
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_LOC_HOST;
> +			memcpy(spec.loc_host, uip6_entry->ip6dst, sizeof(spec.loc_host));
> +		}
> +		if (!ip6_mask_is_empty(uip6_mask->ip6src)) {
> +			if (!ip6_mask_is_full(uip6_mask->ip6src))
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_REM_HOST;
> +			memcpy(spec.rem_host, uip6_entry->ip6src, sizeof(spec.rem_host));
> +		}
> +		if (uip6_mask->l4_proto) {
> +			if (uip6_mask->l4_proto !=3D IP_PROTO_FULL_MASK)
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_IP_PROTO;
> +			spec.ip_proto =3D uip6_entry->l4_proto;
> +		}
> +		break;
> +
> =C2=A0	case ETHER_FLOW:
> =C2=A0		if (!is_zero_ether_addr(mac_mask->h_dest)) {
> =C2=A0			if (ether_addr_equal(mac_mask->h_dest,
--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein
--=-vDCL9YKXZ89G2zGwr7rL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVrTUgOe/yOyVhhEJAQpIQxAAtnyFE/387BfcClwNQp30UqqBG98td9Yt
+LaSyH/KvohWXNGh/MYJeMIo7lBL/xg/tAVMwivvj/EJWjtAoWyzDmmLG1aZDLDi
7estzok5MGqgT4qKkb1zM2bD5bEo200bzh95rcykVjcnM/7KPr/5UVo5Vb5PLMBl
U735EFvfyM4IpkKegufbytKPaUB7zHgLSRwSFLtkJ3APWA5RsDYlymg4HWME/3eX
WJ11WYqhMute8ZJ90mgY0fz29OLHpyzBsd7zXlxw4swxaLNe50ddNBXezcu/O9xO
c9wnpKK7gcyQk0r93lZ6vVrlAExxXegEmWWkz6L6CHu4ubzPy2zhewfHHTDS5U0U
t3bDegvvwFfmG+1yjx0a14mMbx67SZdxa3h3JWohoALrLQB6Edxc879e01Plw14G
BGiJeiNuto4sesB2LrSmNvnMsd8keQKtSmFSypt81xsuvl4M301SkE2NI3XZ7dXz
l3KCLfxUHt4sxsLCyNaPEOL1WQs2DxSVxzZ3azv6MbPiGcYVMvSWyGR/d3fWRPOc
HPhXYHQ9XZR5U7rMhqU5+ORGD1MgOtVL6APBgnojunuBS36nyGX032JCocAL+/kQ
UnBaZAj3E8SpTxVnQ/z5f+0YOWN8lN4Do1p10l0GuVQEsmC1v3tXdzGdzR7KfuDh
SWPf6zJN/2s=
=TTXl
-----END PGP SIGNATURE-----

--=-vDCL9YKXZ89G2zGwr7rL--
