From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Fri, 26 Sep 2008 08:49:40 -0500
Message-ID: <48DCE874.8070704@acm.org>
References: <20080926031832.GA27289@minyard.local>
 <20080926040917.GB7209@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, jarkao2@gmail.com, shemminger@vyatta.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:42611 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbYIZNtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 09:49:45 -0400
In-reply-to: <20080926040917.GB7209@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> On Thu, Sep 25, 2008 at 10:18:33PM -0500, Corey Minyard wrote:
>   
>> From: Corey Minyard <cminyard@mvista.com>
>>
>> Convert access to the udp_hash table to use RCU.
>>     
>
> Looks much better!
>
> Some rcu_dereference() fixes, a comment fix, and a question below.
>
> 							Thanx, Paul
>
>   
>> Signed-off-by: Corey Minyard <cminyard@mvista.com>
>> ---
>>  include/linux/rculist.h |   19 +++++++++++++++++
>>  include/net/sock.h      |   51 +++++++++++++++++++++++++++++++++++++++++++++++
>>  include/net/udp.h       |    9 ++++---
>>  net/ipv4/udp.c          |   47 ++++++++++++++++++++++++------------------
>>  net/ipv6/udp.c          |   17 ++++++++-------
>>  5 files changed, 111 insertions(+), 32 deletions(-)
>>
>> This patch is the second try; I believe I fixed all issues that people
>> raised.  Thanks to everyone who commented on this.
>>
>> I beat on this for a few hours with my test program, too.
>>
>> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
>> index eb4443c..4d3cc58 100644
>> --- a/include/linux/rculist.h
>> +++ b/include/linux/rculist.h
>> @@ -397,5 +397,24 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
>>  		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
>>  		pos = rcu_dereference(pos->next))
>>
>> +
>> +/**
>> + * hlist_for_each_entry_from_rcu - iterate over rcu list starting from pos
>> + * @tpos:      the type * to use as a loop cursor.
>> + * @pos:       the &struct hlist_node to use as a loop cursor.
>> + * @head:      the head for your list.
>> + * @member:    the name of the hlist_node within the struct.
>> + *
>> + * This list-traversal primitive may safely run concurrently with
>> + * the _rcu list-mutation primitives such as hlist_add_head_rcu()
>> + * as long as the traversal is guarded by rcu_read_lock().
>> + */
>> +#define hlist_for_each_entry_from_rcu(tpos, pos, member)                \
>> +	for (;                                                          \
>> +	     rcu_dereference(pos) && ({ prefetch(pos->next); 1; }) &&    \
>> +	       ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
>> +	     pos = pos->next)
>>     
>
> Always apply rcu_dereference() to whatever it was that you
> rcu_assign_pointer()ed to.  You don't need the first rcu_dereference()
> because you (hopefully) used rcu_dereference() either directly or 
> indirectly when picking up the pointer in the first place.  You -do-
> need one on the ->next, however.
>
> So something like this:
>
> +#define hlist_for_each_entry_from_rcu(tpos, pos, member)                \
> +	for (;                                                          \
> +	     (pos) && ({ prefetch(pos->next); 1; }) &&    \
> +	       ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
> +	     pos = rcu_dereference((pos)->next))
>   
Yes, of course, I've changed it.

> Interesting, though -- you repeat whatever one you stopped on
> previously, unlike the _continue_ variants.
>   
Yes, it is interesting, but it preserves the semantics of 
hlist_for_each_entry_from().  It's the semantics you want in this case, 
and I think the "from" name implies the semantics.

>   
>> +	/*
>> +	 * Note that this is safe, even with an RCU lock.
>> +	 * udp_lib_unhash() is the removal function, it calls
>> +	 * synchronize_sched() and the socket counter cannot go to
>>     
>
> synchronize_rcu(), right?
>   
Yes, thanks.
>   
>> +	 * zero until it returns.  So if we increment it inside the
>> +	 * RCU read lock, it should never go to zero and then be
>> +	 * incremented again.
>>     
>
> So the caller of udp_lib_unhash() does the decrement?  Looks like this
> might be sk_common_release(), but too many pointers to functions.  One
> could also argue for udp_disconnect()...
>   
I don't believe udp_disconnect() releases the socket.  
sk_common_release() seems to be the place where the refcount is 
decremented.  But wherever it is done, it would have to be after the unhash.

/me fires up the test harness again.

Thanks,

-corey
