From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v5 13/16] net: sched: make tc_action safe to
 walk under RCU
Date: Fri, 12 Sep 2014 17:05:00 -0700
Message-ID: <54138A2C.8000301@gmail.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>  <20140912163403.19588.26443.stgit@nitbit.x32> <1410555114.7106.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:37071 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaIMAFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 20:05:20 -0400
Received: by mail-oi0-f43.google.com with SMTP id i138so1031775oig.16
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 17:05:19 -0700 (PDT)
In-Reply-To: <1410555114.7106.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 01:51 PM, Eric Dumazet wrote:
> On Fri, 2014-09-12 at 09:34 -0700, John Fastabend wrote:
>
>> Second there is a suspect usage of list_splice_init_rcu() in the
>> tcf_exts_change() routine. Notice how it is used twice in succession
>> and the second init works on the src tcf_exts. There is probably a
>> better way to accomplish that.

Not only is it suspect its broke as best as I can tell.

>>
>
>
>> +/* It is not safe to use src->actions after this due to _init_rcu usage
>> + * INIT_LIST_HEAD_RCU() is called on src->actions
>> + */
>>   void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
>>   		     struct tcf_exts *src)
>>   {
>>   #ifdef CONFIG_NET_CLS_ACT
>>   	LIST_HEAD(tmp);
>> -	tcf_tree_lock(tp);
>> -	list_splice_init(&dst->actions, &tmp);



>> -	list_splice(&src->actions, &dst->actions);
>> -	tcf_tree_unlock(tp);

Here we have three lists,

	 tmp  (which has just been initialized)

	  dst -> act1 -> act2 -> ... -> actn ->

	  src -> acta -> actb -> ... -> actn ->

The active list is dst from the tc_classify and we want to
switch to the src list


>> +	list_splice_init_rcu(&dst->actions, &tmp, synchronize_rcu);

Now we spliced in tmp and did an INIT_LIST_HEAD_RCU() on dst->actions
(oops) so the lists look like this

	tmp -> act1 -> act2 -> ... -> actn ->

	dst

	src  -> acta -> actb -> ... -> actn ->

The active list is still dst from the tc_classify caller so now we are
missing both the old and new action lists. This is broke.


>> +	list_splice_init_rcu(&src->actions,
>> +			     &dst->actions,
>> +			     synchronize_rcu);

But the final state is what we wanted,

	tmp -> act1 -> act2 -> ... -> actn ->

	dst -> acta -> actb -> ... -> actn ->

	src

>>   	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);

Finally clean it all up,

	tmp

	dst -> acta -> actb -> ... -> actn ->

	src


>>   #endif
>>   }
>
> I am afraid I do not understand this part.

Because it doesn't work as far as I can tell. What I really want here
is to swap the head pointer with,


	struct list_head *tmp = dst->actions;

	rcu_assign_pointer(dst->actions, src->actions)
	synchronize_rcu()
	tcf_action_destroy(tmp);


This requires a bit more work. I'll work out a patch after a bit more
thought.

Thanks again!

.John



-- 
John Fastabend         Intel Corporation
