From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC net-next 2/3] VRF driver and needed infrastructure
Date: Wed, 10 Jun 2015 11:20:19 -0700
Message-ID: <55787FE3.5090300@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34940 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbbFJSUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 14:20:21 -0400
Received: by pacyx8 with SMTP id yx8so39656532pac.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 11:20:21 -0700 (PDT)
In-Reply-To: <dafc9b784df4cb52691f7dce0f280fc1b2b14532.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2015 11:35 AM, Shrijeet Mukherjee wrote:
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
>
> This driver borrows heavily from IPvlan and teaming drivers.
>
> Routing domains (VRF-lite) are created by instantiating a device
> and enslaving all routed interfaces that participate in the domain.
> As part of the enslavement, all local routes pointing to enslaved
> devices are re-pointed to the vrf device, thus forcing outgoing
> sockets to bind to the vrf to function.
>
> Standard FIB rules can then bind the VRF device to tables and regular
> fib rule processing is followed.
>
> Routed traffic through the box, is fwded by using the VRF device as
> the IIF and following the IIF rule to a table which is mated with
> the VRF.
>
> Locally originated traffic is directed at the VRF device using
> SO_BINDTODEVICE or cmsg headers. This in turn drops the packet into
> the xmit function of the vrf driver, which then completes the ip lookup
> and output.
>
> This solution is completely orthogonal to namespaces and allow the L3
> equivalent of vlans to exist allowing the routing space to be
> partitioned.
>
> Example use is
>     ip link add vrf0 type vrf table 5
>     ip link set eth1 master vrf0
>     ip link set vrf0 up
>
>     ip rule add iif vrf0 table 5
>     ip rule add oif vrf0 table 5
>
> TODO:
> This changeset is for IPv4 only
> Connected route management can be made much better, but is deferred to
> user space for now.
>
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> ---
>   drivers/net/Kconfig          |    6 +
>   drivers/net/Makefile         |    1 +
>   drivers/net/vrf.c            |  654 ++++++++++++++++++++++++++++++++++++++++++
>   include/linux/netdevice.h    |   10 +
>   include/net/flow.h           |    1 +
>   include/net/vrf.h            |   19 ++
>   include/uapi/linux/if_link.h |    9 +
>   7 files changed, 700 insertions(+)
>   create mode 100644 drivers/net/vrf.c
>   create mode 100644 include/net/vrf.h
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 019fcef..27a333c 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -283,6 +283,12 @@ config NLMON
>   	  diagnostics, etc. This is mostly intended for developers or support
>   	  to debug netlink issues. If unsure, say N.
>
> +config NET_VRF
> +	tristate "Virtual Routing and Forwarding (Lite)"
> +	---help---
> +          This option enables the support for mapping interfaces into VRF's. The
> +          support enables VRF devices
> +
>   endif # NET_CORE
>
>   config SUNGEM_PHY
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index c12cb22..ca16dd6 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -25,6 +25,7 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
>   obj-$(CONFIG_VXLAN) += vxlan.o
>   obj-$(CONFIG_GENEVE) += geneve.o
>   obj-$(CONFIG_NLMON) += nlmon.o
> +obj-$(CONFIG_NET_VRF) += vrf.o
>
>   #
>   # Networking Drivers
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> new file mode 100644
> index 0000000..08b3e79
> --- /dev/null
> +++ b/drivers/net/vrf.c
> @@ -0,0 +1,654 @@
> +/*
> + * vrf.c: device driver to encapsulate a VRF space
> + *
> + * Copyright (c) 2015 Cumulus Networks
> + *
> + * Based on dummy, team and ipvlan drivers
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/ip.h>
> +#include <linux/init.h>
> +#include <linux/moduleparam.h>
> +#include <linux/rtnetlink.h>
> +#include <net/rtnetlink.h>
> +#include <net/arp.h>
> +#include <linux/u64_stats_sync.h>
> +#include <linux/hashtable.h>
> +
> +#include <linux/inetdevice.h>
> +#include <net/ip.h>
> +#include <net/ip_fib.h>
> +#include <net/ip6_route.h>
> +#include <net/rtnetlink.h>
> +#include <net/route.h>
> +#include <net/addrconf.h>
> +#include <net/vrf.h>
> +
> +#define DRV_NAME	"vrf"
> +#define DRV_VERSION	"1.0"
> +
> +#define vrf_is_slave(dev)   ((dev->flags & IFF_SLAVE) == IFF_SLAVE)
> +#define vrf_is_master(dev)  ((dev->flags & IFF_MASTER) == IFF_MASTER)
> +
> +#define vrf_master_get_rcu(dev) \
> +	((struct net_device *)rcu_dereference(dev->rx_handler_data))
> +
> +struct pcpu_dstats {
> +	u64			tx_pkts;
> +	u64			tx_bytes;
> +	u64			tx_drps;
> +	u64			rx_pkts;
> +	u64			rx_bytes;
> +	struct u64_stats_sync	syncp;
> +};

Do you really need a new pcpu_dstats or could you just use 
pcpu_sw_netstats?  I'm just wondering if you are expecting to see that 
many Tx packets dropped.  If not you could probably just move that to 
the standard netdev stat instead.

> +struct slave {
> +	struct list_head	list;
> +	struct net_device	*dev;
> +	long			priority;
> +};
> +
> +struct slave_queue {
> +	spinlock_t		lock; /* lock for slave insert/delete */
> +	struct list_head	all_slaves;
> +	int			num_slaves;
> +	struct net_device	*master_dev;
> +};
> +
> +struct net_vrf {
> +	struct slave_queue	queue;
> +	struct fib_table        *tb;
> +	u32                     tb_id;
> +};
> +
> +static int is_ip_rx_frame(struct sk_buff *skb)
> +{
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +	case htons(ETH_P_IPV6):
> +		return 1;
> +	}
> +	return 0;
> +}
> +

This could probably be an inline to save you some function call 
overhead, but the compiler may already be taking care of it assuming it 
isn't doing anything stupid.

> +/* note: already called with rcu_read_lock */
> +static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
> +{
> +	struct sk_buff *skb = *pskb;
> +
> +	if (is_ip_rx_frame(skb)) {
> +		struct net_device *dev = vrf_master_get_rcu(skb->dev);
> +		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
> +
> +		u64_stats_update_begin(&dstats->syncp);
> +		dstats->rx_pkts++;
> +		dstats->rx_bytes += skb->len;
> +		u64_stats_update_end(&dstats->syncp);
> +	}
> +	return RX_HANDLER_PASS;
> +}
> +
> +static struct rtnl_link_stats64 *vrf_get_stats64(
> +	struct net_device *dev, struct rtnl_link_stats64 *stats)
> +{
> +	int i;
> +
> +	for_each_possible_cpu(i) {
> +		const struct pcpu_dstats *dstats;
> +		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
> +		unsigned int start;
> +
> +		dstats = per_cpu_ptr(dev->dstats, i);
> +		do {
> +			start = u64_stats_fetch_begin_irq(&dstats->syncp);
> +			tbytes = dstats->tx_bytes;
> +			tpkts = dstats->tx_pkts;
> +			tdrops = dstats->tx_drps;
> +			rbytes = dstats->rx_bytes;
> +			rpkts = dstats->rx_pkts;
> +		} while (u64_stats_fetch_retry_irq(&dstats->syncp, start));
> +		stats->tx_bytes += tbytes;
> +		stats->tx_packets += tpkts;
> +		stats->tx_dropped += tdrops;
> +		stats->rx_bytes += rbytes;
> +		stats->rx_packets += rpkts;
> +	}
> +	return stats;
> +}
> +
> +static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
> +					   struct net_device *dev)
> +{
> +	return 0;
> +}
> +
> +static int _vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
> +			     struct net_device *vrf_dev)
> +{
> +	struct rtable *rt;
> +	struct net_device *dev = skb->dev;
> +
> +	rt = ip_route_output_flow(dev_net(dev), fl4, NULL);
> +
> +	if (IS_ERR(rt))
> +		goto err;
> +
> +	if ((rt->rt_type != RTN_UNICAST && rt->rt_type != RTN_LOCAL) ||
> +	    !rt->dst.dev->vrf_ptr) {
> +		ip_rt_put(rt);
> +		goto err;
> +	}
> +
> +	/* prevent slave cross reference */
> +	if (rt->dst.dev->vrf_ptr->ifindex != vrf_dev->ifindex) {
> +		ip_rt_put(rt);
> +		goto err;
> +	}
> +
> +	skb_dst_drop(skb);
> +	skb_dst_set(skb, &rt->dst);
> +
> +	return 0;
> +err:
> +	return 1;
> +}
> +
> +static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
> +					   struct net_device *vrf_dev)
> +{
> +	struct iphdr *ip4h = ip_hdr(skb);
> +	int ret = NET_XMIT_DROP;
> +	struct net_device *dev = skb->dev;
> +	struct flowi4 fl4 = {
> +		/* needed to match OIF rule */
> +		.flowi4_oif = vrf_dev->ifindex,
> +		.flowi4_iif = LOOPBACK_IFINDEX,
> +		.flowi4_tos = RT_TOS(ip4h->tos),
> +		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC,
> +		.daddr = ip4h->daddr,
> +		.saddr = 0,
> +	};
> +
> +	if (_vrf_send_v4_prep(skb, &fl4, vrf_dev))
> +		goto err;
> +
> +	dev = skb_dst(skb)->dev;
> +	ip4h->saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
> +	ret = ip_local_out(skb);
> +
> +	if (unlikely(net_xmit_eval(ret)))
> +		vrf_dev->stats.tx_errors++;
> +	else
> +		ret = NET_XMIT_SUCCESS;
> +
> +	goto out;
> +err:
> +	vrf_dev->stats.tx_errors++;
> +	kfree_skb(skb);
> +out:
> +	return ret;
> +}
> +
> +static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
> +{
> +	/* the frames we recv have full L2 headers, strip */
> +	if (skb_mac_header_was_set(skb)) {
> +		skb_pull(skb, sizeof(struct ethhdr));
> +		skb->mac_header = (typeof(skb->mac_header))~0U;
> +		skb_reset_network_header(skb);
> +	}
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +		return vrf_process_v4_outbound(skb, dev);
> +	case htons(ETH_P_IPV6):
> +		return vrf_process_v6_outbound(skb, dev);
> +	default:
> +		return NET_XMIT_DROP;
> +	}
> +}
> +
> +static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	netdev_tx_t ret = is_ip_tx_frame(skb, dev);
> +
> +	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
> +		struct pcpu_dstats *dstats = this_cpu_ptr(dev->dstats);
> +
> +		u64_stats_update_begin(&dstats->syncp);
> +		dstats->tx_pkts++;
> +		dstats->tx_bytes += skb->len;
> +		u64_stats_update_end(&dstats->syncp);
> +	} else {
> +		this_cpu_inc(dev->dstats->tx_drps);
> +	}
> +
> +	return ret;
> +}
> +

So if vrf_dev->stats.tx_errors is incremented already in this path, why 
not just use the dev->stats.tx_dropped instead of the pcpu stat?

> +int vrf_output(struct sock *sk, struct sk_buff *skb)
> +{
> +	struct net_device *dev = skb_dst(skb)->dev;
> +
> +	return vrf_xmit(skb, dev);
> +}
> +
> +/**************************** device handling ********************/
> +
> +/* queue->lock must be held */
> +static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
> +					  struct net_device *dev)
> +{
> +	struct list_head *this, *head;
> +
> +	head = &queue->all_slaves;
> +	list_for_each(this, head) {
> +		struct slave *slave = list_entry(this, struct slave, list);
> +
> +		if (slave->dev == dev)
> +			return slave;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void vrf_kill_one_slave(struct slave_queue *queue, struct slave *slave)
> +{
> +	list_del(&slave->list);
> +	queue->num_slaves--;
> +	slave->dev->flags &= ~IFF_SLAVE;
> +	netdev_rx_handler_unregister(slave->dev);
> +	kfree(slave->dev->vrf_ptr);
> +	slave->dev->vrf_ptr = NULL;
> +	dev_put(slave->dev);
> +	kfree(slave);
> +}
> +
> +/* queue->lock must be held */
> +static int __vrf_insert_slave(struct slave_queue *queue, struct slave *slave,
> +			      struct net_device *master)
> +{
> +	struct net_vrf *vrf = netdev_priv(master);
> +	struct slave *duplicate_slave = NULL;
> +	int master_ifindex = master->ifindex;
> +	int err = 0;
> +
> +	duplicate_slave = __vrf_find_slave_dev(queue, slave->dev);
> +	if (duplicate_slave)
> +		vrf_kill_one_slave(queue, duplicate_slave);
> +
> +	dev_hold(slave->dev);
> +	list_add(&slave->list, &queue->all_slaves);
> +	queue->num_slaves++;
> +	slave->dev->flags |= IFF_SLAVE;
> +
> +	slave->dev->vrf_ptr = kmalloc(sizeof(*slave->dev->vrf_ptr), GFP_KERNEL);
> +	if (!slave->dev->vrf_ptr)
> +		return -ENODEV;
> +	slave->dev->vrf_ptr->ifindex = master_ifindex;
> +	slave->dev->vrf_ptr->tb_id = vrf->tb_id;
> +
> +	/* register the packet handler for slave ports */
> +	err = netdev_rx_handler_register(slave->dev, vrf_handle_frame,
> +					 (void *)master);
> +	if (err) {
> +		netdev_err(slave->dev,
> +			   "Device %s failed to register rx_handler\n",
> +			   slave->dev->name);
> +		return err;
> +	}
> +
> +	return 0;
> +}
> +
> +static void vrf_fib_magic(int cmd, int type, __be32 dst, int dst_len,
> +			  struct in_ifaddr *ifa, struct net_device *vrf_dev)
> +{
> +	struct net_vrf *vrf = netdev_priv(vrf_dev);
> +	struct net *net = dev_net(ifa->ifa_dev->dev);
> +	struct net *vrf_net = dev_net(vrf_dev);
> +	struct fib_table *tb, *lc_tb;
> +	struct fib_config cfg = {
> +		.fc_protocol = RTPROT_KERNEL,
> +		.fc_type = type,
> +		.fc_dst = dst,
> +		.fc_dst_len = dst_len,
> +		.fc_prefsrc = ifa->ifa_local,
> +		.fc_nlflags = NLM_F_CREATE | NLM_F_APPEND,
> +		.fc_nlinfo = {
> +			.nl_net = net,
> +		},
> +	};
> +
> +	lc_tb = fib_new_table(dev_net(vrf_dev), RT_TABLE_LOCAL);
> +	tb = vrf->tb;
> +	if (!tb || !lc_tb)
> +		return;
> +

Depending on which way you are going you should be calling fib_get_table 
on the table that is about to have the rule stolen, and fib_new_table on 
the table that is about to have a rule inserted.  Generally you don't 
want to call fib_new_table unless you are actually inserting a route.

Also you should probably just store the table ID instead of the table 
pointer itself.

> +	if (net != vrf_net)
> +		return;
> +
> +	if (type != RTN_LOCAL)
> +		cfg.fc_scope = RT_SCOPE_LINK;
> +	else
> +		cfg.fc_scope = RT_SCOPE_HOST;
> +
> +	if (cmd == RTM_NEWROUTE) {
> +		cfg.fc_table = lc_tb->tb_id;
> +		cfg.fc_oif = ifa->ifa_dev->dev->ifindex;
> +		fib_table_delete(lc_tb, &cfg);
> +		cfg.fc_table = tb->tb_id;
> +		cfg.fc_oif = vrf_dev->ifindex;
> +		fib_table_insert(tb, &cfg);
> +	} else {
> +		cfg.fc_table = tb->tb_id;
> +		cfg.fc_oif = vrf_dev->ifindex;
> +		fib_table_delete(tb, &cfg);
> +		cfg.fc_table = lc_tb->tb_id;
> +		cfg.fc_oif = ifa->ifa_dev->dev->ifindex;
> +		fib_table_insert(lc_tb, &cfg);
> +	}
> +}
> +
> +static void vrf_move_local_routes(int cmd, struct net_device *dev,
> +				  struct net_device *port_dev)
> +{
> +	struct in_device *in_dev = __in_dev_get_rcu(port_dev);
> +
> +	if (!in_dev)
> +		return;
> +
> +	for_ifa(in_dev) {
> +		__be32 addr;
> +
> +		addr = ifa->ifa_local;
> +		vrf_fib_magic(cmd, RTN_LOCAL, addr, 32, ifa, dev);
> +	} endfor_ifa(in_dev);
> +}
> +
> +static int vrf_inetaddr_event(struct notifier_block *this, unsigned long event,
> +			      void *ptr)
> +{
> +	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
> +	struct net_device *port_dev = ifa->ifa_dev->dev;
> +	struct net *net = dev_net(port_dev);
> +	int master = 0;
> +
> +	if (port_dev->vrf_ptr)
> +		master = port_dev->vrf_ptr->ifindex;
> +
> +	if (master) {
> +		struct net_device *dev = dev_get_by_index(net, master);
> +
> +		switch (event) {
> +		case NETDEV_UP:
> +			vrf_move_local_routes(RTM_NEWROUTE, dev, port_dev);
> +			break;
> +		case NETDEV_DOWN:
> +			vrf_move_local_routes(RTM_DELROUTE, dev, port_dev);
> +			break;
> +		}
> +	}
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block vrf_inetaddr_notifier = {
> +	.notifier_call = vrf_inetaddr_event,
> +};
> +
> +/* netlink lock is assumed here */
> +static int vrf_add_slave(struct net_device *dev,
> +			 struct net_device *port_dev)
> +{
> +	if (!dev || !port_dev)
> +		return -ENODEV;
> +
> +	if (dev_net(dev) != dev_net(port_dev))
> +		return -ENODEV;
> +
> +	if (!vrf_is_master(port_dev) && !vrf_is_slave(port_dev)) {
> +		struct slave *s = kmalloc(sizeof(*s), GFP_KERNEL);
> +		struct net_vrf *vrf = netdev_priv(dev);
> +		int ret;
> +
> +		if (!s)
> +			return -ENOMEM;
> +
> +		memset(s, 0, sizeof(*s));
> +		s->dev = port_dev;
> +
> +		spin_lock_bh(&vrf->queue.lock);
> +		ret = __vrf_insert_slave(&vrf->queue, s, dev);
> +		if (ret)
> +			kfree(s);
> +
> +		spin_unlock_bh(&vrf->queue.lock);
> +
> +		vrf_move_local_routes(RTM_NEWROUTE, dev, port_dev);
> +		ret = netdev_master_upper_dev_link(port_dev, dev);
> +		return ret;
> +	}
> +
> +	return -EINVAL;
> +}
> +
> +static int vrf_del_slave(struct net_device *dev,
> +			 struct net_device *port_dev)
> +{
> +	struct net_vrf *vrf = netdev_priv(dev);
> +	struct slave_queue *queue = &vrf->queue;
> +	struct slave *slave = __vrf_find_slave_dev(queue, port_dev);
> +
> +	if (!slave)
> +		return -EINVAL;
> +
> +	vrf_kill_one_slave(queue, slave);
> +	vrf_move_local_routes(RTM_DELROUTE, dev, port_dev);
> +	netdev_upper_dev_unlink(port_dev, dev);
> +
> +	return 0;
> +}
> +
> +static int vrf_dev_init(struct net_device *dev)
> +{
> +	struct net_vrf *vrf = netdev_priv(dev);
> +
> +	spin_lock_init(&vrf->queue.lock);
> +	INIT_LIST_HEAD(&vrf->queue.all_slaves);
> +	vrf->queue.master_dev = dev;
> +
> +	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
> +	dev->flags  =  IFF_MASTER | IFF_NOARP;
> +	if (!dev->dstats)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void vrf_dev_uninit(struct net_device *dev)
> +{
> +	free_percpu(dev->dstats);
> +}
> +
> +static int vrf_dev_close(struct net_device *dev)
> +{
> +	struct net_vrf *vrf = netdev_priv(dev);
> +	struct slave_queue *queue = &vrf->queue;
> +	struct list_head *this, *head;
> +
> +	head = &queue->all_slaves;
> +	list_for_each(this, head) {
> +		struct slave *slave = list_entry(this, struct slave, list);
> +
> +		slave->dev->vrf_ptr->ifindex = 0;
> +		slave->dev->vrf_ptr->tb_id = 0;
> +	}
> +
> +	if (dev->flags & IFF_MASTER)
> +		dev->flags &= ~IFF_UP;
> +/* XXX does the table not need a free
> + * fib_table_delete(vrf->tb, cfg);
> + */
> +	return 0;
> +}
> +

The call would probably be fib_free_table, not fib_table_delete since 
delete drops a rule as I recall.  I believe the behavior is to leave the 
table there once it is created.  It will be empty, but I don't believe 
there is much that actually frees the tables themsleves other than 
unloading the network namespace.

> +static int vrf_dev_open(struct net_device *dev)
> +{
> +	struct net_vrf *vrf = netdev_priv(dev);
> +	struct slave_queue *queue = &vrf->queue;
> +	struct list_head *this, *head;
> +	int err = 0;
> +
> +	head = &queue->all_slaves;
> +	list_for_each(this, head) {
> +		struct slave *slave = list_entry(this, struct slave, list);
> +
> +		slave->dev->vrf_ptr->ifindex = dev->ifindex;
> +		slave->dev->vrf_ptr->tb_id = vrf->tb_id;
> +	}
> +
> +	if (dev->flags & IFF_MASTER)
> +		dev->flags |= IFF_UP;
> +
> +	if (!vrf->tb)
> +		return -EINVAL;
> +
> +	return err;
> +}
> +
> +static int vrf_neigh_create(struct neighbour *n)
> +{
> +	n->nud_state = NUD_REACHABLE;
> +	n->dead      = 0;
> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops vrf_netdev_ops = {
> +	.ndo_init		= vrf_dev_init,
> +	.ndo_uninit		= vrf_dev_uninit,
> +	.ndo_open		= vrf_dev_open,
> +	.ndo_stop               = vrf_dev_close,
> +	.ndo_start_xmit		= vrf_xmit,
> +	.ndo_get_stats64	= vrf_get_stats64,
> +	.ndo_add_slave          = vrf_add_slave,
> +	.ndo_del_slave          = vrf_del_slave,
> +	.ndo_neigh_construct    = vrf_neigh_create,
> +};
> +
> +static void vrf_get_drvinfo(struct net_device *dev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
> +	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> +}
> +
> +static const struct ethtool_ops vrf_ethtool_ops = {
> +	.get_drvinfo            = vrf_get_drvinfo,
> +};
> +
> +static void vrf_setup(struct net_device *dev)
> +{
> +	ether_setup(dev);
> +
> +	/* Initialize the device structure. */
> +	dev->netdev_ops = &vrf_netdev_ops;
> +	dev->ethtool_ops = &vrf_ethtool_ops;
> +	dev->destructor = free_netdev;
> +
> +	/* Fill in device structure with ethernet-generic values. */
> +	dev->tx_queue_len = 0;
> +	eth_hw_addr_random(dev);
> +}
> +
> +static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
> +{
> +	if (tb[IFLA_ADDRESS]) {
> +		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
> +			return -EINVAL;
> +		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
> +			return -EADDRNOTAVAIL;
> +	}
> +	return 0;
> +}
> +
> +static int vrf_newlink(struct net *src_net, struct net_device *dev,
> +		       struct nlattr *tb[], struct nlattr *data[])
> +{
> +	int err;
> +	struct net_vrf *vrf = netdev_priv(dev);
> +
> +	if (data && data[IFLA_VRF_TABLE]) {
> +		vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
> +		/* reserve a table for this VRF device */
> +		vrf->tb = fib_new_table(dev_net(dev), vrf->tb_id);
> +		if (!vrf->tb)
> +			return -ERANGE;
> +
> +		dev->priv_flags |= IFF_VRF_MASTER;
> +		err = register_netdevice(dev);
> +		if (err) {
> +			free_netdev(dev);
> +			return -ENODEV;
> +		}
> +	}
> +	return 0;
> +}
> +

You probably don't need to create the new table here.  This can wait 
until the first new route is added to the table.

> +static void vrf_dellink(struct net_device *dev, struct list_head *head)
> +{
> +	/* Need to free the table ? */
> +	unregister_netdev(dev);
> +}
> +
> +static const struct nla_policy vrf_nl_policy[IFLA_VRF_MAX + 1] = {
> +	[IFLA_VRF_TABLE] = { .type = NLA_U32 },
> +};
> +
> +static struct rtnl_link_ops vrf_link_ops __read_mostly = {
> +	.kind		= DRV_NAME,
> +	.priv_size      = sizeof(struct net_vrf),
> +	.policy         = vrf_nl_policy,
> +	.newlink        = vrf_newlink,
> +	.dellink        = vrf_dellink,
> +	.setup		= vrf_setup,
> +	.validate	= vrf_validate,
> +	.maxtype        = IFLA_VRF_MAX,
> +};
> +
> +static int __init vrf_init_module(void)
> +{
> +	int err = 0;
> +
> +	rtnl_lock();
> +	err = __rtnl_link_register(&vrf_link_ops);
> +	if (err < 0)
> +		goto out;
> +
> +	register_inetaddr_notifier(&vrf_inetaddr_notifier);
> +
> +out:
> +	rtnl_unlock();
> +	return err;
> +}
> +
> +static void __exit vrf_cleanup_module(void)
> +{
> +	unregister_inetaddr_notifier(&vrf_inetaddr_notifier);
> +	rtnl_link_unregister(&vrf_link_ops);
> +}
> +
> +module_init(vrf_init_module);
> +module_exit(vrf_cleanup_module);
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS_RTNL_LINK(DRV_NAME);
> +MODULE_VERSION(DRV_VERSION);
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 51f8d2f..29febf3 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -51,6 +51,7 @@
>   #include <linux/neighbour.h>
>   #include <uapi/linux/netdevice.h>
>   #include <uapi/linux/if_bonding.h>
> +#include <net/vrf.h>
>
>   struct netpoll_info;
>   struct device;
> @@ -1270,6 +1271,7 @@ enum netdev_priv_flags {
>   	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
>   	IFF_IPVLAN_MASTER		= 1<<23,
>   	IFF_IPVLAN_SLAVE		= 1<<24,
> +	IFF_VRF_MASTER		        = 1<<25,
>   };
>
>   #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
> @@ -1297,6 +1299,7 @@ enum netdev_priv_flags {
>   #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
>   #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
>   #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
> +#define IFF_VRF_MASTER		        IFF_VRF_MASTER
>
>   /**
>    *	struct net_device - The DEVICE structure.
> @@ -1413,6 +1416,7 @@ enum netdev_priv_flags {
>    *	@dn_ptr:	DECnet specific data
>    *	@ip6_ptr:	IPv6 specific data
>    *	@ax25_ptr:	AX.25 specific data
> + *	@vrf_ptr:	VRF specific data
>    *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
>    *
>    *	@last_rx:	Time of last Rx
> @@ -1625,6 +1629,7 @@ struct net_device {
>   	struct dn_dev __rcu     *dn_ptr;
>   	struct inet6_dev __rcu	*ip6_ptr;
>   	void			*ax25_ptr;
> +	struct net_vrf_dev      *vrf_ptr;
>   	struct wireless_dev	*ieee80211_ptr;
>   	struct wpan_dev		*ieee802154_ptr;
>   #if IS_ENABLED(CONFIG_MPLS_ROUTING)
> @@ -3776,6 +3781,11 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
>   	return dev->priv_flags & IFF_SUPP_NOFCS;
>   }
>
> +static inline bool netif_is_vrf(struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_VRF_MASTER;
> +}
> +
>   /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
>   static inline void netif_keep_dst(struct net_device *dev)
>   {
> diff --git a/include/net/flow.h b/include/net/flow.h
> index 8109a15..69aaa99 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -29,6 +29,7 @@ struct flowi_common {
>   	__u8	flowic_flags;
>   #define FLOWI_FLAG_ANYSRC		0x01
>   #define FLOWI_FLAG_KNOWN_NH		0x02
> +#define FLOWI_FLAG_VRFSRC		0x04
>   	__u32	flowic_secid;
>   };
>
> diff --git a/include/net/vrf.h b/include/net/vrf.h
> new file mode 100644
> index 0000000..11d7dbf8
> --- /dev/null
> +++ b/include/net/vrf.h
> @@ -0,0 +1,19 @@
> +/*
> + * include/net/net_vrf.h - adds vrf dev structure definitions
> + * Copyright (c) 2015 Cumulus Networks
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef __LINUX_NET_VRF_H
> +#define __LINUX_NET_VRF_H
> +
> +struct net_vrf_dev {
> +	int                     ifindex; /* ifindex of master dev */
> +	u32                     tb_id;
> +};
> +
> +#endif /* __LINUX_NET_VRF_H */
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index afccc93..b98a443 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -339,6 +339,15 @@ enum macvlan_macaddr_mode {
>
>   #define MACVLAN_FLAG_NOPROMISC	1
>
> +/* VRF section */
> +enum {
> +	IFLA_VRF_UNSPEC,
> +	IFLA_VRF_TABLE,
> +	__IFLA_VRF_MAX
> +};
> +
> +#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
> +
>   /* IPVLAN section */
>   enum {
>   	IFLA_IPVLAN_UNSPEC,
>
