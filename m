From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v2 09/14] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Fri, 25 Aug 2017 23:46:16 +0100
Message-ID: <20170825224616.GE20805@n2100.armlinux.org.uk>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-10-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:40220 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756358AbdHYWqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 18:46:32 -0400
Content-Disposition: inline
In-Reply-To: <20170825144821.31129-10-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 04:48:16PM +0200, Antoine Tenart wrote:
> This patch adds logic to reconfigure the comphy/gop when the link status
> change at runtime. This is very useful on boards such as the mcbin which
> have SFP and Ethernet ports connected to the same MAC port: depending on
> what the user connects the driver will automatically reconfigure the
> link mode.

This commit commentry needs updating - as I've already pointed out in
the previous round, the need to reconfigure things has *nothing* to do
with there being SFP and "Ethernet" ports present.  Hence, your commit
message is entirely misleading.

> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 49a6789a4142..04e0c8ab7b51 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -5740,6 +5740,7 @@ static void mvpp2_link_event(struct net_device *dev)
>  {
>  	struct mvpp2_port *port = netdev_priv(dev);
>  	struct phy_device *phydev = dev->phydev;
> +	bool link_reconfigured = false;
>  
>  	if (!netif_running(dev))
>  		return;
> @@ -5750,9 +5751,27 @@ static void mvpp2_link_event(struct net_device *dev)
>  			port->duplex = phydev->duplex;
>  			port->speed  = phydev->speed;
>  		}
> +
> +		if (port->phy_interface != phydev->interface && port->comphy) {
> +	                /* disable current port for reconfiguration */
> +	                mvpp2_interrupts_disable(port);
> +	                netif_carrier_off(port->dev);
> +	                mvpp2_port_disable(port);
> +			phy_power_off(port->comphy);
> +
> +	                /* comphy reconfiguration */
> +	                port->phy_interface = phydev->interface;
> +	                mvpp22_comphy_init(port);
> +
> +	                /* gop/mac reconfiguration */
> +	                mvpp22_gop_init(port);
> +	                mvpp2_port_mii_set(port);
> +
> +	                link_reconfigured = true;
> +		}
>  	}
>  
> -	if (phydev->link != port->link) {
> +	if (phydev->link != port->link || link_reconfigured) {
>  		port->link = phydev->link;
>  
>  		if (phydev->link) {
> -- 
> 2.13.5
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
