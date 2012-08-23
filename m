From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 13:16:22 +0200
Message-ID: <20120823111622.GC2238@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56084 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab2HWLQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 07:16:28 -0400
Received: by wgbdr13 with SMTP id dr13so521723wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 04:16:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 02:56:51AM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Where possible, move PTP-related functions into igb_ptp.c and update the
> names of functions and variables to match the established coding style
> in the files and specify that they are PTP-specific.

Function renaming as an end in itself? Sounds like churn to me. Also,
I disagree with some of the displacements.
 
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index 6adb0f7..d1a120e 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -2280,21 +2280,8 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
>  	}
>  }
>  
> -static int igb_ethtool_begin(struct net_device *netdev)
> -{
> -	struct igb_adapter *adapter = netdev_priv(netdev);
> -	pm_runtime_get_sync(&adapter->pdev->dev);
> -	return 0;
> -}
> -
> -static void igb_ethtool_complete(struct net_device *netdev)
> -{
> -	struct igb_adapter *adapter = netdev_priv(netdev);
> -	pm_runtime_put(&adapter->pdev->dev);
> -}
> -

Why have you moved this block? How are these "PTP-related"?

>  #ifdef CONFIG_IGB_PTP
> -static int igb_ethtool_get_ts_info(struct net_device *dev,
> +static int igb_get_ts_info(struct net_device *dev,

I like the old name better.

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c

...
  
> -#ifdef CONFIG_IGB_PTP
> -/**
> - * igb_tx_hwtstamp - utility function which checks for TX time stamp
> - * @q_vector: pointer to q_vector containing needed info
> - * @buffer: pointer to igb_tx_buffer structure
> - *
> - * If we were asked to do hardware stamping and such a time stamp is
> - * available, then it must have been for this skb here because we only
> - * allow only one such packet into the queue.
> - */
> -static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
> -			    struct igb_tx_buffer *buffer_info)
> -{
> -	struct igb_adapter *adapter = q_vector->adapter;
> -	struct e1000_hw *hw = &adapter->hw;
> -	struct skb_shared_hwtstamps shhwtstamps;
> -	u64 regval;
> -
> -	/* if skb does not support hw timestamp or TX stamp not valid exit */
> -	if (likely(!(buffer_info->tx_flags & IGB_TX_FLAGS_TSTAMP)) ||
> -	    !(rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID))
> -		return;
> -
> -	regval = rd32(E1000_TXSTMPL);
> -	regval |= (u64)rd32(E1000_TXSTMPH) << 32;
> -
> -	igb_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
> -	skb_tstamp_tx(buffer_info->skb, &shhwtstamps);
> -}
> -#endif /* CONFIG_IGB_PTP */
> -

Here you have taken a static local function and made it into a global
function. This can have performance impacts.

>  /**
>   * igb_clean_tx_irq - Reclaim resources after transmit completes
>   * @q_vector: pointer to q_vector containing needed info
> @@ -5827,7 +5796,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
>  
>  #ifdef CONFIG_IGB_PTP
>  		/* retrieve hardware timestamp */
> -		igb_tx_hwtstamp(q_vector, tx_buffer);
> +		igb_ptp_tx_hwtstamp(q_vector, tx_buffer);

This name stinks, too. You know that you can have time stamping all by
itself, right? It is logically separate from the ptp clock stuff.

This patch doesn't really improve the driver at all, IMHO.

Thanks,
Richard
