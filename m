From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bonding: make global bonding stats more reliable
Date: Fri, 26 Sep 2014 18:16:47 -0400
Message-ID: <5425E5CF.4040403@cumulusnetworks.com>
References: <1411684631-7509-1-git-send-email-gospo@cumulusnetworks.com> <54257B50.20709@redhat.com> <20140926153501.GC18564@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36504 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755574AbaIZWQv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 18:16:51 -0400
In-Reply-To: <20140926153501.GC18564@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/26/14, 11:35 AM, Andy Gospodarek wrote:
> On Fri, Sep 26, 2014 at 04:42:24PM +0200, Nikolay Aleksandrov wrote:
>> On 26/09/14 00:37, Andy Gospodarek wrote:
>>> As the code stands today, bonding stats are based simply on the stats
>> >from the member interfaces.  If a member was to be removed from a bond,
>>> the stats would instantly drop.  This would be confusing to an admin
>>> would would suddonly see interface stats drop while traffic is still
>>> flowing.
>>>
>>> In addition to preventing the stats drops mentioned above, new members
>>> will now be added to the bond and only traffic received after the member
>>> was added to the bond will be counted as part of bonding stats.
>>>
>>> v2: Changes suggested by Nik to properly allocate/free stats memory.
>>>
>>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>> ---
>>>  drivers/net/bonding/bond_main.c | 85 +++++++++++++++++++++++++++--------------
>>>  drivers/net/bonding/bonding.h   |  3 ++
>>>  2 files changed, 60 insertions(+), 28 deletions(-)
>>>
>> <<<<snip>>>>
>>> @@ -3857,6 +3874,8 @@ static void bond_uninit(struct net_device *bond_dev)
>>>  		__bond_release_one(bond_dev, slave->dev, true);
>>>  	netdev_info(bond_dev, "Released all slaves\n");
>>>
>>> +	kfree(bond->bond_stats);
>>> +
>>>  	list_del(&bond->bond_list);
>>>
>>>  	bond_debug_unregister(bond);
>>> @@ -4243,7 +4262,13 @@ static int bond_init(struct net_device *bond_dev)
>>>
>>>  	bond->wq = create_singlethread_workqueue(bond_dev->name);
>>>  	if (!bond->wq)
>>> -		return -ENOMEM;
>>> +		goto bond_wq_fail;
>>> +
>>> +	/* initialize persistent stats for the bond */
>>> +	bond->bond_stats = kzalloc(sizeof(struct rtnl_link_stats64),
>>> +				   GFP_KERNEL);
>>> +	if (!bond->bond_stats)
>>> +		goto bond_stats_fail;
>>>
>>>  	bond_set_lockdep_class(bond_dev);
>>>
>>> @@ -4259,6 +4284,10 @@ static int bond_init(struct net_device *bond_dev)
>>>  		eth_hw_addr_random(bond_dev);
>>>
>>>  	return 0;
>>> +bond_stats_fail:
>>> +	kfree(bond->wq);
>> ^^^^^^^^^^
>> I think you should use destroy_workqueue() to properly get rid of the wq.
> I'm beginning to think I should have gone with my first approach and
> placed the rtnl_link_stats64 structs inside struct slave and struct
> bonding rather than creating pointers....

I agree, would simplify the initialization and tear-down code. Is there
any reason statically increasing the slave and bonding structures would
be a bad idea? Don't see how not allocating those stats structures are
an option so not sure what the additional dynamic memory buys, one could
argue it wastes memory.

> 
>>
>>
>>> +bond_wq_fail:
>>> +	return -ENOMEM;
>>>  }
>>>
>>>  unsigned int bond_get_num_tx_queues(void)
>>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>> index 6140bf0..fe25265 100644
>>> --- a/drivers/net/bonding/bonding.h
>>> +++ b/drivers/net/bonding/bonding.h
>>> @@ -24,6 +24,7 @@
>>>  #include <linux/inetdevice.h>
>>>  #include <linux/etherdevice.h>
>>>  #include <linux/reciprocal_div.h>
>>> +#include <linux/if_link.h>
>>>
>>>  #include "bond_3ad.h"
>>>  #include "bond_alb.h"
>>> @@ -175,6 +176,7 @@ struct slave {
>>>  	struct netpoll *np;
>>>  #endif
>>>  	struct kobject kobj;
>>> +	struct rtnl_link_stats64 *slave_stats;
>>>  };
>>>
>>>  /*
>>> @@ -224,6 +226,7 @@ struct bonding {
>>>  	/* debugging support via debugfs */
>>>  	struct	 dentry *debug_dir;
>>>  #endif /* CONFIG_DEBUG_FS */
>>> +	struct rtnl_link_stats64 *bond_stats;
>>>  };
>>>
>>>  #define bond_slave_get_rcu(dev) \
>>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
