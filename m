From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH next 1/3] ipvlan: Defer multicast / broadcast processing
 to a work-queue
Date: Fri, 24 Apr 2015 15:15:42 -0500
Message-ID: <1429906542.6379.16.camel@redhat.com>
References: <1429824589-23663-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965780AbbDXUOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 16:14:35 -0400
In-Reply-To: <1429824589-23663-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 14:29 -0700, Mahesh Bandewar wrote:
> Processing multicast / broadcast in fast path is performance draining
> and having more links means more clonning and bringing performance
> down further.
> 
> Broadcast; in particular, need to be given to all the virtual links.
> Earlier tricks of enabling broadcast bit for IPv4 only interfaces are not
> really working since it fails autoconf. Which means enabling braodcast
> for all the links if protocol specific hacks do not have to be added into
> the driver.
> 
> This patch defers all (incoming as well as outgoing) multicast traffic to
> a work-queue leaving only the unicast traffic in the fast-path. Now if we
> need to apply any additional tricks to further reduce the impact of this
> (multicast / broadcast) type of traffic, it can be implemented while
> processing this work without affecting the fast-path.

These patches appear to work for me for the L2 + DHCP use-case, however
I experienced some quite odd behavior when pinging the ipvlan interface
from another machine.  I did this:

ip link add link eno1 type ipvlan mode l2
ip netns add ipv
ip link set dev ipvlan0 netns ipv
ip netns exec ipv /sbin/dhclient -B -4 -1 -v
-pf /run/dhclient-ipvlan0.pid -C adafdasdfasf ipvlan0
ip netns exec ping 4.2.2.1 <success>

However, when pinging from another machine, I got very inconsistent ping
replies:

64 bytes from 192.168.1.38: icmp_seq=1 ttl=64 time=11.4 ms
64 bytes from 192.168.1.38: icmp_seq=16 ttl=64 time=64.9 ms
64 bytes from 192.168.1.38: icmp_seq=25 ttl=64 time=87.9 ms
64 bytes from 192.168.1.38: icmp_seq=30 ttl=64 time=242 ms
64 bytes from 192.168.1.38: icmp_seq=35 ttl=64 time=40.1 ms
64 bytes from 192.168.1.38: icmp_seq=36 ttl=64 time=60.9 ms

But I cannot reproduce that in a second run (though I haven't rebooted
to test cleanly again).

And oddly, the dhclient process takes a consistent 5% CPU and wireshark
running on eno1 (not even the ipvlan interface) jumps to 100% CPU along
with the dumpcap process taking another 25%, none of which are normal.
This is a 4-core i4790 box, so something is wrong here; is something
holding onto a spinlock for way too long?

But at least it handles the packets ok, so I say progress!  Happy to
help track down the CPU usage issue if you want to give me patches to
test.

Dan

> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/ipvlan/ipvlan.h      |   5 ++
>  drivers/net/ipvlan/ipvlan_core.c | 134 +++++++++++++++++++++++++--------------
>  drivers/net/ipvlan/ipvlan_main.c |   5 ++
>  3 files changed, 96 insertions(+), 48 deletions(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> index 54549a6223dd..953a97492fab 100644
> --- a/drivers/net/ipvlan/ipvlan.h
> +++ b/drivers/net/ipvlan/ipvlan.h
> @@ -39,6 +39,8 @@
>  #define IPVLAN_MAC_FILTER_SIZE	(1 << IPVLAN_MAC_FILTER_BITS)
>  #define IPVLAN_MAC_FILTER_MASK	(IPVLAN_MAC_FILTER_SIZE - 1)
>  
> +#define IPVLAN_QBACKLOG_LIMIT	1000
> +
>  typedef enum {
>  	IPVL_IPV6 = 0,
>  	IPVL_ICMPV6,
> @@ -93,6 +95,8 @@ struct ipvl_port {
>  	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
>  	struct list_head	ipvlans;
>  	struct rcu_head		rcu;
> +	struct work_struct	wq;
> +	struct sk_buff_head	backlog;
>  	int			count;
>  	u16			mode;
>  };
> @@ -112,6 +116,7 @@ void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
>  void ipvlan_init_secret(void);
>  unsigned int ipvlan_mac_hash(const unsigned char *addr);
>  rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
> +void ipvlan_process_multicast(struct work_struct *work);
>  int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev);
>  void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr);
>  struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index c30b5c300c05..58891666088c 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -189,64 +189,85 @@ unsigned int ipvlan_mac_hash(const unsigned char *addr)
>  	return hash & IPVLAN_MAC_FILTER_MASK;
>  }
>  
> -static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
> -				   const struct ipvl_dev *in_dev, bool local)
> +void ipvlan_process_multicast(struct work_struct *work)
>  {
> -	struct ethhdr *eth = eth_hdr(skb);
> +	struct ipvl_port *port = container_of(work, struct ipvl_port, wq);
> +	struct ethhdr *ethh;
>  	struct ipvl_dev *ipvlan;
> -	struct sk_buff *nskb;
> +	struct sk_buff *skb, *nskb;
> +	struct sk_buff_head list;
>  	unsigned int len;
>  	unsigned int mac_hash;
>  	int ret;
> +	u8 pkt_type;
> +	bool hlocal, dlocal;
>  
> -	if (skb->protocol == htons(ETH_P_PAUSE))
> -		return;
> -
> -	rcu_read_lock();
> -	list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
> -		if (local && (ipvlan == in_dev))
> -			continue;
> +	__skb_queue_head_init(&list);
>  
> -		mac_hash = ipvlan_mac_hash(eth->h_dest);
> -		if (!test_bit(mac_hash, ipvlan->mac_filters))
> -			continue;
> +	spin_lock_bh(&port->backlog.lock);
> +	skb_queue_splice_tail_init(&port->backlog, &list);
> +	spin_unlock_bh(&port->backlog.lock);
>  
> -		ret = NET_RX_DROP;
> -		len = skb->len + ETH_HLEN;
> -		nskb = skb_clone(skb, GFP_ATOMIC);
> -		if (!nskb)
> -			goto mcast_acct;
> +	while ((skb = __skb_dequeue(&list)) != NULL) {
> +		ethh = eth_hdr(skb);
> +		hlocal = ether_addr_equal(ethh->h_source, port->dev->dev_addr);
> +		mac_hash = ipvlan_mac_hash(ethh->h_dest);
>  
> -		if (ether_addr_equal(eth->h_dest, ipvlan->phy_dev->broadcast))
> -			nskb->pkt_type = PACKET_BROADCAST;
> +		if (ether_addr_equal(ethh->h_dest, port->dev->broadcast))
> +			pkt_type = PACKET_BROADCAST;
>  		else
> -			nskb->pkt_type = PACKET_MULTICAST;
> +			pkt_type = PACKET_MULTICAST;
> +
> +		dlocal = false;
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
> +			if (hlocal && (ipvlan->dev == skb->dev)) {
> +				dlocal = true;
> +				continue;
> +			}
> +			if (!test_bit(mac_hash, ipvlan->mac_filters))
> +				continue;
> +
> +			ret = NET_RX_DROP;
> +			len = skb->len + ETH_HLEN;
> +			nskb = skb_clone(skb, GFP_ATOMIC);
> +			if (!nskb)
> +				goto acct;
> +
> +			nskb->pkt_type = pkt_type;
> +			nskb->dev = ipvlan->dev;
> +			if (hlocal)
> +				ret = dev_forward_skb(ipvlan->dev, nskb);
> +			else
> +				ret = netif_rx(nskb);
> +acct:
> +			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
> +		}
> +		rcu_read_unlock();
>  
> -		nskb->dev = ipvlan->dev;
> -		if (local)
> -			ret = dev_forward_skb(ipvlan->dev, nskb);
> +		if (!dlocal)
> +			nskb = skb;
>  		else
> -			ret = netif_rx(nskb);
> -mcast_acct:
> -		ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
> -	}
> -	rcu_read_unlock();
> +			nskb = skb_clone(skb, GFP_ATOMIC);
>  
> -	/* Locally generated? ...Forward a copy to the main-device as
> -	 * well. On the RX side we'll ignore it (wont give it to any
> -	 * of the virtual devices.
> -	 */
> -	if (local) {
> -		nskb = skb_clone(skb, GFP_ATOMIC);
>  		if (nskb) {
> -			if (ether_addr_equal(eth->h_dest, port->dev->broadcast))
> -				nskb->pkt_type = PACKET_BROADCAST;
> -			else
> -				nskb->pkt_type = PACKET_MULTICAST;
> +			/* Always forward a copy to the master device. */
> +			if (hlocal) {
> +				dev_forward_skb(port->dev, nskb);
> +			} else {
> +				nskb->dev = port->dev;
> +				netif_rx(nskb);
> +			}
> +		}
>  
> -			dev_forward_skb(port->dev, nskb);
> +		if (dlocal) {
> +			/* If the packet originated here, send it out. */
> +			skb->dev = port->dev;
> +			skb->pkt_type = pkt_type;
> +			dev_queue_xmit(skb);
>  		}
>  	}
> +	return;
>  }
>  
>  static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *skb,
> @@ -446,6 +467,24 @@ out:
>  	return ret;
>  }
>  
> +static void ipvlan_multicast_enqueue(struct ipvl_port *port,
> +				     struct sk_buff *skb)
> +{
> +	if (skb->protocol == htons(ETH_P_PAUSE))
> +		return;
> +
> +	spin_lock(&port->backlog.lock);
> +	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
> +		__skb_queue_tail(&port->backlog, skb);
> +		spin_unlock(&port->backlog.lock);
> +	} else {
> +		spin_unlock(&port->backlog.lock);
> +		atomic_long_inc(&skb->dev->rx_dropped);
> +		kfree_skb(skb);
> +	}
> +	schedule_work(&port->wq);
> +}
> +
>  static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
>  {
>  	const struct ipvl_dev *ipvlan = netdev_priv(dev);
> @@ -493,11 +532,8 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
>  		return dev_forward_skb(ipvlan->phy_dev, skb);
>  
>  	} else if (is_multicast_ether_addr(eth->h_dest)) {
> -		u8 ip_summed = skb->ip_summed;
> -
> -		skb->ip_summed = CHECKSUM_UNNECESSARY;
> -		ipvlan_multicast_frame(ipvlan->port, skb, ipvlan, true);
> -		skb->ip_summed = ip_summed;
> +		ipvlan_multicast_enqueue(ipvlan->port, skb);
> +		return NET_XMIT_SUCCESS;
>  	}
>  
>  	skb->dev = ipvlan->phy_dev;
> @@ -581,8 +617,10 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
>  	int addr_type;
>  
>  	if (is_multicast_ether_addr(eth->h_dest)) {
> -		if (ipvlan_external_frame(skb, port))
> -			ipvlan_multicast_frame(port, skb, NULL, false);
> +		if (ipvlan_external_frame(skb, port)) {
> +			ipvlan_multicast_enqueue(port, skb);
> +			return RX_HANDLER_CONSUMED;
> +		}
>  	} else {
>  		struct ipvl_addr *addr;
>  
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 77b92a0fe557..a16d3017fdc3 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -54,6 +54,9 @@ static int ipvlan_port_create(struct net_device *dev)
>  	for (idx = 0; idx < IPVLAN_HASH_SIZE; idx++)
>  		INIT_HLIST_HEAD(&port->hlhead[idx]);
>  
> +	skb_queue_head_init(&port->backlog);
> +	INIT_WORK(&port->wq, ipvlan_process_multicast);
> +
>  	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
>  	if (err)
>  		goto err;
> @@ -72,6 +75,8 @@ static void ipvlan_port_destroy(struct net_device *dev)
>  
>  	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
>  	netdev_rx_handler_unregister(dev);
> +	cancel_work_sync(&port->wq);
> +	__skb_queue_purge(&port->backlog);
>  	kfree_rcu(port, rcu);
>  }
>  
