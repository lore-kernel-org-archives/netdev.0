From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1 2.6.29] cxgb3 - enable lro control through ethtool
Date: Fri, 31 Oct 2008 00:55:57 -0400
Message-ID: <490A8FDD.6010705@garzik.org>
References: <20081029054032.20973.32213.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52428 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbYJaE4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:56:01 -0400
In-Reply-To: <20081029054032.20973.32213.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Implement ethtool's get_flags and set_flags methods.
> It enables ethtool to control the LRO settings.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_main.c |   69 +++++++++++++++++++++++++++++++++-------
>  1 files changed, 57 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 1ace41a..e1746ee 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -494,6 +494,36 @@ static void enable_all_napi(struct adapter *adap)
>  }
>  
>  /**
> + *	set_qset_lro - Turn a queue set's LRO capability on and off
> + *	@dev: the device the qset is attached to
> + *	@qset_idx: the queue set index
> + *	@val: the LRO switch
> + *
> + *	Sets LRO on or off for a particular queue set.
> + *	the device's features flag is updated to reflect the LRO
> + *	capability when all queues belonging to the device are
> + *	in the same state.
> + */
> +static void set_qset_lro(struct net_device *dev, int qset_idx, int val)
> +{
> +	struct port_info *pi = netdev_priv(dev);
> +	struct adapter *adapter = pi->adapter;
> +	int i, lro_on = 1;
> +
> +	adapter->params.sge.qset[qset_idx].lro = !!val;
> +	adapter->sge.qs[qset_idx].lro_enabled = !!val;
> +
> +	/* let ethtool report LRO on only if all queues are LRO enabled */
> +	for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; ++i)
> +		lro_on &= adapter->params.sge.qset[i].lro;
> +
> +	if (lro_on)
> +		dev->features |= NETIF_F_LRO;
> +	else
> +		dev->features &= ~NETIF_F_LRO;
> +}
> +
> +/**
>   *	setup_sge_qsets - configure SGE Tx/Rx/response queues
>   *	@adap: the adapter
>   *
> @@ -516,8 +546,7 @@ static int setup_sge_qsets(struct adapter *adap)
>  		pi->qs = &adap->sge.qs[pi->first_qset];
>  		for (j = pi->first_qset; j < pi->first_qset + pi->nqsets;
>  		     ++j, ++qset_idx) {
> -			if (!pi->rx_csum_offload)
> -				adap->params.sge.qset[qset_idx].lro = 0;
> +			set_qset_lro(dev, qset_idx, pi->rx_csum_offload);
>  			err = t3_sge_alloc_qset(adap, qset_idx, 1,
>  				(adap->flags & USING_MSIX) ? qset_idx + 1 :
>  							     irq_idx,
> @@ -1632,13 +1661,10 @@ static int set_rx_csum(struct net_device *dev, u32 data)
>  
>  	p->rx_csum_offload = data;
>  	if (!data) {
> -		struct adapter *adap = p->adapter;
>  		int i;
>  
> -		for (i = p->first_qset; i < p->first_qset + p->nqsets; i++) {
> -			adap->params.sge.qset[i].lro = 0;
> -			adap->sge.qs[i].lro_enabled = 0;
> -		}
> +		for (i = p->first_qset; i < p->first_qset + p->nqsets; i++)
> +			set_qset_lro(dev, i, 0);
>  	}
>  	return 0;
>  }
> @@ -1793,6 +1819,25 @@ static void get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  	memset(&wol->sopass, 0, sizeof(wol->sopass));
>  }
>  
> +static int cxgb3_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct port_info *pi = netdev_priv(dev);
> +	int i;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (!pi->rx_csum_offload)
> +			return -EINVAL;
> +
> +		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
> +			set_qset_lro(dev, i, 1);
> +
> +	} else
> +		for (i = pi->first_qset; i < pi->first_qset + pi->nqsets; i++)
> +			set_qset_lro(dev, i, 0);
> +
> +	return 0;
> +}
> +
>  static const struct ethtool_ops cxgb_ethtool_ops = {
>  	.get_settings = get_settings,
>  	.set_settings = set_settings,
> @@ -1822,6 +1867,8 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
>  	.get_regs = get_regs,
>  	.get_wol = get_wol,
>  	.set_tso = ethtool_op_set_tso,
> +	.get_flags = ethtool_op_get_flags,
> +	.set_flags = cxgb3_set_flags,
>  };
>  
>  static int in_range(int val, int lo, int hi)
> @@ -1938,11 +1985,9 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
>  				}
>  			}
>  		}
> -		if (t.lro >= 0) {
> -			struct sge_qset *qs = &adapter->sge.qs[t.qset_idx];
> -			q->lro = t.lro;
> -			qs->lro_enabled = t.lro;
> -		}
> +		if (t.lro >= 0)
> +			set_qset_lro(dev, t.qset_idx, t.lro);
> +
>  		break;
>  	}
>  	case CHELSIO_GET_QSET_PARAMS:{

applied


