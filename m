From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Tue, 28 May 2013 13:10:46 +0400
Message-ID: <51A47496.6000100@yandex-team.ru>
References: <519B8908.9080007@yandex-team.ru>  <1369150693.3301.233.camel@edumazet-glaptop>  <519BB90B.6080706@yandex-team.ru>  <1369188080.3301.268.camel@edumazet-glaptop>  <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru>  <1369225837.3301.324.camel@edumazet-glaptop>  <519CC2FB.2010006@yandex-team.ru>  <20130522174532.GC3431@linux.vnet.ibm.com> <519D19DA.50400@yandex-team.ru>  <20130525113715.GA3795@linux.vnet.ibm.com>  <51A39E11.5020405@yandex-team.ru> <1369699930.3301.494.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369699930.3301.494.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28.05.2013 04:12, Eric Dumazet wrote:
> On Mon, 2013-05-27 at 21:55 +0400, Roman Gushchin wrote:
>> Hi, Paul!
>>
>>> On 25.05.2013 15:37, Paul E. McKenney wrote:
>>>> Again, I believe that your retry logic needs to extend back into the
>>>> calling function for your some_func() example above.
>>
>> And what do you think about the following approach (diff below)?
>>
>> It seems to me, it's enough clear (especially with good accompanying comments)
>> and produces a good binary code (without significant overhead).
>> Also, we will remove a hidden reef in using rcu-protected (h)list traverses with restarts.
>>
>
>> diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_nulls.h
>> index 2ae1371..4af5ee5 100644
>> --- a/include/linux/rculist_nulls.h
>> +++ b/include/linux/rculist_nulls.h
>> @@ -107,7 +107,8 @@ static inline void hlist_nulls_add_head_rcu(struct hlist_nulls_node *n,
>>     *
>>     */
>>    #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                        \
>> -       for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
>> +       for (ACCESS_ONCE(*(head)),                                              \
>> +               pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));         \
>>                   (!is_a_nulls(pos)) &&                                           \
>>                   ({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
>>                   pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
>
> It looks like this still relies on gcc being friendly here.
>
> I repeat again : @head here is a constant.

No.
Actually, there are two volatile objects: pointer to the first element (as a part of the head structure),
and the first element by itself. So, to be strict, head as a structure contains a volatile field.
Head->first should be treated as a volatile pointer to a volatile data. So, the whole head object is volatile.

>
> Macro already uses ACCESS_ONCE(), we only have to instruct gcc that
> caching the value is forbidden if we restart the loop
> (aka "goto begin;" see Documentation/RCU/rculist_nulls.txt line 146)

My patch seems to be correct, because, ACCESS_ONCE(*(head)) will cause gcc to (re)read head data from the memory.
According to gcc documentation:
	"A scalar volatile object is read when it is accessed in a void context:
      		volatile int *src = somevalue;
      		*src;
	Such expressions are rvalues, and GCC implements this as a read of the volatile object being pointed to."
And this is exactly our case.

> Adding a barrier() is probably what we want.

I agree, inserting barrier() is also a correct and working fix.

Thanks!

Regards,
Roman
