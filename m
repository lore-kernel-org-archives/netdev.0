From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [Patch 1/2] s2io: add dynamic LRO disable support
Date: Thu, 3 Jun 2010 15:38:11 +0200
Message-ID: <20100603153811.7b14a1a8@leela>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, herbert.xu@redhat.com,
	nhorman@redhat.com, sgruszka@redhat.com, davem@davemloft.net,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab0FCNiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 09:38:18 -0400
In-Reply-To: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding Ram Vepa to CC]

On Wed, 2 Jun 2010 23:38:59 -0400 Amerigo Wang wrote:
> 
> This patch adds dynamic LRO diable support for s2io net driver.
> 
> I don't have s2io card, so only did compiling test. Anyone who wants
> to test this is more than welcome.
> 
> This is based on Neil's initial work.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
> Acked-by: Neil Horman <nhorman@redhat.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> 
> 
> ---
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 668327c..9db5df7 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -6684,6 +6684,35 @@ static int s2io_ethtool_op_set_tso(struct
> net_device *dev, u32 data) 
>  	return 0;
>  }
> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct s2io_nic *sp = netdev_priv(dev);
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (lro_enable) {
> +			if (!(dev->features & NETIF_F_LRO)) {
> +				dev->features |= NETIF_F_LRO;
> +				changed = 1;
> +			}
> +		} else
> +			rc = -EINVAL;
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
> +		s2io_start_all_tx_queue(sp);
> +	}
> +
> +	return rc;
> +}
>  
>  static const struct ethtool_ops netdev_ethtool_ops = {
>  	.get_settings = s2io_ethtool_gset,
> @@ -6701,6 +6730,8 @@ static const struct ethtool_ops
> netdev_ethtool_ops = { .get_rx_csum = s2io_ethtool_get_rx_csum,
>  	.set_rx_csum = s2io_ethtool_set_rx_csum,
>  	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
> +	.set_flags = s2io_ethtool_set_flags,
> +	.get_flags = ethtool_op_get_flags,
>  	.set_sg = ethtool_op_set_sg,
>  	.get_tso = s2io_ethtool_op_get_tso,
>  	.set_tso = s2io_ethtool_op_set_tso,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
