From: Ulf Samuelsson <ulf@emagii.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Sun, 15 Mar 2015 20:34:30 +0100
Message-ID: <5505DEC6.30006@emagii.com>
References: <1426105727-64654-1-git-send-email-netdev@emagii.com> <55054259.30308@linux-ipv6.org>
Reply-To: ulf@emagii.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Ulf Samuelsson <netdev@emagii.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf3.bahnhof.se ([213.80.101.27]:61434 "EHLO mxf3.bahnhof.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbbCOUBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 16:01:34 -0400
In-Reply-To: <55054259.30308@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 2015-03-15 09:27, YOSHIFUJI Hideaki skrev:
> Hello.
>
> Ulf Samuelsson wrote:
>> From: Ulf Samuelsson <ulf@emagii.com>
>>
>> The neighbour state is changed in the ARP timer handler.
>> If the state is changed to NUD_STALE, then the neighbour
>> entry becomes a candidate for garbage collection.
>>
>> The garbage collection is handled by a "periodic work" routine.
>>
>> When :
>>
>> 	* noone refers to the entry
>> 	* the state is no longer valid (I.E: NUD_STALE).
> NUD_STALE is still valid.
Yes, my fault.
The condition which causes garbage collection to be skipped is.


     if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {

     NUD_STALE is not part of that, so GC will not be skipped,
     and therefore the patch is needed if you want to be able
     to use the API to modify the neigh statemachine..
>
>> 	* the timeout value has  been reached or state is FAILED
>>
>> the "periodic work" routine will notify
>> the stack that the entry should be deleted.
>>
>> A user application monitoring and controlling the neighbour table
>> using NETLINK may fail, if the "period work" routine is run
>> directly after the state has been changed to NUD_STALE,
>> but before the user application has had a chance to change
>> the state to something valid.
>>
>> The "period work" routine will detect the NUD_STALE state
>> and if the timeout value has been reached, it will notify the stack
>> that the entry should be deleted.
>>
>> The patch adds a check in the periodic work routine
>> which will skip test for garbage collection
>> unless a number of ticks has passed since the last time
>> the neighbour entry state was changed.
>>
>> The feature is controlled through Kconfig
>>
>> The featuree is enabled by setting ARP_GC_APPLY_GUARDBAND
>> The guardband time (in ticks) is set in ARP_GC_GUARDBAND
>> Default time is 100 ms if HZ_### is set.
> We have "lower limit" not to start releasing neighbour entries.
> Try increasing gc_thresh1.
Why would  that work?

The only place where this is used is

     "if (atomic_read(&tbl->entries) < tbl->gc_thresh1)"

tbl->entries is related to how many entries there are in the neighbour 
table.

The only way I think this would work, is if this is raised so high that
garbage collection does not occur.

That is not the intention.

It does not solve the race condition between the timer_handler and the 
periodic_work.

BR
Ulf Samuelsson

>
> --yoshfuji
>
>> Signed-off-by: Ulf Samuelsson <ulf@emagii.com>
>> ---
>>   net/Kconfig          |   32 ++++++++++++++++++++++++++++++++
>>   net/core/neighbour.c |   15 ++++++++++++---
>>   2 files changed, 44 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/Kconfig b/net/Kconfig
>> index 44dd578..099a5dd 100644
>> --- a/net/Kconfig
>> +++ b/net/Kconfig
>> @@ -77,6 +77,38 @@ config INET
>>   	  Short answer: say Y.
>>   
>>   if INET
>> +
>> +#
>> +# Core Network configuration
>> +#
>> +
>> +config ARP_GC_APPLY_GUARDBAND
>> +	bool "IP: ARP: Avoid garbage collection directly after state change"
>> +	default n
>> +	---help---
>> +	  With this item selected, an entry in the neighbour table
>> +	  will not be garbage collected directly after the ARP state
>> +	  has changed to STALE of FAILED
>> +	  This allows an application program change the state to something valid
>> +	  before garbage colllection occurs.
>> +
>> +	  If unsure, say N.
>> +
>> +config ARP_GC_GUARDBAND
>> +	int "Guardband time on garbage collection"
>> +	depends on ARP_GC_APPLY_GUARDBAND
>> +	default 10 if HZ_100
>> +	default 25 if HZ_250
>> +	default 30 if HZ_300
>> +	default 100 if HZ_1000
>> +	default 100
>> +
>> +	---help---
>> +	  The number of ticks to delay garbage collection
>> +	  after the neighbour entry has been updated
>> +	  A delay of 100 ms is reasonable.
>> +	  With CONFIG_HZ = 250, this value should be 25
>> +
>>   source "net/ipv4/Kconfig"
>>   source "net/ipv6/Kconfig"
>>   source "net/netlabel/Kconfig"
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 70fe9e1..194195d 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -786,13 +786,23 @@ static void neigh_periodic_work(struct work_struct *work)
>>   
>>   			state = n->nud_state;
>>   			if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
>> -				write_unlock(&n->lock);
>>   				goto next_elt;
>>   			}
>>   
>>   			if (time_before(n->used, n->confirmed))
>>   				n->used = n->confirmed;
>>   
>> +#if defined(CONFIG_ARP_GC_APPLY_GUARDBAND)
>> +			/* Do not garbage collect directly after we
>> +			 * updated n->state to allow applications to
>> +			 * react to the event
>> +			 */
>> +			if (time_before(jiffies,
>> +					n->updated + CONFIG_ARP_GC_GUARDBAND)) {
>> +				goto next_elt;
>> +			}
>> +#endif
>> +
>>   			if (atomic_read(&n->refcnt) == 1 &&
>>   			    (state == NUD_FAILED ||
>>   			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
>> @@ -802,9 +812,8 @@ static void neigh_periodic_work(struct work_struct *work)
>>   				neigh_cleanup_and_release(n);
>>   				continue;
>>   			}
>> -			write_unlock(&n->lock);
>> -
>>   next_elt:
>> +			write_unlock(&n->lock);
>>   			np = &n->next;
>>   		}
>>   		/*
>>


-- 
Best Regards
Ulf Samuelsson
ulf@emagii.com
+46 722 427437
