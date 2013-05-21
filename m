From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 19:51:10 +0400
Message-ID: <519B97EE.3030404@yandex-team.ru>
References: <519B38EC.90401@yandex-team.ru>   <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru> <1369149381.3301.228.camel@edumazet-glaptop>
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
In-Reply-To: <1369149381.3301.228.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.05.2013 19:16, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 18:47 +0400, Roman Gushchin wrote:
>> On 21.05.2013 17:44, Eric Dumazet wrote:
>>> On Tue, 2013-05-21 at 05:09 -0700, Paul E. McKenney wrote:
>>>
>>>>>
>>>>> -#define hlist_nulls_first_rcu(head) \
>>>>> -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
>>>>> +#define hlist_nulls_first_rcu(head)			\
>>>>> +	(*((struct hlist_nulls_node __rcu __force **)	\
>>>>> +	   &((volatile typeof(*head) *)head)->first))
>>>>
>>>> Why not use ACCESS_ONCE() or (better) rcu_dereference_raw() here?
>>>
>>> More exactly we have :
>>>
>>> #define list_entry_rcu(ptr, type, member) \
>>>           ({typeof (*ptr) __rcu *__ptr = (typeof (*ptr) __rcu __force *)ptr; \
>>>            container_of((typeof(ptr))rcu_dereference_raw(__ptr), type, member); \
>>>           })
>>>
>>> #define list_for_each_entry_rcu(pos, head, member) \
>>>           for (pos = list_entry_rcu((head)->next, typeof(*pos), member); \
>>>                   &pos->member != (head); \
>>>                   pos = list_entry_rcu(pos->member.next, typeof(*pos), member))
>>> << and >>
>>>
>>> #define hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)                 \
>>>           for (pos = rcu_dereference_raw(hlist_nulls_first_rcu(head));            \
>>>                   (!is_a_nulls(pos)) &&                                           \
>>>                   ({ tpos = hlist_nulls_entry(pos, typeof(*tpos), member); 1; }); \
>>>                   pos = rcu_dereference_raw(hlist_nulls_next_rcu(pos)))
>>>
>>> We need to change hlist_nulls_for_each_entry_rcu() to use same construct,
>>> so that the rcu_dereference_raw() is performed at the right place.
>>
>> No.
>>
>> This code has the same mistake: it is rcu_dereference_raw(head->first),
>> so there is nothing that prevents gcc to store the (head->first) value
>> in a register.
>
> Please read again what I wrote, you misundertood.
>
> hlist_nulls_for_each_entry_rcu() should use same construct than
> list_for_each_entry_rcu(), and not use rcu_dereference_raw()
>
> Is that clear, or do you want me to send the patch ?

If you think, that it will solve the problem, please, send a patch. I 
think, you are wrong here.
If you think only that it will look better, I agree.

Regards,
Roman
