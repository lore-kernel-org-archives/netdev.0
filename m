From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 4/7] bridge: Automatically manage port
	promiscuous mode.
Date: Wed, 26 Feb 2014 17:51:11 +0200
Message-ID: <20140226155111.GE15330@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1393427905-6811-5-git-send-email-vyasevic@redhat.com>
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

On Wed, Feb 26, 2014 at 10:18:22AM -0500, Vlad Yasevich wrote:
> When there is only 1 flooding port, this port is programmed
> with all the address

all the addresses?

> the bridge accumulated.  This allows
> us to place this port into non-promiscuous mode.
> At other times, all ports are set as promiscuous.  To help
> track whether the bridge set the mode or not, a new
> flag is introduced.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_if.c      | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
>  net/bridge/br_private.h |  1 +
>  2 files changed, 47 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index e782c2e..51df642 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -136,7 +136,7 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	sysfs_remove_link(br->ifobj, p->dev->name);
>  
> -	dev_set_promiscuity(dev, -1);
> +	dev_set_allmulti(dev, -1);
>  
>  	spin_lock_bh(&br->lock);
>  	br_stp_disable_port(p);
> @@ -359,7 +359,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  
>  	call_netdevice_notifiers(NETDEV_JOIN, dev);
>  
> -	err = dev_set_promiscuity(dev, 1);
> +	err = dev_set_allmulti(dev, 1);
>  	if (err)
>  		goto put_back;
>  
> @@ -465,6 +465,48 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>  	return 0;
>  }
>  
> +static int br_port_set_promisc(struct net_bridge_port *p)
> +{
> +	int err = 0;
> +
> +	if (p->flags & BR_PROMISC)
> +		return err;
> +
> +	err = dev_set_promiscuity(p->dev, 1);
> +	if (err)
> +		return err;
> +
> +	p->flags |= BR_PROMISC;
> +	return err;
> +}
> +

you take pains to return an error code here,
only to ignore it in the caller?

> +static void br_port_clear_promisc(struct net_bridge_port *p)
> +{
> +	if (!(p->flags & BR_PROMISC))
> +		return;
> +
> +	dev_set_promiscuity(p->dev, -1);
> +	p->flags &= ~BR_PROMISC;
> +}
> +
> +/* When a port is added or removed or when the flooding status of
> + * the port changes, this function is called to automatically mange
> + * promiscuity setting of all the bridge ports.  We are always called
> + * under RTNL so can skip using rcu primitives.
> + */
> +static void br_manage_promisc(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +
> +	list_for_each_entry(p, &br->port_list, list) {
> +		if (!br_port_exists(p->dev) ||
> +		    (br->n_flood_ports == 1 && br->c_flood_port == p))
> +			br_port_clear_promisc(p);
> +		else
> +			br_port_set_promisc(p);
> +	}
> +}
> +
>  static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>  {
>  	/* Increment the number of  flooding ports, and if we
> @@ -475,6 +517,7 @@ static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>  		br->c_flood_port = p;
>  
>  	br_fdb_addrs_sync(br);
> +	br_manage_promisc(br);
>  }
>  
>  static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
> @@ -502,6 +545,7 @@ static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>  			}
>  		}
>  	}
> +	br_manage_promisc(br);
>  }
>  
>  void br_port_flags_change(struct net_bridge_port *p, unsigned long mask)
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 40a6927..6670cb3 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -174,6 +174,7 @@ struct net_bridge_port
>  #define BR_ADMIN_COST		0x00000010
>  #define BR_LEARNING		0x00000020
>  #define BR_FLOOD		0x00000040
> +#define BR_PROMISC		0x00000080
>

Considering you then have a separate logic in 7/7
will this be cleaner as a per-port flag?
  
>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>  	struct bridge_mcast_query	ip4_query;
> -- 
> 1.8.5.3
