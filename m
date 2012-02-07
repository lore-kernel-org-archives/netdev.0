From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3 net-next] bnx2: Add support for ethtool
 --show-channels|--set-channels
Date: Tue, 7 Feb 2012 20:19:14 +0000
Message-ID: <1328645954.3549.17.camel@bwh-desktop>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36114 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756458Ab2BGUTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:19:21 -0500
In-Reply-To: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-02-05 at 17:24 -0800, Michael Chan wrote:
> Allow the user to override the default number of RSS/TSS rings.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c |   99 ++++++++++++++++++++++++++++++---
>  drivers/net/ethernet/broadcom/bnx2.h |    3 +
>  2 files changed, 93 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 0a4c540..2ab31da 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -6246,7 +6246,16 @@ static int
>  bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
>  {
>  	int cpus = num_online_cpus();
> -	int msix_vecs = min(cpus + 1, RX_MAX_RINGS);
> +	int msix_vecs;
> +
> +	if (!bp->num_req_rx_rings)
> +		msix_vecs = max(cpus + 1, bp->num_req_tx_rings);
> +	else if (!bp->num_req_tx_rings)
> +		msix_vecs = max(cpus, bp->num_req_rx_rings);
> +	else
> +		msix_vecs = max(bp->num_req_rx_rings, bp->num_req_tx_rings);
> +
> +	msix_vecs = min(msix_vecs, RX_MAX_RINGS);

If I read this correctly, IRQs may be shared between RX and TX queues
i.e. there may be 'combined channels'.

[...]
> +static void bnx2_get_channels(struct net_device *dev,
> +			      struct ethtool_channels *channels)
> +{
> +	struct bnx2 *bp = netdev_priv(dev);
> +	u32 max_rx_rings = 1;
> +	u32 max_tx_rings = 1;
> +
> +	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !disable_msi) {
> +		max_rx_rings = RX_MAX_RINGS;
> +		max_tx_rings = TX_MAX_RINGS;
> +	}
> +
> +	channels->max_rx = max_rx_rings;
> +	channels->max_tx = max_tx_rings;
> +	channels->max_other = 0;
> +	channels->max_combined = 0;
> +	channels->rx_count = bp->num_rx_rings;
> +	channels->tx_count = bp->num_tx_rings;
> +	channels->other_count = 0;
> +	channels->combined_count = 0;
> +}
[...]

But here you report that all channels are RX-only or TX-only.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
