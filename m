From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add multi cpu port support
Date: Tue, 30 May 2017 15:56:27 -0700
Message-ID: <8d6996ef-72c0-546f-6bbe-5a6ea6e83c5f@gmail.com>
References: <20170530104419.6052-1-john@phrozen.org>
 <20170530104419.6052-2-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, jiri@resnulli.us,
        idosch@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530104419.6052-2-john@phrozen.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+Jiri, Ido,

On 05/30/2017 03:44 AM, John Crispin wrote:
> Some boards have two CPU interfaces connected to the switch, e.g. WiFi
> access points, with 1 port labeled WAN, 4 ports labeled lan1-lan4, and
> two port connected to the SoC.
> 
> This patch extends DSA to allows both CPU ports to be used. The "cpu"
> node in the DSA tree can now have a phandle to the host interface it
> connects to. Each user port can have a phandle to a cpu port which
> should be used for traffic between the port and the CPU. Thus simple
> load sharing over the two CPU ports can be achieved.

Part of the problem here is that:

- we have the initial state where we only allow the user-ports to be
talking to the CPU port, now we have more than one CPU port, so which
one do we choose? You have proposed a Device Tree change for that, and
while this works, we are going beyond pure HW description and we are
already describing a desired policy, not ideal

- past the initial setup, if we start creating bridge devices and so on,
we have no way to tell: group Ports 0-3 together and send traffic to CPU
port 0, then let Port 5 alone and send traffic to CPU port 1, that's a
DSA-only problem though, because we still have the CPU port(s) as
independent network interfaces.

Right now, we cannot enslave master network devices into the bridge when
a tagging protocol is used (see
8db0a2ee2c6302a1dcbcdb93cb731dfc6c0cdb5e) so we cannot quite associate a
bridge device with its underlying CPU port.

I suppose we could revise that commit and let the enslaving happen in
order for the switch drivers to "learn" which CPU/master network device
is being added to the bridge, and just not register the RX handler for
that interface.

Now, that would still force the user to configure two bridges in order
to properly steer traffic towards the requested ports but it would allow
us to be very flexible (which is probably desired here) in how ports are
grouped together.

Does that make sense?

> 
> Signed-off-by: John Crispin <john@phrozen.org>
> ---
>  include/net/dsa.h  | 21 ++++++++++++++++++++-
>  net/dsa/dsa2.c     | 35 +++++++++++++++++++++++++++++++----
>  net/dsa/dsa_priv.h |  1 +
>  net/dsa/slave.c    | 26 ++++++++++++++++----------
>  4 files changed, 68 insertions(+), 15 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index c0e567c0c824..d2994bd2c507 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -186,6 +186,8 @@ struct dsa_port {
>  	u8			stp_state;
>  	struct net_device	*bridge_dev;
>  	struct devlink_port	devlink_port;
> +	struct net_device	*ethernet;
> +	int			upstream;
>  };
>  
>  struct dsa_switch {
> @@ -251,7 +253,7 @@ struct dsa_switch {
>  
>  static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
>  {
> -	return ds->dst->cpu_dp == &ds->ports[p];
> +	return !!(ds->cpu_port_mask & (1 << p));
>  }
>  
>  static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
> @@ -269,6 +271,11 @@ static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
>  	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
>  }
>  
> +static inline bool dsa_is_upstream_port(struct dsa_switch *ds, int p)
> +{
> +	return dsa_is_cpu_port(ds, p) || dsa_is_dsa_port(ds, p);
> +}
> +
>  static inline u8 dsa_upstream_port(struct dsa_switch *ds)
>  {
>  	struct dsa_switch_tree *dst = ds->dst;
> @@ -285,6 +292,18 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
>  		return ds->rtable[dst->cpu_dp->ds->index];
>  }
>  
> +static inline u8 dsa_port_upstream_port(struct dsa_switch *ds, int port)
> +{
> +	/*
> +	 * If this port has a specific upstream cpu port, use it,
> +	 * otherwise use the switch default.
> +	 */
> +	if (ds->ports[port].upstream)
> +		return ds->ports[port].upstream;
> +	else
> +		return dsa_upstream_port(ds);
> +}
> +
>  struct dsa_switch_ops {
>  	/*
>  	 * Legacy probing.
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 4301f52e4f5a..8b13aa735c40 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -253,8 +253,6 @@ static int dsa_cpu_port_apply(struct dsa_port *port, u32 index,
>  		return err;
>  	}
>  
> -	ds->cpu_port_mask |= BIT(index);
> -
>  	memset(&ds->ports[index].devlink_port, 0,
>  	       sizeof(ds->ports[index].devlink_port));
>  	err = devlink_port_register(ds->devlink, &ds->ports[index].devlink_port,
> @@ -269,6 +267,10 @@ static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
>  	dsa_cpu_dsa_destroy(port);
>  	ds->cpu_port_mask &= ~BIT(index);
>  
> +	if (ds->ports[index].ethernet) {
> +		dev_put(ds->ports[index].ethernet);
> +		ds->ports[index].ethernet = NULL;
> +	}
>  }
>  
>  static int dsa_user_port_apply(struct dsa_port *port, u32 index,
> @@ -530,6 +532,29 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
>  
>  	dst->rcv = dst->tag_ops->rcv;
>  
> +	dev_hold(ethernet_dev);
> +	ds->ports[index].ethernet = ethernet_dev;
> +	ds->cpu_port_mask |= BIT(index);
> +
> +	return 0;
> +}
> +
> +static int dsa_user_parse(struct device_node *port, u32 index,
> +			  struct dsa_switch *ds)
> +{
> +	struct device_node *cpu_port;
> +	const unsigned int *cpu_port_reg;
> +	int cpu_port_index;
> +
> +	cpu_port = of_parse_phandle(port, "cpu", 0);
> +	if (cpu_port) {
> +		cpu_port_reg = of_get_property(cpu_port, "reg", NULL);
> +		if (!cpu_port_reg)
> +			return -EINVAL;
> +		cpu_port_index = be32_to_cpup(cpu_port_reg);
> +		ds->ports[index].upstream = cpu_port_index;
> +	}
> +
>  	return 0;
>  }
>  
> @@ -544,11 +569,13 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
>  		if (!dsa_port_is_valid(port))
>  			continue;
>  
> -		if (dsa_port_is_cpu(port)) {
> +		if (dsa_port_is_cpu(port))
>  			err = dsa_cpu_parse(port, index, dst, ds);
> +		else if (dsa_is_normal_port(port))
> +			err = dsa_user_parse(port->dn, index,  ds);
> +
>  			if (err)
>  				return err;
> -		}
>  	}
>  
>  	pr_info("DSA: switch %d %d parsed\n", dst->tree, ds->index);
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index c1d4180651af..91fdc16befb2 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -78,6 +78,7 @@ struct dsa_slave_priv {
>  
>  	/* DSA port data, such as switch, port index, etc. */
>  	struct dsa_port		*dp;
> +	struct net_device	*master;
>  
>  	/*
>  	 * The phylib phy_device pointer for the PHY connected
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 887e26695519..45f17f35ced1 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -66,7 +66,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
>  
> -	return p->dp->ds->dst->master_netdev->ifindex;
> +	return p->master->ifindex;
>  }
>  
>  static inline bool dsa_port_is_bridged(struct dsa_port *dp)
> @@ -77,7 +77,7 @@ static inline bool dsa_port_is_bridged(struct dsa_port *dp)
>  static int dsa_slave_open(struct net_device *dev)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct net_device *master = p->dp->ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  	struct dsa_switch *ds = p->dp->ds;
>  	u8 stp_state = dsa_port_is_bridged(p->dp) ?
>  			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
> @@ -132,7 +132,7 @@ static int dsa_slave_open(struct net_device *dev)
>  static int dsa_slave_close(struct net_device *dev)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct net_device *master = p->dp->ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  	struct dsa_switch *ds = p->dp->ds;
>  
>  	if (p->phy)
> @@ -159,7 +159,7 @@ static int dsa_slave_close(struct net_device *dev)
>  static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct net_device *master = p->dp->ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  
>  	if (change & IFF_ALLMULTI)
>  		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
> @@ -170,7 +170,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
>  static void dsa_slave_set_rx_mode(struct net_device *dev)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct net_device *master = p->dp->ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  
>  	dev_mc_sync(master, dev);
>  	dev_uc_sync(master, dev);
> @@ -179,7 +179,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
>  static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct net_device *master = p->dp->ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  	struct sockaddr *addr = a;
>  	int err;
>  
> @@ -376,7 +376,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Queue the SKB for transmission on the parent interface, but
>  	 * do not modify its EtherType
>  	 */
> -	nskb->dev = p->dp->ds->dst->master_netdev;
> +	nskb->dev = p->master;
>  	dev_queue_xmit(nskb);
>  
>  	return NETDEV_TX_OK;
> @@ -685,7 +685,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
>  	struct dsa_switch *ds = p->dp->ds;
> -	struct net_device *master = ds->dst->master_netdev;
> +	struct net_device *master = p->master;
>  	struct netpoll *netpoll;
>  	int err = 0;
>  
> @@ -1140,11 +1140,16 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	struct net_device *master;
>  	struct net_device *slave_dev;
>  	struct dsa_slave_priv *p;
> +	int port_cpu = ds->ports[port].upstream;
>  	int ret;
>  
> -	master = ds->dst->master_netdev;
> -	if (ds->master_netdev)
> +	if (port_cpu && ds->ports[port_cpu].ethernet)
> +		master = ds->ports[port_cpu].ethernet;
> +	else if (ds->master_netdev)
>  		master = ds->master_netdev;
> +	else
> +		master = ds->dst->master_netdev;
> +	master->dsa_ptr = (void *)ds->dst;
>  
>  	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
>  				 NET_NAME_UNKNOWN, ether_setup);
> @@ -1173,6 +1178,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	p->dp = &ds->ports[port];
>  	INIT_LIST_HEAD(&p->mall_tc_list);
>  	p->xmit = dst->tag_ops->xmit;
> +	p->master = master;
>  
>  	p->old_pause = -1;
>  	p->old_link = -1;
> 


-- 
Florian
