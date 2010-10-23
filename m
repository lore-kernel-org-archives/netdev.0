From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 11:33:41 -0400
Message-ID: <4CC30055.5040509@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop> <1287846669.2658.247.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:55622 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757581Ab0JWPds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 11:33:48 -0400
In-Reply-To: <1287846669.2658.247.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>
> Did that... Hmm...
>
> I am wondering if smp_rcu_assign_pointer() (or more precisely smp_wmb())
> is correctly implemented on octeon platform.
>
> Try to add in fib_nl_newrule() right after the kzalloc bloc :
>
> 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
> 	if (rule == NULL) {
> 		err = -ENOMEM;
> 		goto errout;
> 	}
> +       rule->list.next = LIST_POISON1;
> +       rule->list.prev = LIST_POISON2;
>
>
> So that we can actually see if the NULL dereference bug you hit becomes
> a "LIST_POISON1" dereference bug...
>
>
>   

Thanks -- I'll try it when I'm back in the office Tuesday.

It is always possible that there is some issue with the Octeon memory
barrier stuff, but I would think that the system would be much more
unstable than it is -- we're really beating on a dual CPU LINUX instance
that has Java and C++ apps running and also doing some network I/O.

My strategy at this point is logging events to memory and dumping the
log to the console at the time of the panic.  I might be able to figure
out the sequence of events causing the crash.

The load test that causes the panic is using several dozen TAP
interfaces, ifconfig'd up/down every 10 seconds or so, with
source-routes, DNAT and SNAT being set up and taken down also.

Joe Buehler
