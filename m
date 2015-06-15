From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port speeds/duplex
Date: Mon, 15 Jun 2015 10:35:17 -0700
Message-ID: <557F0CD5.4070705@gmail.com>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33604 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754514AbbFORgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:36:24 -0400
Received: by pdjn11 with SMTP id n11so77578280pdj.0
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 10:36:24 -0700 (PDT)
In-Reply-To: <1434129537-15252-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/15 10:18, Andrew Lunn wrote:
> By default, DSA and CPU ports are configured to the maximum speed the
> switch supports. However there can be use cases where the peer device
> port is slower. Allow a fixed-link property to be used with the DSA
> and CPU port in the device tree, and use this information to configure
> the port.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  include/net/dsa.h |  1 +
>  net/dsa/dsa.c     | 39 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 40 insertions(+)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index fbca63ba8f73..24572f99224c 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -160,6 +160,7 @@ struct dsa_switch {
>  	 * Slave mii_bus and devices for the individual ports.
>  	 */
>  	u32			dsa_port_mask;
> +	u32			cpu_port_mask;
>  	u32			phys_port_mask;
>  	u32			phys_mii_mask;
>  	struct mii_bus		*slave_mii_bus;
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 392e29a0227d..f9c8f4e7ebce 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -176,6 +176,36 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
>  #endif /* CONFIG_NET_DSA_HWMON */
>  
>  /* basic switch operations **************************************************/
> +static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
> +{
> +	struct dsa_chip_data *cd = ds->pd;
> +	struct device_node *port_dn;
> +	struct phy_device *phydev;
> +	int ret, port;
> +
> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
> +		if (!((ds->cpu_port_mask | ds->dsa_port_mask) & (1 << port)))
> +			continue;
> +
> +		port_dn = cd->port_dn[port];
> +		if (of_phy_is_fixed_link(port_dn)) {
> +			ret = of_phy_register_fixed_link(port_dn);
> +			if (ret) {
> +				netdev_err(master,
> +					   "failed to register fixed PHY\n");
> +				return ret;
> +			}
> +			phydev = of_phy_find_device(port_dn);
> +			phydev->is_pseudo_fixed_link = true;

I suppose this could be automatically set by the Generic PHY driver once
we bind it to the fixed MDIO bus implementation instead of having driver
have to do this, what do you think?
-- 
Florian
