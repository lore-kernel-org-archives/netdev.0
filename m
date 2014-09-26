From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: make global bonding stats more reliable
Date: Fri, 26 Sep 2014 15:35:33 +0200
Message-ID: <54256BA5.9080803@redhat.com>
References: <1411650996-2087-1-git-send-email-gospo@cumulusnetworks.com> <54252940.6070100@redhat.com> <20140926132631.GA18564@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbaIZNfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 09:35:45 -0400
In-Reply-To: <20140926132631.GA18564@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/09/14 15:26, Andy Gospodarek wrote:
> On Fri, Sep 26, 2014 at 10:52:16AM +0200, Nikolay Aleksandrov wrote:
>> On 25/09/14 15:16, Andy Gospodarek wrote:
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
>>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>> ---
>> Hi Andy,
>>
<<<<snip>>>>
>>> @@ -4258,6 +4274,9 @@ static int bond_init(struct net_device *bond_dev)
>>>   	    bond_dev->addr_assign_type == NET_ADDR_PERM)
>>>   		eth_hw_addr_random(bond_dev);
>>>
>>> +	/* initialize persistent stats for the bond */
>>> +	bond->bond_stats = kzalloc(sizeof(struct rtnl_link_stats64),
>>> +				   GFP_ATOMIC);
>> ^^^^^^^^^^^^^^^^^^^^^^^^
>> I don't think this will get freed if the bond device is destroyed.
> Another good catch.  Thanks for the review.  V2 incoming after some
> testing.
>
Great, one more thing I forgot to ask, why the GFP_ATOMIC here ? I believe we're 
allowed to sleep in ndo_init(), and you should probably handle the case where 
the bond_stats allocation fails, too.

>>
>>>   	return 0;
>>>   }
>>>
>>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>> index 6140bf0..fe25265 100644
>>> --- a/drivers/net/bonding/bonding.h
>>> +++ b/drivers/net/bonding/bonding.h
>>> @@ -24,6 +24,7 @@
>>>   #include <linux/inetdevice.h>
>>>   #include <linux/etherdevice.h>
>>>   #include <linux/reciprocal_div.h>
>>> +#include <linux/if_link.h>
>>>
>>>   #include "bond_3ad.h"
>>>   #include "bond_alb.h"
>>> @@ -175,6 +176,7 @@ struct slave {
>>>   	struct netpoll *np;
>>>   #endif
>>>   	struct kobject kobj;
>>> +	struct rtnl_link_stats64 *slave_stats;
>>>   };
>>>
>>>   /*
>>> @@ -224,6 +226,7 @@ struct bonding {
>>>   	/* debugging support via debugfs */
>>>   	struct	 dentry *debug_dir;
>>>   #endif /* CONFIG_DEBUG_FS */
>>> +	struct rtnl_link_stats64 *bond_stats;
>>>   };
>>>
>>>   #define bond_slave_get_rcu(dev) \
>>>
>>
