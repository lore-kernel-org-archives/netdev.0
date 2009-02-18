From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 13:50:49 +0100
Message-ID: <20090218125049.GA28791@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net> <20090218120508.GB4100@elte.hu> <499C000A.4040205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37522 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbZBRMvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 07:51:15 -0500
Content-Disposition: inline
In-Reply-To: <499C000A.4040205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Patrick McHardy <kaber@trash.net> wrote:

> Ingo Molnar wrote:
>> * Patrick McHardy <kaber@trash.net> wrote:
>>
>>> We need to avoid having a timer that was deleted by one CPU
>>> getting re-added by another, but want to avoid taking the
>>> conntrack lock for every timer update. The timer-internal
>>> locking is enough for this as long as we have a mod_timer
>>> variant that forwards a timer, but doesn't activate it in
>>> case it isn't active already.
>>
>> that makes sense - but the implementation is still somewhat ugly. How 
>> about the one below instead? Not tested.
>
> This seems to fulfill our needs. I also like the mod_timer_pending()
> name better than mod_timer_noact().
>
>> One open question is this construct in mod_timer():
>>
>> +	/*
>> +	 * This is a common optimization triggered by the
>> +	 * networking code - if the timer is re-modified
>> +	 * to be the same thing then just return:
>> +	 */
>> +	if (timer->expires == expires && timer_pending(timer))
>> +		return 1;
>>
>> We've had this for ages, but it seems rather SMP-unsafe.  
>> timer_pending(), if used in an unserialized fashion, can be any random 
>> value in theory - there's no internal serialization here anywhere.
>>
>> We could end up with incorrectly not re-activating a timer in  
>> mod_timer() for example - have such things never been observed in 
>> practice?
>
> Yes, it seems racy if done for timers that might get 
> activated. For forwarding only without activation it seems OK, 
> in that case the timer_pending check doesn't seem necessary at 
> all.

ok.

To accelerate matters i've committed the new API patch into a 
new standalone topic branch: tip:timers/new-apis.

Unless there are objections or test failures, you (or Stephen or 
David) can then git-pull it into the networking tree via the Git 
coordinates below - and you'll get this single commit in a 
surgical manner - no other timer changes are included.

Doing so has the advantage of:

- You not having to wait a kernel cycle for the API to go
  upstream.

- You can also push it upstream without waiting for the timer 
  tree. (the timer tree and the networking tree will share the 
  exact same commit)

- It will also all merge cleanly with the timer tree in 
  linux-next, etc.

I'd suggest to do it in about a week, to make sure any after 
effects have trickled down and to make sure the topic has become 
append-only. You can ping Thomas and me about testing/review 
status then, whenever you want to do the pull.

	Ingo

------------->

You can pull the latest timers/new-apis git tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git timers/new-apis

 Thanks,

	Ingo

------------------>
Ingo Molnar (1):
      timers: add mod_timer_pending()


 arch/powerpc/platforms/cell/spufs/sched.c  |    2 +-
 drivers/infiniband/hw/ipath/ipath_driver.c |    6 +-
 include/linux/timer.h                      |   22 +-----
 kernel/relay.c                             |    2 +-
 kernel/timer.c                             |  110 ++++++++++++++++++---------
 5 files changed, 80 insertions(+), 62 deletions(-)

