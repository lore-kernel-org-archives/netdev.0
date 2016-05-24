From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v5 2/2] skb_array: ring test
Date: Tue, 24 May 2016 19:03:20 +0200
Message-ID: <20160524190320.69761a67@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
	<1464000201-15560-3-git-send-email-mst@redhat.com>
	<20160523150918.2c58fa7d@redhat.com>
	<20160523235014-mutt-send-email-mst@redhat.com>
	<20160524122809.140f7020@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160524122809.140f7020@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 24 May 2016 12:28:09 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> I do like perf, but it does not answer my questions about the
> performance of this queue. I will code something up in my own
> framework[2] to answer my own performance questions.
> 
> Like what is be minimum overhead (in cycles) achievable with this type
> of queue, in the most optimal situation (e.g. same CPU enq+deq cache hot)
> for fastpath usage.

Coded it up here:
 https://github.com/netoptimizer/prototype-kernel/commit/b16a3332184
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_bench01.c

This is a really fake benchmark, but it sort of shows the minimum
overhead achievable with this type of queue, where it is the same
CPU enqueuing and dequeuing, and cache is guaranteed to be hot.

Measured on a i7-4790K CPU @ 4.00GHz, the average cost of
enqueue+dequeue of a single object is around 102 cycles(tsc).

To compare this with below, where enq and deq is measured separately:
 102 / 2 = 51 cycles

 
> Then I also want to know how this performs when two CPUs are involved.
> As this is also a primary use-case, for you when sending packets into a
> guest.

Coded it up here:
 https://github.com/netoptimizer/prototype-kernel/commit/75fe31ef62e
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c
 
This parallel benchmark try to keep two (or more) CPUs busy enqueuing or
dequeuing on the same skb_array queue.  It prefills the queue,
and stops the test as soon as queue is empty or full, or
completes a number of "loops"/cycles.

For two CPUs the results are really good:
 enqueue: 54 cycles(tsc)
 dequeue: 53 cycles(tsc)

Going to 4 CPUs, things break down (but it was not primary use-case?):
 CPU(0) 927 cycles(tsc) enqueue
 CPU(1) 921 cycles(tsc) dequeue
 CPU(2) 927 cycles(tsc) enqueue
 CPU(3) 898 cycles(tsc) dequeue


Next on my todo-list is to implement same tests for e.g. alf_queue, so
we can compare the concurrency part (which is the important part).
But FYI I'll be busy the next days at conf http://fosd2016.itu.dk/

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


[1] https://git.kernel.org/cgit/linux/kernel/git/mst/vhost.git/log/?h=vhost
[2] https://github.com/netoptimizer/prototype-kernel
