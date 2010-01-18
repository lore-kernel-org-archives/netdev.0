From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] list.h: add list_for_each_struct_entry macro
Date: Mon, 18 Jan 2010 22:07:19 +0100
Message-ID: <20100118210718.GC4521@psychotron.redhat.com>
References: <20100118162338.GD4229@psychotron.lab.eng.brq.redhat.com>
 <1263835033.3667.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754717Ab0ARVHc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1263835033.3667.23.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jan 18, 2010 at 06:17:13PM CET, bhutchings@solarflare.com wrote:
>On Mon, 2010-01-18 at 17:23 +0100, Jiri Pirko wrote:
>> When preparing to upcoming migration of mc_list (list of multicast MACs)
>> to list_head, the need of traversing the list over one structure member
>> appeared. I thought I'll do it locally but I decided that an intruduction
>> the macro in list.h would be much clearer. Please kindly for a review.
>> 
>> Jirka
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>> diff --git a/include/linux/list.h b/include/linux/list.h
>> index 969f6e9..8350a94 100644
>> --- a/include/linux/list.h
>> +++ b/include/linux/list.h
>> @@ -420,6 +420,22 @@ static inline void list_splice_tail_init(struct list_head *list,
>>  	     pos = list_entry(pos->member.prev, typeof(*pos), member))
>>  
>>  /**
>> + * list_for_each_struct_entry  -       iterate over list of given type using
>> + *                                     the struct member.
>> + * @pos:       the type * to use as a loop cursor.
>> + * @head:      the head for your list.
>> + * @type:      the type of the struct.
>> + * @posmember: the name ot the loop cursor within the struct.
>> + * @member:    the name of the list_struct within the struct.
>> + */
>> +#define list_for_each_struct_entry(pos, head, type, posmember, member)		\
>> +	for (pos = list_entry((head)->next, type, member)->posmember;		\
>
>Surely &list_entry(...)->posmember ?

Ugh, right, I tested this with char * so it worked well. Got i corrected now so
I can repost.

>
>> +	     prefetch(container_of(pos, type, posmember)->member.next),		\
>> +	     &container_of(pos, type, posmember)->member != (head);		\
>
>It seems a bit dodgy to do this pointer arithmetic on a list node which
>might be the list head.

Well I tried to be as much close to other traverse macros as it could be.

>
>> +	     pos = list_entry(container_of(pos, type, posmember)->member.next,	\
>> +	     type, member)->posmember)
>
>My version:
>
>#define list_for_each_struct_entry(pos, head, type, posmember, member)	     \
>	for (pos = list_empty(head) ? NULL :				     \
>		&list_first_entry(head, type, member)->posmember;	     \
>	     prefetch(container_of(pos, type, posmember)->member.next), pos; \
>	     pos = list_is_last(&container_of(pos, type, posmember)->member, \
>				head) ?	NULL :				     \
>		&list_entry(container_of(pos, type, posmember)->member.next, \
>			    type, member)->posmember)
>

At the first glance, this would take even more cputime for lists longer
than 2 or so, wouldn't it?


Jirka

>Ben.
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
