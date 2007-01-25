From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 31/31] net: Add etun driver
Date: Thu, 25 Jan 2007 13:25:07 -0700
Message-ID: <m1mz46yhuk.fsf@ebiederm.dsl.xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
	<11697516404048-git-send-email-ebiederm@xmission.com>
	<45B9094C.3030902@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48411 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030553AbXAYUZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 15:25:25 -0500
In-Reply-To: <45B9094C.3030902@candelatech.com> (Ben Greear's message of "Thu,
	25 Jan 2007 11:47:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Eric W. Biederman wrote:
>> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
>>
>> etun is a simple two headed tunnel driver that at the link layer
>> looks like ethernet.  It's target audience is communicating
>> between network namespaces but it is general enough it may
>> have other uses as well.
>>
>
> This looks almost identical to my redir-dev module.  Which is
> fine..I don't really care which gets into the kernel so long as
> one of them does...
>
> Comments and questions are inline below.

If is I don't really care much either.

>> +/*
>> + * The higher levels take care of making this non-reentrant (it's
>> + * called with bh's disabled).
>> + */
>> +static int etun_xmit(struct sk_buff *skb, struct net_device *tx_dev)
>> +{
>> +	struct etun_info *tx_info = tx_dev->priv;
>> +	struct net_device *rx_dev = tx_info->rx_dev;
>> +	struct etun_info *rx_info = rx_dev->priv;
>> +
>> +	tx_info->stats.tx_packets++;
>> +	tx_info->stats.tx_bytes += skb->len;
>> +
>> +	/* Drop the skb state that was needed to get here */
>> +	skb_orphan(skb);
>> +	if (skb->dst)
>> +		skb->dst = dst_pop(skb->dst);	/* Allow for smart routing */
>
> I ended up setting dst to NULL.  What does the dst_pop() accomplish?

It allows an ambitious routing program to realize all of the routing
is on one machine and compute a route through multiple network
stack traversals.

I don't know it every makes sense to really use that but since
in the normal case this just sets dst to NULL.  I figured I would
leave it in, in case that ever looks useful.

>> +	
>> +	/* Switch to the receiving device */
>> +	skb->pkt_type = PACKET_HOST;
>> +	skb->protocol = eth_type_trans(skb, rx_dev);
>> +	skb->dev = rx_dev;
>> +	skb->ip_summed = CHECKSUM_NONE;
>> +
>> +	/* If both halves agree no checksum is needed */
>> +	if (tx_dev->features & NETIF_F_NO_CSUM)
>> +		skb->ip_summed = rx_info->ip_summed;
>> +
>> +	rx_dev->last_rx = jiffies;
>
> Do you need to set tx_dev->trans_start to jiffies as well?

Could be.  I haven't had any problems with it but I may have missed
a trick or two.
 			
>> +	rx_info->stats.rx_packets++;
>> +	rx_info->stats.rx_bytes += skb->len;
>
> I think you need to zero out the skb->tstamp as well.  This lets it
> be re-calculated when the receive logic of the other device is called.
>
> Otherwise this fails:
>
> rx skb on eth1, delay skb for network emulation, bridge onto etun0, rx on etun1
> (time-stamp is still what it was when rx'd on eth1, which is too old.)

Quite possibly.  I wouldn't be at all surprised if I missed something like that.

>> +static int etun_open(struct net_device *tx_dev)
>> +{
>> +	struct etun_info *tx_info = tx_dev->priv;
>> +	struct net_device *rx_dev = tx_info->rx_dev;
>> +	if (rx_dev->flags & IFF_UP) {
>> +		netif_carrier_on(tx_dev);
>> +		netif_carrier_on(rx_dev);
>> +	}
>> +	netif_start_queue(tx_dev);
>
> Does this carrier logic keep etun0 from transmitting to
> etun1 if etun0 is UP but etun1 is not UP yet?

A little bit.  It also allows user space to see that there really
is not a connection.  I think I was just having fun when I implemented
that bit.

>> +
>> +	random_ether_addr(dev->dev_addr);
>> + dev->tx_queue_len = 0; /* A queue is silly for a loopback device */
>> +	dev->hard_start_xmit	= etun_xmit;
>> +	dev->get_stats		= etun_get_stats;
>> +	dev->open		= etun_open;
>> +	dev->stop		= etun_stop;
>> +	dev->set_multicast_list	= etun_set_multicast_list;
>> +	dev->do_ioctl		= etun_ioctl;
>> +	dev->features		= NETIF_F_FRAGLIST
>> +				  | NETIF_F_HIGHDMA
>> +				  | NETIF_F_LLTX;
>> +	dev->flags		= IFF_BROADCAST | IFF_MULTICAST |IFF_PROMISC;
>> +	dev->ethtool_ops	= &etun_ethtool_ops;
>> +	dev->destructor		= free_netdev;
>
> You should add ability to change MTU.  I believe it is as trivial as this:
>
> int redirdev_change_mtu(struct net_device *dev, int new_mtu) {
> 	dev->mtu = new_mtu;
> 	return 0;
> }

It should be.  If I missed that it was an oversight.

>
>> +	dev_hold(dev0);
>> +	dev_hold(dev1);
>> +	info0->rx_dev = dev1;
>> +	info1->rx_dev = dev0;
>
> Can this race such that someone could manage to tx on one of these
> devices before you assign the rx_dev?  Maybe register-netdev after
> this assignment here, instead of in the alloc_etun method above?

Good paranoid thought.
>
>> +
>> +	/* Only place one member of the pair on the list
>> +	 * so I don't confuse list_for_each_entry_safe,
>> +	 * by deleting two list entries at once.
>> +	 */
>> +	rtnl_lock();
>> +	list_add(&info0->list, &etun_list);
>> +	INIT_LIST_HEAD(&info1->list);
>> +	rtnl_unlock();
>> +
>> +	return 0;
>> +}
>> +
>> +static int etun_unregister_pair(struct net_device *dev0)
>> +{
>> +	struct etun_info *info0, *info1;
>> +	struct net_device *dev1;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	if (!dev0)
>> +		return -ENODEV;
>> +
>> +	info0 = dev0->priv;
>> +	dev1  = info0->rx_dev;
>> +	info1 = dev1->priv;
>> +
>> +	/* Drop the cross device references */
>> +	dev_put(dev0);
>> +	dev_put(dev1);
>
> The devices are still potentially transmitting at this point,
> since you have not yet called unregister_netdev?

It really doesn't matter. In this context because all I'm doing
is dropping a reference count, that is just there to see if there
was a leak of users of the device.  

> For redir devices, I dropped association in the 'down' logic,
> and re-acquired it lazily.  I saved the peer device's name
> (not if-index).  I am not certain this is required, but I believe
> it made locking simpler.

Actually I don't do that, because I have no clue which device
namespace my partner is in.  Quite possibly both of my devices
are named eth0.

Anyway I think I have the locking handled and except for the
micro race during allocation things appear to look correct.

Eric
