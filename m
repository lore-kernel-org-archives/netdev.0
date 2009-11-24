From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] macvlan: implement bridge, VEPA and private mode
Date: Tue, 24 Nov 2009 11:42:39 +0100
Message-ID: <4B0BB89F.7030605@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64918 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932695AbZKXKmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 05:42:36 -0500
In-Reply-To: <1259024166-28158-4-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> This allows each macvlan slave device to be in one
> of three modes, depending on the use case:
> 
> MACVLAN_PRIVATE:
>   The device never communicates with any other device
>   on the same upper_dev. This even includes frames
>   coming back from a reflective relay, where supported
>   by the adjacent bridge.
> 
> MACVLAN_VEPA:
>   The new Virtual Ethernet Port Aggregator (VEPA) mode,
>   we assume that the adjacent bridge returns all frames
>   where both source and destination are local to the
>   macvlan port, i.e. the bridge is set up as a reflective
>   relay.
>   Broadcast frames coming in from the upper_dev get
>   flooded to all macvlan interfaces in VEPA mode.
>   We never deliver any frames locally.
> 
> MACVLAN_BRIDGE:
>   We provide the behavior of a simple bridge between
>   different macvlan interfaces on the same port. Frames
>   from one interface to another one get delivered directly
>   and are not sent out externally. Broadcast frames get
>   flooded to all other bridge ports and to the external
>   interface, but when they come back from a reflective
>   relay, we don't deliver them again.
>   Since we know all the MAC addresses, the macvlan bridge
>   mode does not require learning or STP like the bridge
>   module does.

This looks pretty nice. Some stylistic nitpicking below :)

> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index a0dea23..b840b3a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -29,9 +29,16 @@
>  #include <linux/if_link.h>
>  #include <linux/if_macvlan.h>
>  #include <net/rtnetlink.h>
> +#include <net/xfrm.h>

Do we really need this?

> @@ -129,11 +137,14 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan, int length,
>  }
>  
>  static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
> -				 const struct ethhdr *eth)
> +				 const struct ethhdr *eth, int local)

bool local?

>  {
>  	if (!skb)
>  		return NET_RX_DROP;
>  
> +	if (local)
> +		return dev_forward_skb(dev, skb);
> +
>  	skb->dev = dev;
>  	if (!compare_ether_addr_64bits(eth->h_dest,
>  				       dev->broadcast))
> @@ -145,7 +156,9 @@ static int macvlan_broadcast_one(struct sk_buff *skb, struct net_device *dev,
>  }
>  
>  static void macvlan_broadcast(struct sk_buff *skb,
> -			      const struct macvlan_port *port)
> +			      const struct macvlan_port *port,
> +			      struct net_device *src,
> +			      enum macvlan_mode mode)
>  {
>  	const struct ethhdr *eth = eth_hdr(skb);
>  	const struct macvlan_dev *vlan;
> @@ -159,8 +172,12 @@ static void macvlan_broadcast(struct sk_buff *skb,
>  
>  	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
>  		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
> +			if ((vlan->dev == src) || !(vlan->mode & mode))

Please remove those unnecessary parentheses around the
device comparison.

> @@ -173,6 +190,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
>  	const struct ethhdr *eth = eth_hdr(skb);
>  	const struct macvlan_port *port;
>  	const struct macvlan_dev *vlan;
> +	const struct macvlan_dev *src;
>  	struct net_device *dev;
>  
>  	port = rcu_dereference(skb->dev->macvlan_port);
> @@ -180,7 +198,20 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
>  		return skb;
>  
>  	if (is_multicast_ether_addr(eth->h_dest)) {
> -		macvlan_broadcast(skb, port);
> +		src = macvlan_hash_lookup(port, eth->h_source);
> +		if (!src)
> +			/* frame comes from an external address */
> +			macvlan_broadcast(skb, port, NULL, MACVLAN_MODE_PRIVATE
> +				| MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);

The '|' should go on the first line.

> +		else if (src->mode == MACVLAN_MODE_VEPA)
> +			/* flood to everyone except source */
> +			macvlan_broadcast(skb, port, src->dev,
> +				MACVLAN_MODE_VEPA | MACVLAN_MODE_BRIDGE);
> +		else if (src->mode == MACVLAN_MODE_BRIDGE)
> +			/* flood only to VEPA ports, bridge ports
> +			   already saw the frame */

Multi-line comments should begin every line with '*'.

> +			macvlan_broadcast(skb, port, src->dev,
> +				MACVLAN_MODE_VEPA);

Please align the mode values (in all cases above) to the arguments
on the line above.

>  		return skb;
>  	}
>  
> @@ -203,18 +234,46 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
>  	return NULL;
>  }
>  
> +static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	const struct macvlan_dev *vlan = netdev_priv(dev);
> +	const struct macvlan_port *port = vlan->port;
> +	const struct macvlan_dev *dest;
> +
> +	if (vlan->mode == MACVLAN_MODE_BRIDGE) {
> +		const struct ethhdr *eth = (void *)skb->data;

eth_hdr()?

> +
> +		/* send to other bridge ports directly */
> +		if (is_multicast_ether_addr(eth->h_dest)) {
> +			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
> +			goto xmit_world;
> +		}
> +
> +		dest = macvlan_hash_lookup(port, eth->h_dest);
> +		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
> +			int length = skb->len + ETH_HLEN;

unsigned int for length values please.

> +			int ret = dev_forward_skb(dest->dev, skb);
> +			macvlan_count_rx(dest, length,
> +					 likely(ret == NET_RX_SUCCESS), 0);
> +
> +			return NET_XMIT_SUCCESS;
> +		}
> +	}
> +
> +xmit_world:
> +	skb->dev = vlan->lowerdev;
> +	return dev_queue_xmit(skb);
> +}
