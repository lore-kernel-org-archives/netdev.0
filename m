From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] net: dsa: Fix of kernel panic in case of missing
 PHY.
Date: Tue, 09 Dec 2014 10:37:19 -0800
Message-ID: <5487415F.6020802@gmail.com>
References: <54873205.30401@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrey Volkov <andrey.volkov@nexvision.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33638 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbaLIShe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 13:37:34 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so1072134pdj.13
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 10:37:34 -0800 (PST)
In-Reply-To: <54873205.30401@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/14 09:31, Andrey Volkov wrote:
> Fix of kernel panic in case of missing PHY.

Humm, I can trust you, but I would need more context on how you could
trigger a kernel panic here, the only code path that I could imagine is
problematic is the end of dsa_slave_phy_setup():

        if (!p->phy) {
                p->phy = ds->slave_mii_bus->phy_map[p->port];
                phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
                                   p->phy_interface);
        } else {
                netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
                            p->phy->addr, p->phy->drv->name);
        }

Did you observe this with a pure platform_devices/data only setup, or
was that with Device Tree?

Thanks!


> 
> Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
> ---
>  net/dsa/slave.c |   19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 528380a..6f89caa 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -512,7 +512,7 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
>  }
>  
>  /* slave device setup *******************************************************/
> -static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
> +static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  				struct net_device *slave_dev)
>  {
>  	struct dsa_switch *ds = p->parent;
> @@ -533,7 +533,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  		ret = of_phy_register_fixed_link(port_dn);
>  		if (ret) {
>  			netdev_err(slave_dev, "failed to register fixed PHY\n");
> -			return;
> +			return ret;
>  		}
>  		phy_is_fixed = true;
>  		phy_dn = port_dn;
> @@ -555,12 +555,17 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  	 */
>  	if (!p->phy) {
>  		p->phy = ds->slave_mii_bus->phy_map[p->port];
> -		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
> +		if(p->phy)
> +			phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
>  				   p->phy_interface);
> +		else
> +			return -ENODEV;
> +
>  	} else {
>  		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
>  			    p->phy->addr, p->phy->drv->name);
>  	}
> +	return 0;
>  }
>  
>  int dsa_slave_suspend(struct net_device *slave_dev)
> @@ -653,7 +658,13 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	p->old_link = -1;
>  	p->old_duplex = -1;
>  
> -	dsa_slave_phy_setup(p, slave_dev);
> +	ret = dsa_slave_phy_setup(p, slave_dev);
> +	if (ret) {
> +		netdev_err(master, "error %d registering interface %s\n",
> +			   ret, slave_dev->name);
> +		free_netdev(slave_dev);
> +		return NULL;
> +	}
>  
>  	ret = register_netdev(slave_dev);
>  	if (ret) {
> 
