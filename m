From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Fri, 22 Aug 2014 07:01:05 +0200
Message-ID: <1408683665.5648.69.camel@marge.simpson.net>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408608310-13579-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-08-21 at 16:05 +0800, Jason Wang wrote: 
> Rx busy loop does not scale well in the case when several parallel
> sessions is active. This is because we keep looping even if there's
> another process is runnable. For example, if that process is about to
> send packet, keep busy polling in current process will brings extra
> delay and damage the performance.
> 
> This patch solves this issue by exiting the busy loop when there's
> another process is runnable in current cpu. Simple test that pin two
> netperf sessions in the same cpu in receiving side shows obvious
> improvement:

That patch says to me it's a bad idea to spin when someone (anyone) else
can get some work done on a CPU, which intuitively makes sense.  But..

(ponders net goop: with silly 1 byte ping-pong load, throughput is bound
by fastpath latency, net plus sched plus fixable nohz and governor crud
if not polling, so you can't get a lot of data moved byte at a time no
matter how sexy the pipe whether polling or not due to bound.  If OTOH
net hardware is a blazing fast large bore packet cannon, net overhead
per unit payload drops, sched+crud is a constant)

Seems the only time it's a good idea to poll is if blasting big packets
on sexy hardware, and if you're doing that, you want to poll regardless
of whether somebody else is waiting, or?

> Before:
> netperf -H 192.168.100.2 -T 0,0 -t TCP_RR -P 0 & \
> netperf -H 192.168.100.2 -T 1,0 -t TCP_RR -P 0
> 16384  87380  1        1       10.00    15513.74
> 16384  87380
> 16384  87380  1        1       10.00    15092.78
> 16384  87380
> 
> After:
> netperf -H 192.168.100.2 -T 0,0 -t TCP_RR -P 0 & \
> netperf -H 192.168.100.2 -T 1,0 -t TCP_RR -P 0
> 16384  87380  1        1       10.00    23334.53
> 16384  87380
> 16384  87380  1        1       10.00    23327.58
> 16384  87380
> 
> Benchmark was done through two 8 cores Xeon machine back to back connected
> with mlx4 through netperf TCP_RR test (busy_read were set to 50):
> 
> sessions/bytes/before/after/+improvement%/busy_read=0/
> 1/1/30062.10/30034.72/+0%/20228.96/
> 16/1/214719.83/307669.01/+43%/268997.71/
> 32/1/231252.81/345845.16/+49%/336157.442/
> 64/512/212467.39/373464.93/+75%/397449.375/
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  include/net/busy_poll.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
> index 1d67fb6..8a33fb2 100644
> --- a/include/net/busy_poll.h
> +++ b/include/net/busy_poll.h
> @@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
>  		cpu_relax();
>  
>  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
> -		 !need_resched() && !busy_loop_timeout(end_time));
> +		 !need_resched() && !busy_loop_timeout(end_time) &&
> +		 nr_running_this_cpu() < 2);
>  
>  	rc = !skb_queue_empty(&sk->sk_receive_queue);
>  out:
