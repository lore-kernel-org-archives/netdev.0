From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6 1/3] ethtool: Change
 ethtool_op_set_flags to validate flags
Date: Fri, 2 Jul 2010 09:55:14 -0700
Message-ID: <20100702095514.7fb324c8.randy.dunlap@oracle.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>, linux-net-drivers@solarflare.com,
	Dimitris Michailidis <dm@chelsio.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Amerigo Wang <amwang@redhat.com>, Jeff,
	e1000-devel <e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Garzik <jgarzik@redhat.com>, Vasanthy Kolluri <vkolluri@cisco.com>,
	Brice Goglin <brice@myri.com>, Andrew Gallatin <gallatin@myri.com>,
	Scott Feldman <scofeldm@cisco.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Roopa Prabhu <roprabhu@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2010 13:44:32 +0100 Ben Hutchings wrote:

> ethtool_op_set_flags() does not check for unsupported flags, and has
> no way of doing so.  This means it is not suitable for use as a
> default implementation of ethtool_ops::set_flags.
> 
> Add a 'supported' parameter specifying the flags that the driver and
> hardware support, validate the requested flags against this, and
> change all current callers to pass this parameter.
> 
> Change some other trivial implementations of ethtool_ops::set_flags to
> call ethtool_op_set_flags().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Acked-by: Jeff Garzik <jgarzik@redhat.com>
> ---
>  drivers/net/cxgb4/cxgb4_main.c    |    9 +--------
>  drivers/net/enic/enic_main.c      |    1 -
>  drivers/net/ixgbe/ixgbe_ethtool.c |    5 ++++-
>  drivers/net/mv643xx_eth.c         |    7 ++++++-
>  drivers/net/myri10ge/myri10ge.c   |   10 +++++++---
>  drivers/net/niu.c                 |    9 +--------
>  drivers/net/sfc/ethtool.c         |    5 +----
>  drivers/net/sky2.c                |   16 ++++++----------
>  include/linux/ethtool.h           |    2 +-
>  net/core/ethtool.c                |   28 +++++-----------------------
>  10 files changed, 32 insertions(+), 60 deletions(-)
> 

> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 2c8af09..084ddb3 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -457,7 +457,7 @@ int ethtool_op_set_tso(struct net_device *dev, u32 data);
>  u32 ethtool_op_get_ufo(struct net_device *dev);
>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
>  u32 ethtool_op_get_flags(struct net_device *dev);
> -int ethtool_op_set_flags(struct net_device *dev, u32 data);
> +int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);

That one-line change is missing from linux-next-20100702, causing:

drivers/infiniband/ulp/ipoib/ipoib_ethtool.c:157: warning: initialization from incompatible pointer type


but the change (below) to net/core/ethtool.c is merged.
I don't quite see how this happened...


>  void ethtool_ntuple_flush(struct net_device *dev);
>  
>  /**
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index a0f4964..5d42fae 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -144,31 +144,13 @@ u32 ethtool_op_get_flags(struct net_device *dev)
>  }
>  EXPORT_SYMBOL(ethtool_op_get_flags);
>  
> -int ethtool_op_set_flags(struct net_device *dev, u32 data)
> +int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
>  {
> -	const struct ethtool_ops *ops = dev->ethtool_ops;
> -	unsigned long features = dev->features;
> -
> -	if (data & ETH_FLAG_LRO)
> -		features |= NETIF_F_LRO;
> -	else
> -		features &= ~NETIF_F_LRO;
> -
> -	if (data & ETH_FLAG_NTUPLE) {
> -		if (!ops->set_rx_ntuple)
> -			return -EOPNOTSUPP;
> -		features |= NETIF_F_NTUPLE;
> -	} else {
> -		/* safe to clear regardless */
> -		features &= ~NETIF_F_NTUPLE;
> -	}
> -
> -	if (data & ETH_FLAG_RXHASH)
> -		features |= NETIF_F_RXHASH;
> -	else
> -		features &= ~NETIF_F_RXHASH;
> +	if (data & ~supported)
> +		return -EINVAL;
>  
> -	dev->features = features;
> +	dev->features = ((dev->features & ~flags_dup_features) |
> +			 (data & flags_dup_features));
>  	return 0;
>  }
>  EXPORT_SYMBOL(ethtool_op_set_flags);
> -- 

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
