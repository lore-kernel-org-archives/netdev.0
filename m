From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Thu, 08 Sep 2016 06:28:03 -0700
Message-ID: <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
         <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
         <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <57D0FF87.604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34592 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752803AbcIHN2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 09:28:07 -0400
Received: by mail-pa0-f65.google.com with SMTP id gi6so2422208pac.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 06:28:07 -0700 (PDT)
In-Reply-To: <57D0FF87.604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 23:04 -0700, John Fastabend wrote:

> So the actual issue as I see it is with the late binding actions the
> ones created with the ill documented 'tc action' syntax.
> 
> If you add a rule here and then bind it to a filter (stealing Jamals
> example),
> 
>   tc actions add action skbedit mark 10 index 1
>   tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
>              match ip dst 17.0.0.1/32 flowid 1:10 action skbedit index 1
> 
> then you can modify this action later with the following
> 
>   tc actions replace action ....
> 
> So for an action such as act_mirred we may end up running with a
> partially updated state from this,
> 
> 	tcf_mirred_init(...)
> 	[...]
> 
> 		m->tcf_action = parm->action;
> 	        m->tcfm_eaction = parm->eaction;
> 	
> 		[...]
> 	
> 
> and then in the execution of the action,
> 
> 
> 	tcf_mirred(...)
> 		[...]
> 	        retval = READ_ONCE(m->tcf_action);
> 		[...]
>                 if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
> 		[...]
> 
> 
> So its at least possible I think these could be interleaved on multiple
> cpus.

Sure, this was very clear when I wrote this code. Otherwise I would have
used an intermediate object and one rcu_dereference() instead of the
READ_ONCE().


> 
> Notice that some of the actions are fine though and don't have this
> issue act_bpf for example is fine.
> 
> I think we can either fix it in the hash table create part of the
> list as this series does or just let each action handle it on its own.

If we want a fix for stable kernels we want a tc_mirred fix on its own,
and I was planning to do so.

Given that a "tc qdisc replace ..." drops all packets sitting in the old
qdisc, I never thought someone would actually depend on atomically
switching tc_mirred parameters. I for sure did not care.

Thanks.
