From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Wed, 01 Apr 2015 15:07:03 -0500
Message-ID: <1427918823.3025.22.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
	 <1427749308.1913.28.camel@redhat.com>
	 <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbbDAUGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 16:06:41 -0400
In-Reply-To: <1427775770.30696.3.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-30 at 23:22 -0500, Dan Williams wrote:
> The broadcast MAC is supposed to be allowed whenever the device
> has an IPv4 address, otherwise ARP requests get dropped on the
> floor.  If ndo_set_rx_mode (and thus
> ipvlan_set_multicast_mac_filter()) got called after the address
> was added, it would blow away the broadcast MAC address in
> mac_filters that was added at IPv4 address addition.
> 
> Next, ipvlan currently fails DHCP addressing for two reasons:
> 
> 1) DHCP offers are typically unicast back to the device's MAC
> address, and at the IP layer have a destination IP address
> matching the new lease address.  In ipvlan unicast packets
> are checked against existing addresses assigned to the ipvlan
> interface, so clearly this fails hard because the ipvlan
> interface has no IP addresses yet.  Workaround: request
> that the server broadcast replies (-B for dhclient) which
> don't get checked against the address list.
> 
> 2) Even when that's done, mac_filters only allows the
> broadcast MAC address when the interface has >= 1 IPv4
> addresses, so double-fail, and the incoming DHCP offer
> gets dropped on the floor again.
> 
> To fix these issues, Watch for outgoing DHCP requests and
> enable the broadcast MAC address indefinitely when one is seen.

Any thoughts on this approach Mahesh?

Dan

> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
> NOTE: this patch supercedes my previous two ipvlan patches:
> [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC filters
> [PATCH 2/2] ipvlan: always allow the broadcast MAC address
> 
>  drivers/net/ipvlan/ipvlan.h      |  2 ++
>  drivers/net/ipvlan/ipvlan_core.c | 36 ++++++++++++++++++++++++++++++++++--
>  drivers/net/ipvlan/ipvlan_main.c | 12 +++++++++---
>  3 files changed, 45 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
> index 924ea98..7e0b8ff 100644
> --- a/drivers/net/ipvlan/ipvlan.h
> +++ b/drivers/net/ipvlan/ipvlan.h
> @@ -67,6 +67,7 @@ struct ipvl_dev {
>  	struct list_head	addrs;
>  	int			ipv4cnt;
>  	int			ipv6cnt;
> +	bool			dhcp4_seen;
>  	struct ipvl_pcpu_stats	__percpu *pcpu_stats;
>  	DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
>  	netdev_features_t	sfeatures;
> @@ -118,4 +119,5 @@ bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6);
>  struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
>  					const void *iaddr, bool is_v6);
>  void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync);
> +void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set);
>  #endif /* __IPVLAN_H */
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 2a17500..6dd992b 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -126,6 +126,12 @@ static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
>  		lyr3h = arph;
>  		break;
>  	}
> +	case htons(ETH_P_ALL): {
> +		/* Raw sockets */
> +		if (eth_hdr(skb)->h_proto != htons(ETH_P_IP))
> +			break;
> +		/* Fall through */
> +	}
>  	case htons(ETH_P_IP): {
>  		u32 pktlen;
>  		struct iphdr *ip4h;
> @@ -454,16 +460,42 @@ out:
>  	return ipvlan_process_outbound(skb, ipvlan);
>  }
>  
> +#define DHCP_PACKET_MIN_LEN 282
> +
> +static bool is_dhcp(struct sk_buff *skb)
> +{
> +	struct iphdr *ip4h = ip_hdr(skb);
> +	struct udphdr *udph;
> +
> +	if (skb->len < DHCP_PACKET_MIN_LEN || ip4h->protocol != IPPROTO_UDP
> +		|| ip_is_fragment(ip4h))
> +		return false;
> +
> +	/* In the case of RAW sockets the transport header is not set by
> +	 * the IP stack so we must set it ourselves.
> +	 */
> +	if (skb->transport_header == skb->network_header)
> +		skb_set_transport_header(skb, ETH_HLEN + sizeof(struct iphdr));
> +	udph = udp_hdr(skb);
> +	return udph && udph->dest == htons(67) && udph->source == htons(68);
> +}
> +
>  static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
>  {
> -	const struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
>  	struct ethhdr *eth = eth_hdr(skb);
>  	struct ipvl_addr *addr;
>  	void *lyr3h;
>  	int addr_type;
>  
> +	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
> +	if (!ipvlan->dhcp4_seen && lyr3h && addr_type == IPVL_IPV4
> +	    && is_dhcp(skb)) {
> +		ipvlan->dhcp4_seen = true;
> +		ipvlan_set_broadcast_mac_filter(ipvlan, true);
> +	}
> +
>  	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
> -		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
>  		if (lyr3h) {
>  			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
>  			if (addr)
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 4f4099d..a497fb9 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -167,6 +167,8 @@ static int ipvlan_stop(struct net_device *dev)
>  
>  	dev_uc_del(phy_dev, phy_dev->dev_addr);
>  
> +	ipvlan->dhcp4_seen = false;
> +
>  	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
>  		list_for_each_entry(addr, &ipvlan->addrs, anode)
>  			ipvlan_ht_addr_del(addr, !dev->dismantle);
> @@ -214,7 +216,7 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
>  		dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
>  }
>  
> -static void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
> +void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, bool set)
>  {
>  	struct net_device *dev = ipvlan->dev;
>  	unsigned int hashbit = ipvlan_mac_hash(dev->broadcast);
> @@ -239,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
>  		netdev_for_each_mc_addr(ha, dev)
>  			__set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
>  
> +		if (ipvlan->ipv4cnt || ipvlan->dhcp4_seen)
> +			__set_bit(ipvlan_mac_hash(dev->broadcast), mc_filters);
> +
>  		bitmap_copy(ipvlan->mac_filters, mc_filters,
>  			    IPVLAN_MAC_FILTER_SIZE);
>  	}
> @@ -467,6 +472,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>  	INIT_LIST_HEAD(&ipvlan->addrs);
>  	ipvlan->ipv4cnt = 0;
>  	ipvlan->ipv6cnt = 0;
> +	ipvlan->dhcp4_seen = false;
>  
>  	/* TODO Probably put random address here to be presented to the
>  	 * world but keep using the physical-dev address for the outgoing
> @@ -708,8 +714,8 @@ static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
>  	list_del_rcu(&addr->anode);
>  	ipvlan->ipv4cnt--;
>  	WARN_ON(ipvlan->ipv4cnt < 0);
> -	if (!ipvlan->ipv4cnt)
> -	    ipvlan_set_broadcast_mac_filter(ipvlan, false);
> +	if (!ipvlan->ipv4cnt && !ipvlan->dhcp4_seen)
> +		ipvlan_set_broadcast_mac_filter(ipvlan, false);
>  	kfree_rcu(addr, rcu);
>  
>  	return;
