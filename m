From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Sun, 23 Nov 2014 21:00:07 -0500 (EST)
Message-ID: <20141123.210007.430908731772563207.davem@davemloft.net>
References: <1416791954-6445-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maze@google.com,
	chavey@google.com, thockin@google.com, brandon.philips@coreos.com,
	xemul@parallels.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaKXCAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 21:00:11 -0500
In-Reply-To: <1416791954-6445-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sun, 23 Nov 2014 17:19:14 -0800

> +static u8 ipvlan_get_v4_hash(const void *iaddr)
> +{
> +	const struct in_addr *ip4_addr = iaddr;
> +	return jhash_1word(ip4_addr->s_addr, ipvlan_jhash_secret) &
> +	       IPVLAN_HASH_MASK;

Please put an empty line between variable declarations and code.

> +unsigned int ipvlan_mac_hash(const unsigned char *addr)
> +{
> +	u32 hash = jhash_1word(__get_unaligned_cpu32(addr+2),
> +			       ipvlan_jhash_secret);
> +	return hash & IPVLAN_MAC_FILTER_MASK;
> +}

Likewise.

> +	} else if (addr_type == IPVL_ICMPV6) {
> +		struct nd_msg *ndmh;
> +		struct in6_addr *i6addr;
> +		ndmh = (struct nd_msg *)lyr3h;

Likewise.
> +	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
> +		netif_dbg(ipvlan, pktdata, dev,
> +			  "Comm betn 2 virt devs PROT=%x\n",
> +			  ntohs(skb->protocol));
> +		if ((lyr3h = ipvlan_get_L3_hdr(skb, &addr_type)) == NULL)
> +			goto to_default;

Please don't mix assignments and if() statement tests, put the
assignment by itself first, then test the variable.

Althought I'm not fundamentally against goto statements, it
doesn't help in any way here, and this code reads must easier
as:

		if (lyr3h) {
			addr = ipvlan_addr_lookup(...);
			if (addr)
				return ipvlan_rcv_frame(...);
		}

> +		/* No matching ipvlan dev! Must be on the Physical device */
> +to_default:

And then this label and even the comment above it can just be
deleted.

> +	} else if (is_multicast_ether_addr(eth->h_dest)) {
> +		u8 ip_summed = skb->ip_summed;
> +		/* Packet needs to be multicast-ed. */
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;

Empty line between variable declarations and code, please.

And I think because we're testing against a mutlicast address,
you don't have to explicitly state that this is "the multicast
code path."

Use comments when it truly adds information, rather than basically
restating what the code is already explicitly saying to the reader.

Most of your comments in this driver just recap the code statements
in one way or another.

> +int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	struct ipvl_port *port = ipvlan_port_get_rcu(ipvlan->phy_dev);
> +
> +	if (!port)
> +		goto out;
> +
> +	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
> +		goto out;
> +
> +	switch(port->mode) {
> +	case IPVLAN_MODE_L2:
> +		return ipvlan_xmit_mode_l2(skb, dev);
> +	case IPVLAN_MODE_L3:
> +		return ipvlan_xmit_mode_l3(skb, dev);
> +	}
> +
> +	/* Should not reach here */
> +	BUG();

Only use BUG statements when the kernel cannot continue operating
safely.  Just because your own personal assertion is violated doesn't
mean the whole machine needs to be taken down.

Free the packet and emit a log message (perhaps with WARN()).

> +		if ((lyr3h = ipvlan_get_L3_hdr(skb, &addr_type)) == NULL)
> +			return true;

Change this to:

		lyr3h = ipvlan_get_L3_hdr(...);
		if (!lyr3h)
			return true;

> +rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
> +{
> +	struct sk_buff *skb = *pskb;
> +	struct ipvl_port *port = ipvlan_port_get_rcu(skb->dev);
> +
> +	if (!port)
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

Again, use WARN() not BUG().

> +	if ((port = kzalloc(sizeof(struct ipvl_port), GFP_KERNEL)) == NULL)
> +		return -ENOMEM;

Change this to:

	port = kzalloc(sizeof(struct ipvl_port), GFP_KERNEL);
	if (!port)
		return -ENOMEM;

> +		list_for_each_entry(addr, &ipvlan->addrs, anode) {
> +			ipvlan_ht_addr_add(ipvlan, addr);
> +		}

Single line basic blocks do not require enclosing braces, please
remove them.

> +		list_for_each_entry(addr, &ipvlan->addrs, anode) {
> +			ipvlan_ht_addr_del(addr, !dev->dismantle);
> +		}

Likewise.

> +	struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	return features & (ipvlan->sfeatures | ~IPVLAN_FEATURES);

Empty line between local variable declarations and code.

> +	if (set && !test_bit(hashbit, ipvlan->mac_filters)) {
> +		/* Set broadcast hash-bit (for IPv4) */
> +		__set_bit(hashbit, ipvlan->mac_filters);
> +	} else if (!set && test_bit(hashbit, ipvlan->mac_filters)) {
> +		/* Reset broadcast hash-bit */
> +		__clear_bit(hashbit, ipvlan->mac_filters);
> +	}

Comments are just restating the code, remove them.  And then these
basic blocks are single line and thus you can remove all of the
braces as well.

> +		netdev_for_each_mc_addr(ha, dev) {
> +			__set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
> +		}

Single line basic block, toss the curly braces.

> +			} while(u64_stats_fetch_retry_irq(&pcptr->syncp, strt));

Space needed between 'while' and the openning parenthesis.

> +	const struct ipvl_dev *ipvlan = netdev_priv(dev);
> +	return __ethtool_get_settings(ipvlan->phy_dev, cmd);

Empty line between variable declarations and code.

> +	if (data && data[IFLA_IPVLAN_MODE]) {
> +		u16 nmode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
> +		ipvlan_set_port_mode(port, nmode);
> +	}

Likewise.

> +		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
> +			ipvlan_adjust_mtu(ipvlan, dev);
> +		}

Single line basic block doesn't need curly braces, please remove.

> +	if ((addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC)) == NULL)
> +		return -ENOMEM;

Change this to:

	addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC);
	if (!addr)
		return -ENOMEM;

> +	if ((addr = ipvlan_ht_addr_lookup(ipvlan->port, ip6_addr, true)) ==NULL)
> +		return;

Same kind of transformation needed here.

> +	/* Delete from the hash-table */
> +	ipvlan_ht_addr_del(addr, true);

Comment just restates the code, remove.

> +	/* Delete from the logical's addr list */
> +	list_del_rcu(&addr->anode);

Likewise.

> +	if ((addr= ipvlan_ht_addr_lookup(ipvlan->port, ip4_addr, false)) ==NULL)
> +		return;

This really looks terrible, bad spacing and combining an assignment
with an if() test.  After reading the rest of my feedback above you
should know what to do with this.

Finally, please think seriously about all of your *_dbg() logging in
this driver.  Does it really have true value after initial driver
development and debug?  They take up a significant amount of lines
in the driver, and make it seem bigger than it really is.

Thanks.
