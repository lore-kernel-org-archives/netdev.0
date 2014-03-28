From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v4 net] bridge: use is_skb_forwardable in
	forward path
Date: Thu, 27 Mar 2014 21:56:30 -0400
Message-ID: <5334D6CE.9000605@redhat.com>
References: <1395971350-10559-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395971350-10559-1-git-send-email-vyasevic@redhat.com>
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

On 03/27/2014 09:49 PM, Vlad Yasevich wrote:
> Use existing function instead of trying to use our own.  This allows
> us to better handle Q-in-Q packets.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Nack.  Causes build issues with modules...

-vlad

> ---
> v2: Fix missing hunk in patch 2/2 to make it build.
> 
> v3: Fix indent for is_skb_forwardable
> 
> v4: Made is_skb_forwardable inline in netdevice.h and squashed
>     the 2 patches into one since having 2 doesn't make much sense
>     any more.
> 
>  include/linux/netdevice.h | 24 ++++++++++++++++++++++++
>  net/bridge/br_forward.c   |  9 ++-------
>  net/core/dev.c            | 21 ---------------------
>  3 files changed, 26 insertions(+), 28 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e8eeebd..5d07fee 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3146,6 +3146,30 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
>  	skb->mac_len = mac_len;
>  }
>  
> +
> +#include <linux/if_vlan.h>
> +
> +static inline bool is_skb_forwardable(struct net_device *dev,
> +				      struct sk_buff *skb)
> +{
> +	unsigned int len;
> +
> +	if (!(dev->flags & IFF_UP))
> +		return false;
> +
> +	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
> +	if (skb->len <= len)
> +		return true;
> +
> +	/* if TSO is enabled, we don't care about the length as the packet
> +	 * could be forwarded without being segmented before
> +	 */
> +	if (skb_is_gso(skb))
> +		return true;
> +
> +	return false;
> +}
> +
>  static inline bool netif_is_macvlan(struct net_device *dev)
>  {
>  	return dev->priv_flags & IFF_MACVLAN;
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index d3409e6..056b67b 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -35,16 +35,11 @@ static inline int should_deliver(const struct net_bridge_port *p,
>  		p->state == BR_STATE_FORWARDING;
>  }
>  
> -static inline unsigned int packet_length(const struct sk_buff *skb)
> -{
> -	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
> -}
> -
>  int br_dev_queue_push_xmit(struct sk_buff *skb)
>  {
>  	/* ip_fragment doesn't copy the MAC header */
>  	if (nf_bridge_maybe_copy_header(skb) ||
> -	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
> +	    !is_skb_forwardable(skb->dev, skb)) {
>  		kfree_skb(skb);
>  	} else {
>  		skb_push(skb, ETH_HLEN);
> @@ -71,7 +66,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
>  	skb->dev = to->dev;
>  
>  	if (unlikely(netpoll_tx_running(to->br->dev))) {
> -		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
> +		if (!is_skb_forwardable(skb->dev, skb))
>  			kfree_skb(skb);
>  		else {
>  			skb_push(skb, ETH_HLEN);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b1b0c8d..3e4a965 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1645,27 +1645,6 @@ static inline void net_timestamp_set(struct sk_buff *skb)
>  			__net_timestamp(SKB);		\
>  	}						\
>  
> -static inline bool is_skb_forwardable(struct net_device *dev,
> -				      struct sk_buff *skb)
> -{
> -	unsigned int len;
> -
> -	if (!(dev->flags & IFF_UP))
> -		return false;
> -
> -	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
> -	if (skb->len <= len)
> -		return true;
> -
> -	/* if TSO is enabled, we don't care about the length as the packet
> -	 * could be forwarded without being segmented before
> -	 */
> -	if (skb_is_gso(skb))
> -		return true;
> -
> -	return false;
> -}
> -
>  /**
>   * dev_forward_skb - loopback an skb to another netif
>   *
> 
