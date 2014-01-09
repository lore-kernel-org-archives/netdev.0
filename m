From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net-next 3/3] bonding: fix __get_active_agg() RCU logic
Date: Thu, 9 Jan 2014 13:13:28 +0100
Message-ID: <20140109121328.GL5786@redhat.com>
References: <1389266425-28365-1-git-send-email-vfalico@redhat.com>
 <1389266425-28365-4-git-send-email-vfalico@redhat.com>
 <52CE9049.6020206@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbaAIMQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:16:29 -0500
Content-Disposition: inline
In-Reply-To: <52CE9049.6020206@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 08:04:25PM +0800, Ding Tianhong wrote:
>On 2014/1/9 19:20, Veaceslav Falico wrote:
>> Currently, the implementation is meaningless - once again, we take the
>> slave structure and use it after we've exited RCU critical section.
>>
>> Fix this by removing the rcu_read_lock() from __get_active_agg(), and
>> ensuring that all its callers are holding either RCU or RTNL lock.
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
>>  drivers/net/bonding/bond_3ad.c | 12 +++++-------
>>  1 file changed, 5 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index d2782c8..845545b 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -674,6 +674,8 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
>>  /**
>>   * __get_active_agg - get the current active aggregator
>>   * @aggregator: the aggregator we're looking at
>> + *
>> + * Caller must hold either RCU or RTNL lock.
>>   */
>>  static struct aggregator *__get_active_agg(struct aggregator *aggregator)
>>  {
>> @@ -681,13 +683,9 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
>>  	struct list_head *iter;
>>  	struct slave *slave;
>>
>> -	rcu_read_lock();
>> -	bond_for_each_slave_rcu(bond, slave, iter)
>> -		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
>> -			rcu_read_unlock();
>> +	bond_for_each_slave(bond, slave, iter)
>> +		if (SLAVE_AD_INFO(slave).aggregator.is_active)
>>  			return &(SLAVE_AD_INFO(slave).aggregator);
>> -		}
>
>Is the bond_for_each_slave safe in rcu_read_lock()?

Yeah, good catch, responded in the second patch.

Thanks for the review!

>
>
>> -	rcu_read_unlock();
>>
>>  	return NULL;
>>  }
>> @@ -1495,11 +1493,11 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>>  	struct slave *slave;
>>  	struct port *port;
>>
>> +	rcu_read_lock();
>>  	origin = agg;
>>  	active = __get_active_agg(agg);
>>  	best = (active && agg_device_up(active)) ? active : NULL;
>>
>> -	rcu_read_lock();
>>  	bond_for_each_slave_rcu(bond, slave, iter) {
>>  		agg = &(SLAVE_AD_INFO(slave).aggregator);
>>
>>
>
>
