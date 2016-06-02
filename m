From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v5 2/2] skb_array: ring test
Date: Thu, 2 Jun 2016 20:47:25 +0200
Message-ID: <20160602204725.7bcfd927@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
	<1464000201-15560-3-git-send-email-mst@redhat.com>
	<20160523150918.2c58fa7d@redhat.com>
	<20160523235014-mutt-send-email-mst@redhat.com>
	<20160524122809.140f7020@redhat.com>
	<20160524190320.69761a67@redhat.com>
	<20160524224710-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160524224710-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 May 2016 23:34:14 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, May 24, 2016 at 07:03:20PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > On Tue, 24 May 2016 12:28:09 +0200
> > Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >   
> > > I do like perf, but it does not answer my questions about the
> > > performance of this queue. I will code something up in my own
> > > framework[2] to answer my own performance questions.
> > > 
> > > Like what is be minimum overhead (in cycles) achievable with this type
> > > of queue, in the most optimal situation (e.g. same CPU enq+deq cache hot)
> > > for fastpath usage.  
> > 
> > Coded it up here:
> >  https://github.com/netoptimizer/prototype-kernel/commit/b16a3332184
> >  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_bench01.c
> > 
> > This is a really fake benchmark, but it sort of shows the  
> > overhead achievable with this type of queue, where it is the same
> > CPU enqueuing and dequeuing, and cache is guaranteed to be hot.
> > 
> > Measured on a i7-4790K CPU @ 4.00GHz, the average cost of
> > enqueue+dequeue of a single object is around 102 cycles(tsc).
> > 
> > To compare this with below, where enq and deq is measured separately:
> >  102 / 2 = 51 cycles

The alf_queue[1] baseline is 26 cycles in this minimum overhead
achievable benchmark with a MPMC (Multi-Producer/Multi-Consumer) queue
which use a locked cmpxchg.  (SPSC variant is 5 cycles, thus most cost
comes from locked cmpxchg).

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/include/linux/alf_queue.h

> > > Then I also want to know how this performs when two CPUs are involved.
> > > As this is also a primary use-case, for you when sending packets into a
> > > guest.  
> > 
> > Coded it up here:
> >  https://github.com/netoptimizer/prototype-kernel/commit/75fe31ef62e
> >  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c
> >  
> > This parallel benchmark try to keep two (or more) CPUs busy enqueuing or
> > dequeuing on the same skb_array queue.  It prefills the queue,
> > and stops the test as soon as queue is empty or full, or
> > completes a number of "loops"/cycles.
> > 
> > For two CPUs the results are really good:
> >  enqueue: 54 cycles(tsc)
> >  dequeue: 53 cycles(tsc)

As MST points out, a scheme like the alf_queue[1] have the issue that it
"reads" the opposite cacheline of the consumer.tail/producer.tail to
determine if space-is-left/queue-is-empty.  This cause an expensive
transition for the cache coherency protocol.

Coded up similar test for alf_queue:
 https://github.com/netoptimizer/prototype-kernel/commit/b3ff2624f1
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/alf_queue_parallel01.c

For two CPUs MPMC results are, significantly worse, and demonstrate MSTs point:
 enqueue: 227 cycles(tsc)
 dequeue: 231 cycles(tsc)

Alf_queue also have a SPSC (Single-Producer/Single-Consumer) variant:
 enqueue: 24 cycles(tsc)
 dequeue: 23 cycles(tsc)


> > Going to 4 CPUs, things break down (but it was not primary use-case?):
> >  CPU(0) 927 cycles(tsc) enqueue
> >  CPU(1) 921 cycles(tsc) dequeue
> >  CPU(2) 927 cycles(tsc) enqueue
> >  CPU(3) 898 cycles(tsc) dequeue  
> 
> It's mostly the spinlock contention I guess.
> Maybe we don't need fair spinlocks in this case.
> Try replacing spinlocks with simple cmpxchg
> and see what happens?

The alf_queue uses a cmpxchg scheme, and it does scale better when the
number of CPUs increase:

 CPUs:4 Average: 586 cycles(tsc)
 CPUs:6 Average: 744 cycles(tsc)
 CPUs:8 Average: 1578 cycles(tsc)

Notice the alf_queue was designed with the purpose of bulking, to
mitigate the effect of this cacheline bouncing, but it was not covered
in this test.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
