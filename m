From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 17:02:27 -0400
Message-ID: <46BCD263.6050807@garzik.org>
References: <20070810202426.GA25050@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757088AbXHJVCw@vger.kernel.org>
In-Reply-To: <20070810202426.GA25050@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4a616d7..559a4dc 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -341,6 +341,7 @@ struct net_device
>  #define NETIF_F_GSO		2048	/* Enable software GSO. */
>  #define NETIF_F_LLTX		4096	/* LockLess TX */
>  #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
> +#define NETIF_F_LRO		32768	/* large receive offload */
>  
>  	/* Segmentation offload features */
>  #define NETIF_F_GSO_SHIFT	16
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 2ab0a60..6e8563e 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -109,6 +109,32 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
>  	return 0;
>  }
>  
> +/* the following list of flags are the same as their associated
> + * NETIF_F_xxx values in include/linux/netdevice.h
> + */
> +static const u32 flags_dup_features =
> +	ETH_FLAG_LRO;
> +
> +u32 ethtool_op_get_flags(struct net_device *dev)
> +{
> +	/* in the future, this function will probably contain additional
> +	 * handling for flags which are not so easily handled
> +	 * by a simple masking operation
> +	 */
> +	
> +	return dev->features & flags_dup_features;
> +}
> +
> +int ethtool_op_set_flags(struct net_device *dev, u32 data)
> +{
> +	if (data & ETH_FLAG_LRO)
> +		dev->features |= NETIF_F_LRO;
> +	else
> +		dev->features &= ~NETIF_F_LRO;
> +

And, a side discussion:

This patch copies Auke in adding NETIF_F_LRO.  Is that just for 
temporary merging, or does the net core really not touch it at all?

Because, logically, if NETIF_F_LRO exists nowhere else but this patch, 
we should not add it to dev->features.  LRO knowledge can be contained 
entirely within the driver, if the net core never tests NETIF_F_LRO.

I haven't reviewed the other NETIF_F_XXX flags, but, that logic can be 
applied to any other NETIF_F_XXX flag:  if the net stack isn't using it, 
it's a piece of information specific to that driver.

	Jeff
