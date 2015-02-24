From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: integrate with SWITCHDEV for
 HW bridging
Date: Tue, 24 Feb 2015 12:43:36 -0800
Message-ID: <20150224204336.GA18025@roeck-us.net>
References: <1424808511-18222-1-git-send-email-f.fainelli@gmail.com>
 <1424808511-18222-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:41266 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbbBXUnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 15:43:40 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YQMKR-0017GD-Gs
	for netdev@vger.kernel.org; Tue, 24 Feb 2015 20:43:39 +0000
Content-Disposition: inline
In-Reply-To: <1424808511-18222-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Tue, Feb 24, 2015 at 12:08:30PM -0800, Florian Fainelli wrote:
> In order to support bridging offloads in DSA switch drivers, select
> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
> NDOs that we are required to implement.
> 
> To facilitate the integratation at the DSA driver level, we implement 3
> types of operations:
> 
> - port_join_bridge
> - port_leave_bridge
> - port_stp_update
> 
> DSA will resolve which switch ports that are currently bridge port
> members as some Switch hardware/drivers need to know about that to limit
> the register programming to just the relevant registers (especially for
> slow MDIO buses).
> 
> We also take care of setting the correct STP state when slave network
> devices are brought up/down while being bridge members.
> 
> Finally, when a port is leaving the bridge, we make sure we set in
> BR_STATE_FORWARDING state, otherwise the bridge layer would leave it
> disabled as a result of having left the bridge.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
[ ... ]

>  
> +/* Return a bitmask of all ports being currently bridged within a given bridge
> + * device. Note that on leave, the mask will still return the bitmask of ports
> + * currently bridged, prior to port removal, and this is exactly what we want.
> + */
> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
> +				  struct net_device *bridge)
> +{
> +	struct dsa_slave_priv *p;
> +	unsigned int port;
> +	u32 mask = 0;
> +
> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
> +		if (!((1 << port) & ds->phys_port_mask))
> +			continue;
> +
> +		p = netdev_priv(ds->ports[port]);
> +

ds->ports[port] can still be NULL here since the function can be called
before all ports are initialized (which is what I had actually seen).

Thanks,
Guenter
