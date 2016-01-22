From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH v2] ethtool: add IPv6 to the NFC API
Date: Fri, 22 Jan 2016 10:54:53 -0800
Message-ID: <CAKgT0UdTLSio=LZPOzT5aiPL=GbPHXHxD6dCaBQ470f29YKq7Q@mail.gmail.com>
References: <56A260D9.3020004@solarflare.com>
	<56A26F1A.1000505@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34393 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbcAVSyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 13:54:54 -0500
Received: by mail-ig0-f178.google.com with SMTP id ik10so17062182igb.1
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 10:54:54 -0800 (PST)
In-Reply-To: <56A26F1A.1000505@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 10:04 AM, Edward Cree <ecree@solarflare.com> wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> changes from v1:
> * split out separate spec structs for different flow types
> * clarified the proto field in usr_ip6_spec
> * changed IP6_USER_FLOW to 0x0e as I noticed there's a gap there
>
>  include/uapi/linux/ethtool.h | 67 ++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 62 insertions(+), 5 deletions(-)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 57fa390..ad805b9 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -748,6 +748,56 @@ struct ethtool_usrip4_spec {
>         __u8    proto;
>  };
>
> +/**
> + * struct ethtool_tcpip6_spec - flow specification for TCP/IPv6 etc.
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @psrc: Source port
> + * @pdst: Destination port
> + * @tos: Type-of-service
> + *
> + * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
> + */
> +struct ethtool_tcpip6_spec {
> +       __be32  ip6src[4];
> +       __be32  ip6dst[4];
> +       __be16  psrc;
> +       __be16  pdst;
> +       __u8    tos;
> +};
> +
> +/**
> + * struct ethtool_ah_espip6_spec - flow specification for IPsec/IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @spi: Security parameters index
> + * @tos: Type-of-service
> + *
> + * This can be used to specify an IPsec transport or tunnel over IPv6.
> + */
> +struct ethtool_ah_espip6_spec {
> +       __be32  ip6src[4];
> +       __be32  ip6dst[4];
> +       __be32  spi;
> +       __u8    tos;
> +};
> +
> +/**
> + * struct ethtool_usrip6_spec - general flow specification for IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @l4_4_bytes: First 4 bytes of transport (layer 4) header
> + * @tos: Type-of-service
> + * @proto: Transport protocol number (nexthdr after any Extension Headers)
> + */
> +struct ethtool_usrip6_spec {
> +       __be32  ip6src[4];
> +       __be32  ip6dst[4];
> +       __be32  l4_4_bytes;
> +       __u8    tos;
> +       __u8    proto;
> +};
> +

It might be better to refer to this as l4_proto so that it is clear
that this is specifying the protocol of the l4 header that the
l4_4_bytes will be pulled from.

It still might even be useful to add a nexthdr field since it is
possible that there may be NICs out there that don't support parsing
the extension headers.  In such a case they could block setting
protocol and use nexthdr instead.  It provides an indirect way of
communicating if the NIC supports parsing extension headers or not as
the NIC can block adding a filter on one mask being set or the other.

>  union ethtool_flow_union {
>         struct ethtool_tcpip4_spec              tcp_ip4_spec;
>         struct ethtool_tcpip4_spec              udp_ip4_spec;
> @@ -755,6 +805,12 @@ union ethtool_flow_union {
>         struct ethtool_ah_espip4_spec           ah_ip4_spec;
>         struct ethtool_ah_espip4_spec           esp_ip4_spec;
>         struct ethtool_usrip4_spec              usr_ip4_spec;
> +       struct ethtool_tcpip6_spec              tcp_ip6_spec;
> +       struct ethtool_tcpip6_spec              udp_ip6_spec;
> +       struct ethtool_tcpip6_spec              sctp_ip6_spec;
> +       struct ethtool_ah_espip6_spec           ah_ip6_spec;
> +       struct ethtool_ah_espip6_spec           esp_ip6_spec;
> +       struct ethtool_usrip6_spec              usr_ip6_spec;
>         struct ethhdr                           ether_spec;
>         __u8                                    hdata[52];
>  };
> @@ -1367,15 +1423,16 @@ enum ethtool_sfeatures_retval_bits {
>  #define        UDP_V4_FLOW     0x02    /* hash or spec (udp_ip4_spec) */
>  #define        SCTP_V4_FLOW    0x03    /* hash or spec (sctp_ip4_spec) */
>  #define        AH_ESP_V4_FLOW  0x04    /* hash only */
> -#define        TCP_V6_FLOW     0x05    /* hash only */
> -#define        UDP_V6_FLOW     0x06    /* hash only */
> -#define        SCTP_V6_FLOW    0x07    /* hash only */
> +#define        TCP_V6_FLOW     0x05    /* hash or spec (tcp_ip6_spec; nfc only) */
> +#define        UDP_V6_FLOW     0x06    /* hash or spec (udp_ip6_spec; nfc only) */
> +#define        SCTP_V6_FLOW    0x07    /* hash or spec (sctp_ip6_spec; nfc only) */
>  #define        AH_ESP_V6_FLOW  0x08    /* hash only */
>  #define        AH_V4_FLOW      0x09    /* hash or spec (ah_ip4_spec) */
>  #define        ESP_V4_FLOW     0x0a    /* hash or spec (esp_ip4_spec) */
> -#define        AH_V6_FLOW      0x0b    /* hash only */
> -#define        ESP_V6_FLOW     0x0c    /* hash only */
> +#define        AH_V6_FLOW      0x0b    /* hash or spec (ah_ip6_spec; nfc only) */
> +#define        ESP_V6_FLOW     0x0c    /* hash or spec (esp_ip6_spec; nfc only) */
>  #define        IP_USER_FLOW    0x0d    /* spec only (usr_ip4_spec) */
> +#define        IP6_USER_FLOW   0x0e    /* spec only (usr_ip6_spec; nfc only) */
>  #define        IPV4_FLOW       0x10    /* hash only */
>  #define        IPV6_FLOW       0x11    /* hash only */
>  #define        ETHER_FLOW      0x12    /* spec only (ether_spec) */
