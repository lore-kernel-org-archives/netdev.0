From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Thu, 07 Jun 2012 23:02:16 -0700 (PDT)
Message-ID: <20120607.230216.2014005732863772019.davem@davemloft.net>
References: <alpine.DEB.2.00.1206072201200.13686@pokey.mtv.corp.google.com>
	<1339135057.6001.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab2FHGCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 02:02:17 -0400
In-Reply-To: <1339135057.6001.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jun 2012 07:57:37 +0200

> On Thu, 2012-06-07 at 22:05 -0700, Tom Herbert wrote:
>> In the transmit path of the bonding driver, skb->cb is used to
>> stash the skb->queue_mapping so that the bonding device can set its
>> own queue mapping.  This value becomes corrupted since the skb->cb is
>> also used in __dev_xmit_skb.
>> 
>> When transmitting through bonding driver, bond_select_queue is
>> called from dev_queue_xmit.  In bond_select_queue the original
>> skb->queue_mapping is copied into skb->cb (via bond_queue_mapping)
>> and skb->queue_mapping is overwritten with the bond driver queue.
>> Subsequently in dev_queue_xmit, __dev_xmit_skb is called which writes
>> the packet length into skb->cb, thereby overwriting the stashed
>> queue mappping.  In bond_dev_queue_xmit (called from hard_start_xmit),
>> the queue mapping for the skb is set to the stashed value which is now
>> the skb length and hence is an invalid queue for the slave device.
>> 
>> Fix is to set bond_queue_mapping to skb->cb +
>> sizeof((struct qdisc_skb_cb)
>> 
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    4 +++-
>>  1 files changed, 3 insertions(+), 1 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 2ee8cf9..044c1c0 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -76,6 +76,7 @@
>>  #include <net/route.h>
>>  #include <net/net_namespace.h>
>>  #include <net/netns/generic.h>
>> +#include <net/sch_generic.h>
>>  #include "bonding.h"
>>  #include "bond_3ad.h"
>>  #include "bond_alb.h"
>> @@ -381,7 +382,8 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
>>  	return next;
>>  }
>>  
>> -#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb))
>> +#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb + \
>> +    sizeof(struct qdisc_skb_cb)))
>>  
>>  /**
>>   * bond_dev_queue_xmit - Prepare skb for xmit.
> 
> 
> Sorry this wont work in all cases.
> 
> Some qdisc also use skb->cb[]

Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
explicitly allocated:

>  	unsigned char		data[24];

there. :-)
