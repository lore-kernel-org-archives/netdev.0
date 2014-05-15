From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 8/8] bridge: Automatically manage
 promisc mode when vlan filtering is on.
Date: Thu, 15 May 2014 21:57:38 +0300
Message-ID: <20140515185738.GH1699@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
	<1400173016-8952-9-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400173016-8952-9-git-send-email-vyasevic@redhat.com>
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

On Thu, May 15, 2014 at 12:56:56PM -0400, Vlad Yasevich wrote:
> If the user doesn't enable vlan filtering, we have to place all
> bridge ports in promsic mode

s/promsic/promisc/

> so that we retain the capability of
> of receiving tagged frames.

s/of of/of/

> When vlan filtering is enabled, the each port

s/the each port/each port/

> will be provided with
> necessary vlan configuration and would be able to receive tagged
> traffic without promiscuous mode set, thus allowing us to automatically
> turn promiscuity on or off depending on the configuration.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

again I would smash this up, though it is less clear-cut here.


> ---
>  net/bridge/br_if.c      | 12 ++++++++----
>  net/bridge/br_private.h |  9 +++++++++
>  net/bridge/br_vlan.c    |  1 +
>  3 files changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 1a3638e..33a83ea 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -131,12 +131,16 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
>  void br_manage_promisc(struct net_bridge *br)
>  {
>  	struct net_bridge_port *p;
> +	bool set_all = false;
> +
> +	/* If vlan filtering is disabled or bridge interface is placed
> +	 * into promiscuous mode, place all ports in promiscuous mode.
> +	 */
> +	if ((br->dev->flags & IFF_PROMISC) || !br_vlan_enabled(br))
> +		set_all = true;
>  
>  	list_for_each_entry(p, &br->port_list, list) {
> -		if (br->dev->flags & IFF_PROMISC) {
> -			/* PROMISC flag has been turned on for the bridge
> -			 * itself.  Turn on promisc on all ports.
> -			 */
> +		if (set_all) {
>  			br_port_set_promisc(p);
>  		} else {
>  			/* If the number of auto-ports is <= 1, then all other
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 06976af..2b2286d 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -642,6 +642,10 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
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
> @@ -722,6 +726,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
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
> index 4a37161..24c5cc5 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -332,6 +332,7 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
>  		goto unlock;
>  
>  	br->vlan_enabled = val;
> +	br_manage_promisc(br);
>  
>  unlock:
>  	rtnl_unlock();
> -- 
> 1.9.0
