From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/9] qlcnic: fix TSO race condition
Date: Sat, 13 Apr 2013 11:35:16 -0700
Message-ID: <1365878116.4459.105.camel@edumazet-glaptop>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
	 <1365874114-6759-8-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39548 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab3DMSfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 14:35:19 -0400
Received: by mail-pb0-f41.google.com with SMTP id mc17so1926491pbc.28
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 11:35:18 -0700 (PDT)
In-Reply-To: <1365874114-6759-8-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-13 at 13:28 -0400, Shahed Shaikh wrote:
> From: Sritej Velaga <sritej.velaga@qlogic.com>
> 
> When driver receives a packet with gso size > 0 and when TSO is disabled,
> it should be transmitted as a TSO packet to prevent Tx timeout and subsequent
> firmware reset.
> 
> Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
>  .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 ++
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    8 ++++++--
>  3 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index 7551b18..53c414f 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> @@ -485,6 +485,7 @@ struct qlcnic_adapter_stats {
>  	u64  tx_dma_map_error;
>  	u64  spurious_intr;
>  	u64  mac_filter_limit_overrun;
> +	u64  invalid_tso_pkt;
>  };
>  
>  /*
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> index 7b56a50..48434ee 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> @@ -53,6 +53,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
>  				QLC_OFF(stats.mac_filter_limit_overrun)},
>  	{"spurious intr", QLC_SIZEOF(stats.spurious_intr),
>  	 QLC_OFF(stats.spurious_intr)},
> +	{"invalid_tso_pkt", QLC_SIZEOF(stats.invalid_tso_pkt),
> +			QLC_OFF(stats.invalid_tso_pkt)},
>  
>  };
>  
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> index a85ca63..cb19e30 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
> @@ -362,8 +362,12 @@ set_flags:
>  		memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
>  	}
>  	opcode = TX_ETHER_PKT;
> -	if ((adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
> -	    skb_shinfo(skb)->gso_size > 0) {
> +
> +	if (skb_shinfo(skb)->gso_size > 0) {
> +		if (!(adapter->netdev->features &
> +		      (NETIF_F_TSO | NETIF_F_TSO6))) {
> +			adapter->stats.invalid_tso_pkt++;
> +		}
>  		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
>  		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
>  		first_desc->total_hdr_length = hdr_len;

This looks like not needed at all.

Take a look at all other network drivers.

Not a single one does the (netdev->features & (NETIF_F_TSO |
NETIF_F_TSO6)) check in their tx fast path.

This is done by the core networking stacks.

Just remove the check, and do not add an "invalid_tso_pkt", as there is
nothing invalid here.

If a driver advertised NETIF_F_TSO in its hw_features, then it _must_ be
prepared to send TSO packets, even if the admin plays with "ethtool -k
tso off".

RTNL is not taken in TX path, so there is always the possibility a
driver has to transmit a TSO packet right after the change.
