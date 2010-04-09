From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 Patch 2/3] bridge: make bridge support netpoll
Date: Fri, 09 Apr 2010 13:43:47 +0800
Message-ID: <4BBEBE93.2030507@redhat.com>
References: <20100408062234.4499.17042.sendpatchset@localhost.localdomain>	<20100408062246.4499.5670.sendpatchset@localhost.localdomain> <20100408083710.2b61ee44@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>, Matt Mackall <mpm@selenic.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100408083710.2b61ee44@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 8 Apr 2010 02:18:58 -0400
> Amerigo Wang <amwang@redhat.com> wrote:
> 
>> Based on the previous patch, make bridge support netpoll by:
>>
>> 1) implement the 2 methods to support netpoll for bridge;
>>
>> 2) modify netpoll during forwarding packets via bridge;
>>
>> 3) disable netpoll support of bridge when a netpoll-unabled device
>>    is added to bridge;
>>
>> 4) enable netpoll support when all underlying devices support netpoll.
>>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
>> Cc: Matt Mackall <mpm@selenic.com>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>>
>> ---
>>
>> Index: linux-2.6/net/bridge/br_device.c
>> ===================================================================
>> --- linux-2.6.orig/net/bridge/br_device.c
>> +++ linux-2.6/net/bridge/br_device.c
>> @@ -13,8 +13,10 @@
>>  
>>  #include <linux/kernel.h>
>>  #include <linux/netdevice.h>
>> +#include <linux/netpoll.h>
>>  #include <linux/etherdevice.h>
>>  #include <linux/ethtool.h>
>> +#include <linux/list.h>
>>  
>>  #include <asm/uaccess.h>
>>  #include "br_private.h"
>> @@ -162,6 +164,59 @@ static int br_set_tx_csum(struct net_dev
>>  	return 0;
>>  }
>>  
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +bool br_devices_support_netpoll(struct net_bridge *br)
>> +{
>> +	struct net_bridge_port *p;
>> +	bool ret = true;
>> +	int count = 0;
>> +	unsigned long flags;
>> +
>> +	spin_lock_irqsave(&br->lock, flags);
>> +	list_for_each_entry(p, &br->port_list, list) {
>> +		count++;
>> +		if (p->dev->priv_flags & IFF_DISABLE_NETPOLL
>> +				|| !p->dev->netdev_ops->ndo_poll_controller)
>> +			ret = false;
>> +	}
>> +	spin_unlock_irqrestore(&br->lock, flags);
>> +	return count != 0 && ret;
>> +}
>> +
>> +static void br_poll_controller(struct net_device *br_dev)
>> +{
>> +	struct netpoll *np = br_dev->npinfo->netpoll;
>> +
>> +	if (np->real_dev != br_dev)
>> +		netpoll_poll_dev(np->real_dev);
>> +}
>> +
>> +void br_netpoll_cleanup(struct net_device *br_dev)
>> +{
>> +	struct net_bridge *br = netdev_priv(br_dev);
>> +	struct net_bridge_port *p, *n;
>> +	const struct net_device_ops *ops;
>> +
>> +	br->dev->npinfo = NULL;
>> +	list_for_each_entry_safe(p, n, &br->port_list, list) {
>> +		if (p->dev) {
>> +			ops = p->dev->netdev_ops;
>> +			if (ops->ndo_netpoll_cleanup)
>> +				ops->ndo_netpoll_cleanup(p->dev);
>> +			else
>> +				p->dev->npinfo = NULL;
>> +		}
>> +	}
>> +}
>> +
>> +#else
>> +
>> +void br_netpoll_cleanup(struct net_device *br_dev)
>> +{
>> +}
>> +
>> +#endif
> 
> Could you use more stub functions to eliminate #ifdef's in code.


Probably no, because only br_netpoll_cleanup() will be called
no matter if CONFIG_NET_POLL_CONTROLLER is defined.


>> @@ -50,7 +51,13 @@ int br_dev_queue_push_xmit(struct sk_buf
>>  		else {
>>  			skb_push(skb, ETH_HLEN);
>>  
>> -			dev_queue_xmit(skb);
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +			if (skb->dev->priv_flags & IFF_IN_NETPOLL) {
>> +				netpoll_send_skb(skb->dev->npinfo->netpoll, skb);
>> +				skb->dev->priv_flags &= ~IFF_IN_NETPOLL;
>> +			} else
>> +#endif
> 
> There is no protection on dev->priv_flags for SMP access.
> It would better bit value in dev->state if you are using it as control flag.
> 
> Then you could use 
> 			if (unlikely(test_and_clear_bit(__IN_NETPOLL, &skb->dev->state)))
> 				netpoll_send_skb(...)
> 


Yes? netpoll_send_skb() needs to see IFF_IN_NETPOLL is set, so
we can't clear this bit before calling it.

But we do need a find a safe way to check/set this flag.


>>  static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
>>  {
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +	struct net_bridge *br = to->br;
>> +	if (br->dev->priv_flags & IFF_IN_NETPOLL) {
>> +		struct netpoll *np;
>> +		to->dev->npinfo = skb->dev->npinfo;
>> +		np = skb->dev->npinfo->netpoll;
>> +		np->real_dev = np->dev = to->dev;
>> +		to->dev->priv_flags |= IFF_IN_NETPOLL;
>> +	}
>> +#endif
> 
> This is n hot path, so use unlikely()


Ok, good point.


>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +	if (br_devices_support_netpoll(br)) {
>> +		br->dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
>> +		if (br->dev->npinfo)
>> +			dev->npinfo = br->dev->npinfo;
>> +	} else if (!(br->dev->priv_flags & IFF_DISABLE_NETPOLL)) {
>> +		br->dev->priv_flags |= IFF_DISABLE_NETPOLL;
>> +		printk(KERN_INFO "New device %s does not support netpoll\n",
>> +			dev->name);
>> +		printk(KERN_INFO "Disabling netpoll for %s\n",
>> +			br->dev->name);
> 
> One message is sufficient.
> 

Yes? The first messages explains the reason for the second message.


Thanks.
