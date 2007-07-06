From: Patrick McHardy <kaber@trash.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
 to -mm tree
Date: Fri, 06 Jul 2007 16:21:13 +0200
Message-ID: <468E4FD9.4060702@trash.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>	 <20070705142135.GG4759@ff.dom.local>	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>	 <20070706064523.GA2144@ff.dom.local> <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58926 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbXGFOVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 10:21:37 -0400
In-Reply-To: <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranko Zivojnovic wrote:
> BUG: spinlock lockup on CPU#0, swapper/0, c03eff80
>  [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
>  [<c02a8468>] __qdisc_run+0x97/0x1b0
>  [<c02a96f3>] qdisc_watchdog+0x19/0x58
>  [<c02fe5e7>] __lock_text_start+0x37/0x43
>  [<c02a9730>] qdisc_watchdog+0x56/0x58
>  [<c02a96da>] qdisc_watchdog+0x0/0x58
>  [<c0135d84>] run_hrtimer_softirq+0x58/0xb5
>  [...]

> BUG: spinlock lockup on CPU#1, swapper/0, c03eff80
>  [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
>  [<c0298b9b>] est_timer+0x53/0x148
>  [<c01294b3>] run_timer_softirq+0x30/0x184
>  [<c01295a4>] run_timer_softirq+0x121/0x184
>  [<c0126252>] __do_softirq+0x66/0xf3
>  [<c0298b48>] est_timer+0x0/0x148
>  [...]


There is at least one ABBA deadlock, est_timer does:

read_lock(&est_lock)
spin_lock(e->stats_lock) (which is dev->queue_lock)

and qdisc_destroy calls htb_destroy under dev->queue_lock, which
calls htb_destroy_class, then gen_kill_estimator and this
write_locks est_lock.

I can't see the problem above though, the qdisc_run path only takes
dev->queue_lock. Please enable lockdep and post the output if any.
