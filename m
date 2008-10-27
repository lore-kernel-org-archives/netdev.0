From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 10:30:35 +0100
Message-ID: <20081027093035.GA23743@elte.hu>
References: <20081026092722.GA24799@ioremap.net> <20081026023439.c6cf4e94.akpm@linux-foundation.org> <20081026100555.GA26033@ioremap.net> <20081026.193451.36032548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, akpm@linux-foundation.org, a.p.zijlstra@chello.nl,
	efault@gmx.de, jkosina@suse.cz, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40085 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058AbYJ0Jba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 05:31:30 -0400
Content-Disposition: inline
In-Reply-To: <20081026.193451.36032548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Sun, 26 Oct 2008 13:05:55 +0300
> 
> > I'm not surprised there were no changes when I reported hrtimers to be
> > the main guilty factor in my setup for dbench tests, and only when David
> > showed that they also killed his sparks via wake_up(), something was
> > done. Now this regression even dissapeared from the list.
> > Good direction, we should always follow this.
> 
> Yes, this situation was in my opinion a complete fucking joke.  
> Someone like me shouldn't have to do all of the hard work for the 
> scheduler folks in order for a bug like this to get seriously looked 
> at.

yeah, that overhead was bad, and once it became clear that you had 
high-resolution timers enabled for your benchmaking runs (which is 
default-off and which is still rare for benchmarking runs - despite 
being a popular end-user feature) we immediately disabled the hrtick via 
this upstream commit:

  0c4b83d: sched: disable the hrtick for now

that commit is included in v2.6.28-rc1 so this particular issue should 
be resolved.

high-resolution timers are still default-disabled in the upstream 
kernel, so this never affected usual configs that folks keep 
benchmarking - it only affected those who decided they want higher 
resolution timers and more precise scheduling.

Anyway, the sched-hrtick is off now, and we wont turn it back on without 
making sure that it's really low cost in the hotpath.

Regarding tbench, a workload that context-switches in excess of 100,000 
per second is inevitably going to show scheduler overhead - so you'll 
get the best numbers if you eliminate all/most scheduler code from the 
hotpath. We are working on various patches to mitigate the cost some 
more - and your patches and feedback is welcome as well.

But it's a difficult call with no silver bullets. On one hand we have 
folks putting more and more stuff into the context-switching hotpath on 
the (mostly valid) point that the scheduler is a slowpath compared to 
most other things. On the other hand we've got folks doing 
high-context-switch ratio benchmarks and complaining about the overhead 
whenever something goes in that improves the quality of scheduling of a 
workload that does not context-switch as massively as tbench. It's a 
difficult balance and we cannot satisfy both camps.

Nevertheless, this is not a valid argument in favor of the hrtick 
overhead: that was clearly excessive overhead and we zapped it.

	Ingo
