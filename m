From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 16:40:15 -0500
Message-ID: <20050519214015.GA19961@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 06:28:26PM +0300, Catalin(ux aka Dino) BOIE wrote:
> Hello!
> 
> The attached patch, makes the bridge to select features (almost all) only 
> if _all_ devices supports them.
> The patch was tested (create a bridge, add an interface, remove the 
> interface and always check features flags).
> 
> What do you think?
> 
> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> ---
> Catalin(ux aka Dino) BOIE
> catab at deuroconsult.ro
> http://kernel.umbrella.ro/

> --- bridge1/net/bridge/br_private.h	2005-03-02 09:37:50.000000000 +0200
> +++ linux/net/bridge/br_private.h	2005-05-19 18:00:05.000000000 +0300
> @@ -27,6 +27,10 @@
>  #define BR_PORT_BITS	10
>  #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
>  
> +#define BR_FEAT_MASK	(NETIF_F_HW_CSUM | NETIF_F_SG \
> +			| NETIF_F_FRAGLIST | NETIF_F_IP_CSUM \
> +			| NETIF_F_HIGHDMA | NETIF_F_TSO)
> +
>  typedef struct bridge_id bridge_id;
>  typedef struct mac_addr mac_addr;
>  typedef __u16 port_id;
> --- bridge1/net/bridge/br_device.c	2005-03-02 09:37:30.000000000 +0200
> +++ linux/net/bridge/br_device.c	2005-05-19 17:14:21.000000000 +0300
> @@ -107,4 +107,5 @@ void br_dev_setup(struct net_device *dev
>  	dev->tx_queue_len = 0;
>  	dev->set_mac_address = NULL;
>  	dev->priv_flags = IFF_EBRIDGE;
> +	dev->features = BR_FEAT_MASK;
>  }
> --- bridge1/net/bridge/br_if.c	2005-03-02 09:38:33.000000000 +0200
> +++ linux/net/bridge/br_if.c	2005-05-19 18:21:39.000000000 +0300
> @@ -314,6 +314,27 @@ int br_min_mtu(const struct net_bridge *
>  	return mtu;
>  }
>  
> +/*
> + * If slave device (@dev) doesn't support special features,
> + * turn them off globally.
> + */
> +static inline void br_features_change(struct net_bridge *br, struct net_device *dev)
> +{
> +	br->dev->features &= dev->features | ~BR_FEAT_MASK;

~BR_FEAT_MASK isn't necessary. Either you wanted to do an '&' just
before it, so that BR_FEAT_MASK features are the only ones that you want
or you are enabling features that aren't necessarily supported by the
adapter/driver (like LLTX and HW_VLAN stuff).

> +}
> +
> +/*
> + * Recomputes features using slave's features
> + */
> +static void br_features_recompute(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +
> +	br->dev->features |= BR_FEAT_MASK;

The OR is not needed.  Just re-initialize features to BR_FEAT_MASK and
everything will take case of itself.

> +	list_for_each_entry(p, &br->port_list, list)
> +		br_features_change(br, p->dev);
> +}
> +
>  /* called with RTNL */
>  int br_add_if(struct net_bridge *br, struct net_device *dev)
>  {
> @@ -332,9 +353,10 @@ int br_add_if(struct net_bridge *br, str
>  	if (IS_ERR(p = new_nbp(br, dev, br_initial_port_cost(dev))))
>  		return PTR_ERR(p);
>  
> +	br_features_change(br, dev);
> +
>   	if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
>  		destroy_nbp(p);
> - 
>  	else if ((err = br_sysfs_addif(p)))
>  		del_nbp(p);
>  	else {
> @@ -368,6 +390,7 @@ int br_del_if(struct net_bridge *br, str
>  
>  	spin_lock_bh(&br->lock);
>  	br_stp_recalculate_bridge_id(br);
> +	br_features_recompute(br);
>  	spin_unlock_bh(&br->lock);
>  
>  	return 0;
