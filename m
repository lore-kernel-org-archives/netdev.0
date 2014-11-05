From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: slave: Fix autoneg for phys on switch MDIO
 bus
Date: Wed, 05 Nov 2014 12:53:35 -0800
Message-ID: <545A8E4F.9040009@gmail.com>
References: <1415213248-29037-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:58357 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaKEUyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:54:09 -0500
Received: by mail-pa0-f44.google.com with SMTP id bj1so1516462pad.31
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:54:09 -0800 (PST)
In-Reply-To: <1415213248-29037-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 10:47 AM, Andrew Lunn wrote:
> When the ports phys are connected to the switches internal MDIO bus,
> we need to connect the phy to the slave netdev, otherwise
> auto-negotiation etc, does not work.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> 
> Hi Florian
> 
> Is this the right fix?
> 
> What i found is that ports on mv88E6171 we coming up as 10/half.  If i
> forced a renegotiation with ethtool -r lan0, the phy would then goto
> 1000/full.
> 
> The code for phys on internal switch MDIO buses never connect the phy
> to the device, only phys listed in DT get connected via
> of_phy_connect(). By connecting the phy, the state machine is active
> and does an autoneg when the slave interface is opened.

This looks fine to me, I think we might want to revisit/nuke the code at
the end of dsa_slave_create since it:

- is racy: netif_carrier_off() is called before register_netdev()
- is double racy: we should be bound to a PHY before calling
register_netdev() otherwise there could be MDIO accesses done to that
PHY without an actual PHY being registered

> 
> net/dsa/slave.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 6d1817449c36..ab03e00ffe8f 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -489,11 +489,14 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  	/* We could not connect to a designated PHY, so use the switch internal
>  	 * MDIO bus instead
>  	 */
> -	if (!p->phy)
> +	if (!p->phy) {
>  		p->phy = ds->slave_mii_bus->phy_map[p->port];
> -	else
> +		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
> +				   p->phy_interface);
> +	} else {
>  		pr_info("attached PHY at address %d [%s]\n",
>  			p->phy->addr, p->phy->drv->name);
> +	}
>  }
>  
>  int dsa_slave_suspend(struct net_device *slave_dev)
> 
