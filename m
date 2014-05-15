From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 2/8] bridge: Keep track of ports
 capable of automatic discovery.
Date: Thu, 15 May 2014 21:43:07 +0300
Message-ID: <20140515184307.GC1699@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
	<1400173016-8952-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400173016-8952-3-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2014 at 12:56:50PM -0400, Vlad Yasevich wrote:
> By default, ports on the bridge are capable of automatic
> discovery of nodes located behind the port.  This is accomplished
> via flooding of unknown traffic (BR_FLOOD) and learning the
> mac addresses from these packets (BR_LEARNING).
> If the above functionality is disabled by turning off these
> flags, the port requires static configuration in the form
> of static FDB entries to function properly.
> 
> This patch adds functionality to keep track of all ports
> capable of automatic discovery.  This will later be used
> to control promiscuity settings.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  net/bridge/br_if.c       | 24 ++++++++++++++++++++++++
>  net/bridge/br_netlink.c  |  3 +++
>  net/bridge/br_private.h  |  5 +++++
>  net/bridge/br_sysfs_if.c |  5 ++++-
>  4 files changed, 36 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 5262b86..f7ef5f2 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -85,6 +85,18 @@ void br_port_carrier_check(struct net_bridge_port *p)
>  	spin_unlock_bh(&br->lock);
>  }
>  
> +static void nbp_update_port_count(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +	u32 cnt = 0;
> +
> +	list_for_each_entry(p, &br->port_list, list) {
> +		if (br_auto_port(p))
> +			cnt++;
> +	}
> +	br->auto_cnt = cnt;
> +}
> +
>  static void release_nbp(struct kobject *kobj)
>  {
>  	struct net_bridge_port *p
> @@ -146,6 +158,8 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	list_del_rcu(&p->list);
>  
> +	nbp_update_port_count(br);
> +
>  	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>  
>  	netdev_rx_handler_unregister(dev);
> @@ -384,6 +398,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  
>  	list_add_rcu(&p->list, &br->port_list);
>  
> +	nbp_update_port_count(br);
> +
>  	netdev_update_features(br->dev);
>  
>  	if (br->dev->needed_headroom < dev->needed_headroom)
> @@ -455,3 +471,11 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>  
>  	return 0;
>  }
> +
> +void br_port_flags_change(struct net_bridge_port *p, unsigned long mask)
> +{
> +	struct net_bridge *br = p->br;
> +
> +	if (mask & BR_AUTO_MASK)
> +		nbp_update_port_count(br);
> +}
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index e8844d9..26edb51 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -328,6 +328,7 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
>  static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  {
>  	int err;
> +	unsigned long old_flags = p->flags;
>  
>  	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
>  	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
> @@ -353,6 +354,8 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  		if (err)
>  			return err;
>  	}
> +
> +	br_port_flags_change(p, old_flags ^ p->flags);
>  	return 0;
>  }
>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 06811d7..5ce3191 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -174,6 +174,7 @@ struct net_bridge_port
>  #define BR_ADMIN_COST		0x00000010
>  #define BR_LEARNING		0x00000020
>  #define BR_FLOOD		0x00000040
> +#define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
>  
>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>  	struct bridge_mcast_query	ip4_query;
> @@ -198,6 +199,8 @@ struct net_bridge_port
>  #endif
>  };
>  
> +#define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
> +
>  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
>  
>  static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
> @@ -290,6 +293,7 @@ struct net_bridge
>  	struct timer_list		topology_change_timer;
>  	struct timer_list		gc_timer;
>  	struct kobject			*ifobj;
> +	u32				auto_cnt;
>  #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>  	u8				vlan_enabled;
>  	struct net_port_vlans __rcu	*vlan_info;
> @@ -415,6 +419,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev);
>  int br_min_mtu(const struct net_bridge *br);
>  netdev_features_t br_features_recompute(struct net_bridge *br,
>  					netdev_features_t features);
> +void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
>  
>  /* br_input.c */
>  int br_handle_frame_finish(struct sk_buff *skb);
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index 112a25e..c7fbe38 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -49,7 +49,9 @@ static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
>  static int store_flag(struct net_bridge_port *p, unsigned long v,
>  		     unsigned long mask)
>  {
> -	unsigned long flags = p->flags;
> +	unsigned long flags;
> +
> +	flags = p->flags;
>  
>  	if (v)
>  		flags |= mask;
> @@ -58,6 +60,7 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
>  
>  	if (flags != p->flags) {
>  		p->flags = flags;
> +		br_port_flags_change(p, mask);
>  		br_ifinfo_notify(RTM_NEWLINK, p);
>  	}
>  	return 0;
> -- 
> 1.9.0
