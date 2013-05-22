From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 23:17:46 +0400
Message-ID: <519D19DA.50400@yandex-team.ru>
References: <20130521120906.GD3578@linux.vnet.ibm.com> <1369143885.3301.221.camel@edumazet-glaptop> <519B8908.9080007@yandex-team.ru> <1369150693.3301.233.camel@edumazet-glaptop> <519BB90B.6080706@yandex-team.ru> <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop> <519CC2FB.2010006@yandex-team.ru> <20130522174532.GC3431@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522174532.GC3431@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.05.2013 21:45, Paul E. McKenney wrote:
> On Wed, May 22, 2013 at 05:07:07PM +0400, Roman Gushchin wrote:
>> On 22.05.2013 16:30, Eric Dumazet wrote:
>>> On Wed, 2013-05-22 at 15:58 +0400, Roman Gushchin wrote:
>>>
>>>> +/*
>>>> + * Same as ACCESS_ONCE(), but used for accessing field of a structure.
>>>> + * The main goal is preventing compiler to store &ptr->field in a register.
>>>
>>> But &ptr->field is a constant during the whole duration of
>>> udp4_lib_lookup2() and could be in a register, in my case field is at
>>> offset 0, and ptr is a parameter (so could be in a 'register')
>>>
>>> The bug you found is that compiler caches the indirection  (ptr->field)
>>> into a register, not that compiler stores &ptr->field into a register.
>>>
>>>> + */
>>>> +#define ACCESS_FIELD_ONCE(PTR, FIELD) (((volatile typeof(*PTR) *)PTR)->FIELD)
>>>> +
>>>
>>> Here we force the compiler to consider ptr as volatile, but semantically
>>> it is not required in rcu_dereference(ptr->field)
>>
>> Actually, we need to mark an "address of a place" where the field value is
>> located as volatile before dereferencing. I have no idea how to do it in another way,
>> except using multiple casts and offsetof's, but, IMHO, it will be even more complex:
>> 	ACCESS_ONCE(typeof(&ptr->field)((char*)ptr + offsetof(typeof(*ptr), field)))

Probably I miss one more ACCESS_ONCE() in this expression. Should be something like
ACCESS_ONCE(typeof(&ptr->field)((char*)ACCESS_ONCE(ptr) + offsetof(typeof(*ptr), field))) .
But this is not a working example, just an illustration against using ACCESS_ONCE() here.

> Why not just ACCESS_ONCE(ptr->field)?  Or if it is the thing that
> ptr->field points to that is subject to change, ACCESS_ONCE(*ptr->field)?
>
> Or rcu_dereference(ptr->field), as appropriate?

It's not enough. So is the code now, and it doesn't work as expected.
You can't write (ptr->field) without ptr being marked as a volatile pointer.

I try to explain the problem once more from scratch:

1) We have the following pseudo-code (based on udp4_lib_lookup2()):

static void some_func(struct hlist_nulls_head *head) {
	struct hlist_nulls_node *node;

begin:
	for (node = rcu_dereference(head->first);
		!is_nulls(node) & ...;
		node = rcu_dereference(node->next)) {
		<...>
	}

	if (restart_condition)
		goto begin;

2) A problem occurs when restart_condition is true and we jump to the begin label.
We do not recalculate (head + offsetof(head, first)) address, we just dereference
again the OLD (head->first) pointer. So, we get a node, that WAS the first node in a
previous time instead of current first node. That node can be dead, or, for instance,
can be a head of another chain.

It is correct from gcc's point of view, since it doesn't expect the head pointer
to change, and this address is just (head + constant offset).

3) If we start with a wrong first element, restart_condition can be always true, so,
we get an infinite loop. In any case, we do not scan the whole (socket) chain,
as expected.

This scenario is absolutely real and causes our DNS servers to hang
sometimes under high load.

Note, that there are no problems if we don't restart a loop. Also, it is highly
dependent on gcc options, and the code in the body of the loop. Even small changes
in the code (like adding debugging print) preventing reproducing of the issue.

Thanks!

Regards,
Roman
