From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 10/15] net: sched: rcu'ify cls_rsvp
Date: Tue, 09 Sep 2014 09:46:20 -0700
Message-ID: <540F2EDC.2050804@gmail.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>  <20140909055844.2071.50705.stgit@nitbit.x32> <1410269221.11872.179.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:64812 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbaIIQqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 12:46:37 -0400
Received: by mail-oa0-f44.google.com with SMTP id o6so12052543oag.3
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 09:46:36 -0700 (PDT)
In-Reply-To: <1410269221.11872.179.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 06:27 AM, Eric Dumazet wrote:
> On Mon, 2014-09-08 at 22:58 -0700, John Fastabend wrote:
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   net/sched/cls_rsvp.h |  155 +++++++++++++++++++++++++++++---------------------
>>   1 file changed, 89 insertions(+), 66 deletions(-)
>>
>> diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
>> index 1020e23..8a35bdc 100644

[...]

>> @@ -521,12 +535,17 @@ insert:
>>
>>   			tcf_exts_change(tp, &f->exts, &e);
>>
>> -			for (fp = &s->ht[h2]; *fp; fp = &(*fp)->next)
>> -				if (((*fp)->spi.mask & f->spi.mask) != f->spi.mask)
>> +			fp = &s->ht[h2];
>> +			for (nfp = rtnl_dereference(*fp); nfp;
>> +			     fp = &nfp->next, nfp = rtnl_dereference(*fp)) {
>> +				__u32 mask = nfp->spi.mask & f->spi.mask;
>> +
>> +				if (mask != f->spi.mask)
>>   					break;
>> -			f->next = *fp;
>> +			}
>> +			rcu_assign_pointer(f->next, nfp);
>
> RCU_INIT_POINTER()
>
>>   			wmb();
>
> Are you sure we need to keep this wmb() ? I dont think so.

Agreed, I'll remove it.

>
>> -			*fp = f;
>> +			rcu_assign_pointer(*fp, f);
>>
>>   			*arg = (unsigned long)f;
>>   			return 0;
>> @@ -546,13 +565,15 @@ insert:
>>   		s->protocol = pinfo->protocol;
>>   		s->tunnelid = pinfo->tunnelid;
>>   	}
>> -	for (sp = &data->ht[h1]; *sp; sp = &(*sp)->next) {
>> -		if (((*sp)->dpi.mask&s->dpi.mask) != s->dpi.mask)
>> +	sp = &data->ht[h1];
>> +	for (nsp = rtnl_dereference(*sp); nsp;
>> +	     sp = &nsp->next, nsp = rtnl_dereference(*sp)) {
>> +		if ((nsp->dpi.mask & s->dpi.mask) != s->dpi.mask)
>>   			break;
>>   	}
>> -	s->next = *sp;
>> +	rcu_assign_pointer(s->next, nsp);
>
> 	RCU_INIT_POINTER()
>
>>   	wmb();
>
> This wmb() can be removed.
>

yep, same here I'll remove it.


Thanks,
John

-- 
John Fastabend         Intel Corporation
