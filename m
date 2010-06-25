From: Jon Mason <jon.mason@exar.com>
Subject: Re: [v4 Patch 1/2] s2io: add dynamic LRO disable support
Date: Thu, 24 Jun 2010 23:33:43 -0500
Message-ID: <20100625043343.GB2739@exar.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:38017 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab0FYEdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:33:07 -0400
Received: by pxi8 with SMTP id 8so523571pxi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 21:33:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 22, 2010 at 01:50:07AM -0700, Amerigo Wang wrote:
> 
> This patch adds dynamic LRO diable support for s2io net driver.
> 
> (I don't have s2io card, so only did compiling test. Anyone who wants
> to test this is more than welcome.)

Unfortunately the patch did not quite work, mostly due to NETIF_F_LRO
needing to be added at probe time to the device features.  I was able
to modify the patch to get it working, and will respond seperately
with the working patch.

Thanks,
Jon

> 
> This is based on Neil's initial work, and heavily modified
> based on Ramkrishna's suggestions.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
> Acked-by: Neil Horman <nhorman@redhat.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
> 
> ---
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 668327c..2e6e3b3 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -795,7 +795,6 @@ static int init_shared_mem(struct s2io_nic *nic)
>  		ring->rx_curr_put_info.ring_len = rx_cfg->num_rxd - 1;
>  		ring->nic = nic;
>  		ring->ring_no = i;
> -		ring->lro = lro_enable;
>  
>  		blk_cnt = rx_cfg->num_rxd / (rxd_count[nic->rxd_mode] + 1);
>  		/*  Allocating all the Rx blocks */
> @@ -6684,6 +6683,41 @@ static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
>  
>  	return 0;
>  }
> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct s2io_nic *sp = netdev_priv(dev);
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & ~ETH_FLAG_LRO)
> +		return -EOPNOTSUPP;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (lro_enable) {
> +			if (!(dev->features & NETIF_F_LRO)) {
> +				dev->features |= NETIF_F_LRO;
> +				changed = 1;
> +			}
> +		} else
> +			rc = -EOPNOTSUPP;
> +	} else if (dev->features & NETIF_F_LRO) {
> +		dev->features &= ~NETIF_F_LRO;
> +		changed = 1;
> +	}
> +
> +	if (changed && netif_running(dev)) {
> +		s2io_stop_all_tx_queue(sp);
> +		s2io_card_down(sp);
> +		sp->lro = dev->features & NETIF_F_LRO;
> +		rc = s2io_card_up(sp);
> +		if (rc)
> +			s2io_reset(sp);
> +		else
> +			s2io_start_all_tx_queue(sp);
> +	}
> +
> +	return rc;
> +}
>  
>  static const struct ethtool_ops netdev_ethtool_ops = {
>  	.get_settings = s2io_ethtool_gset,
> @@ -6701,6 +6735,8 @@ static const struct ethtool_ops netdev_ethtool_ops = {
>  	.get_rx_csum = s2io_ethtool_get_rx_csum,
>  	.set_rx_csum = s2io_ethtool_set_rx_csum,
>  	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
> +	.set_flags = s2io_ethtool_set_flags,
> +	.get_flags = ethtool_op_get_flags,
>  	.set_sg = ethtool_op_set_sg,
>  	.get_tso = s2io_ethtool_op_get_tso,
>  	.set_tso = s2io_ethtool_op_set_tso,
> @@ -7229,6 +7265,7 @@ static int s2io_card_up(struct s2io_nic *sp)
>  		struct ring_info *ring = &mac_control->rings[i];
>  
>  		ring->mtu = dev->mtu;
> +		ring->lro = sp->lro;
>  		ret = fill_rx_buffers(sp, ring, 1);
>  		if (ret) {
>  			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
