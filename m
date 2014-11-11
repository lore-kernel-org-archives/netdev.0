From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Tue, 11 Nov 2014 15:28:11 -0800
Message-ID: <1415748491.9613.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:59770 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbaKKX2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:28:14 -0500
Received: by mail-ig0-f175.google.com with SMTP id h3so1955935igd.14
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 15:28:13 -0800 (PST)
In-Reply-To: <1415744984-25802-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-11 at 14:29 -0800, Mahesh Bandewar wrote:

...

> +static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
> +{
> +	void *lyr3h = NULL;
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_ARP): {
> +		struct arphdr *arph;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct arphdr))))
> +			return NULL;
> +
> +		arph = arp_hdr(skb);
> +		*type = IPVL_ARP;
> +		lyr3h = arph;
> +		break;
> +	}
> +
> +	case htons(ETH_P_IP): {
> +		u32 pktlen;
> +		struct iphdr *ip4h;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct iphdr))))
> +			return NULL;
> +
> +		ip4h = ip_hdr(skb);
> +		pktlen = ntohs(ip4h->tot_len);
> +		if (ip4h->ihl < 5 || ip4h->version != 4)
> +			return NULL;
> +		if (skb->len < pktlen || pktlen < (ip4h->ihl * 4))
> +			return NULL;
> +
> +		*type = IPVL_IPV4;
> +		lyr3h = ip4h;
> +		break;
> +	}
> +	case htons(ETH_P_IPV6): {
> +		struct ipv6hdr *ip6h;
> +
> +		if (unlikely(!pskb_may_pull(skb, sizeof(struct iphdr))))

	sizeof(struct ipv6hdr) or sizeof(*ip6h)

> +			return NULL;
> +
> +		ip6h = ipv6_hdr(skb);
> +		if (ip6h->version != 6)
> +			return NULL;
> +
> +		*type = IPVL_IPV6;
> +		lyr3h = ip6h;
> +		/* Only Neighbour Solicitation pkts need different treatment */
> +		if (ipv6_addr_any(&ip6h->saddr) &&
> +		    ip6h->nexthdr == NEXTHDR_ICMP) {
> +			/* Get to the ICMPv6 header */
> +			*type = IPVL_ICMPV6;
> +			lyr3h = ip6h + 1;
> +		}
> +		break;
> +	}
> +	default:
> +		return NULL;
> +	}
> +
> +	return lyr3h;
> +}

...
> +static int ipvlan_process_v6_outbound(struct sk_buff *skb)
> +{
> +	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
> +	struct net_device *dev = skb->dev;
> +	struct dst_entry *dst;
> +	int err, ret = NET_XMIT_DROP;
> +	struct flowi6 fl6 = {
> +		.flowi6_iif = skb->dev->ifindex,
> +		.daddr = ip6h->daddr,
> +		.saddr = ip6h->saddr,
> +		.flowi6_flags = FLOWI_FLAG_ANYSRC,
> +		.flowlabel = ip6_flowinfo(ip6h),
> +		.flowi6_mark = skb->mark,
> +		.flowi6_proto = ip6h->nexthdr,
> +	};
> +
> +	dst = ip6_route_output(dev_net(dev), NULL, &fl6);
> +	if (IS_ERR(dst)) {
> +		err = PTR_ERR(dst);
> +		dst = NULL;

dst = NULL; seems not needed.

> +		goto err;
> +	}
> +	skb_dst_drop(skb);
> +	skb_dst_set(skb, dst);
> +	err = ip6_local_out(skb);
> +	if (unlikely(net_xmit_eval(err)))
> +		dev->stats.tx_errors++;
> +	else
> +		ret = NET_XMIT_SUCCESS;
> +	goto out;
> +err:
> +	dev->stats.tx_errors++;
> +	kfree_skb(skb);
> +out:
> +	return ret;
> +}
...

> +static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
> +						 struct ipvl_port *port)
> +{
> +	struct sk_buff *skb = *pskb;
> +	struct ethhdr *eth = eth_hdr(skb);
> +	rx_handler_result_t ret = RX_HANDLER_PASS;
> +	void *lyr3h;
> +	int addr_type;
> +
> +	/* First Handle multi-cast frames */
> +	if (is_multicast_ether_addr(eth->h_dest)) {
> +		/* Pass to virtual devs only if they haven't seen the frame. */
> +		if (ipvlan_external_frame(skb, port)) {
> +			ipvlan_dbg(4, "%s[%d]L2:Mcast Recv:[%s], PROT=[%x]\n",
> +				   __func__, __LINE__, port->dev->name,
> +				   ntohs(skb->protocol));
> +			ipvlan_multicast_frame(port, skb, NULL, false);
> +		}
> +	} else if ((lyr3h = ipvlan_get_L3_hdr(skb, &addr_type)) != NULL) {
> +		struct ipvl_addr *addr = NULL;


= NULL; not needed.

> +
> +		addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
> +		if (addr) {
> +			ipvlan_dbg(4, "%s[%d]L2:Ucast Recv:[%s], PROT=[%x]\n",
> +				   __func__, __LINE__, addr->master->dev->name,
> +				   ntohs(skb->protocol));
> +			ret = ipvlan_rcv_frame(addr, skb, false);
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
> +{
> +	struct sk_buff *skb = *pskb;
> +	struct ipvl_port *port = ipvlan_port_get_rcu(skb->dev);
> +
> +	if (!port)
> +		goto out;
> +
> +	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))

This looks strange. 

Here we are sure ethernet header was already pulled by eth_type_trans()

> +		goto out;
> +
> +	switch (port->mode) {
> +	case IPVLAN_MODE_L2:
> +		return ipvlan_handle_mode_l2(pskb, port);
> +	case IPVLAN_MODE_L3:
> +		return ipvlan_handle_mode_l3(pskb, port);
> +	}
> +
> +	/* Should not reach here */
> +	BUG();
> +out:
> +	return RX_HANDLER_PASS;
> +}
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> new file mode 100644
> index 000000000000..e87b6eb01060
> --- /dev/null
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -0,0 +1,828 @@
> +/* Copyright (c) 2014 Mahesh Bandewar <maheshb@google.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of
> + * the License, or (at your option) any later version.
> + *
> + */
> +
> +
...

> +static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
> +{
> +	struct ipvl_addr *addr = NULL;
> +
> +	if (ipvlan_addr_busy(ipvlan, ip6_addr, true)) {
> +		pr_warn("%s[%d]: Failed IPv6=%x:%x:%x:%x address for %s intf\n",
> +			__func__, __LINE__, ip6_addr->s6_addr32[0],
> +			ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
> +			ip6_addr->s6_addr32[3], ipvlan->dev->name);
> +		return -EINVAL;
> +	}
> +	if ((addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC)) == NULL)

Why is GFP_ATOMIC used here ?

> +		return -ENOMEM;
> +
> +	ipvlan_dbg(1, "%s[%d]: Adding IPv6=%x:%x:%x:%x address for %s intf\n",
> +		   __func__, __LINE__, ip6_addr->s6_addr32[0],
> +		   ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
> +		   ip6_addr->s6_addr32[3], ipvlan->dev->name);
> +	addr->master = ipvlan;
> +	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
> +	addr->atype = IPVL_IPV6;
> +	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
> +	ipvlan->ipv6cnt++;
> +	ipvlan_ht_addr_add(ipvlan, addr);
> +
> +	return 0;
> +}
> +
> +static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
> +{
> +	struct ipvl_addr *addr = NULL;
> +
> +	if ((addr = ipvlan_ht_addr_lookup(ipvlan->port, ip6_addr, true)) ==NULL)
> +		return;
> +
> +	ipvlan_dbg(1,
> +		   "%s[%d]: Deleting IPv6=%x:%x:%x:%x address for %s intf.\n",
> +		   __func__, __LINE__, ip6_addr->s6_addr32[0],
> +		   ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
> +		   ip6_addr->s6_addr32[3], ipvlan->dev->name);
> +	/* Delete from the hash-table */
> +	ipvlan_ht_addr_del(addr, true);
> +	/* Delete from the logical's addr list */
> +	list_del_rcu(&addr->anode);
> +	ipvlan->ipv6cnt--;
> +	WARN_ON(ipvlan->ipv6cnt < 0);
> +	kfree_rcu(addr, rcu);
> +
> +	return;
> +}
> +
> +static int ipvlan_addr6_event(struct notifier_block *unused,
> +			      unsigned long event, void *ptr)
> +{
> +	struct inet6_ifaddr *if6 = (struct inet6_ifaddr *)ptr;
> +	struct net_device *dev = (struct net_device *)if6->idev->dev;
> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
> +
> +	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
> +	if (!ipvlan_dev_slave(dev))
> +		return NOTIFY_DONE;
> +
> +	if (!ipvlan || !ipvlan->port)
> +		return NOTIFY_DONE;
> +
> +	switch (event) {
> +	case NETDEV_UP:
> +		if (ipvlan_add_addr6(ipvlan, &if6->addr))
> +			return NOTIFY_BAD;
> +		break;
> +
> +	case NETDEV_DOWN:
> +		ipvlan_del_addr6(ipvlan, &if6->addr);
> +		break;
> +	}
> +
> +	ipvlan_dbg(3, "%s[%d]: Leaving...\n", __func__, __LINE__);
> +	return NOTIFY_OK;
> +}
> +
> +static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *ip4_addr)
> +{
> +	struct ipvl_addr *addr = NULL;
> +
> +	if (ipvlan_addr_busy(ipvlan, ip4_addr, false)) {
> +		pr_warn("%s[%d]: Failed to add IPv4=%x on %s intf.\n",
> +			__func__, __LINE__, ntohl(ip4_addr->s_addr),
> +			   ipvlan->dev->name);
> +		return -EINVAL;
> +	}
> +	if ((addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC)) == NULL)

Same issue here ? GFP_KERNEL should be OK.
