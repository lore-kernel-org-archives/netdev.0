From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 02/11] net: define gso types for IPx over IPv4
 and IPv6
Date: Fri, 6 May 2016 15:48:19 -0700
Message-ID: <572D1F33.9040206@gmail.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
 <1462572726-566137-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34485 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759201AbcEFWs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 18:48:27 -0400
Received: by mail-pa0-f52.google.com with SMTP id r5so53021654pag.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 15:48:26 -0700 (PDT)
In-Reply-To: <1462572726-566137-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2016 03:11 PM, Tom Herbert wrote:
> This patch defines two new GDO definitions SKB_GSO_IPXIP4 and
> SKB_GSO_IPXIP6 along with corresponding NETIF_F_GSO_IPXIP4 and
> NETIF_F_GSO_IPXIP6. These are used to described IP in IP
> tunnel and what the outer protocol is. The inner protocol
> can be deduced from other GSO types (e.g. SKB_GSO_TCPV4 and
> SKB_GSO_TCPV6). The GSO types of SKB_GSO_IPIP and SKB_GSO_SIT
> are removed (these are both instances of SKB_GSO_IPXIP4).
> SKB_GSO_IPXIP6 will be used when support for GSO with IP
> encapsulation over IPv6 is added.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 ++---
>   drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 ++--
>   drivers/net/ethernet/intel/i40e/i40e_main.c       |  3 +--
>   drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  3 +--
>   drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  3 +--
>   drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  3 +--
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  3 +--
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
>   include/linux/netdev_features.h                   | 12 ++++++------
>   include/linux/netdevice.h                         |  4 ++--
>   include/linux/skbuff.h                            |  4 ++--
>   net/core/ethtool.c                                |  4 ++--
>   net/ipv4/af_inet.c                                |  2 +-
>   net/ipv4/ipip.c                                   |  2 +-
>   net/ipv6/ip6_offload.c                            |  4 ++--
>   net/ipv6/sit.c                                    |  4 ++--
>   net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++----------
>   17 files changed, 35 insertions(+), 45 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index d465bd7..0a5b770 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -13259,12 +13259,11 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
>   		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
>   	if (!chip_is_e1x) {
>   		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
> -				    NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
> +				    NETIF_F_GSO_IPXIP4;
>   		dev->hw_enc_features =
>   			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
>   			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> -			NETIF_F_GSO_IPIP |
> -			NETIF_F_GSO_SIT |
> +			NETIF_F_GSO_IPXIP4 |
>   			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
>   	}
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index fd85b6d..e449228 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -6218,7 +6218,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>   	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
>   			   NETIF_F_TSO | NETIF_F_TSO6 |
>   			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
> -			   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +			   NETIF_F_GSO_IPXIP4 |
>   			   NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
>   			   NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
>   			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
> @@ -6228,7 +6228,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>   			NETIF_F_TSO | NETIF_F_TSO6 |
>   			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
>   			NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
> -			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +			NETIF_F_GSO_IPXIP4;
>   			NETIF_F_GSO_PARTIAL;
>   	dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM |
>   				    NETIF_F_GSO_GRE_CSUM;

You should try building the bnxt driver at least if you are making 
changes to it.  This bit is broken.  It should be an '|' and not a ';' here.

The other bits seem to be correct.  I'll try testing this over the next 
few hours to see if I can find any other issues.

- Alex
