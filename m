From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging operations
Date: Wed, 18 Feb 2015 18:48:19 -0800
Message-ID: <54E54EF3.9020802@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35048 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbbBSCsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 21:48:32 -0500
Received: by pdbfl12 with SMTP id fl12so5642943pdb.2
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 18:48:32 -0800 (PST)
In-Reply-To: <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/15 11:26, Florian Fainelli wrote:
> Update the Broadcom Starfighter 2 switch driver to implement the
> join/leave/stp_update callbacks required for basic hardware bridging
> support.
> 
> There is not much to be done at the driver level but translating the
> STP state from Linux to their HW values.
> 
> Joining a bridge means that the joining port and the other port members
> need to be in the same VLAN membership as the CPU, while leaving the
> bridge puts the port back into a separate VLAN membership with only the
> CPU.

I found a couple additional issues while testing:

- manipulating UP/DOWN state of interfaces that are part of a bridge
would not restore their bridge membership

- removing an interface from a bridge and bringing it back up would
leave it in blocked state

> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/dsa/bcm_sf2.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 93 insertions(+)
> 
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index 4daffb284931..006c86a4df54 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -23,6 +23,7 @@
>  #include <linux/of_address.h>
>  #include <net/dsa.h>
>  #include <linux/ethtool.h>
> +#include <linux/if_bridge.h>
>  
>  #include "bcm_sf2.h"
>  #include "bcm_sf2_regs.h"
> @@ -400,6 +401,95 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
>  	return 0;
>  }
>  
> +static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
> +			      u32 br_port_mask)
> +{
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +	unsigned int i;
> +	u32 reg, p_ctl;
> +
> +	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
> +
> +	for (i = 0; i < priv->hw_params.num_ports; i++) {
> +		if (!((1 << i) & br_port_mask))
> +			continue;
> +
> +		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
> +		reg |= 1 << port;
> +		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
> +
> +		p_ctl |= 1 << i;
> +	}
> +
> +	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
> +
> +	return 0;
> +}
> +
> +static int bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port,
> +			       u32 br_port_mask)
> +{
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +	unsigned int i;
> +	u32 reg, p_ctl;
> +
> +	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
> +
> +	for (i = 0; i < priv->hw_params.num_ports; i++) {
> +		/* Don't touch the remaining ports */
> +		if (!((1 << i) & br_port_mask))
> +			continue;
> +
> +		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
> +		reg &= ~(1 << port);
> +		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
> +
> +		/* Prevent self removal to preserve isolation */
> +		if (port != i)
> +			p_ctl &= ~(1 << i);
> +	}
> +
> +	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
> +
> +	return 0;
> +}
> +
> +static int bcm_sf2_sw_br_stp_update(struct dsa_switch *ds, int port,
> +				    u8 state)
> +{
> +	struct bcm_sf2_priv *priv = ds_to_priv(ds);
> +	u32 reg;
> +	u8 hw_state;
> +
> +	switch (state) {
> +	case BR_STATE_DISABLED:
> +		hw_state = G_MISTP_DIS_STATE;
> +		break;
> +	case BR_STATE_LISTENING:
> +		hw_state = G_MISTP_LISTEN_STATE;
> +		break;
> +	case BR_STATE_LEARNING:
> +		hw_state = G_MISTP_LEARN_STATE;
> +		break;
> +	case BR_STATE_FORWARDING:
> +		hw_state = G_MISTP_FWD_STATE;
> +		break;
> +	case BR_STATE_BLOCKING:
> +		hw_state = G_MISTP_BLOCK_STATE;
> +		break;
> +	default:
> +		pr_err("%s: invalid STP state: %d\n", __func__, state);
> +		return -EINVAL;
> +	}
> +
> +	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
> +	reg &= ~(G_MISTP_STATE_MASK << G_MISTP_STATE_SHIFT);
> +	reg |= hw_state;
> +	core_writel(priv, reg, CORE_G_PCTL_PORT(port));
> +
> +	return 0;
> +}
> +
>  static irqreturn_t bcm_sf2_switch_0_isr(int irq, void *dev_id)
>  {
>  	struct bcm_sf2_priv *priv = dev_id;
> @@ -916,6 +1006,9 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
>  	.port_disable		= bcm_sf2_port_disable,
>  	.get_eee		= bcm_sf2_sw_get_eee,
>  	.set_eee		= bcm_sf2_sw_set_eee,
> +	.port_join_bridge	= bcm_sf2_sw_br_join,
> +	.port_leave_bridge	= bcm_sf2_sw_br_leave,
> +	.port_stp_update	= bcm_sf2_sw_br_stp_update,
>  };
>  
>  static int __init bcm_sf2_init(void)
> 


-- 
Florian
