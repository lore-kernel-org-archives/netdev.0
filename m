From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 03/20] net: dsa: pass dsa_port down to drivers bridge ops
Date: Thu, 28 Apr 2016 01:12:58 +0200
Message-ID: <20160427231258.GI29024@lunn.ch>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1461796217-18893-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461796217-18893-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 06:30:00PM -0400, Vivien Didelot wrote:
> Now that DSA as proper structure for DSA ports, pass it down to the
> port_bridge_join and port_bridge_leave driver functions.

I should look at the later patches, but this looks like a step
backwards.

If your ports array is a member of ds, you have no need for this patch
at all.

What advantage does this change bring?

      Andrew

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/bcm_sf2.c   | 28 ++++++++++++++--------------
>  drivers/net/dsa/mv88e6xxx.c | 10 +++++-----
>  drivers/net/dsa/mv88e6xxx.h |  4 ++--
>  include/net/dsa.h           |  4 ++--
>  net/dsa/slave.c             |  4 ++--
>  5 files changed, 25 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index f394ea9..2d7b297 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -491,15 +491,15 @@ static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
>  	return 0;
>  }
>  
> -static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
> +static int bcm_sf2_sw_br_join(struct dsa_switch *ds, struct dsa_port *dp,
>  			      struct net_device *bridge)
>  {
>  	struct bcm_sf2_priv *priv = ds_to_priv(ds);
>  	unsigned int i;
>  	u32 reg, p_ctl;
>  
> -	priv->port_sts[port].bridge_dev = bridge;
> -	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
> +	priv->port_sts[dp->port].bridge_dev = bridge;
> +	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
>  
>  	for (i = 0; i < priv->hw_params.num_ports; i++) {
>  		if (priv->port_sts[i].bridge_dev != bridge)
> @@ -509,7 +509,7 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
>  		 * membership and update the remote port bitmask
>  		 */
>  		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
> -		reg |= 1 << port;
> +		reg |= 1 << dp->port;
>  		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
>  		priv->port_sts[i].vlan_ctl_mask = reg;
>  
> @@ -519,20 +519,20 @@ static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
>  	/* Configure the local port VLAN control membership to include
>  	 * remote ports and update the local port bitmask
>  	 */
> -	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
> -	priv->port_sts[port].vlan_ctl_mask = p_ctl;
> +	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(dp->port));
> +	priv->port_sts[dp->port].vlan_ctl_mask = p_ctl;
>  
>  	return 0;
>  }
>  
> -static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port,
> +static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, struct dsa_port *dp,
>  				struct net_device *bridge)
>  {
>  	struct bcm_sf2_priv *priv = ds_to_priv(ds);
>  	unsigned int i;
>  	u32 reg, p_ctl;
>  
> -	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(port));
> +	p_ctl = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(dp->port));
>  
>  	for (i = 0; i < priv->hw_params.num_ports; i++) {
>  		/* Don't touch the remaining ports */
> @@ -540,18 +540,18 @@ static void bcm_sf2_sw_br_leave(struct dsa_switch *ds, int port,
>  			continue;
>  
>  		reg = core_readl(priv, CORE_PORT_VLAN_CTL_PORT(i));
> -		reg &= ~(1 << port);
> +		reg &= ~(1 << dp->port);
>  		core_writel(priv, reg, CORE_PORT_VLAN_CTL_PORT(i));
> -		priv->port_sts[port].vlan_ctl_mask = reg;
> +		priv->port_sts[dp->port].vlan_ctl_mask = reg;
>  
>  		/* Prevent self removal to preserve isolation */
> -		if (port != i)
> +		if (dp->port != i)
>  			p_ctl &= ~(1 << i);
>  	}
>  
> -	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(port));
> -	priv->port_sts[port].vlan_ctl_mask = p_ctl;
> -	priv->port_sts[port].bridge_dev = NULL;
> +	core_writel(priv, p_ctl, CORE_PORT_VLAN_CTL_PORT(dp->port));
> +	priv->port_sts[dp->port].vlan_ctl_mask = p_ctl;
> +	priv->port_sts[dp->port].bridge_dev = NULL;
>  }
>  
>  static void bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 86f8f2f..3f78c73 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2203,7 +2203,7 @@ unlock:
>  	return err;
>  }
>  
> -int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
> +int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
>  			       struct net_device *bridge)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -2212,7 +2212,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
>  	mutex_lock(&ps->smi_mutex);
>  
>  	/* Assign the bridge and remap each port's VLANTable */
> -	ps->ports[port].bridge_dev = bridge;
> +	ps->ports[dp->port].bridge_dev = bridge;
>  
>  	for (i = 0; i < ps->info->num_ports; ++i) {
>  		if (ps->ports[i].bridge_dev == bridge) {
> @@ -2227,7 +2227,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
>  	return err;
>  }
>  
> -void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
> +void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
>  				 struct net_device *bridge)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> @@ -2236,10 +2236,10 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
>  	mutex_lock(&ps->smi_mutex);
>  
>  	/* Unassign the bridge and remap each port's VLANTable */
> -	ps->ports[port].bridge_dev = NULL;
> +	ps->ports[dp->port].bridge_dev = NULL;
>  
>  	for (i = 0; i < ps->info->num_ports; ++i)
> -		if (i == port || ps->ports[i].bridge_dev == bridge)
> +		if (i == dp->port || ps->ports[i].bridge_dev == bridge)
>  			if (_mv88e6xxx_port_based_vlan_map(ds, i))
>  				netdev_warn(ds->ports[i], "failed to remap\n");
>  
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 2eb9a82..55b8eac 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -490,9 +490,9 @@ int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
>  int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e);
>  int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
>  		      struct phy_device *phydev, struct ethtool_eee *e);
> -int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
> +int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, struct dsa_port *dp,
>  			       struct net_device *bridge);
> -void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
> +void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, struct dsa_port *dp,
>  				 struct net_device *bridge);
>  void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state);
>  int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index ed33500..fb626ae 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -303,9 +303,9 @@ struct dsa_switch_driver {
>  	/*
>  	 * Bridge integration
>  	 */
> -	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
> +	int	(*port_bridge_join)(struct dsa_switch *ds, struct dsa_port *dp,
>  				    struct net_device *bridge);
> -	void	(*port_bridge_leave)(struct dsa_switch *ds, int port,
> +	void	(*port_bridge_leave)(struct dsa_switch *ds, struct dsa_port *dp,
>  				     struct net_device *bridge);
>  	void	(*port_stp_state_set)(struct dsa_switch *ds, int port,
>  				      u8 state);
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index f2ec13d..9a8ea9a 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -441,7 +441,7 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
>  	p->bridge_dev = br;
>  
>  	if (ds->drv->port_bridge_join)
> -		ret = ds->drv->port_bridge_join(ds, p->dp->port, br);
> +		ret = ds->drv->port_bridge_join(ds, p->dp, br);
>  
>  	if (ret && ret != -EOPNOTSUPP) {
>  		p->bridge_dev = NULL;
> @@ -460,7 +460,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
>  	p->bridge_dev = NULL;
>  
>  	if (ds->drv->port_bridge_leave)
> -		ds->drv->port_bridge_leave(ds, p->dp->port, br);
> +		ds->drv->port_bridge_leave(ds, p->dp, br);
>  
>  	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
>  	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
> -- 
> 2.8.0
> 
