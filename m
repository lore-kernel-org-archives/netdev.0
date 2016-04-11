From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Mon, 11 Apr 2016 19:31:57 +0300
Message-ID: <20160411182111-mutt-send-email-mst@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
 <1408683665.5648.69.camel@marge.simpson.net>
 <20140822073653.GA7372@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140822073653.GA7372@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 22, 2014 at 09:36:53AM +0200, Ingo Molnar wrote:
> 
> > > diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
> > > index 1d67fb6..8a33fb2 100644
> > > --- a/include/net/busy_poll.h
> > > +++ b/include/net/busy_poll.h
> > > @@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
> > >  		cpu_relax();
> > >  
> > >  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> > > -		 !need_resched() && !busy_loop_timeout(end_time));
> > > +		 !need_resched() && !busy_loop_timeout(end_time) &&
> > > +		 nr_running_this_cpu() < 2);
> 
> So it's generally a bad idea to couple to the scheduler through 
> such a low level, implementation dependent value like 
> 'nr_running', causing various problems:
> 
>  - It misses important work that might be pending on this CPU,
>    like RCU callbacks.
> 
>  - It will also over-credit task contexts that might be
>    runnable, but which are less important than the currently
>    running one: such as a SCHED_IDLE task
> 
>  - It will also over-credit even regular SCHED_NORMAL tasks, if
>    this current task is more important than them: say
>    SCHED_FIFO. A SCHED_FIFO workload should run just as fast 
>    with SCHED_NORMAL tasks around, as a SCHED_NORMAL workload 
>    on an otherwise idle system.
> 
> So what you want is a more sophisticated query to the 
> scheduler, a sched_expected_runtime() method that returns the 
> number of nsecs this task is expected to run in the future, 
> which returns 0 if you will be scheduled away on the next 
> schedule(), and returns infinity for a high prio SCHED_FIFO 
> task, or if this SCHED_NORMAL task is on an otherwise idle CPU.
> 
> It will return a regular time slice value in other cases, when 
> there's some load on the CPU.
> 
> The polling logic can then do its decision based on that time 
> value.
> 
> All this can be done reasonably fast and lockless in most 
> cases, so that it can be called from busy-polling code.
>
> An added advantage would be that this approach consolidates the 
> somewhat random need_resched() checks into this method as well.
> 
> In any case I don't agree with the nr_running_this_cpu() 
> method.
> 
> (Please Cc: me and lkml to future iterations of this patchset.)
> 
> Thanks,
> 
> 	Ingo

I tried to look into this: it might be even nicer to add
sched_expected_to_run(time) which tells us whether we expect the current
task to keep running for the next XX nsecs.

For the fair scheduler, it seems that it could be as simple as

+static bool expected_to_run_fair(struct cfs_rq *cfs_rq, s64 t)
+{
+       struct sched_entity *left;
+       struct sched_entity *curr = cfs_rq->curr;
+
+       if (!curr || !curr->on_rq)
+               return false;
+
+       left = __pick_first_entity(cfs_rq);
+       if (!left)
+               return true;
+
+       return (s64)(curr->vruntime + calc_delta_fair(t, curr) -
+                    left->vruntime) < 0;
+}

The reason it seems easier is because that way we can reuse
calc_delta_fair and don't have to do the reverse translation
from vruntime to nsec.

And I guess if we do this with interrupts disabled, and only poke
at the current CPU's rq, we know first entity
won't go away so we don't need locks? 

Is this close to what you had in mind?

Thanks,

-- 
MST
