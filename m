From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 11:46:48 +0100
Message-ID: <1232016408.8870.43.camel@laptop>
References: <20081010090426.GA6054@ff.dom.local>
	 <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop>
	 <200901141505.46929.denys@visp.net.lb> <20090114131257.GC6117@ff.dom.local>
	 <1231938929.14825.6.camel@laptop> <20090114132603.GD6117@ff.dom.local>
	 <1231939946.14825.9.camel@laptop> <20090114141311.GA6643@ff.dom.local>
	 <1231943283.14825.14.camel@laptop>  <20090115090120.GE4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47463 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbZAOKqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:46:54 -0500
In-Reply-To: <20090115090120.GE4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-15 at 09:01 +0000, Jarek Poplawski wrote:
> On Wed, Jan 14, 2009 at 03:28:03PM +0100, Peter Zijlstra wrote:
> ....
> > Right, found all that...
> > 
> > Can't spot anything obviously wrong though.. hrtimer_start*() does
> > remove_hrtimer() which checks STATE_ENQUEUED, STATE_PENDING and pulls it
> > off the relevant list before it continues the enqueue.
> > 
> > However a loop in enqueue_hrtimer() would suggest a corrupted RB-tree,
> > but I cannot find an RB-op that doesn't hold base-lock.
> > 
> 
> I've revisited it yesterday, and if I don't miss something, there is
> possible a scenario similar to this:
> 
> cpu1:				cpu2:
> 
> run_hrtimer_pending
> spin_unlock
> restart = fn(timer)
> 
> 				hrtimer_start
> 				enqueue_hrtimer
> 
> 				hrtimer_start
> 				remove_hrtimer
> 				(the HRTIMER_STATE_CALLBACK is removed)
> 
> 				switch_hrtimer_base
> spin_lock
> (not this hrtimer's anymore)
> __remove_hrtimer
> list_add_tail			enqueue_hrtimer
> 

(looking at .28 code)

run_hrtimer_pending() reads like:

while (pending timers) {
  __remove_hrtimer(timer, HRTIMER_STATE_CALLBACK);
  spin_unlock(&cpu_base->lock);

  fn(timer);

  spin_lock(&cpu_base->lock);
  timer->state &= ~HRTIMER_STATE_CALLBACK; // _should_ result in HRTIMER_STATE_INACTIVE
  if (HRTIMER_RESTART)
    re-queue
  else if (timer->state != INACTIVE) {
    // so another cpu re-queued this timer _while_ we were executing it.
    if (timer is first && !reprogramm) {
      __remove_hrtimer(timer, HRTIMER_STATE_PENDING);
      list_add_tail(timer, &cb_pending);
    }
  } 
}

So in the window where we drop the lock, one can, as you said, have
another cpu requeue the timer, but the rb_entry and list_entry are free,
so it should not cause the data corruption we're seeing.



