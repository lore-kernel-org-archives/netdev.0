From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Wed, 7 Sep 2016 23:04:55 -0700
Message-ID: <57D0FF87.604@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34521 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752849AbcIHGQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:16:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so2031874pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:16:35 -0700 (PDT)
In-Reply-To: <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-06 07:52 AM, Eric Dumazet wrote:
> On Thu, 2016-09-01 at 22:57 -0700, Cong Wang wrote:
> 
> 
> 
> Missing changelog ?
> 

Yeah this stuff is a bit tricky more notes to walk us through
this would be helpful. (btw you can disregard my comment from
earlier this morning I've tracked most of this down now)

> Here I have no idea what you want to fix, since John already took care
> all this infra.
> 
> Adding extra rcu_dereference() and rcu_read_lock() while the critical
> RCU dereferences already happen in callers is not needed.
> 

Agreed drop all the extra rcu_read_lock/unlock here.

>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/sched/act_api.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 2f8db3c..fb6ff52 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -470,10 +470,14 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
>>  		goto exec_done;
>>  	}
>>  	for (i = 0; i < nr_actions; i++) {
>> -		const struct tc_action *a = actions[i];
>> +		const struct tc_action *a;
>>  
>> +		rcu_read_lock();
> 
> But the caller already has rcu_read_lock() or rcu_read_lock_bh()
> 
> This was done in commit 25d8c0d55f241ce2 ("net: rcu-ify tcf_proto")
> 
>> +		a = rcu_dereference(actions[i]);
> 
> 
> Add in your .config :
> CONFIG_SPARSE_RCU_POINTER=y
> make C=2 M=net/sched
> 
>>  repeat:
>>  		ret = a->ops->act(skb, a, res);
>> +		rcu_read_unlock();
>> +
>>  		if (ret == TC_ACT_REPEAT)
>>  			goto repeat;	/* we need a ttl - JHS */
>>  		if (ret != TC_ACT_PIPE)
> 
> 
> 
> I do not believe this patch is necessary.
> 
> Please add John as reviewer next time.
> 
> Thanks.
> 
> 

So the actual issue as I see it is with the late binding actions the
ones created with the ill documented 'tc action' syntax.

If you add a rule here and then bind it to a filter (stealing Jamals
example),

  tc actions add action skbedit mark 10 index 1
  tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
             match ip dst 17.0.0.1/32 flowid 1:10 action skbedit index 1

then you can modify this action later with the following

  tc actions replace action ....

So for an action such as act_mirred we may end up running with a
partially updated state from this,

	tcf_mirred_init(...)
	[...]

		m->tcf_action = parm->action;
	        m->tcfm_eaction = parm->eaction;
	
		[...]
	

and then in the execution of the action,


	tcf_mirred(...)
		[...]
	        retval = READ_ONCE(m->tcf_action);
		[...]
                if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
		[...]


So its at least possible I think these could be interleaved on multiple
cpus.

Notice that some of the actions are fine though and don't have this
issue act_bpf for example is fine.

I think we can either fix it in the hash table create part of the
list as this series does or just let each action handle it on its own.

.John
