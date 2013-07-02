From: Mike Galbraith <bitbucket@online.de>
Subject: Re: sched: context tracking demolishes pipe-test
Date: Tue, 02 Jul 2013 09:19:25 +0200
Message-ID: <1372749565.8079.5.camel@marge.simpson.net>
References: <1372579056.6607.16.camel@marge.simpson.net>
	 <20130630212940.GK6626@twins.programming.kicks-ass.net>
	 <1372658875.7678.17.camel@marge.simpson.net>
	 <20130701080638.GM6626@twins.programming.kicks-ass.net>
	 <1372669941.7678.113.camel@marge.simpson.net>
	 <1372670432.7678.114.camel@marge.simpson.net>
	 <1372737803.7363.101.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372737803.7363.101.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CCs net-wizards since staring at profile/annotation isn't helping, and I
know all too well how these things laugh perversely at bisection.

On Tue, 2013-07-02 at 06:03 +0200, Mike Galbraith wrote: 
> On Mon, 2013-07-01 at 11:20 +0200, Mike Galbraith wrote: 
> > On Mon, 2013-07-01 at 11:12 +0200, Mike Galbraith wrote: 
> > > On Mon, 2013-07-01 at 10:06 +0200, Peter Zijlstra wrote:
> > > 
> > > > So aside from the context tracking stuff, there's still a regression
> > > > we might want to look at. That's still a ~10% drop against 2.6.32 for
> > > > TCP_RR and few percents for tbench.
> > > 
> > > Yeah, known, and some of it's ours.
> > 
> > (btw tbench has a ~5% phase-of-moon jitter, you can pretty much
> > disregard that one)
> 
> Hm.  Seems we don't own much of TCP_RR regression after all, somewhere
> along the line while my silly-tester hat was moldering, we got some
> cycles back.. in the light config case anyway.
> 
> With wakeup granularity set to zero, per pipe-test, scheduler is within
> variance of .32, sometimes appearing a tad lighter, though usually a wee
> bit heavier.  TCP_RR throughput delta does not correlate.
> 
> echo 0 > sched_wakeup_granularity_ns
> 
> pipe-test
> 2.6.32-regress    689.8 Khz            1.000
> 3.10.0-regress    682.5 Khz             .989
> 
> netperf TCP_RR
> 2.6.32-regress   117910.11 Trans/sec   1.000
> 3.10.0-regress    96955.12 Trans/sec    .822
> 
> It should be closer than this. 
> 
>      3.10.0-regress                                              2.6.32-regress
>      3.85%  [kernel]        [k] tcp_ack                          4.04%  [kernel]        [k] tcp_sendmsg
>      3.34%  [kernel]        [k] __schedule                       3.63%  [kernel]        [k] schedule
>      2.93%  [kernel]        [k] tcp_sendmsg                      2.86%  [kernel]        [k] tcp_recvmsg
>      2.54%  [kernel]        [k] tcp_rcv_established              2.83%  [kernel]        [k] tcp_ack
>      2.26%  [kernel]        [k] tcp_transmit_skb                 2.19%  [kernel]        [k] system_call
>      1.90%  [kernel]        [k] __netif_receive_skb_core         2.16%  [kernel]        [k] tcp_transmit_skb
>      1.87%  [kernel]        [k] tcp_v4_rcv                       2.07%  libc-2.14.1.so  [.] __libc_recv
>      1.84%  [kernel]        [k] tcp_write_xmit                   1.95%  [kernel]        [k] _spin_lock_bh
>      1.70%  [kernel]        [k] __switch_to                      1.89%  libc-2.14.1.so  [.] __libc_send
>      1.57%  [kernel]        [k] tcp_recvmsg                      1.77%  [kernel]        [k] tcp_rcv_established
>      1.54%  [kernel]        [k] _raw_spin_lock_bh                1.70%  [kernel]        [k] netif_receive_skb
>      1.52%  libc-2.14.1.so  [.] __libc_recv                      1.61%  [kernel]        [k] tcp_v4_rcv
>      1.43%  [kernel]        [k] ip_rcv                           1.49%  [kernel]        [k] native_sched_clock
>      1.35%  [kernel]        [k] local_bh_enable                  1.49%  [kernel]        [k] tcp_write_xmit
>      1.33%  [kernel]        [k] _raw_spin_lock_irqsave           1.46%  [kernel]        [k] __switch_to
>      1.26%  [kernel]        [k] ip_queue_xmit                    1.35%  [kernel]        [k] dev_queue_xmit
>      1.16%  [kernel]        [k] __inet_lookup_established        1.29%  [kernel]        [k] __alloc_skb
>      1.14%  [kernel]        [k] mod_timer                        1.27%  [kernel]        [k] skb_release_data
>      1.13%  [kernel]        [k] process_backlog                  1.26%  netserver       [.] recv_tcp_rr
>      1.13%  [kernel]        [k] read_tsc                         1.22%  [kernel]        [k] local_bh_enable
>      1.13%  libc-2.14.1.so  [.] __libc_send                      1.18%  netperf         [.] send_tcp_rr
>      1.12%  [kernel]        [k] system_call                      1.18%  [kernel]        [k] sched_clock_local
>      1.07%  [kernel]        [k] tcp_event_data_recv              1.11%  [kernel]        [k] copy_user_generic_string
>      1.04%  [kernel]        [k] ip_finish_output                 1.07%  [kernel]        [k] _spin_lock_irqsave
> 
> 	-Mike
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
