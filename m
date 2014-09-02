From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 02/15] net: rcu-ify tcf_proto
Date: Mon, 01 Sep 2014 18:39:13 -0700
Message-ID: <54051FC1.6030106@gmail.com>
References: <20140825004659.2180.35028.stgit@nitbit.x32> <20140825004830.2180.70308.stgit@nitbit.x32> <20140824.223133.170922940598584254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:63351 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaIBBjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:39:39 -0400
Received: by mail-ob0-f171.google.com with SMTP id wn1so4326555obc.16
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:39:39 -0700 (PDT)
In-Reply-To: <20140824.223133.170922940598584254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2014 10:31 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sun, 24 Aug 2014 17:48:31 -0700
>
>> @@ -722,8 +724,9 @@ static void sfq_free(void *addr)
>>   static void sfq_destroy(struct Qdisc *sch)
>>   {
>>   	struct sfq_sched_data *q = qdisc_priv(sch);
>> +	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
>>
>> -	tcf_destroy_chain(&q->filter_list);
>> +	tcf_destroy_chain(&fl);

Sorry for the delayed reply...

>
> This will cause tcf_destroy_chain() to set the local variable
> 'fl' to NULL rather than q->filter_list.
>
> I don't see how this can be correct at all.

Right now (without these patches) nothing sets q->filter_list
to NULL and we only call this when the qdisc is being destroyed.
In all cases there is a rcu_assign_pointer() to detach the qdisc
from the netdev_queue followed by a synchronize_net().

	dev_deactivate_many
	   [...]
	   dev_deactivate_queue
		rcu_assign_pointer(dev_queue->qdisc, qdisc_default)

  	   [...]
	   synchronize_net()

After the synchronize_net there should be no other references
to q->filter_list other then in the destroy path so I think it
works and the rtnl_dereference in my patch is there for annotation
to make sparse happy but doesn't change the logic.

Does that make sense?

>
> You need to make tcf_destroy_chain() take a pointer to an __rcu
> pointer, and do the proper dereferencing and RCU assignments in
> that chain destroy loop.
>
> This might be why you're getting annotation warnings.
>

The annotation warnings comes from the find_tcf blocks for example
here is the block in the sfq scheduler,

     struct sfq_sched_data *q = qdisc_priv(sch);

     if (cl)
         return NULL;
     return &q->filter_list;

This is called inside the rtnl lock but filter list is rcu protected
fixing the function types like this seems to resolve it,

     static struct tcf_proto * __rcu *sfq_find_tcf(struct Qdisc *sch, 
unsigned long cl)

and similarly the ops struct,

     struct tcf_proto * __rcu * (*tcf_chain)(struct Qdisc *, unsigned long);

This fixes the sparse warnings and looks correct to me. I'll send
an update with these fixes.

Thanks!
John



-- 
John Fastabend         Intel Corporation
