From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 11:04:06 -0400
Message-ID: <20090707150406.GC7124@Krystal>
References: <20090703090606.GA3902@elte.hu> <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, davidel@xmailserver.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts40.bellnexxia.net ([209.226.175.97]:60290 "EHLO
	tomts40-srv.bellnexxia.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752977AbZGGPHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 11:07:08 -0400
Content-Disposition: inline
In-Reply-To: <20090707143416.GB11704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Oleg Nesterov (oleg@redhat.com) wrote:
> On 07/07, Mathieu Desnoyers wrote:
> >
> > As with any optimization (and this is one that adds a semantic that will
> > just grow the memory barrier/locking rule complexity), it should come
> > with performance benchmarks showing real-life improvements.
> 
> Well, the same applies to smp_mb__xxx_atomic_yyy or smp_mb__before_clear_bit.
> 
> Imho the new helper is not worse, and it could be also used by
> try_to_wake_up(), __pollwake(), insert_work() at least.

It's basically related to Amdahl law. If the smp_mb is a small portion
of the overall read_lock cost, then it may not be worth it to remove it.
At the contrary, if the mb is a big portion of set/clear bit, then it's
worth it. We also have to consider the frequency at which these
operations are done to figure out the overall performance impact.
Also, locks imply cache-line bouncing, which are typically costly.
clear/set bit does not imply this as much. So the tradeoffs are very
different there.

So it's not as simple as "we do this for set/clear bit, we should
therefore do this for locks".

> 
> > Otherwise I'd recommend sticking to smp_mb() if this execution path is
> > not that critical, or to move to RCU if it's _that_ critical.
> >
> > A valid argument would be if the data structures protected are so
> > complex that RCU is out of question but still the few cycles saved by
> > removing a memory barrier are really significant.
> 
> Not sure I understand how RCU can help,
> 

Changing a read_lock to a rcu_read_lock would save the whole atomic
cache-line bouncing operation on that fast path. But it may imply data
structure redesign. So it is more for future development than current
kernel releases.

> > And even then, the
> > proper solution would be more something like a
> > __read_lock()+smp_mb+smp_mb+__read_unlock(), so we get the performance
> > improvements on architectures other than x86 as well.
> 
> Hmm. could you explain what you mean?
> 

Actually, thinking about it more, to appropriately support x86, as well
as powerpc, arm and mips, we would need something like:

read_lock_smp_mb()

Which would be a read_lock with an included memory barrier.

Mathieu


> Oleg.
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
