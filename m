From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next 02/14] net: define gso types for IPx over IPv4
 and IPv6
Date: Mon, 16 May 2016 10:04:36 -0700
Message-ID: <CAKgT0UdvVwURGfLfDmSdSW3fSnm96U0JJYu9fPd=CUjU=BXnjg@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34742 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbcEPREh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:04:37 -0400
Received: by mail-io0-f196.google.com with SMTP id d62so16166946iof.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 10:04:37 -0700 (PDT)
In-Reply-To: <1463355755-3481375-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrote:
> This patch defines two new GSO definitions SKB_GSO_IPXIP4 and
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
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 ++---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_main.c       |  3 +--
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  3 +--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  3 +--
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  3 +--
>  drivers/net/ethernet/intel/igb/igb_main.c         |  3 +--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  3 +--
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
>  include/linux/netdev_features.h                   | 12 ++++++------
>  include/linux/netdevice.h                         |  4 ++--
>  include/linux/skbuff.h                            |  4 ++--
>  net/core/ethtool.c                                |  4 ++--
>  net/ipv4/af_inet.c                                |  2 +-
>  net/ipv4/ipip.c                                   |  2 +-
>  net/ipv6/ip6_offload.c                            |  4 ++--
>  net/ipv6/sit.c                                    |  4 ++--
>  net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++----------
>  18 files changed, 36 insertions(+), 47 deletions(-)
>

<...>

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 2172769..808d48f 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2418,8 +2418,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>  #define IGB_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
>                                   NETIF_F_GSO_GRE_CSUM | \
> -                                 NETIF_F_GSO_IPIP | \
> -                                 NETIF_F_GSO_SIT | \
> +                                 SKB_GSO_IPXIP4 | \
>                                   NETIF_F_GSO_UDP_TUNNEL | \
>                                   NETIF_F_GSO_UDP_TUNNEL_CSUM)
>

Sorry but this is yet another bug.  It should be NETIF_F_GSO_IPXIP4,
not SKB_GSO_IPXIP4.

So we are up to at least 3 items that need to be addressed in this patch.

1.  igbvf/netdev.c also has a reference to NETIF_F_GSO_IPIP/NETIF_F_GSO_SIT.
2.  bnxt needs a '|' instead of a ';' to avoid statement with no effect.
3.  Use of SKB_GSO_IPXIP4 in igb/igb_main.c which should have been
NETIF_F_GSO_IPXIP4.

I think that is everything for this patch.  I'll be certain once I can
do some performance testing to determine if the hardware offloads for
the Intel parts are working correctly.

Thanks.

- Alex
