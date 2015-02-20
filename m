From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Fri, 20 Feb 2015 16:26:44 +0100
Message-ID: <20150220152644.GD13797@lunn.ch>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
 <1424429473-4601-3-git-send-email-jonasj76@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46712 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754442AbbBTP3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2015 10:29:38 -0500
Content-Disposition: inline
In-Reply-To: <1424429473-4601-3-git-send-email-jonasj76@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 11:51:13AM +0100, Jonas Johansson wrote:
> From: Jonas Johansson <jonas.johansson@westermo.se>
> 
> This patch will use the DSA hardware bonding support hooks to setup trunking
> for the Marvell 88E6095 device. The implementation only handles trunking in
> a single device.
> 
> Hooks:
>  .bond_add_group: Add port to a bond group
>  .bond_del_group: Remove port from a bond group
>  .bond_attach: Attach/activate port in bond group
>  .bond_detach: Detach/inactivate port in bond group
> 
> Procedure to add/remome port from bond group:
>  Setup trunk learning (Port Association Vector)
>  Setup loop prevention (VLAN Table)
>  Setup load balancing (Trunk Mask Load Balance Table)
> 
> Procedure to attach/detach port:
>  Change load balancing (Trunk Mask Load Balance Table)
> 
> Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
> ---
>  drivers/net/dsa/mv88e6131.c | 254 ++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  14 +++
>  2 files changed, 268 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index 2540ef0..3ba7a0c 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -382,6 +382,256 @@ mv88e6131_get_ethtool_stats(struct dsa_switch *ds,
>  				    mv88e6131_hw_stats, port, data);
>  }
>  
> +/* Trunking */
> +static int mv88e6131_bond_set_trunk_learning(struct dsa_switch *ds,
> +					     int *ports, size_t num)
> +{
> +	u16 port_vec = 0;
> +	int ret;
> +	int i;
> +
> +	num = num < MAX_PORTS ? num : MAX_PORTS;
> +
> +	for (i = 0; i < num; i++)
> +		port_vec |= 1 << ports[i];
> +
> +	for (i = 0; i < num; i++) {
> +		ret = mv88e6xxx_reg_read(ds, REG_PORT(ports[i]), REG_PORT_PAV);
> +		if (ret < 0)
> +			continue;
> +		ret = (ret & 0xf800) | (port_vec & 0x7ff);
> +		mv88e6xxx_reg_write(ds, REG_PORT(ports[i]), REG_PORT_PAV, ret);
> +	}
> +
> +	return 0;
> +}

The mv886060 seems to have the PAV register. So i guess most of the
Marvell switches support this. Is there anything specific to the 6131
here? Could this be moved into mv88x6xxx so other switch drivers can
use it?

> +
> +static int mv88e6131_bond_set_loop_prevention(struct dsa_switch *ds,
> +					      int *ports, size_t num)
> +{
> +	u16 port_vec = 0;
> +	int ret;
> +	int i;
> +
> +	num = num < MAX_PORTS ? num : MAX_PORTS;
> +
> +	for (i = 0; i < num; i++)
> +		port_vec |= 1 << ports[i];
> +
> +	for (i = 0; i < num; i++) {
> +		ret = mv88e6xxx_reg_read(ds, REG_PORT(ports[i]), REG_PORT_VLAN_MAP);
> +		if (ret < 0)
> +			continue;
> +		ret &= ~port_vec & 0x7ff;
> +		mv88e6xxx_reg_write(ds, REG_PORT(ports[i]), REG_PORT_VLAN_MAP, ret);
> +	}
> +
> +	return 0;
> +}

Same question again, anything specific to the 6131 here?

> +static int mv88e6131_wait_trunk_mask(struct dsa_switch *ds)
> +{
> +	const int max_retries = 10;
> +	int retries = 0;
> +	int ret;
> +
> +	/* Wait for update Trunk Mask data */
> +	while (1) {
> +		ret = REG_READ(REG_GLOBAL2, REG_TRUNK_MASK);
> +		if (!(ret & 0x8000))
> +			return ret;
> +		if (retries > max_retries) {
> +			pr_warn("mv88e6131: Timeout waiting for "
> +				"Trunk Mask Table Register Update\n");
> +			return -EBUSY;
> +		}
> +		retries++;
> +		usleep_range(20, 50);
> +	};

This looks a lot like the wait functions what Guenter Roeck added to
6352 and i just moved to mv88e6xxx.c. Please use the generic
infrastructure in the shared code.

Please could you look at all your functions and see what is specific
to the 6131 and what is generic. Place the generic code into mv88e6xxx
please so we can all use it.

       Thanks
	Andrew
