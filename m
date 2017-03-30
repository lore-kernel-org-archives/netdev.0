From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/9] net: dsa: mv88e6xxx: rework in-chip bridging
Date: Thu, 30 Mar 2017 15:57:30 +0200
Message-ID: <20170330135730.GE17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40561 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754300AbdC3N5d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 09:57:33 -0400
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-6-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 04:30:16PM -0400, Vivien Didelot wrote:
> All ports -- internal and external, for chips featuring a PVT -- have a
> mask restricting to which internal ports a frame is allowed to egress.
> 
> Now that DSA exposes the number of ports and their bridge devices, it is
> possible to extract the code generating the VLAN map and make it generic
> so that it can be shared later with the cross-chip bridging code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

> +static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
> +{
> +	struct dsa_switch *ds = NULL;
> +	struct net_device *br;
> +	u16 pvlan;
> +	int i;
> +
> +	if (dev < DSA_MAX_SWITCHES)
> +		ds = chip->ds->dst->ds[dev];
> +
> +	/* Prevent frames from unknown switch or port */
> +	if (!ds || port >= ds->num_ports)
> +		return 0;
> +
> +	/* Frames from DSA links and CPU ports can egress any local port */
> +	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
> +		return mv88e6xxx_port_mask(chip);
> +
> +	br = ds->ports[port].bridge_dev;
> +	pvlan = 0;

You could do this where you define the variable, but having it here,
close to where it is used also has its merits.

> +
> +	/* Frames from user ports can egress any local DSA links and CPU ports,
> +	 * as well as any local member of their bridge group.
> +	 */
> +	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
> +		if (dsa_is_cpu_port(chip->ds, i) ||
> +		    dsa_is_dsa_port(chip->ds, i) ||
> +		    (br && chip->ds->ports[i].bridge_dev == br))
> +			pvlan |= BIT(i);
> +
> +	return pvlan;

  Andrew
