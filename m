From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 07/15] net: sched: RCU cls_route
Date: Tue, 09 Sep 2014 09:24:02 -0700
Message-ID: <540F29A2.8050805@gmail.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>  <20140909055703.2071.75757.stgit@nitbit.x32> <1410267553.11872.167.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:45464 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbaIIQYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 12:24:22 -0400
Received: by mail-ob0-f174.google.com with SMTP id uz6so12173486obc.33
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 09:24:19 -0700 (PDT)
In-Reply-To: <1410267553.11872.167.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 05:59 AM, Eric Dumazet wrote:
> On Mon, 2014-09-08 at 22:57 -0700, John Fastabend wrote:
>> RCUify the route classifier. For now however spinlock's are used to
>> protect fastmap cache.
>>
>> The issue here is the fastmap may be read by one CPU while the
>> cache is being updated by another. An array of pointers could be
>> one possible solution.
>
> Yep, this doesnt seem like an urgent issue anyway.
>
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---


[...]

>> @@ -296,27 +324,35 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
>>   	h = f->handle;
>>   	b = f->bkt;
>>
>> -	for (fp = &b->ht[from_hash(h >> 16)]; *fp; fp = &(*fp)->next) {
>> -		if (*fp == f) {
>> -			tcf_tree_lock(tp);
>> +	fp = &b->ht[from_hash(h >> 16)];
>> +	for (nf = rtnl_dereference(*fp); nf;
>> +	     fp = &nf->next, nf = rtnl_dereference(*fp)) {
>> +		if (nf == f) {
>> +			/* unlink it */
>>   			*fp = f->next;
>
> Strange you left this without annotations, while rest of your patches
> always use rcu_assign_pointer(*fp, rtnl_dereference(f->next)
>
> Note that it is absolutely fine to use *fp = f->next;
>
> ;)
>

I was just trying to be explicit in the other cases although I
chose rcu_assign_pointer in many cases instead of INIT_POINTER. So for
consistency I'll make this,

	RCU_INIT_POINTER(*fp, rtnl_dereference(f->next))

I also thought that sparse would warn about not wrapping f->next in
rtnl_dereference, but apparently that is not the case.

>> -			tcf_tree_unlock(tp);
>>
>
>
>


-- 
John Fastabend         Intel Corporation
