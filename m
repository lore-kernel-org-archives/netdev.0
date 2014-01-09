From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 2/3] bonding: fix __get_first_agg RCU usage
Date: Thu, 9 Jan 2014 12:58:39 +0100
Message-ID: <20140109115839.GJ5786@redhat.com>
References: <1389266425-28365-1-git-send-email-vfalico@redhat.com>
 <1389266425-28365-3-git-send-email-vfalico@redhat.com>
 <52CE8ED9.60609@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752512AbaAIMBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:01:43 -0500
Content-Disposition: inline
In-Reply-To: <52CE8ED9.60609@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 07:58:17PM +0800, Ding Tianhong wrote:
>On 2014/1/9 19:20, Veaceslav Falico wrote:
>> Currently, the RCU read lock usage is just wrong - it gets the slave struct
>> under RCU and continues to use it when RCU lock is released.
>>
>> However, it's still safe to do this cause we didn't need the
>> rcu_read_lock() initially - all of the __get_first_agg() callers are either
>> holding RCU read lock or the RTNL lock, so that we can't sync while in it.
>>
>> So, remove the useless rcu locking and add a comment.
>>
>> Fixes: be79bd048 ("bonding: add RCU for bond_3ad_state_machine_handler()")
>> CC: dingtianhong@huawei.com
>> CC: Jay Vosburgh <fubar@us.ibm.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>> ---
>>
>> Notes:
>>     v1 -> v2:
>>     Don't use RCU primitives as we can hold RTNL.
>>
>>  drivers/net/bonding/bond_3ad.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index cf5fab8..d2782c8 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -143,6 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
>>   *
>>   * Return the aggregator of the first slave in @bond, or %NULL if it can't be
>>   * found.
>> + * The caller must either hold RCU or RTNL lock.
>>   */
>>  static inline struct aggregator *__get_first_agg(struct port *port)
>>  {
>> @@ -153,9 +154,7 @@ static inline struct aggregator *__get_first_agg(struct port *port)
>>  	if (bond == NULL)
>>  		return NULL;
>>
>> -	rcu_read_lock();
>> -	first_slave = bond_first_slave_rcu(bond);
>> -	rcu_read_unlock();
>> +	first_slave = bond_first_slave(bond);
>>
>>  	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
>>  }
>>
>
>Hi, Veaceslav:
>
>Do you mean the bond_first_slave is safe in rcu_read_xxlock()?
>
>#define bond_first_slave(bond) \
>	(bond_has_slaves(bond) ? \
>		netdev_adjacent_get_private(bond_slave_list(bond)->next) : \
>		NULL)

Heh, good catch. We can't use neither _rcu primitives, because we can be
called under RTNL, and nor the RTNL ones, cause we can be called under RCU.
Not that easy to fix your RCU updates...

I'll take a look and send v3.

>
>
>Regards
>Ding
>
>
