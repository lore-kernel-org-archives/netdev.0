From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: Set valid phy interface type
Date: Tue, 17 Feb 2015 09:04:48 -0800
Message-ID: <54E374B0.5070603@gmail.com>
References: <1424150631-22396-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:38487 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbBQRFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 12:05:02 -0500
Received: by pdbfp1 with SMTP id fp1so40675372pdb.5
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 09:05:01 -0800 (PST)
In-Reply-To: <1424150631-22396-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/15 21:23, Guenter Roeck wrote:
> If the phy interface mode is not found in devicetree, or if devicetree
> is not configured, of_get_phy_mode returns -ENODEV. The current code
> sets the phy interface mode to the return value from of_get_phy_mode
> without checking if it is valid.
> 
> This invalid phy interface mode is passed as parameter to of_phy_connect
> or to phy_connect_direct. This sets the phy interface mode to the invalid
> value, which in turn causes problems for any code using phydev->interface.
> 
> Fixes: b31f65fb4383 ("net: dsa: slave: Fix autoneg for phys on switch MDIO bus")
> Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

This is 'net' material since you are fixing a bug here, thanks!

> ---
>  net/dsa/slave.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index d104ae1..f23dead 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -521,10 +521,13 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  	struct device_node *phy_dn, *port_dn;
>  	bool phy_is_fixed = false;
>  	u32 phy_flags = 0;
> -	int ret;
> +	int mode, ret;
>  
>  	port_dn = cd->port_dn[p->port];
> -	p->phy_interface = of_get_phy_mode(port_dn);
> +	mode = of_get_phy_mode(port_dn);
> +	if (mode < 0)
> +		mode = PHY_INTERFACE_MODE_NA;
> +	p->phy_interface = mode;
>  
>  	phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
>  	if (of_phy_is_fixed_link(port_dn)) {
> @@ -559,6 +562,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
>  		if (!p->phy)
>  			return -ENODEV;
>  
> +		/* Use already configured phy mode */
> +		p->phy_interface = p->phy->interface;
>  		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
>  				   p->phy_interface);
>  	} else {
> 


-- 
Florian
