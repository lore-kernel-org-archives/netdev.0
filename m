From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] ethtool: add IPv6 to the NFC API
Date: Thu, 21 Jan 2016 14:48:51 -0800
Message-ID: <CAKgT0UeP4u04PsaupuQ19HdOxa6qZ3dCaxbdJeJ4DJ-Oqq+SOA@mail.gmail.com>
References: <1453317771.3734.68.camel@decadent.org.uk>
	<56A12E29.7000507@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38451 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcAUWsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 17:48:52 -0500
Received: by mail-ig0-f181.google.com with SMTP id mw1so43652758igb.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 14:48:52 -0800 (PST)
In-Reply-To: <56A12E29.7000507@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 11:14 AM, Edward Cree <ecree@solarflare.com> wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> Haven't yet tried to write the ethtool client end of this (or a driver
> implementation), but does it look reasonable?
>
>  include/uapi/linux/ethtool.h | 30 +++++++++++++++++++++++++-----
>  1 file changed, 25 insertions(+), 5 deletions(-)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 57fa390..74bef53 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -748,6 +748,24 @@ struct ethtool_usrip4_spec {
>         __u8    proto;
>  };
>
> +/**
> + * struct ethtool_ip6_spec - general flow specification for IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @l4_4_bytes: First 4 bytes of transport (layer 4) header
> + * @spi: Security parameters index, for %AH_V6_FLOW and %ESP_V6_FLOW
> + * @tos: Type-of-service
> + * @proto: Transport protocol number, for %IP6_USER_FLOW
> + */
> +struct ethtool_ip6_spec {
> +       __be32  ip6src[4];
> +       __be32  ip6dst[4];
> +       __be32  l4_4_bytes;

The one concern I would have about the filter is that for protocols
like UDP and TCP which have 2 __be16 values in the l4_4_bytes field is
that it would be pretty easy to end up swapping src and dst and then
making a mess of it.  I really would like to see a ethtool_tcpip6_spec
just to make sure we have it laid out clearly that it should be src
port and then destination port.

> +       __be32  spi;

Is this supposed to be the flow label, or is this the IPSec security
parameter index?  If it is the flow label you may want to rename it.
If it is supposed to be the IPSec security parameter index this might
belong in a different flow definition since it is not actually a part
of the IPv6 header.

> +       __u8    tos;
> +       __u8    proto;
> +};
> +

Technically the name of the field for proto is nexthdr.

>  union ethtool_flow_union {
>         struct ethtool_tcpip4_spec              tcp_ip4_spec;
>         struct ethtool_tcpip4_spec              udp_ip4_spec;
> @@ -755,6 +773,7 @@ union ethtool_flow_union {
>         struct ethtool_ah_espip4_spec           ah_ip4_spec;
>         struct ethtool_ah_espip4_spec           esp_ip4_spec;
>         struct ethtool_usrip4_spec              usr_ip4_spec;
> +       struct ethtool_ip6_spec                 ip6_spec;
>         struct ethhdr                           ether_spec;
>         __u8                                    hdata[52];
>  };
> @@ -1367,18 +1386,19 @@ enum ethtool_sfeatures_retval_bits {
>  #define        UDP_V4_FLOW     0x02    /* hash or spec (udp_ip4_spec) */
>  #define        SCTP_V4_FLOW    0x03    /* hash or spec (sctp_ip4_spec) */
>  #define        AH_ESP_V4_FLOW  0x04    /* hash only */
> -#define        TCP_V6_FLOW     0x05    /* hash only */
> -#define        UDP_V6_FLOW     0x06    /* hash only */
> -#define        SCTP_V6_FLOW    0x07    /* hash only */
> +#define        TCP_V6_FLOW     0x05    /* hash or spec (ip6_spec) */
> +#define        UDP_V6_FLOW     0x06    /* hash or spec (ip6_spec) */
> +#define        SCTP_V6_FLOW    0x07    /* hash or spec (ip6_spec) */
>  #define        AH_ESP_V6_FLOW  0x08    /* hash only */
>  #define        AH_V4_FLOW      0x09    /* hash or spec (ah_ip4_spec) */
>  #define        ESP_V4_FLOW     0x0a    /* hash or spec (esp_ip4_spec) */
> -#define        AH_V6_FLOW      0x0b    /* hash only */
> -#define        ESP_V6_FLOW     0x0c    /* hash only */
> +#define        AH_V6_FLOW      0x0b    /* hash or spec (ip6_spec) */
> +#define        ESP_V6_FLOW     0x0c    /* hash or spec (ip6_spec) */
>  #define        IP_USER_FLOW    0x0d    /* spec only (usr_ip4_spec) */
>  #define        IPV4_FLOW       0x10    /* hash only */
>  #define        IPV6_FLOW       0x11    /* hash only */
>  #define        ETHER_FLOW      0x12    /* spec only (ether_spec) */
> +#define        IP6_USER_FLOW   0x13    /* spec only (ip6_spec) */
>  /* Flag to enable additional fields in struct ethtool_rx_flow_spec */
>  #define        FLOW_EXT        0x80000000
>  #define        FLOW_MAC_EXT    0x40000000
