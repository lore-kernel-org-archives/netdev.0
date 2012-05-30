From: dave taht <dave.taht@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Wed, 30 May 2012 08:00:57 -0700
Message-ID: <4FC63629.7090404@gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>  <88c43001441945e1431609db252b69e7@visp.net.lb>  <df211722d18136698aeeda2f17b876e2@visp.net.lb>  <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>  <CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>  <79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>  <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>  <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>  <CA+mtBx_uYy9XcRvpD2E46FuMBFu38iQvCiwFHWqbhPBmY=JfOg@mail.gmail.com>  <20120530090602.6204d857.shimoda.hiroaki@gmail.com>  <1338367231.2760.125.camel@edumazet-glaptop>  <20120530194355.92bf5d51.shimoda.hiroaki@gmail.com>  <1338376107.2760.156.camel@edumazet-glaptop>  <20120530202917.b2642929.shimoda.hiroaki@gmail.com> <1338389342.2760.195.camel@edumazet
 -glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55128 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171Ab2E3PBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 11:01:02 -0400
Received: by pbbrp8 with SMTP id rp8so67502pbb.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 08:01:01 -0700 (PDT)
In-Reply-To: <1338389342.2760.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2012 07:49 AM, Eric Dumazet wrote:
> On Wed, 2012-05-30 at 20:29 +0900, Hiroaki SHIMODA wrote:
>> On Wed, 30 May 2012 13:08:27 +0200
>> Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>>
>>> On Wed, 2012-05-30 at 19:43 +0900, Hiroaki SHIMODA wrote:
>>>
>>>> While examining ping problem, below pattern is often observed.
>>>>
>>>>                                                 TIME
>>>>         dql_queued()         dql_completed()     |
>>>>        a) initial state                          |
>>>>                                                  |
>>>>        b) X bytes queued                         V
>>>>
>>>>        c) Y bytes queued
>>>>                             d) X bytes completed
>>>>        e) Z bytes queued
>>>>                             f) Y bytes completed
>>>>
>>>> a) dql->limit has already some value and there is no in-flight packet.
>>>> b) X bytes queued.
>>>> c) Y bytes queued and excess limit.
>>>> d) X bytes completed and dql->prev_ovlimit is set and also
>>>>     dql->prev_num_queued is set Y.
>>>> e) Z bytes queued.
>>>> f) Y bytes completed. inprogress and prev_inprogress are true.
>>>>
>>>> At f), if I read the comment correctly, all_prev_completed becomes
>>>> true and limit should be increased. But POSDIFF() ignores
>>>> (A == B) case, so limit is decreased.
>>> Which POSDIFF(), because there are many ;)
>> I mean,
>> 	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
>>
>>> By the way, given complexity of this I suggest you split your ideas in
>>> independent patches.
>> In this case, here is the patch what I thinking.
>>
>> diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
>> @@ -11,12 +11,14 @@
>>   #include<linux/dynamic_queue_limits.h>
>>
>>   #define POSDIFF(A, B) ((A)>  (B) ? (A) - (B) : 0)
>> +#define #define AFTER_EQ(A, B) ((int)((A) - (B))>= 0)
>>
>>   /* Records completed count and recalculates the queue limit */
>>   void dql_completed(struct dql *dql, unsigned int count)
>>   {
>>   	unsigned int inprogress, prev_inprogress, limit;
>> -	unsigned int ovlimit, all_prev_completed, completed;
>> +	unsigned int ovlimit, completed;
>> +	bool all_prev_completed;
>>
>>   	/* Can't complete more than what's in queue */
>>   	BUG_ON(count>  dql->num_queued - dql->num_completed);
>> @@ -26,7 +28,7 @@ void dql_completed(struct dql *dql, unsigned int count)
>>   	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
>>   	inprogress = dql->num_queued - completed;
>>   	prev_inprogress = dql->prev_num_queued - dql->num_completed;
>> -	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
>> +	all_prev_completed = AFTER_EQ(completed, dql->prev_num_queued);
>>
>>   	if ((ovlimit&&  !inprogress) ||
>>   	    (dql->prev_ovlimit&&  all_prev_completed)) {
> I am fine with this one.
>
> Can you send official patches please ?

While this looks encouraging, BQL presently overbuffers by about a 
factor of 2 in low (sub 100Mbit) scenarios
on the hardware I have available to me.

I look forward to re-running benchmarks with this patch however.

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
