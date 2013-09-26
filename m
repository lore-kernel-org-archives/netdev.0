From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v5 net-next 11/27] bonding: rework bond_3ad_xmit_xor()
 to use bond_for_each_slave() only
Date: Thu, 26 Sep 2013 14:39:11 +0800
Message-ID: <5243D68F.4090806@huawei.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com> <1380093632-1842-12-git-send-email-vfalico@redhat.com> <52439C87.6050809@huawei.com> <20130926054317.GA2547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:34868 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3IZGjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 02:39:24 -0400
In-Reply-To: <20130926054317.GA2547@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/9/26 13:43, Veaceslav Falico wrote:
> On Thu, Sep 26, 2013 at 10:31:35AM +0800, Ding Tianhong wrote:
> 
> First of all - thanks a lot for the review! Answered below.
> 
>> On 2013/9/25 15:20, Veaceslav Falico wrote:
>>> Currently, there are two loops - first we find the first slave in an
>>> aggregator after the xmit_hash_policy() returned number, and after that we
>>> loop from that slave, over bonding head, and till that slave to find any
>>> suitable slave to send the packet through.
>>>
>>> Replace it by just one bond_for_each_slave() loop, which first loops
>>> through the requested number of slaves, saving the first suitable one, and
>>> after that we've hit the requested number of slaves to skip - search for
>>> any up slave to send the packet through. If we don't find such kind of
>>> slave - then just send the packet through the first suitable slave found.
>>>
>>> Logic remains unchainged, and we skip two loops. Also, refactor it a bit
>>> for readability.
>>>
>>> CC: Jay Vosburgh <fubar@us.ibm.com>
>>> CC: Andy Gospodarek <andy@greyhouse.net>
>>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>>> ---
>>>
>>> Notes:
>>>     v4  -> v5
>>>     No change.
>>>
>>>     v3  -> v4:
>>>     No change.
>>>
>>>     v2  -> v3:
>>>     No change.
>>>
>>>     v1  -> v2:
>>>     No changes.
>>>
>>>     RFC -> v1:
>>>     New patch.
>>>
>>>  drivers/net/bonding/bond_3ad.c | 46 ++++++++++++++++++++----------------------
>>>  1 file changed, 22 insertions(+), 24 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>>> index 3847aee..c861ee7 100644
>>> --- a/drivers/net/bonding/bond_3ad.c
>>> +++ b/drivers/net/bonding/bond_3ad.c
>>> @@ -2417,15 +2417,15 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>>>
>>>  int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>>  {
>>> -    struct slave *slave, *start_at;
>>>      struct bonding *bond = netdev_priv(dev);
>>> +    struct slave *slave, *first_ok_slave;
>>> +    struct aggregator *agg;
>>> +    struct ad_info ad_info;
>>>      struct list_head *iter;
>>> -    int slave_agg_no;
>>>      int slaves_in_agg;
>>> -    int agg_id;
>>> -    int i;
>>> -    struct ad_info ad_info;
>>> +    int slave_agg_no;
>>>      int res = 1;
>>> +    int agg_id;
>>>
>>>      read_lock(&bond->lock);
>>>      if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>> @@ -2438,20 +2438,28 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>>      agg_id = ad_info.aggregator_id;
>>>
>>>      if (slaves_in_agg == 0) {
>>> -        /*the aggregator is empty*/
>>>          pr_debug("%s: Error: active aggregator is empty\n", dev->name);
>>>          goto out;
>>>      }
>>>
>>>      slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
>>> +    first_ok_slave = NULL;
>>>
>>>      bond_for_each_slave(bond, slave, iter) {
>>> -        struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>>> +        agg = SLAVE_AD_INFO(slave).port.aggregator;
>>> +        if (!agg || agg->aggregator_identifier != agg_id)
>>> +            continue;
>>>
>>> -        if (agg && (agg->aggregator_identifier == agg_id)) {
>>> +        if (slave_agg_no >= 0) {
>>> +            if (!first_ok_slave && SLAVE_IS_OK(slave))
>>> +                first_ok_slave = slave;
>>>              slave_agg_no--;
>>> -            if (slave_agg_no < 0)
>>> -                break;
>>> +            continue;
>>> +        }
> 
> [1]        ^^^^^^^^^^^^^^^^^^^^^^^^^
> 
>>> +
>>> +        if (SLAVE_IS_OK(slave)) {
>>> +            res = bond_dev_queue_xmit(bond, skb, slave->dev);
>>> +            goto out;
>>>          }
> 
> [2]        ^^^^^^^^^^^^^^^^^^^^^^^^^
>

>>
>> I think you miss something, you will send skb always by the first suitable port,
>> it could not support load balance.
> 
> Well, yes, it will send always by the first suitable port AFTER
> slave_agg_no, returned by the xmit_hash_policy(), which is the whole point
> in the hash function and in the load balance.
> 
> It will first loop through the slaves, decrementing slave_agg_no to a
> negative value, while saving the first good to send slave, as shown in [1].
> Notice the "continue;":
> 
> if (slave_agg_no >= 0) {
>     if (!first_ok_slave && SLAVE_IS_OK(slave))
>         first_ok_slave = slave;
>     slave_agg_no--;
>     continue;
> }
> 

yes, I got your opinion, tnanks.

> Once we hit the negative value - which means we've skipped enough slaves,
> as requested by the hash function - we can start looking for the first
> slave that is good to send AFTER those all skipped slaves, as shown in [2].
> 
> Down the patch we also use that 'first_ok_slave' - in case we didn't find
> any suitable one after we've skipped first slave_agg_no and till the last
> slave, so it implements the same 'circular' logic as was in
> bond_for_each_slave_from().
> 
>> pls consult my function.
>>         if (agg && (agg->aggregator_identifier == agg_id)) {
>> -            slave_agg_no--;
>> -            if (slave_agg_no < 0)
>> -                break;
>> +            if (--slave_agg_no < 0) {
>> +                if (SLAVE_IS_OK(slave)) {
>> +                    res = bond_dev_queue_xmit(bond,
>> +                        skb, slave->dev);
>> +                    goto out;
>> +                }
>> +            }
> 
> I'll review your function in your patch.
> 
>>         }
>>     }
>>
>>>      }
>>>
>>> @@ -2461,20 +2469,10 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>>>          goto out;
>>>      }
>>>
>>> -    start_at = slave;
>>> -
>>> -    bond_for_each_slave_from(bond, slave, i, start_at) {
>>> -        int slave_agg_id = 0;
>>> -        struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
>>> -
>>> -        if (agg)
>>> -            slave_agg_id = agg->aggregator_identifier;
>>> -
>>> -        if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
>>> -            res = bond_dev_queue_xmit(bond, skb, slave->dev);
>>> -            break;
>>> -        }
>>> -    }
>>> +    /* we couldn't find any suitable slave after the agg_no, so use the
>>> +     * first suitable found, if found. */
>>> +    if (first_ok_slave)
>>> +        res = bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
>>>
>>>  out:
>>>      read_unlock(&bond->lock);
>>>
>>
>>
> 
> .
> 
