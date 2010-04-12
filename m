From: Cong Wang <amwang@redhat.com>
Subject: Re: [v3 Patch 2/3] bridge: make bridge support netpoll
Date: Mon, 12 Apr 2010 18:37:22 +0800
Message-ID: <4BC2F7E2.7020309@redhat.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445Ab0DLKeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 06:34:05 -0400
In-Reply-To: <20100408083710.2b61ee44@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> Index: linux-2.6/net/bridge/br_forward.c
>> ===================================================================
>> --- linux-2.6.orig/net/bridge/br_forward.c
>> +++ linux-2.6/net/bridge/br_forward.c
>> @@ -15,6 +15,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/kernel.h>
>>  #include <linux/netdevice.h>
>> +#include <linux/netpoll.h>
>>  #include <linux/skbuff.h>
>>  #include <linux/if_vlan.h>
>>  #include <linux/netfilter_bridge.h>
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
> 

Hmm, I think we can't use ->state here, it is not for this kind of purpose,
according to its comments.

Also, I find other usages of IFF_XXX flags of ->priv_flags are also using
&, | to set or clear the flags. So there must be some other things preventing
the race...


Thanks.
