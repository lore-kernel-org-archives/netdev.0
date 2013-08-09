From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 1/6] bonding: add rcu to vlan_uses_dev() and
 make bond_vlan_used() use it
Date: Fri, 9 Aug 2013 13:11:21 +0200
Message-ID: <20130809111121.GB17510@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
 <1375981079-2936-2-git-send-email-vfalico@redhat.com>
 <5204CD4B.5080401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967570Ab3HILMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 07:12:54 -0400
Content-Disposition: inline
In-Reply-To: <5204CD4B.5080401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 01:06:51PM +0200, Nikolay Aleksandrov wrote:
>On 08/08/2013 06:57 PM, Veaceslav Falico wrote:
>> RFC -> v1: don't add vlan_uses_dev_rcu() and change vlan_uses_dev() instead
>> v1  -> v2: remove the ASSERT_RTNL(), cause we can now be called under rcu.
>>
>> Currently, bond_vlan_used() looks for any vlan, including the pseudo-vlan
>> id 0, and always returns true if 8021q is loaded. This creates several bad
>> situations - some warnings in __bond_release_one() because it thinks that
>> we still have vlans while removing, sending LB packets with vlan id 0 and,
>> possibly, other caused by vlan id 0.
>>
>> Fix it by changing vlan_uses_dev() to use rcu_dereference_rtnl() instead of
>> rtnl_dereference(), and thus it can already be used in bond_vlan_used()
>> under rcu_read_lock().
>>
>> By the time vlan_uses_dev() returns we cannot be sure if there were no
>> vlans added/removed, so it's basicly an optimization function.
>>
>> Also, use the vlan_uses_dev() in __bond_release_one() cause the rtnl lock
>> is held there.
>>
>> For this call to be visible in bonding.h, add include <linux/if_vlan.h>,
>> and also remove it from any other bonding file, cause they all include
>> bonding.h, and thus linux/if_vlan.h.
>>
>> CC: Jay Vosburgh <fubar@us.ibm.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> CC: Patrick McHardy <kaber@trash.net>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: Nikolay Aleksandrov <nikolay@redhat.com>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>  drivers/net/bonding/bond_alb.c  |    1 -
>>  drivers/net/bonding/bond_main.c |    3 +--
>>  drivers/net/bonding/bonding.h   |   10 +++++++++-
>>  net/8021q/vlan_core.c           |    5 ++---
>>  4 files changed, 12 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index 3a5db7b..2684329 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -34,7 +34,6 @@
>>  #include <linux/if_arp.h>
>>  #include <linux/if_ether.h>
>>  #include <linux/if_bonding.h>
>> -#include <linux/if_vlan.h>
>>  #include <linux/in.h>
>>  #include <net/ipx.h>
>>  #include <net/arp.h>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 4264a76..9d1045d 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -69,7 +69,6 @@
>>  #include <net/arp.h>
>>  #include <linux/mii.h>
>>  #include <linux/ethtool.h>
>> -#include <linux/if_vlan.h>
>>  #include <linux/if_bonding.h>
>>  #include <linux/jiffies.h>
>>  #include <linux/preempt.h>
>> @@ -1953,7 +1952,7 @@ static int __bond_release_one(struct net_device *bond_dev,
>>  		bond_set_carrier(bond);
>>  		eth_hw_addr_random(bond_dev);
>>
>> -		if (bond_vlan_used(bond)) {
>> +		if (vlan_uses_dev(bond_dev)) {
>>  			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
>>  				   bond_dev->name, bond_dev->name);
>>  			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 4bf52d5..9c4539e 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -23,6 +23,7 @@
>>  #include <linux/netpoll.h>
>>  #include <linux/inetdevice.h>
>>  #include <linux/etherdevice.h>
>> +#include <linux/if_vlan.h>
>>  #include "bond_3ad.h"
>>  #include "bond_alb.h"
>>
>> @@ -267,9 +268,16 @@ struct bonding {
>>  #endif /* CONFIG_DEBUG_FS */
>>  };
>>
>> +/* use vlan_uses_dev() if under rtnl */
>Small nitpick - I don't think this comment is necessary as both calls now reduce
>to vlan_uses_dev() and can be used interchangeably, maybe it's better to stick
>to bond_vlan_used() just for consistency everywhere.
>Anyway, I'm okay with this version as well:

Good catch, leftover from previous version.

>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Thank you.

>
