From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 03/11] ixgb: Fix hard coded numbers
Date: Sat, 22 Apr 2006 11:17:25 +0200
Message-ID: <20060422091725.GC26666@electric-eye.fr.zoreil.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com> <20060422010036.24255.25895.stgit@jk-desktop.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:45973 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1750711AbWDVRYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2006 13:24:54 -0400
Received: from fr.zoreil.com (electric-eye.fr.zoreil.com [213.41.134.224])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3M9Jmil006563
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 09:19:49 GMT
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Disposition: inline
In-Reply-To: <20060422010036.24255.25895.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
[...]
> diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
> index e8d83de..978be30 100644
> --- a/drivers/net/ixgb/ixgb_ethtool.c
> +++ b/drivers/net/ixgb/ixgb_ethtool.c
[...]
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index 6f8fd6f..f468d5d 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -1227,11 +1227,11 @@ ixgb_tso(struct ixgb_adapter *adapter, s
>  		if(++i == adapter->tx_ring.count) i = 0;
>  		adapter->tx_ring.next_to_use = i;
>  
> -		return 1;
> +		return TRUE;
>  	}
>  #endif
>  
> -	return 0;
> +	return FALSE;
>  }

Grmbl... TRUE/FALSE

More importantly, it seems bogus. See below:

drivers/net/ixgb/ixgb_main.c::ixgb_xmit_frame
[...]
        tso = ixgb_tso(adapter, skb);
        if (tso < 0) {
               ^^^
                dev_kfree_skb_any(skb);
                return N

[...]
> @@ -1413,7 +1413,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
>  	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
>  		netif_stop_queue(netdev);
>  		spin_unlock_irqrestore(&adapter->tx_lock, flags);
> -		return 1;
> +		return NETDEV_TX_BUSY;
>  	}

It is considered a bug. You can check for this situation on the current
skb but the driver should check if there is enough room for the *next*
packet before it leaves ixgb_xmit_frame().

-- 
Ueimor
