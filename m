From: Joe Perches <joe@perches.com>
Subject: Re: [RFC v2 1/2] net/hsr: Add support for IEC 62439-3
 High-availability Seamless Redundancy
Date: Tue, 03 Jul 2012 17:30:24 -0700
Message-ID: <1341361824.1993.16.camel@joe2Laptop>
References: <4FF38A5C.9000802@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Javier Boticario <jboticario@gmail.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38179 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751754Ab2GDAaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 20:30:25 -0400
In-Reply-To: <4FF38A5C.9000802@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-04 at 00:12 +0000, Arvid Brodin wrote:
> The kernel patch.

[]

> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c

> @@ -0,0 +1,531 @@

> +static int is_admin_up(struct net_device *dev)
> +{
> +	return (dev->flags & IFF_UP);
> +}
> +
> +static int is_operstate_up(struct net_device *dev)
> +{
> +	return (dev->operstate == IF_OPER_UP);
> +}

bool?

> +static void __hsr_set_operstate(struct net_device *dev, int transition)
> +{
> +	if (dev->operstate != transition) {
> +/*
> +		switch (transition) {
> +		case IF_OPER_UP:
> +			printk(KERN_INFO "%s: new operstate is IF_OPER_UP\n", dev->name);

	netdev_info(dev, "new operstate is IF_OPER_UP\n");

> +			break;
> +		default:
> +			printk(KERN_INFO "%s: new operstate is !IF_OPER_UP (%d)\n", dev->name, transition);

etc.

> +void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *slave1,
> +						struct net_device *slave2)
> +{
> +	if (!is_admin_up(hsr_dev)) {
> +		__hsr_set_operstate(hsr_dev, IF_OPER_DOWN);
> +		return;
> +	}
> +/*
> +	printk(KERN_INFO "Slave1/2 operstate: %d/%d\n",
> +					slave1->operstate, slave2->operstate);
> +*/

Please remove commented out code.

> +static void restore_slaves(struct net_device *hsr_dev)
> +{
> +	struct hsr_priv *hsr_priv;
> +	struct net_device *slave[2];
> +	int i;
> +	int res;
> +
> +	hsr_priv = netdev_priv(hsr_dev);
> +	for (i = 0; i < 2; i++)
> +		slave[i] = hsr_priv->slave_data[i].dev;
> +
> +	rtnl_lock();
> +
> +	/* Restore promiscuity */
> +	for (i = 0; i < 2; i++) {
> +		if (!hsr_priv->slave_data[i].promisc)
> +			continue;
> +		res = dev_set_promiscuity(slave[i],
> +					-hsr_priv->slave_data[i].promisc);
> +		if (res)
> +			pr_info("HSR: Cannot restore promiscuity (%s, %d)\n",
> +							slave[i]->name,
> +							res);

shouldn't this just be:

			netdev_info(slave[i], "cannot restore promiscuity: %d\n",
				    res);

If you must use pr_<level> please add
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before any include and let the printk subsystem
add MODNAME as a prefix.


> +static int check_slave_ok(struct net_device *dev)
> +{
> +	/* Don't allow HSR on non-ethernet like devices */
> +	if ((dev->flags & IFF_LOOPBACK) || (dev->type != ARPHRD_ETHER) ||
> +						(dev->addr_len != ETH_ALEN)) {
> +		pr_info("%s: Cannot enslave loopback or non-ethernet device\n",
> +								dev->name);

		netdev_info(dev, "Cannot enslave...");

> +		return -EINVAL;
> +	}
> +
> +	/* Don't allow enslaving hsr devices */
> +	if (is_hsr_master(dev)) {
> +		pr_info("%s: Don't try to create trees of hsr devices!\n",
> +								dev->name);


		netdev_err(dev, "Cannot create trees of hsr devices\n");


> +int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2])
> +{

> +	/* Set hsr_dev's MAC address to that of mac_slave1 */
> +	memcpy(hsr_dev->dev_addr, hsr_priv->slave_data[0].dev->dev_addr,
> +							hsr_dev->addr_len);

ETH_ALEN?

> diff --git a/net/hsr/hsr_device.h b/net/hsr/hsr_device.h
[]
> @@ -0,0 +1,27 @@

> +void hsr_dev_setup(struct net_device *dev);
> +int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2]);
> +void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *slave1,
> +						struct net_device *slave2);

please align arguments immediately after the open parenthesis.

> diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
[]
> +static struct node_entry *find_node_by_AddrA(struct list_head *node_db,
> +						unsigned char addr[ETH_ALEN])

static struct node_entry *find_node_by_AddrA(struct list_head *node_db,
					     unsigned char addr[ETH_ALEN])
[]
> +static struct node_entry *find_node_by_AddrB(struct list_head *node_db,
> +						unsigned char addr[ETH_ALEN])

Alignment...

> +int framereg_merge_node(struct hsr_priv *hsr_priv, enum hsr_dev_idx dev_idx,
> +							struct sk_buff *skb)
> +{
[]
> +	node = find_node_by_AddrA(&hsr_priv->node_db, hsr_stag->MacAddressA);
> +	if (!node) {
> +		rcu_read_unlock();
> +		found = 0;
> +		node = kmalloc(sizeof(*node), GFP_ATOMIC);

why GFP_ATOMIC?

> +		if (!node)
> +			return -ENOMEM;
> +
> +		memcpy(node->MacAddressA, hsr_stag->MacAddressA, ETH_ALEN);
> +		memcpy(node->MacAddressB, ethhdr->h_source, ETH_ALEN);
> +
> +		for (i = 0; i < HSR_MAX_SLAVE; i++)
> +			node->time_in[i] = 0;
> +		for (i = 0; i < HSR_MAX_DEV; i++)
> +			node->seq_out[i] = 0;
> +/*
> +		printk(KERN_INFO "HSR: Added node %pM / %pM\n",
> +							node->MacAddressA,
> +							node->MacAddressB);
> +*/

Please remove commented out code here and everywhere else...

[too long, stopped reading]
