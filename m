From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 7/8] bridge: Correctly manage
 promiscuity when user requested it.
Date: Thu, 15 May 2014 21:50:32 +0300
Message-ID: <20140515185032.GG1699@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
	<1400173016-8952-8-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400173016-8952-8-git-send-email-vyasevic@redhat.com>
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

On Thu, May 15, 2014 at 12:56:55PM -0400, Vlad Yasevich wrote:
> When the user places the bridge device in promiscuous mode,
> all ports are placed in promisc mode regardless of the number
> of flooding ports configured.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

Though I would smash this one into the previous patch:
it adds about 6 lines so it's not like it makes
the patch much bigger.
OTOH after smash, we are sure bisect won't produce a broken
kernel.

> ---
>  net/bridge/br_device.c  |  7 +++++++
>  net/bridge/br_if.c      | 34 +++++++++++++++++++++-------------
>  net/bridge/br_private.h |  1 +
>  3 files changed, 29 insertions(+), 13 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 9212015..d77e2f0 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -112,6 +112,12 @@ static void br_dev_set_multicast_list(struct net_device *dev)
>  {
>  }
>  
> +static void br_dev_change_rx_flags(struct net_device *dev, int change)
> +{
> +	if (change & IFF_PROMISC)
> +		br_manage_promisc(netdev_priv(dev));
> +}
> +
>  static int br_dev_stop(struct net_device *dev)
>  {
>  	struct net_bridge *br = netdev_priv(dev);
> @@ -309,6 +315,7 @@ static const struct net_device_ops br_netdev_ops = {
>  	.ndo_get_stats64	 = br_get_stats64,
>  	.ndo_set_mac_address	 = br_set_mac_address,
>  	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
> +	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
>  	.ndo_change_mtu		 = br_change_mtu,
>  	.ndo_do_ioctl		 = br_dev_ioctl,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index e3bc5a6..1a3638e 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -128,24 +128,32 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
>   * promiscuity setting of all the bridge ports.  We are always called
>   * under RTNL so can skip using rcu primitives.
>   */
> -static void br_manage_promisc(struct net_bridge *br)
> +void br_manage_promisc(struct net_bridge *br)
>  {
>  	struct net_bridge_port *p;
>  
>  	list_for_each_entry(p, &br->port_list, list) {
> -		/* If the number of auto-ports is <= 1, then all other
> -		 * ports will have their output configuration statically
> -		 * specified through fdbs.  Since ingress on the auto-port
> -		 * becomes forwarding/egress to other ports and egress
> -		 * configuration is statically known, we can say that ingress
> -		 * configuration of the auto-port is also statically known.
> -		 * This lets us disable promiscuous mode and write this config
> -		 * to hw.
> -		 */
> -		if (br->auto_cnt <= br_auto_port(p))
> -			br_port_clear_promisc(p);
> -		else
> +		if (br->dev->flags & IFF_PROMISC) {
> +			/* PROMISC flag has been turned on for the bridge
> +			 * itself.  Turn on promisc on all ports.
> +			 */
>  			br_port_set_promisc(p);
> +		} else {
> +			/* If the number of auto-ports is <= 1, then all other
> +			 * ports will have their output configuration
> +			 * statically specified through fdbs.  Since ingress
> +			 * on the auto-port becomes forwarding/egress to other
> +			 * ports and egress configuration is statically known,
> +			 * we can say that ingress configuration of the
> +			 * auto-port is also statically known.
> +			 * This lets us disable promiscuous mode and write
> +			 * this config to hw.
> +			 */
> +			if (br->auto_cnt <= br_auto_port(p))
> +				br_port_clear_promisc(p);
> +			else
> +				br_port_set_promisc(p);
> +		}
>  	}
>  }
>  
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 00922a4..06976af 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -424,6 +424,7 @@ int br_min_mtu(const struct net_bridge *br);
>  netdev_features_t br_features_recompute(struct net_bridge *br,
>  					netdev_features_t features);
>  void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
> +void br_manage_promisc(struct net_bridge *br);
>  
>  /* br_input.c */
>  int br_handle_frame_finish(struct sk_buff *skb);
> -- 
> 1.9.0
