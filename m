From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] Fix Kernel Panic in bonding driver debugfs file: rlb_hash_table
Date: Wed, 29 Apr 2015 16:30:44 -0400
Message-ID: <55413F74.3010204@akamai.com>
References: <E1YnWel-0004R7-1o@bos-lpqrs.kendall.corp.akamai.com> <554134D1.7070509@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nikolay Aleksandrov <razor@blackwall.org>,
	Andy Gospodarek <andy@greyhouse.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:63558 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbbD2Uap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 16:30:45 -0400
In-Reply-To: <554134D1.7070509@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2015 03:45 PM, Nikolay Aleksandrov wrote:
> On 04/29/2015 08:24 PM, Pai wrote:
>> This patch fixes a Kernel Panic in bonding driver debugfs file: rlb_hash_table.
>>
>> $> modprobe bonding mode=6
>> $> cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
>>
>> This will crash the kernel. The struct alb_bond_info is initialized only when
>> the bonding interface is initialized (ip link set bond0 up) and not at the time
>> it is allocated. If we try to read the table before that, it'll result in a 
>> kernel panic.
>>
>> The patch applies against both net and net-next
>>
>> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
>>  
> Good catch, a few cosmetic nits below.
> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 089a402..806892a 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4510,6 +4510,8 @@ unsigned int bond_get_num_tx_queues(void)
>>  int bond_create(struct net *net, const char *name)
>>  {
>>  	struct net_device *bond_dev;
>> +	struct bonding *bond;
>> +	struct alb_bond_info *bond_info;
> Please arrange these longest to shortest line, it's easier to read.
> 
>>  	int res;
>>  
>>  	rtnl_lock();
>> @@ -4523,6 +4525,14 @@ int bond_create(struct net *net, const char *name)
>>  		return -ENOMEM;
>>  	}
>>  
>> +	/*
>> +	 * Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
>> +	 * It is set to 0 by default which is wrong.
>> +	 */
> Multiline comment style of networking content is:
> 	/* text
> 	 * text
> 	 */
> 
> See: Documentation/networking/netdev-FAQ.txt
> 
> Alternatively you can create an inline with descriptive name that does the
> initialization and wouldn't need the comment. Either way's fine by me.
> 
> Cheers,
>  Nik
> 
>> +	bond = netdev_priv(bond_dev);
>> +	bond_info = &(BOND_ALB_INFO(bond));
>> +	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
>> +
>>  	dev_net_set(bond_dev, net);
>>  	bond_dev->rtnl_link_ops = &bond_link_ops;
>>  
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 

David,

Since the patch has been applied already - should I send a V2 with the
suggested changes? Or submit a new patch that applies on top of the
first patch?

Thanks,
Vishwanath
