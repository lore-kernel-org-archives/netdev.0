From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v4 1/6] bonding: simplify and use RCU protection
 for 3ad xmit path
Date: Sat, 7 Sep 2013 17:03:50 +0200
Message-ID: <20130907150350.GF26163@redhat.com>
References: <52298407.9040103@huawei.com>
 <20130907142041.GA20237@redhat.com>
 <522B3BF1.2020208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384Ab3IGPFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 11:05:35 -0400
Content-Disposition: inline
In-Reply-To: <522B3BF1.2020208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 04:45:05PM +0200, Nikolay Aleksandrov wrote:
>
>On 09/07/2013 04:20 PM, Veaceslav Falico wrote:
>> On Fri, Sep 06, 2013 at 03:28:07PM +0800, Ding Tianhong wrote:
...snip...
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index f4b1001..37b49d1 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -23,6 +23,7 @@
>>   * way, we must not access it directly
>>   */
>>  #define list_next_rcu(list)    (*((struct list_head __rcu
>> **)(&(list)->next)))
>> +#define list_prev_rcu(list)    (*((struct list_head __rcu
>> **)(&(list)->prev)))
>>
>>  /*
>>   * Insert a new entry between two known consecutive entries.
>> @@ -271,6 +272,12 @@ static inline void list_splice_init_rcu(struct
>> list_head *list,
>>        likely(__ptr != __next) ? container_of(__next, type, member) : NULL; \
>>      })
>>
>> +#define list_last_or_null_rcu(ptr, type, member) \
>> +    ({struct list_head *__ptr = (ptr); \
>> +      struct list_head __rcu *__last = list_prev_rcu(__ptr); \
>> +      likely(__ptr != __last) ? container_of(__prev, type, member) : NULL; \
>> +    })
>> +
>Hi,
>Actually I don't think you can dereference ->prev and use the standard
>list_del_rcu because it guarantees only the ->next ptr will be valid and
>->prev is set to LIST_POISON2.
>IMO, you'll need something like this: https://lkml.org/lkml/2012/7/25/193
>with the bidir_del and all that.

Yeah, right, my bad - we can rely only on the ->next pointer, indeed,
missed that part. RCU is hard :).

So it'll be a lot harder to implement bond_last_slave_rcu() in a
'straightforward' approach.

I'd rather go in the opposite direction here - i.e. drop the 'reverse'
traversal completely, and all the use cases for bond_last_slave_rcu(). I've
got some patches already - http://patchwork.ozlabs.org/patch/272076/ doing
that, and hopefully will remove the whole 'backword' traversal completely
in the future.

>
>But in any case I complete agree with Veaceslav here. Read all the
>documentation carefully :-)
>
>Cheers,
> Nik
>
>>  /**
>>   * list_for_each_entry_rcu    -    iterate over rcu list of given type
>>   * @pos:    the type * to use as a loop cursor.
>> ------- END OF PATCH ------
>>
>> Anyway, it's up to you.
>>
>> Hope that helps.
>
