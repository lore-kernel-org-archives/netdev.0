From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 21:40:43 +0200
Message-ID: <20160831214043.2f44cf08@redhat.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
        <20160831100854.23dad2d8@redhat.com>
        <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472650688.32433.115.camel@redhat.com>
        <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831164216.2901190c@redhat.com>
        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Aug 2016 10:42:29 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> A while back, Paolo and Hannes sent an RFC patch adding threaded-able
> napi poll loop support : (https://patchwork.ozlabs.org/patch/620657/) 
> 
> The problem seems to be that softirqs are very aggressive and are often
> handled by the current process, even if we are under stress and that
> ksoftirqd was scheduled, so that innocent threads would have more chance
> to make progress.
> 
> This patch makes sure that if ksoftirq is running, we let it
> perform the softirq work.
> 
> Jonathan Corbet summarized the issue in https://lwn.net/Articles/687617/
> 
> Tested:
> 
>  - NIC receiving traffic handled by CPU 0
>  - UDP receiver running on CPU 0, using a single UDP socket.
>  - Incoming flood of UDP packets targeting the UDP socket.
> 
> Before the patch, the UDP receiver could almost never get cpu cycles and
> could only receive ~2,000 packets per second.
> 
> After the patch, cpu cycles are split 50/50 between user application and
> ksoftirqd/0, and we can effectively read ~900,000 packets per second,
> a huge improvement in DOS situation. (Note that more packets are now
> dropped by the NIC itself, since the BH handlers get less cpu cycles to
> drain RX ring buffer)

I can confirm the improvement of approx 900Kpps (no wonder people have
been complaining about DoS against UDP/DNS servers).

BUT during my extensive testing, of this patch, I also think that we
have not gotten to the bottom of this.  I was expecting to see a higher
(collective) PPS number as I add more UDP servers, but I don't.

Running many UDP netperf's with command:
 super_netperf 4 -H 198.18.50.3 -l 120 -t UDP_STREAM -T 0,0 -- -m 1472 -n -N

With 'top' I can see ksoftirq are still getting a higher %CPU time:

    PID   %CPU     TIME+  COMMAND
     3   36.5   2:28.98  ksoftirqd/0
 10724    9.6   0:01.05  netserver
 10722    9.3   0:01.05  netserver
 10723    9.3   0:01.05  netserver
 10725    9.3   0:01.05  netserver


> Since the load runs in well identified threads context, an admin can
> more easily tune process scheduling parameters if needed.

With this patch applied, I found that changing the UDP server process,
scheduler policy to SCHED_RR or SCHED_FIFO gave me a performance boost
from 900Kpps to 1.7Mpps, and not a single UDP packet dropped (even with
a single UDP stream, also tested with more)

Command used:
 sudo chrt --rr -p 20 $(pgrep netserver)

The scheduling picture also change a lot:

   PID  %CPU   TIME+   COMMAND
 10783  24.3  0:21.53  netserver
 10784  24.3  0:21.53  netserver
 10785  24.3  0:21.52  netserver
 10786  24.3  0:21.50  netserver
     3   2.7  3:12.18  ksoftirqd/0

 
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Miller <davem@davemloft.net
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  kernel/softirq.c |   16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index 17caf4b63342..8ed90e3a88d6 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -78,6 +78,17 @@ static void wakeup_softirqd(void)
>  }
>  
>  /*
> + * If ksoftirqd is scheduled, we do not want to process pending softirqs
> + * right now. Let ksoftirqd handle this at its own rate, to get fairness.
> + */
> +static bool ksoftirqd_running(void)
> +{
> +	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
> +
> +	return tsk && (tsk->state == TASK_RUNNING);
> +}
> +
> +/*
>   * preempt_count and SOFTIRQ_OFFSET usage:
>   * - preempt_count is changed by SOFTIRQ_OFFSET on entering or leaving
>   *   softirq processing.
> @@ -313,7 +324,7 @@ asmlinkage __visible void do_softirq(void)
>  
>  	pending = local_softirq_pending();
>  
> -	if (pending)
> +	if (pending && !ksoftirqd_running())
>  		do_softirq_own_stack();
>  
>  	local_irq_restore(flags);
> @@ -340,6 +351,9 @@ void irq_enter(void)
>  
>  static inline void invoke_softirq(void)
>  {
> +	if (ksoftirqd_running())
> +		return;
> +
>  	if (!force_irqthreads) {
>  #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
>  		/*
> 
> 

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
