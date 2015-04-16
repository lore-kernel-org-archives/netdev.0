From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Thu, 16 Apr 2015 10:12:33 -0600
Message-ID: <20150416161233.GC21809@obsidianresearch.com>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1429191274-11600-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2015 at 04:34:34PM +0300, Erez Shitrit wrote:
> Currently, iflink of the parent interface was always accessed, even 
> when interface didn't have a parent and hence we crashed there.
> 
> Handle the interface types properly: for a child interface, return
> the ifindex of the parent, for parent interface, return its ifindex.
> 
> For child devices, make sure to set the parent pointer prior to
> invoking register_netdevice(), this allows the new ndo to be called
> by the stack immediately after the child device is registered.
> 
> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
> Reported-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Reviewed-By: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>+

> changes from V0:
>  - fixed two typos in the change-log
> 
>  drivers/infiniband/ulp/ipoib/ipoib_main.c | 5 +++++
>  drivers/infiniband/ulp/ipoib/ipoib_vlan.c | 3 +--
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> index 657b89b..915ad04 100644
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -846,6 +846,11 @@ static int ipoib_get_iflink(const struct net_device *dev)
>  {
>  	struct ipoib_dev_priv *priv = netdev_priv(dev);
>  
> +	/* parent interface */
> +	if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
> +		return dev->ifindex;
> +
> +	/* child/vlan interface */
>  	return priv->parent->ifindex;
>  }
>  
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
> index 4dd1313..fca1a88 100644
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
> @@ -58,6 +58,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
>  	/* MTU will be reset when mcast join happens */
>  	priv->dev->mtu   = IPOIB_UD_MTU(priv->max_ib_mtu);
>  	priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
> +	priv->parent = ppriv->dev;
>  	set_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags);
>  
>  	result = ipoib_set_dev_features(priv, ppriv->ca);
> @@ -84,8 +85,6 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
>  		goto register_failed;
>  	}
>  
> -	priv->parent = ppriv->dev;
> -
>  	ipoib_create_debug_files(priv->dev);
>  
>  	/* RTNL childs don't need proprietary sysfs entries */
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
