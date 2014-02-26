From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/7] bridge: Support promisc management when
 all ports are non-flooding
Date: Wed, 26 Feb 2014 17:57:00 +0200
Message-ID: <20140226155700.GH15330@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-8-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1393427905-6811-8-git-send-email-vyasevic@redhat.com>
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

On Wed, Feb 26, 2014 at 10:18:25AM -0500, Vlad Yasevich wrote:
> Configuration where all ports are set to non-flooding is a slight
> special case.  In this config, the user would have to manage all fdbs
> for all ports.  In this special case, since we'll know all addresses,
> we can turn off promisc on all ports and program all ports with the
> same set of addresses.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Here the logic is different be we could sync them,
just make this a per-port flag and
scan all ports instead of relying on flood_port.
This will be slower in the single flooding port
case but worst case remains the same since
this patch scans all ports.

What do you think?

> ---
>  include/linux/netdevice.h |  3 +++
>  net/bridge/br_fdb.c       | 22 +++++++++++++++++-----
>  net/bridge/br_if.c        | 40 ++++++++++++++++++++++++++++++++++------
>  net/bridge/br_private.h   |  2 +-
>  net/core/dev_addr_lists.c |  7 ++++---
>  5 files changed, 59 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e29cce1..79e97ee 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2889,6 +2889,9 @@ int __hw_addr_del(struct netdev_hw_addr_list *list,
>  		  unsigned char addr_type);
>  int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
>  		   struct netdev_hw_addr_list *from_list, int addr_len);
> +int __hw_addr_sync_multiple(struct netdev_hw_addr_list *to_list,
> +			    struct netdev_hw_addr_list *from_list,
> +			    int addr_len);
>  void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
>  		      struct netdev_hw_addr_list *from_list, int addr_len);
>  void __hw_addr_init(struct netdev_hw_addr_list *list);
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index ef95e81..26ea4fe 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -911,19 +911,31 @@ void br_fdb_addrs_sync(struct net_bridge *br)
>  	if (br->n_flood_ports == 1) {
>  		p = br->c_flood_port;
>  		netif_addr_lock(p->dev);
> -		err = __hw_addr_sync(&p->dev->uc, &br->conf_addrs,
> -				     p->dev->addr_len);
> +		err = __hw_addr_sync_multiple(&p->dev->uc, &br->conf_addrs,
> +					      p->dev->addr_len);
>  		if (!err)
>  			__dev_set_rx_mode(p->dev);
>  		netif_addr_unlock(p->dev);
> +	} else if (br->n_flood_ports == 0) {
> +		list_for_each_entry(p, &br->port_list, list) {
> +			/* skip over ports being deleted. */
> +			if (!br_port_exists(p->dev))
> +				continue;
>  
> +			netif_addr_lock_nested(p->dev);
> +			err = __hw_addr_sync_multiple(&p->dev->uc,
> +						      &br->conf_addrs,
> +						      p->dev->addr_len);
> +			if (!err)
> +				__dev_set_rx_mode(p->dev);
> +			netif_addr_unlock(p->dev);
> +		}
>  	}
> +
>  }
>  
> -void br_fdb_addrs_unsync(struct net_bridge *br)
> +void br_fdb_addrs_unsync(struct net_bridge *br, struct net_bridge_port *p)
>  {
> -	struct net_bridge_port *p = br->c_flood_port;
> -
>  	if (!p)
>  		return;
>  
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 55e4e28..4ba62ef 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -148,6 +148,8 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	if (p->flags & BR_FLOOD)
>  		br_del_flood_port(p, br);
> +	else
> +		br_fdb_addrs_unsync(br, p);
>  
>  	nbp_vlan_flush(p);
>  	br_fdb_delete_by_port(br, p, 1);
> @@ -530,8 +532,26 @@ static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>  	 * only have 1 flooding port cache if for future use.
>  	 */
>  	br->n_flood_ports++;
> -	if (br->n_flood_ports == 1)
> +	if (br->n_flood_ports == 1) {
> +		struct net_bridge_port *port;
> +
> +		/* We are transitioning from 0 flood ports to 1.  Remove
> +		 * the addresses from all the non-flood ports and turn on
> +		 * promisc on those ports.
> +		 */
> +		list_for_each_entry(port, &br->port_list, list) {
> +			/* skip the current port we are changing */
> +			if (port == p)
> +				continue;
> +
> +			if (!(port->flags & BR_FLOOD)) {
> +				br_port_set_promisc(port);
> +				br_fdb_addrs_unsync(br, port);
> +			}
> +		}
> +
>  		br->c_flood_port = p;
> +	}
>  
>  	br_fdb_addrs_sync(br);
>  	br_manage_promisc(br);
> @@ -547,12 +567,20 @@ static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>  	 * set it if it is not set.
>  	 */
>  	br->n_flood_ports--;
> -	if (p == br->c_flood_port) {
> -		br_fdb_addrs_unsync(br);
> -		br->c_flood_port = NULL;
> -	}
> +	if (br->n_flood_ports == 0) {
> +		/* We just dropped to 0 flood ports.  If we
> +		 * are deleting this port, unsync addresses
> +		 * from it.
> +		 */
> +		if (!br_port_exists(p->dev))
> +			br_fdb_addrs_unsync(br, p);
>  
> -	if (br->n_flood_ports == 1) {
> +		br->c_flood_port = NULL;
> +		br_fdb_addrs_sync(br);
> +	} else if (br->n_flood_ports == 1) {
> +		/* We just dropped to 1 flood port. Find this one flood
> +		 * port and sync to it.
> +		 */
>  		list_for_each_entry(port, &p->br->port_list, list) {
>  			if (br_port_exists(port->dev) &&
>  			    (port->flags & BR_FLOOD)) {
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 87dcc09..13840de 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -400,7 +400,7 @@ int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
>  int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  		struct net_device *dev, int idx);
>  void br_fdb_addrs_sync(struct net_bridge *br);
> -void br_fdb_addrs_unsync(struct net_bridge *br);
> +void br_fdb_addrs_unsync(struct net_bridge *br, struct net_bridge_port *p);
>  
>  /* br_forward.c */
>  void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
> index 3de44a3..24da78f 100644
> --- a/net/core/dev_addr_lists.c
> +++ b/net/core/dev_addr_lists.c
> @@ -171,9 +171,9 @@ static void __hw_addr_unsync_one(struct netdev_hw_addr_list *to_list,
>  	__hw_addr_del_entry(from_list, ha, false, false);
>  }
>  
> -static int __hw_addr_sync_multiple(struct netdev_hw_addr_list *to_list,
> -				   struct netdev_hw_addr_list *from_list,
> -				   int addr_len)
> +int __hw_addr_sync_multiple(struct netdev_hw_addr_list *to_list,
> +			    struct netdev_hw_addr_list *from_list,
> +			    int addr_len)
>  {
>  	int err = 0;
>  	struct netdev_hw_addr *ha, *tmp;
> @@ -189,6 +189,7 @@ static int __hw_addr_sync_multiple(struct netdev_hw_addr_list *to_list,
>  	}
>  	return err;
>  }
> +EXPORT_SYMBOL(__hw_addr_sync_multiple);
>  
>  /* This function only works where there is a strict 1-1 relationship
>   * between source and destionation of they synch. If you ever need to
> -- 
> 1.8.5.3
