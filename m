From: Joe Eykholt <jeykholt@cisco.com>
Subject: Re: [PATCH net-next 2/8] bonding: Check return of dev_set_promiscuity/allmulti
Date: Sat, 21 Jun 2008 11:19:26 -0700
Message-ID: <485D462E.3060003@cisco.com>
References: <485AFFD2.4090304@cn.fujitsu.com> <20080619.190724.264140435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	fubar@us.ibm.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:26440 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbYFUSTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 14:19:38 -0400
In-Reply-To: <20080619.190724.264140435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 20 Jun 2008 08:54:42 +0800
> 
>> @@ -419,8 +419,11 @@ static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
>>  	}
>>  
>>  	if (!bond->alb_info.primary_is_promisc) {
>> -		bond->alb_info.primary_is_promisc = 1;
>> -		dev_set_promiscuity(bond->curr_active_slave->dev, 1);
>> +		/* dev_set_promiscuity might overflow, check it here */
>> +		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
> 
> Like the first patch, please don't add such comments.
> 
>> @@ -955,6 +965,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
>>  	}
>>  
>>  	if (new_active) {
>> +		/* FIXME: promiscuity and allmulti might overflow,
>> +		 * but bond_mc_swap's caller likes quiet handle.
>> +		 */
>>  		if (bond->dev->flags & IFF_PROMISC) {
>>  			dev_set_promiscuity(new_active->dev, 1);
>>  		}
> 
> Please reword this comment.  The issue is that this code path has no
> mechanism to signal errors upstream.  It isn't about a specific type
> of error condition in particular, it's about error handling capabilites
> in general.

If netdev->promiscuity overflows, shouldn't there be a WARN_ON or BUG_ON
that catches that?  Either someone forgot to clean up, or much less likely,
the counter needs to be widened.  It isn't necessarily the current caller's
fault, but some indication of the problem is better than nothing.

>> @@ -3933,6 +3950,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>>  	 * Do promisc before checking multicast_mode
>>  	 */
>>  	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC)) {
>> +		/*
>> +		 * FIXME: If bond has multi slaves, how to handle the error
>> +		 * when one of the slaves encounters promiscuity overflow.
>> +		 */
>>  		bond_set_promiscuity(bond, 1);
>>  	}
>>  
> 
> Remove specific reference to promiscuity overflow, these are generic error
> handling issues here regardless of the types of errors that the down
> calls could encounter.
> 
>> @@ -3942,6 +3963,10 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>>  
>>  	/* set allmulti flag to slaves */
>>  	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI)) {
>> +		/*
>> +		 * FIXME: If bond has multi slaves, how to handle the error
>> +		 * when one of the slaves encounters allmulti overflow.
>> +		 */
>>  		bond_set_allmulti(bond, 1);
>>  	}
> 
> Likewise.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

