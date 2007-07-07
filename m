From: Patrick McHardy <kaber@trash.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
 to -mm tree
Date: Sat, 7 Jul 2007 17:10:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0707071704370.1808@x2>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>
 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>  <20070705142135.GG4759@ff.dom.local>
  <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>  <20070706061420.GA1846@ff.dom.local>
 <20070706062629.GC1846@ff.dom.local>  <20070706064523.GA2144@ff.dom.local>
  <1183727654.6389.3.camel@ranko-fc2.spidernet.net>  <468E4FD9.4060702@trash.net>
  <1183733732.6389.26.camel@ranko-fc2.spidernet.net>
 <1183794918.30237.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50675 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbXGGPLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 11:11:46 -0400
In-Reply-To: <1183794918.30237.69.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 7 Jul 2007, Ranko Zivojnovic wrote:

>> On Fri, 2007-07-06 at 16:21 +0200, Patrick McHardy wrote:
>>> There is at least one ABBA deadlock, est_timer does:
>>>
>>> read_lock(&est_lock)
>>> spin_lock(e->stats_lock) (which is dev->queue_lock)
>>>
>>> and qdisc_destroy calls htb_destroy under dev->queue_lock, which
>>> calls htb_destroy_class, then gen_kill_estimator and this
>>> write_locks est_lock.
>>>
>>> I can't see the problem above though, the qdisc_run path only takes
>>> dev->queue_lock. Please enable lockdep and post the output if any.
>>
>
> I've got both code paths this time. It shows exactly the ABBA deadlock
> you describe above. The details are below.


Thanks. I'm still wondering whats causing the other lockup
you're seeing.

> Maybe the appropriate way to fix this would to call gen_kill_estimator,
> with the appropriate lock order, before the call to qdisc_destroy, so
> when dev->queue_lock is taken for qdisc_destroy - the structure is
> already off the list.


Probably easier to just kill est_lock and use rcu lists.
I'm currently travelling, I'll look into it tomorrow.
