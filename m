From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/5] bonding: simplify and use RCU protection for 3ad
 xmit path
Date: Fri, 30 Aug 2013 09:57:04 +0800
Message-ID: <521FFBF0.8040107@huawei.com>
References: <521D7A96.9070904@huawei.com> <521F59E2.8030707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:31121 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948Ab3H3B5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 21:57:34 -0400
In-Reply-To: <521F59E2.8030707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/29 22:25, Nikolay Aleksandrov wrote:
> On 08/28/2013 06:20 AM, Ding Tianhong wrote:
>> The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
>> (bonding: initial RCU conversion) has convert the roundrobin, active-backup,
>> broadcast and xor xmit path to rcu protection, the performance will be better
>> for these mode, so this time, convert xmit path for 3ad mode.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>  drivers/net/bonding/bond_3ad.c | 31 +++++++++++++------------------
>>  drivers/net/bonding/bonding.h  | 22 ++++++++++++++++++++++
>>  2 files changed, 35 insertions(+), 18 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 9010265..52d76a4 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -143,7 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>>   */
>>  static inline struct port *__get_first_port(struct bonding *bond)
>>  {
>> -	struct slave *first_slave = bond_first_slave(bond);
>> +	struct slave *first_slave = bond_first_slave_rcu(bond);
>>  
>>  	return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
>>  }
>> @@ -163,7 +163,7 @@ static inline struct port *__get_next_port(struct port *port)
>>  	// If there's no bond for this port, or this is the last slave
>>  	if (bond == NULL)
>>  		return NULL;
>> -	slave_next = bond_next_slave(bond, slave);
>> +	slave_next = bond_next_slave_rcu(bond, slave);
>>  	if (!slave_next || bond_is_first_slave(bond, slave_next))
>>  		return NULL;
>>  
>> @@ -2417,16 +2417,14 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>>  
>>  int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>  {
>> -	struct slave *slave, *start_at;
>> +	struct slave *slave;
> Please re-arrange longest -> shortest where possible.
> 

something wrong with my vim, so fix it, thanks.

>>  	struct bonding *bond = netdev_priv(dev);
>>  	int slave_agg_no;
>>  	int slaves_in_agg;
>>  	int agg_id;
>> -	int i;
>>  	struct ad_info ad_info;
>>  	int res = 1;
>>  
>> -	read_lock(&bond->lock);
>>  	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>  		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
>>  			 dev->name);
>> @@ -2444,13 +2442,16 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>  
>>  	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
>>  
>> -	bond_for_each_slave(bond, slave) {
>> +	bond_for_each_slave_rcu(bond, slave) {
>>  		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>>  
>>  		if (agg && (agg->aggregator_identifier == agg_id)) {
>> -			slave_agg_no--;
>> -			if (slave_agg_no < 0)
>> -				break;
>> +			if (--slave_agg_no < 0) {
>> +				if (SLAVE_IS_OK(slave)) {
>> +					res = bond_dev_queue_xmit(bond, skb, slave->dev);
>> +					goto out;
>> +				}
>> +			}
>>  		}
>>  	}
>>  
>> @@ -2460,23 +2461,17 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>  		goto out;
>>  	}
>>  
>> -	start_at = slave;
>> -
>> -	bond_for_each_slave_from(bond, slave, i, start_at) {
>> -		int slave_agg_id = 0;
>> +	bond_for_each_slave_rcu(bond, slave) {
>>  		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>>  
>> -		if (agg)
>> -			slave_agg_id = agg->aggregator_identifier;
>> -
>> -		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
>> +		if (SLAVE_IS_OK(slave) && agg &&
>> +				(agg->aggregator_identifier == agg_id)) {
> Please drop the ( ) from (agg->aggregator_identifier == agg_id), also align it
> properly.
> 

my mistake, thanks.

>>  			res = bond_dev_queue_xmit(bond, skb, slave->dev);
>>  			break;
>>  		}
>>  	}
>>  
>>  out:
>> -	read_unlock(&bond->lock);
>>  	if (res) {
>>  		/* no suitable interface, frame not sent */
>>  		kfree_skb(skb);
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 4bf52d5..ecb5d1d 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -74,6 +74,9 @@
>>  /* slave list primitives */
>>  #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
>>  
>> +/* slave list primitives, Caller must hold rcu_read_lock */
>> +#define bond_to_slave_rcu(ptr) list_entry_rcu(ptr, struct slave, list)
>> +
>>  /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
>>  #define bond_first_slave(bond) \
>>  	list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
>> @@ -81,6 +84,16 @@
>>  	(list_empty(&(bond)->slave_list) ? NULL : \
>>  					   bond_to_slave((bond)->slave_list.prev))
>>  
>> +/**
>> + * IMPORTANT: bond_first/last_slave_rcu can return NULL in case of an empty list
>> + * Caller must hold rcu_read_lock
>> + */
> Styling nit: the comments in net/ should be /* text...

miss the net-next. add in resend.

> 
>> +#define bond_first_slave_rcu(bond) \
>> +	list_first_or_null_rcu(&(bond)->slave_list, struct slave, list)
>> +#define bond_last_slave_rcu(bond) \
>> +	(list_emptry(&(bond)->slave_list) ? NULL : \
> ^^^^^^^^^^^^^^^^^^^^^
> Did you compile this ?

oh, I compiled, but the func did not used, so did not show any problem, it's a big error, I will review
and check all above.

> 
>> +						bond_to_slave_rcu((bond)->slave_list.prev))
>> +
>>  #define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
>>  #define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
>>  
>> @@ -93,6 +106,15 @@
>>  	(bond_is_first_slave(bond, pos) ? bond_last_slave(bond) : \
>>  					  bond_to_slave((pos)->list.prev))
>>  
>> +/* Since bond_first/last_slave_rcu can return NULL, these can return NULL too */
>> +#define bond_next_slave_rcu(bond, pos) \
>> +	(bond_is_last_slave(bond, pos) ? bond_first_slave_rcu(bond) : \
>> +					 bond_to_slave_rcu((pos)->list.next))
>> +
>> +#define bond_prev_slave_rcu(bond, pos) \
>> +	(bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
>> +					  bond_to_slave_rcu((pos)->list.prev))
>> +
>>  /**
>>   * bond_for_each_slave_from - iterate the slaves list from a starting point
>>   * @bond:	the bond holding this list.
>>
> 
> 
> .
> 
