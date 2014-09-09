From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 09/15] net: sched: make cls_u32 lockless
Date: Tue, 09 Sep 2014 09:35:23 -0700
Message-ID: <540F2C4B.6060404@gmail.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>  <20140909055815.2071.39668.stgit@nitbit.x32> <1410268807.11872.177.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:41458 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751AbaIIQfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 12:35:38 -0400
Received: by mail-ob0-f177.google.com with SMTP id va2so1094130obc.36
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 09:35:38 -0700 (PDT)
In-Reply-To: <1410268807.11872.177.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 06:20 AM, Eric Dumazet wrote:
> On Mon, 2014-09-08 at 22:58 -0700, John Fastabend wrote:
>> Make cls_u32 classifier safe to run without holding lock. This patch
>> converts statistics that are kept in read section u32_classify into
>> per cpu counters.
>>
>> This patch was tested with a tight u32 filter add/delete loop while
>> generating traffic with pktgen. By running pktgen on vlan devices
>> created on top of a physical device we can hit the qdisc layer
>> correctly. For ingress qdisc's a loopback cable was used.
>>
>> for i in {1..100}; do
>>          q=`echo $i%8|bc`;
>>          echo -n "u32 tos: iteration $i on queue $q";
>>          tc filter add dev p3p2 parent $p prio $i u32 match ip tos 0x10 0xff \
>>                    action skbedit queue_mapping $q;
>>          sleep 1;
>>          tc filter del dev p3p2 prio $i;
>>
>>          echo -n "u32 tos hash table: iteration $i on queue $q";
>>          tc filter add dev p3p2 parent $p protocol ip prio $i handle 628: u32 divisor 1
>>          tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>>                  match ip protocol 17 0xff link 628: offset at 0 mask 0xf00 shift 6 plus 0
>>          tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
>>                  ht 628:0 match ip tos 0x10 0xff action skbedit queue_mapping $q
>>          sleep 2;
>>          tc filter del dev p3p2 prio $i
>>          sleep 1;
>> done
>>
>
>
> Note it might be easier to split this patch in 2 parts.
>
> (The percpu stuff could be done in a first step, then rcu conversion)

Sure, I'll split it up.

>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>>
>>   static inline unsigned int u32_hash_fold(__be32 key,
>> @@ -96,7 +103,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
>>   		unsigned int	  off;
>>   	} stack[TC_U32_MAXDEPTH];
>>
>> -	struct tc_u_hnode *ht = tp->root;
>> +	struct tc_u_hnode *ht = rcu_dereference_bh(tp->root);
>>   	unsigned int off = skb_network_offset(skb);
>>   	struct tc_u_knode *n;
>>   	int sdepth = 0;
>> @@ -108,23 +115,23 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
>>   	int i, r;
>>
>>   next_ht:
>> -	n = ht->ht[sel];
>> +	n = rcu_dereference_bh(ht->ht[sel]);
>>
>>   next_knode:
>>   	if (n) {
>>   		struct tc_u32_key *key = n->sel.keys;
>>
>>   #ifdef CONFIG_CLS_U32_PERF
>> -		n->pf->rcnt += 1;
>> +		this_cpu_inc(n->pf->rcnt);
>
> As we run in BH, we are not preemptable, we can use instead :
> __this_cpu_inc()  (on all occurrences)
>
> Using a macro would also reduce the #ifdef mess of this file
>

I'll go ahead and do the macro conversion.

>>   		j = 0;
>>   #endif
>>
>>   #ifdef CONFIG_CLS_U32_MARK
>> -		if ((skb->mark & n->mark.mask) != n->mark.val) {
>> -			n = n->next;
>> +		if ((skb->mark & n->mask) != n->val) {
>> +			n = rcu_dereference_bh(n->next);
>>   			goto next_knode;
>>   		} else {
>> -			n->mark.success++;
>> +			this_cpu_inc(*n->pcpu_success);
>>   		}
>>   #endif
>>

[...]


>> @@ -326,11 +342,11 @@ static int u32_init(struct tcf_proto *tp)
>>   	}
>>
>>   	tp_c->refcnt++;
>> -	root_ht->next = tp_c->hlist;
>> -	tp_c->hlist = root_ht;
>> +	rcu_assign_pointer(root_ht->next, tp_c->hlist);
>
> 	RCU_INIT_POINTER() or root_ht->next = tp_c->hlist;
>

I'll fix all these as well.

>> +	rcu_assign_pointer(tp_c->hlist, root_ht);
>>   	root_ht->tp_c = tp_c;
>>
>> -	tp->root = root_ht;
>> +	rcu_assign_pointer(tp->root, root_ht);
>>   	tp->data = tp_c;
>>   	return 0;
>>   }
>> @@ -342,25 +358,33 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
>>   	if (n->ht_down)
>>   		n->ht_down->refcnt--;
>>   #ifdef CONFIG_CLS_U32_PERF
>> -	kfree(n->pf);
>> +	free_percpu(n->pf);
>>   #endif
>>   	kfree(n);
>>   	return 0;
>>   }
>>
>> +void __u32_delete_key(struct rcu_head *rcu)
>
> Can we consistently use _rcu, as in u32_delete_key_rcu() ?

Yes, I'll rename these calls.

Thanks,
John

-- 
John Fastabend         Intel Corporation
