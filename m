From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] gso: Replace SKB_GSO_IPIP and SKB_GSO_SIT with outer
 L3 types
Date: Thu, 5 May 2016 15:34:53 -0700
Message-ID: <CALx6S342jKgPp3i+DZaWUxZQRtqL9fhqDv8mdaU1mTaZphiVKQ@mail.gmail.com>
References: <20160505221243.11909.29048.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	michael.chan@broadcom.com,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36446 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbcEEWez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 18:34:55 -0400
Received: by mail-ig0-f173.google.com with SMTP id u10so30018592igr.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 15:34:54 -0700 (PDT)
In-Reply-To: <20160505221243.11909.29048.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm testing a similar change, it seems like a good idea.

On Thu, May 5, 2016 at 3:12 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch removes SKB_GSO_IPIP and SKB_GSO_SIT and instead replaces them
> with SKB_GSO_IPIPV4 and SKB_GSO_IPIPV6.  The idea here is that SKB_GSO_IPIP
> and SKB_GSO_SIT are actually redundant as TCPV4 and TCPV6 were already
> representing the inner network header type.  By reporting what the outer
> network header type is we should be able to represent all applicable cases
> as SKB_GSO_IPIPV4 can be combined with SKB_GSO_TCPV4 or SKB_GSO_TCPV6 and
> it should then be possible to describe all possible IP in IP tunnel
> combinations for inner and outer v4/v6.
>
> I played it safe with the Broadcom drivers and just merged GSO_IPIP and
> GSO_SIT into GSO_IPIPV4, if the drivers do support outer IPv6 tunnels I can
> either update this patch to add them in, or can add a patch to enable that
> later.
>
> In the case of the Intel drivers I know they should be able to handle IPv6
> outer headers so I went ahead and enabled GSO_IPIPV6 for them.
>
> This patch is meant to be applied after "gso: Remove arbitrary checks for
> unsupported GSO" which can be found at:
> https://patchwork.ozlabs.org/patch/618757/
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    5 ++---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_main.c       |    4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    4 ++--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    4 ++--
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c   |    4 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c         |    4 ++--
>  drivers/net/ethernet/intel/igbvf/netdev.c         |    4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 ++--
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 ++--
>  include/linux/netdev_features.h                   |   12 ++++++------
>  include/linux/netdevice.h                         |    4 ++--
>  include/linux/skbuff.h                            |    4 ++--
>  net/core/ethtool.c                                |    4 ++--
>  net/ipv4/af_inet.c                                |   16 +++++++++++-----
>  net/ipv4/ipip.c                                   |    2 +-
>  net/ipv6/ip6_offload.c                            |    7 +++++--
>  net/ipv6/sit.c                                    |    4 ++--
>  net/netfilter/ipvs/ip_vs_xmit.c                   |   14 +++-----------
>  19 files changed, 54 insertions(+), 54 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index d465bd721146..fbc713094611 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -13259,12 +13259,11 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
>                 NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
>         if (!chip_is_e1x) {
>                 dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
> -                                   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
> +                                   NETIF_F_GSO_IPIPV4;

I prefer using IPXIP4 and IPXIP6, especially to be clear that the
inner protocol is either IP version.

>                 dev->hw_enc_features =
>                         NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
>                         NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> -                       NETIF_F_GSO_IPIP |
> -                       NETIF_F_GSO_SIT |
> +                       NETIF_F_GSO_IPIPV4 |
>                         NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
>         }
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index fd85b6dd4a6e..b3821fbf8e1b 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -6218,7 +6218,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>         dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
>                            NETIF_F_TSO | NETIF_F_TSO6 |
>                            NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
> -                          NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +                          NETIF_F_GSO_IPIPV4 |
>                            NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
>                            NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
>                            NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
> @@ -6228,7 +6228,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>                         NETIF_F_TSO | NETIF_F_TSO6 |
>                         NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
>                         NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
> -                       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +                       NETIF_F_GSO_IPIPV4 |
>                         NETIF_F_GSO_PARTIAL;
>         dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM |
>                                     NETIF_F_GSO_GRE_CSUM;
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 1cd0ebf7520a..bf1d31c4e310 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -9083,8 +9083,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
>                                    NETIF_F_TSO6                 |
>                                    NETIF_F_GSO_GRE              |
>                                    NETIF_F_GSO_GRE_CSUM         |
> -                                  NETIF_F_GSO_IPIP             |
> -                                  NETIF_F_GSO_SIT              |
> +                                  NETIF_F_GSO_IPIPV4           |
> +                                  NETIF_F_GSO_IPIPV6           |
>                                    NETIF_F_GSO_UDP_TUNNEL       |
>                                    NETIF_F_GSO_UDP_TUNNEL_CSUM  |
>                                    NETIF_F_GSO_PARTIAL          |
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 36a34f7191e3..180d4a889c69 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -2302,8 +2302,8 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
>
>         if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
>                                          SKB_GSO_GRE_CSUM |
> -                                        SKB_GSO_IPIP |
> -                                        SKB_GSO_SIT |
> +                                        SKB_GSO_IPIPV4 |
> +                                        SKB_GSO_IPIPV6 |
>                                          SKB_GSO_UDP_TUNNEL |
>                                          SKB_GSO_UDP_TUNNEL_CSUM)) {
>                 if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> index fd7dae46c5d8..e2630c663cfb 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> @@ -1559,8 +1559,8 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
>
>         if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
>                                          SKB_GSO_GRE_CSUM |
> -                                        SKB_GSO_IPIP |
> -                                        SKB_GSO_SIT |
> +                                        SKB_GSO_IPIPV4 |
> +                                        SKB_GSO_IPIPV6 |
>                                          SKB_GSO_UDP_TUNNEL |
>                                          SKB_GSO_UDP_TUNNEL_CSUM)) {
>                 if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index 642bb45ed906..3a72568d8175 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -2230,8 +2230,8 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
>                                    NETIF_F_TSO6                 |
>                                    NETIF_F_GSO_GRE              |
>                                    NETIF_F_GSO_GRE_CSUM         |
> -                                  NETIF_F_GSO_IPIP             |
> -                                  NETIF_F_GSO_SIT              |
> +                                  NETIF_F_GSO_IPIPV4           |
> +                                  NETIF_F_GSO_IPIPV6           |
>                                    NETIF_F_GSO_UDP_TUNNEL       |
>                                    NETIF_F_GSO_UDP_TUNNEL_CSUM  |
>                                    NETIF_F_GSO_PARTIAL          |
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 21727692bef6..1ba2213ce5d5 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2418,8 +2418,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>  #define IGB_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
>                                   NETIF_F_GSO_GRE_CSUM | \
> -                                 NETIF_F_GSO_IPIP | \
> -                                 NETIF_F_GSO_SIT | \
> +                                 NETIF_F_GSO_IPIPV4 | \
> +                                 NETIF_F_GSO_IPIPV6 | \
>                                   NETIF_F_GSO_UDP_TUNNEL | \
>                                   NETIF_F_GSO_UDP_TUNNEL_CSUM)
>
> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
> index 322a2d7828a5..de1827983096 100644
> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> @@ -2763,8 +2763,8 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>  #define IGBVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
>                                     NETIF_F_GSO_GRE_CSUM | \
> -                                   NETIF_F_GSO_IPIP | \
> -                                   NETIF_F_GSO_SIT | \
> +                                   NETIF_F_GSO_IPIPV4 | \
> +                                   NETIF_F_GSO_IPIPV6 | \
>                                     NETIF_F_GSO_UDP_TUNNEL | \
>                                     NETIF_F_GSO_UDP_TUNNEL_CSUM)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index d08fbcfb9417..9180361a909c 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -9482,8 +9482,8 @@ skip_sriov:
>
>  #define IXGBE_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
>                                     NETIF_F_GSO_GRE_CSUM | \
> -                                   NETIF_F_GSO_IPIP | \
> -                                   NETIF_F_GSO_SIT | \
> +                                   NETIF_F_GSO_IPIPV4 | \
> +                                   NETIF_F_GSO_IPIPV6 | \
>                                     NETIF_F_GSO_UDP_TUNNEL | \
>                                     NETIF_F_GSO_UDP_TUNNEL_CSUM)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 5e348b125090..622f456ec41e 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -4062,8 +4062,8 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>  #define IXGBEVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
>                                       NETIF_F_GSO_GRE_CSUM | \
> -                                     NETIF_F_GSO_IPIP | \
> -                                     NETIF_F_GSO_SIT | \
> +                                     NETIF_F_GSO_IPIPV4 | \
> +                                     NETIF_F_GSO_IPIPV6 | \
>                                       NETIF_F_GSO_UDP_TUNNEL | \
>                                       NETIF_F_GSO_UDP_TUNNEL_CSUM)
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index bc8736266749..f10248df9705 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -44,8 +44,8 @@ enum {
>         NETIF_F_FSO_BIT,                /* ... FCoE segmentation */
>         NETIF_F_GSO_GRE_BIT,            /* ... GRE with TSO */
>         NETIF_F_GSO_GRE_CSUM_BIT,       /* ... GRE with csum with TSO */
> -       NETIF_F_GSO_IPIP_BIT,           /* ... IPIP tunnel with TSO */
> -       NETIF_F_GSO_SIT_BIT,            /* ... SIT tunnel with TSO */
> +       NETIF_F_GSO_IPIPV4_BIT,         /* ... IP in IPv4 tunnel with TSO */
> +       NETIF_F_GSO_IPIPV6_BIT,         /* ... IP in IPv6 tunnel with TSO */
>         NETIF_F_GSO_UDP_TUNNEL_BIT,     /* ... UDP TUNNEL with TSO */
>         NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
>         NETIF_F_GSO_PARTIAL_BIT,        /* ... Only segment inner-most L4
> @@ -121,8 +121,8 @@ enum {
>  #define NETIF_F_RXALL          __NETIF_F(RXALL)
>  #define NETIF_F_GSO_GRE                __NETIF_F(GSO_GRE)
>  #define NETIF_F_GSO_GRE_CSUM   __NETIF_F(GSO_GRE_CSUM)
> -#define NETIF_F_GSO_IPIP       __NETIF_F(GSO_IPIP)
> -#define NETIF_F_GSO_SIT                __NETIF_F(GSO_SIT)
> +#define NETIF_F_GSO_IPIPV4     __NETIF_F(GSO_IPIPV4)
> +#define NETIF_F_GSO_IPIPV6     __NETIF_F(GSO_IPIPV6)
>  #define NETIF_F_GSO_UDP_TUNNEL __NETIF_F(GSO_UDP_TUNNEL)
>  #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
>  #define NETIF_F_TSO_MANGLEID   __NETIF_F(TSO_MANGLEID)
> @@ -200,8 +200,8 @@ enum {
>
>  #define NETIF_F_GSO_ENCAP_ALL  (NETIF_F_GSO_GRE |                      \
>                                  NETIF_F_GSO_GRE_CSUM |                 \
> -                                NETIF_F_GSO_IPIP |                     \
> -                                NETIF_F_GSO_SIT |                      \
> +                                NETIF_F_GSO_IPIPV4 |                   \
> +                                NETIF_F_GSO_IPIPV6 |                   \
>                                  NETIF_F_GSO_UDP_TUNNEL |               \
>                                  NETIF_F_GSO_UDP_TUNNEL_CSUM)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 63580e6d0df4..d9d05d6b5849 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -4005,8 +4005,8 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
>         BUILD_BUG_ON(SKB_GSO_FCOE    != (NETIF_F_FSO >> NETIF_F_GSO_SHIFT));
>         BUILD_BUG_ON(SKB_GSO_GRE     != (NETIF_F_GSO_GRE >> NETIF_F_GSO_SHIFT));
>         BUILD_BUG_ON(SKB_GSO_GRE_CSUM != (NETIF_F_GSO_GRE_CSUM >> NETIF_F_GSO_SHIFT));
> -       BUILD_BUG_ON(SKB_GSO_IPIP    != (NETIF_F_GSO_IPIP >> NETIF_F_GSO_SHIFT));
> -       BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
> +       BUILD_BUG_ON(SKB_GSO_IPIPV4  != (NETIF_F_GSO_IPIPV4 >> NETIF_F_GSO_SHIFT));
> +       BUILD_BUG_ON(SKB_GSO_IPIPV6  != (NETIF_F_GSO_IPIPV6 >> NETIF_F_GSO_SHIFT));
>         BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
>         BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
>         BUILD_BUG_ON(SKB_GSO_PARTIAL != (NETIF_F_GSO_PARTIAL >> NETIF_F_GSO_SHIFT));
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index c413c588a24f..6186a6446d1c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -471,9 +471,9 @@ enum {
>
>         SKB_GSO_GRE_CSUM = 1 << 8,
>
> -       SKB_GSO_IPIP = 1 << 9,
> +       SKB_GSO_IPIPV4 = 1 << 9,
>
> -       SKB_GSO_SIT = 1 << 10,
> +       SKB_GSO_IPIPV6 = 1 << 10,
>
>         SKB_GSO_UDP_TUNNEL = 1 << 11,
>
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index bdb4013581b1..8771dafe93ec 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -84,8 +84,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
>         [NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
>         [NETIF_F_GSO_GRE_BIT] =          "tx-gre-segmentation",
>         [NETIF_F_GSO_GRE_CSUM_BIT] =     "tx-gre-csum-segmentation",
> -       [NETIF_F_GSO_IPIP_BIT] =         "tx-ipip-segmentation",
> -       [NETIF_F_GSO_SIT_BIT] =          "tx-sit-segmentation",
> +       [NETIF_F_GSO_IPIPV4_BIT] =       "tx-ipip4-segmentation",
> +       [NETIF_F_GSO_IPIPV6_BIT] =       "tx-ipip6-segmentation",
>         [NETIF_F_GSO_UDP_TUNNEL_BIT] =   "tx-udp_tnl-segmentation",
>         [NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
>         [NETIF_F_GSO_PARTIAL_BIT] =      "tx-gso-partial",
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 7f08d4525981..c62230f1b16b 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1459,20 +1459,25 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
>
>         if (skb->encapsulation)
>                 skb_set_inner_network_header(skb, nhoff);
> +       else
> +               skb_set_network_header(skb, nhoff);

This seems like an unrelated change.

>
>         csum_replace2(&iph->check, iph->tot_len, newlen);
>         iph->tot_len = newlen;
>
>         rcu_read_lock();
> -       ops = rcu_dereference(inet_offloads[proto]);
> -       if (WARN_ON(!ops || !ops->callbacks.gro_complete))
> -               goto out_unlock;
>
>         /* Only need to add sizeof(*iph) to get to the next hdr below
>          * because any hdr with option will have been flushed in
>          * inet_gro_receive().
>          */
> -       err = ops->callbacks.gro_complete(skb, nhoff + sizeof(*iph));
> +       nhoff += sizeof(*iph);
> +
> +       ops = rcu_dereference(inet_offloads[proto]);
> +       if (WARN_ON(!ops || !ops->callbacks.gro_complete))
> +               goto out_unlock;
> +
> +       err = ops->callbacks.gro_complete(skb, nhoff);

Why this change?

>
>  out_unlock:
>         rcu_read_unlock();
> @@ -1483,7 +1488,8 @@ out_unlock:
>  static int ipip_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         skb->encapsulation = 1;
> -       skb_shinfo(skb)->gso_type |= SKB_GSO_IPIP;
> +       skb_shinfo(skb)->gso_type = (ip_hdr(skb)->version == 4) ?
> +                                   SKB_GSO_IPIPV4 : SKB_GSO_IPIPV6;

I don't think this is necessary. IPIP means IPv4 over IPv4, IPv4 over
IPv6 can have its own gro_complete

>         return inet_gro_complete(skb, nhoff);
>  }
>
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 92827483ee3d..16aa07688955 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -219,7 +219,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>         if (unlikely(skb->protocol != htons(ETH_P_IP)))
>                 goto tx_error;
>
> -       if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
> +       if (iptunnel_handle_offloads(skb, SKB_GSO_IPIPV4))
>                 goto tx_error;
>
>         skb_set_inner_ipproto(skb, IPPROTO_IPIP);
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 9ad743b2c624..b68a8a88f498 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -86,7 +86,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
>
>         if (skb->encapsulation &&
> -           skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
> +           (skb_shinfo(skb)->gso_type & (SKB_GSO_IPIPV4 | SKB_GSO_IPIPV6)))
>                 udpfrag = proto == IPPROTO_UDP && encap;
>         else
>                 udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
> @@ -274,6 +274,8 @@ static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>
>         if (skb->encapsulation)
>                 skb_set_inner_network_header(skb, nhoff);
> +       else
> +               skb_set_network_header(skb, nhoff);

Separate patch maybe?

>
>         iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
>
> @@ -294,7 +296,8 @@ out_unlock:
>  static int sit_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>         skb->encapsulation = 1;
> -       skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
> +       skb_shinfo(skb)->gso_type = (ipv6_hdr(skb)->version == 6) ?
> +                                   SKB_GSO_IPIPV6 : SKB_GSO_IPIPV4;

Can have separate gro_complete for ip6ip6 also

>         return ipv6_gro_complete(skb, nhoff);
>  }
>
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index a13d8c114ccb..3945df11efaf 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -913,7 +913,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
>                 goto tx_error;
>         }
>
> -       if (iptunnel_handle_offloads(skb, SKB_GSO_SIT)) {
> +       if (iptunnel_handle_offloads(skb, SKB_GSO_IPIPV4)) {
>                 ip_rt_put(rt);
>                 goto tx_error;
>         }
> @@ -1000,7 +1000,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>         struct ip_tunnel *tunnel = netdev_priv(dev);
>         const struct iphdr  *tiph = &tunnel->parms.iph;
>
> -       if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
> +       if (iptunnel_handle_offloads(skb, SKB_GSO_IPIPV4))
>                 goto tx_error;
>
>         skb_set_inner_ipproto(skb, IPPROTO_IPIP);
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 6d19d2eeaa60..c2c8732ed652 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -932,17 +932,9 @@ error:
>
>  static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
>  {
> -       if (encaps_af == AF_INET) {
> -               if (orig_af == AF_INET)
> -                       return SKB_GSO_IPIP;
> -
> -               return SKB_GSO_SIT;
> -       }
> -
> -       /* GSO: we need to provide proper SKB_GSO_ value for IPv6:
> -        * SKB_GSO_SIT/IPV6
> -        */
> -       return 0;
> +       if (encaps_af == AF_INET)
> +               return SKB_GSO_IPIPV4;
> +       return SKB_GSO_IPIPV6;
>  }
>
>  /*
>
