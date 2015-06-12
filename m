From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 3/3] net: dsa: Allow configuration of CPU & DSA port speeds/duplex
Date: Fri, 12 Jun 2015 11:03:42 -0700
Message-ID: <557B1EFE.2030700@roeck-us.net>
References: <1434129537-15252-1-git-send-email-andrew@lunn.ch> <1434129537-15252-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:42412 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbbFLSDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 14:03:45 -0400
In-Reply-To: <1434129537-15252-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 06/12/2015 10:18 AM, Andrew Lunn wrote:
> By default, DSA and CPU ports are configured to the maximum speed the
> switch supports. However there can be use cases where the peer device
> port is slower. Allow a fixed-link property to be used with the DSA
> and CPU port in the device tree, and use this information to configure
> the port.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>   include/net/dsa.h |  1 +
>   net/dsa/dsa.c     | 39 +++++++++++++++++++++++++++++++++++++++
>   2 files changed, 40 insertions(+)
>
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index fbca63ba8f73..24572f99224c 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -160,6 +160,7 @@ struct dsa_switch {
>   	 * Slave mii_bus and devices for the individual ports.
>   	 */
>   	u32			dsa_port_mask;
> +	u32			cpu_port_mask;
>   	u32			phys_port_mask;
>   	u32			phys_mii_mask;
>   	struct mii_bus		*slave_mii_bus;
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 392e29a0227d..f9c8f4e7ebce 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -176,6 +176,36 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
>   #endif /* CONFIG_NET_DSA_HWMON */
>
>   /* basic switch operations **************************************************/
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
How does cpu_port_mask interact / interfer / coexist with dst->cpu_port
and dsa_is_cpu_port() ?

Elsewhere we have
	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
so I don't entirely see why we need to add cpu_port_mask at this time.
Shouldn't that be a separate patch, maybe with a new macro / function
to check if the port is a cpu port or an external switch port ?

Thanks,
Guenter
