From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA and CPU ports
Date: Fri, 27 May 2016 10:33:49 -0400
Message-ID: <87lh2v604y.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-10-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54176 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbcE0Odw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 10:33:52 -0400
In-Reply-To: <1464312050-23023-10-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> -static void dsa_switch_destroy(struct dsa_switch *ds)
> +void dsa_cpu_dsa_destroy(struct device_node *port_dn)
>  {
> -	struct device_node *port_dn;
>  	struct phy_device *phydev;
> +
> +	if (of_phy_is_fixed_link(port_dn)) {
> +		phydev = of_phy_find_device(port_dn);
> +		if (phydev) {
> +			phy_device_free(phydev);
> +			fixed_phy_unregister(phydev);
> +		}
> +	}
> +}
> +
> +static void dsa_switch_destroy(struct dsa_switch *ds)
> +{
>  	int port;
>  
>  #ifdef CONFIG_NET_DSA_HWMON
> @@ -445,17 +467,11 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  		dsa_slave_destroy(ds->ports[port].netdev);
>  	}
>  
> -	/* Remove any fixed link PHYs */
> +	/* Disable configuration of the CPU and DSA ports */
>  	for (port = 0; port < DSA_MAX_PORTS; port++) {
> -		port_dn = ds->ports[port].dn;
> -		if (of_phy_is_fixed_link(port_dn)) {
> -			phydev = of_phy_find_device(port_dn);
> -			if (phydev) {
> -				phy_device_free(phydev);
> -				of_node_put(port_dn);

Why does dsa_cpu_dsa_destroy drop that of_node_put call?

> -				fixed_phy_unregister(phydev);
> -			}
> -		}
> +		if ((dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
> +			continue;

Why do we skip DSA and CPU ports here? The previous code didn't.

> +		dsa_cpu_dsa_destroy(ds->ports[port].dn);

Thanks,

        Vivien
