From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 6/7] bridge: Manage promisc mode when vlans are
 configured on top of a bridge
Date: Wed, 26 Feb 2014 18:00:46 +0200
Message-ID: <20140226160046.GI15330@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-7-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1393427905-6811-7-git-send-email-vyasevic@redhat.com>
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

On Wed, Feb 26, 2014 at 10:18:24AM -0500, Vlad Yasevich wrote:
> If the user configures vlan interfaces on top of the bridge and the bridge
> doesn't have vlan filtering enabled, we have to place all the ports in
> promsic mode so that we can correctly receive tagged frames.
> When vlan filtering is enabled, the vlan configuration will be provided
> via filtering interface.
> When the vlan filtering is toggled, we also have mange promiscuity.

have to manage?

> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>


I wonder if it matters that we scan all ports
on vlan add/del now.

If yes, we could optimize some cases by using
a counter of promisc ports.


> ---
>  net/bridge/br_device.c  | 14 ++++++++++++++
>  net/bridge/br_if.c      | 17 +++++++++++++----
>  net/bridge/br_private.h |  9 +++++++++
>  net/bridge/br_vlan.c    |  1 +
>  4 files changed, 37 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 0af9d6c..967abb3 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -297,6 +297,18 @@ void br_netpoll_disable(struct net_bridge_port *p)
>  
>  #endif
>  
> +static int br_dev_rx_add_vid(struct net_device *br_dev, __be16 proto, u16 vid)
> +{
> +	br_manage_promisc(netdev_priv(br_dev));
> +	return 0;
> +}
> +
> +static int br_dev_rx_kill_vid(struct net_device *br_dev, __be16 proto, u16 vid)
> +{
> +	br_manage_promisc(netdev_priv(br_dev));
> +	return 0;
> +}
> +
>  static int br_add_slave(struct net_device *dev, struct net_device *slave_dev)
>  
>  {
> @@ -328,6 +340,8 @@ static const struct net_device_ops br_netdev_ops = {
>  	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
>  	.ndo_change_mtu		 = br_change_mtu,
>  	.ndo_do_ioctl		 = br_dev_ioctl,
> +	.ndo_vlan_rx_add_vid	 = br_dev_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid	 = br_dev_rx_kill_vid,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_netpoll_setup	 = br_netpoll_setup,
>  	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 7e92bd0..55e4e28 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -497,12 +497,21 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
>  void br_manage_promisc(struct net_bridge *br)
>  {
>  	struct net_bridge_port *p;
> +	int set_all = false;
> +
> +	if (br->dev->flags & IFF_PROMISC)
> +		set_all = true;
> +
> +	/* If vlan filtering is disabled and there are any VLANs
> +	 * configured on top of the bridge, set promisc on all
> +	 * ports.
> +	 */
> +	if (!br_vlan_enabled(br) && vlan_uses_dev(br->dev))
> +		set_all = true;
>  
>  	list_for_each_entry(p, &br->port_list, list) {
> -		if (br->dev->flags & IFF_PROMISC) {
> -			/* PROMISC flag has been turned on for the bridge
> -			 * itself.  Turn on promisc on all ports.
> -			 */
> +		if (set_all) {
> +			/* Set all the ports to promisc mode.  */
>  			br_port_set_promisc(p);
>  
>  		} else {
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 4042f86..87dcc09 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -641,6 +641,10 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>  	return v->pvid ?: VLAN_N_VID;
>  }
>  
> +static inline int br_vlan_enabled(struct net_bridge *br)
> +{
> +	return br->vlan_enabled;
> +}
>  #else
>  static inline bool br_allowed_ingress(struct net_bridge *br,
>  				      struct net_port_vlans *v,
> @@ -721,6 +725,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>  {
>  	return VLAN_N_VID;	/* Returns invalid vid */
>  }
> +
> +static inline int br_vlan_enabled(struct net_bridge *br);
> +{
> +	return 0;
> +}
>  #endif
>  
>  /* br_netfilter.c */
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 8249ca7..eddc2f6 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -321,6 +321,7 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
>  		goto unlock;
>  
>  	br->vlan_enabled = val;
> +	br_manage_promisc(br);
>  
>  unlock:
>  	rtnl_unlock();
> -- 
> 1.8.5.3
