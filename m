From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: adjust fixed_phy_register() return
 value
Date: Wed, 01 Oct 2014 14:56:05 -0700
Message-ID: <542C7875.8090102@gmail.com>
References: <20141001214509.2BF4F10070D@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57700 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbaJAV4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 17:56:07 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so919650pde.0
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 14:56:07 -0700 (PDT)
In-Reply-To: <20141001214509.2BF4F10070D@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 02:45 PM, Petri Gynther wrote:
> Adjust fixed_phy_register() to return struct phy_device *, so that
> it becomes easy to use fixed PHYs without device tree support:
> 
>   phydev = fixed_phy_register(PHY_POLL, &fixed_phy_status, NULL);
>   fixed_phy_set_link_update(phydev, fixed_phy_link_update);
>   phy_connect_direct(netdev, phydev, handler_fn, phy_interface);
> 
> This change is a prerequisite for modifying bcmgenet driver to work
> without a device tree on Broadcom's MIPS-based 7xxx platforms.

Without a Device Tree enabled platform, you still have the
fixed_phy_add() API to register a fixed PHY at a known location (the
second parameter), did we someone broke that with Thomas' patches?

You could for instance register a fixed PHY at address 1 for the
GENET/MoCA instance to find it.

Other than that, I am not opposed to the change, since it allows us to
eventually get rid of fixed_phy_add() in the future.

Thanks!

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/phy/fixed.c   | 16 ++++++++--------
>  drivers/of/of_mdio.c      |  7 +++++--
>  include/linux/phy_fixed.h | 14 +++++++-------
>  3 files changed, 20 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 5b19fbb..47872caa 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -233,9 +233,9 @@ EXPORT_SYMBOL_GPL(fixed_phy_del);
>  static int phy_fixed_addr;
>  static DEFINE_SPINLOCK(phy_fixed_addr_lock);
>  
> -int fixed_phy_register(unsigned int irq,
> -		       struct fixed_phy_status *status,
> -		       struct device_node *np)
> +struct phy_device *fixed_phy_register(unsigned int irq,
> +				      struct fixed_phy_status *status,
> +				      struct device_node *np)
>  {
>  	struct fixed_mdio_bus *fmb = &platform_fmb;
>  	struct phy_device *phy;
> @@ -246,19 +246,19 @@ int fixed_phy_register(unsigned int irq,
>  	spin_lock(&phy_fixed_addr_lock);
>  	if (phy_fixed_addr == PHY_MAX_ADDR) {
>  		spin_unlock(&phy_fixed_addr_lock);
> -		return -ENOSPC;
> +		return ERR_PTR(-ENOSPC);
>  	}
>  	phy_addr = phy_fixed_addr++;
>  	spin_unlock(&phy_fixed_addr_lock);
>  
>  	ret = fixed_phy_add(PHY_POLL, phy_addr, status);
>  	if (ret < 0)
> -		return ret;
> +		return ERR_PTR(ret);
>  
>  	phy = get_phy_device(fmb->mii_bus, phy_addr, false);
>  	if (!phy || IS_ERR(phy)) {
>  		fixed_phy_del(phy_addr);
> -		return -EINVAL;
> +		return ERR_PTR(-EINVAL);
>  	}
>  
>  	of_node_get(np);
> @@ -269,10 +269,10 @@ int fixed_phy_register(unsigned int irq,
>  		phy_device_free(phy);
>  		of_node_put(np);
>  		fixed_phy_del(phy_addr);
> -		return ret;
> +		return ERR_PTR(ret);
>  	}
>  
> -	return 0;
> +	return phy;
>  }
>  
>  static int __init fixed_mdio_bus_init(void)
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index a85d800..907baa9 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -286,6 +286,7 @@ int of_phy_register_fixed_link(struct device_node *np)
>  	struct device_node *fixed_link_node;
>  	const __be32 *fixed_link_prop;
>  	int len;
> +	struct phy_device *phy;
>  
>  	/* New binding */
>  	fixed_link_node = of_get_child_by_name(np, "fixed-link");
> @@ -299,7 +300,8 @@ int of_phy_register_fixed_link(struct device_node *np)
>  		status.asym_pause = of_property_read_bool(fixed_link_node,
>  							  "asym-pause");
>  		of_node_put(fixed_link_node);
> -		return fixed_phy_register(PHY_POLL, &status, np);
> +		phy = fixed_phy_register(PHY_POLL, &status, np);
> +		return (!phy || IS_ERR(phy));
>  	}
>  
>  	/* Old binding */
> @@ -310,7 +312,8 @@ int of_phy_register_fixed_link(struct device_node *np)
>  		status.speed = be32_to_cpu(fixed_link_prop[2]);
>  		status.pause = be32_to_cpu(fixed_link_prop[3]);
>  		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
> -		return fixed_phy_register(PHY_POLL, &status, np);
> +		phy = fixed_phy_register(PHY_POLL, &status, np);
> +		return (!phy || IS_ERR(phy));
>  	}
>  
>  	return -ENODEV;
> diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
> index 9411386..f2ca1b4 100644
> --- a/include/linux/phy_fixed.h
> +++ b/include/linux/phy_fixed.h
> @@ -14,9 +14,9 @@ struct device_node;
>  #ifdef CONFIG_FIXED_PHY
>  extern int fixed_phy_add(unsigned int irq, int phy_id,
>  			 struct fixed_phy_status *status);
> -extern int fixed_phy_register(unsigned int irq,
> -			      struct fixed_phy_status *status,
> -			      struct device_node *np);
> +extern struct phy_device *fixed_phy_register(unsigned int irq,
> +					     struct fixed_phy_status *status,
> +					     struct device_node *np);
>  extern void fixed_phy_del(int phy_addr);
>  extern int fixed_phy_set_link_update(struct phy_device *phydev,
>  			int (*link_update)(struct net_device *,
> @@ -27,11 +27,11 @@ static inline int fixed_phy_add(unsigned int irq, int phy_id,
>  {
>  	return -ENODEV;
>  }
> -static inline int fixed_phy_register(unsigned int irq,
> -				     struct fixed_phy_status *status,
> -				     struct device_node *np)
> +static inline struct phy_device *fixed_phy_register(unsigned int irq,
> +						struct fixed_phy_status *status,
> +						struct device_node *np)
>  {
> -	return -ENODEV;
> +	return ERR_PTR(-ENODEV);
>  }
>  static inline int fixed_phy_del(int phy_addr)
>  {
> 
