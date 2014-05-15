From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 6/8] bridge: Automatically manage
 port promiscuous mode.
Date: Thu, 15 May 2014 21:47:46 +0300
Message-ID: <20140515184746.GF1699@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
	<1400173016-8952-7-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400173016-8952-7-git-send-email-vyasevic@redhat.com>
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

On Thu, May 15, 2014 at 12:56:54PM -0400, Vlad Yasevich wrote:
> There exist configurations where the administrator or another management
> entity has the foreknowledge of all the mac addresses of end systems
> that are being bridged together.
> 
> In these environments, the administrator can statically configure known
> addresses in the bridge FDB and disable flooding and learning on ports.
> This makes it possible to turn off promiscuous mode on the interfaces
> connected to the bridge.
> 
> Here is why disabling flooding and learning allows us to control
> promiscuity:
>  Consider port X.  All traffic coming into this port from outside the
> bridge (ingress) will be either forwarded through other ports of the
> bridge (egress) or dropped.  Forwarding (egress) is defined by FDB
> entries and by flooding in the event that no FDB entry exists.
> In the event that flooding is disabled, only FDB entries define
> the egress.  Once learning is disabled, only static FDB entries
> provided by a management entity define the egress.  If we provide
> information from these static FDBs to the ingress port X, then we'll
> be able to accept all traffic that can be successfully forwarded and
> drop all the other traffic sooner without spending CPU cycles to
> process it.
>  Another way to define the above is as following equations:
>     ingress = egress + drop
>  expanding egress
>     ingress = static FDB + learned FDB + flooding + drop
>  disabling flooding and learning we a left with
>     ingress = static FDB + drop
> 
> By adding addresses from the static FDB entries to the MAC address
> filter of an ingress port X, we fully define what the bridge can
> process without dropping and can thus turn off promiscuous mode,
> thus dropping packets sooner.
> 
> There have been suggestions that we may want to allow learning
> and update the filters with learned addresses as well.  This
> would require mac-level authentication similar to 802.1x to
> prevent attacks against the hw filters as they are limited
> resource.
> 
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  net/bridge/br_if.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 86 insertions(+), 7 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 3fefff9..e3bc5a6 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -85,6 +85,70 @@ void br_port_carrier_check(struct net_bridge_port *p)
>  	spin_unlock_bh(&br->lock);
>  }
>  
> +static void br_port_set_promisc(struct net_bridge_port *p)
> +{
> +	int err = 0;
> +
> +	if (br_promisc_port(p))
> +		return;
> +
> +	err = dev_set_promiscuity(p->dev, 1);
> +	if (err)
> +		return;
> +
> +	br_fdb_unsync_static(p->br, p);
> +	p->flags |= BR_PROMISC;
> +}
> +
> +static void br_port_clear_promisc(struct net_bridge_port *p)
> +{
> +	int err;
> +
> +	/* Check if the port is already non-promisc or if it doesn't
> +	 * support UNICAST filtering.  Without unicast filtering support
> +	 * we'll end up re-enabling promisc mode anyway, so just check for
> +	 * it here.
> +	 */
> +	if (!br_promisc_port(p) || !(p->dev->priv_flags & IFF_UNICAST_FLT))
> +		return;
> +
> +	/* Since we'll be clearing the promisc mode, program the port
> +	 * first so that we don't have interruption in traffic.
> +	 */
> +	err = br_fdb_sync_static(p->br, p);
> +	if (err)
> +		return;
> +
> +	dev_set_promiscuity(p->dev, -1);
> +	p->flags &= ~BR_PROMISC;
> +}
> +
> +/* When a port is added or removed or when certain port flags
> + * change, this function is called to automatically mange

s/mange/manage/

Unless you meant it in french :)

> + * promiscuity setting of all the bridge ports.  We are always called
> + * under RTNL so can skip using rcu primitives.
> + */
> +static void br_manage_promisc(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +
> +	list_for_each_entry(p, &br->port_list, list) {
> +		/* If the number of auto-ports is <= 1, then all other
> +		 * ports will have their output configuration statically
> +		 * specified through fdbs.  Since ingress on the auto-port
> +		 * becomes forwarding/egress to other ports and egress
> +		 * configuration is statically known, we can say that ingress
> +		 * configuration of the auto-port is also statically known.
> +		 * This lets us disable promiscuous mode and write this config
> +		 * to hw.
> +		 */
> +		if (br->auto_cnt <= br_auto_port(p))
> +			br_port_clear_promisc(p);
> +		else
> +			br_port_set_promisc(p);
> +	}
> +}
> +
>  static void nbp_update_port_count(struct net_bridge *br)
>  {
>  	struct net_bridge_port *p;
> @@ -94,7 +158,23 @@ static void nbp_update_port_count(struct net_bridge *br)
>  		if (br_auto_port(p))
>  			cnt++;
>  	}
> -	br->auto_cnt = cnt;
> +	if (br->auto_cnt != cnt) {
> +		br->auto_cnt = cnt;
> +		br_manage_promisc(br);
> +	}
> +}
> +
> +static void nbp_delete_promisc(struct net_bridge_port *p)
> +{
> +	/* If port is currently promiscous, unset promiscuity.
> +	 * Otherwise, it is a static port so remove all addresses
> +	 * from it.
> +	 */
> +	dev_set_allmulti(p->dev, -1);
> +	if (br_promisc_port(p))
> +		dev_set_promiscuity(p->dev, -1);
> +	else
> +		br_fdb_unsync_static(p->br, p);
>  }
>  
>  static void release_nbp(struct kobject *kobj)
> @@ -145,7 +225,7 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	sysfs_remove_link(br->ifobj, p->dev->name);
>  
> -	dev_set_promiscuity(dev, -1);
> +	nbp_delete_promisc(p);
>  
>  	spin_lock_bh(&br->lock);
>  	br_stp_disable_port(p);
> @@ -153,11 +233,10 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	br_ifinfo_notify(RTM_DELLINK, p);
>  
> -	nbp_vlan_flush(p);
> -	br_fdb_delete_by_port(br, p, 1);
> -
>  	list_del_rcu(&p->list);
>  
> +	nbp_vlan_flush(p);
> +	br_fdb_delete_by_port(br, p, 1);
>  	nbp_update_port_count(br);
>  
>  	dev->priv_flags &= ~IFF_BRIDGE_PORT;
> @@ -238,7 +317,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
>  	p->path_cost = port_cost(dev);
>  	p->priority = 0x8000 >> BR_PORT_BITS;
>  	p->port_no = index;
> -	p->flags = BR_LEARNING | BR_FLOOD | BR_PROMISC;
> +	p->flags = BR_LEARNING | BR_FLOOD;
>  	br_init_port(p);
>  	p->state = BR_STATE_DISABLED;
>  	br_stp_port_timer_init(p);
> @@ -367,7 +446,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  
>  	call_netdevice_notifiers(NETDEV_JOIN, dev);
>  
> -	err = dev_set_promiscuity(dev, 1);
> +	err = dev_set_allmulti(dev, 1);
>  	if (err)
>  		goto put_back;
>  
> -- 
> 1.9.0
