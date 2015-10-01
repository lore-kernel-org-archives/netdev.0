From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [regression] 6ae459bd skbuff: Fix skb checksum flag on skb pull
Date: Thu, 01 Oct 2015 13:16:17 +0200
Message-ID: <1443698177.3401.1.camel@gmail.com>
References: <20151001084222.GA25104@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151001084222.GA25104@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-01 at 16:42 +0800, Herbert Xu wrote:
> Mike Galbraith <umgwanakikbuti@gmail.com> wrote:
> > 
> > homer:/usr/local/src/kernel/linux-3.x.git # time strace -vvvfFtT git remote update 2> /strace.out
> > Fetching origin
> > 
> > real    2m9.164s
> > user    0m1.616s
> > sys     0m0.316s
> > 
> > 2 minutes of thumb twiddling should have been..
> > 
> > homer:/usr/local/src/kernel/linux-3.x.git # time git remote update
> > Fetching origin
> > 
> > real    0m0.213s
> > user    0m0.156s
> > sys     0m0.036s
> > 
> > Daemon runs as user git like so, with all repositories living in ~git:
> > /usr/lib/git/git-daemon --syslog --detach --reuseaddr --user=git --group=daemon --pid-file=/var/run/git-daemon.pid --export-all --user-path
> > 
> > Bisected and post bisect verified by applying/removing a revert.
> 
> So do you use VXLANs?

Nope.  It really really is that patch though.

> If this patch is indeed causing the regression you should be able
> to spot some differences in the tcpdump.  Can you confirm this?

Will this work instead?

---
 include/linux/skbuff.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2708,8 +2708,10 @@ static inline void skb_postpull_rcsum(st
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		 skb_checksum_start_offset(skb) <= len)
+		 skb_checksum_start_offset(skb) <= len) {
 		skb->ip_summed = CHECKSUM_NONE;
+		trace_printk("skb_checksum_start_offset(skb) = %d len = %u\n", skb_checksum_start_offset(skb), len);
+	}
 }
 
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);

# tracer: nop
#
# nop latency trace v1.1.5 on 4.3.0-master
# --------------------------------------------------------------------
# latency: 0 us, #10/10, CPU#0 | (M:desktop VP:0, KP:0, SP:0 HP:0 #P:8)
#    -----------------
#    | task: -0 (uid:0 nice:0 policy:0 rt_prio:0)
#    -----------------
#
#                  _------=> CPU#            
#                 / _-----=> irqs-off        
#                | / _----=> need-resched    
#                || / _---=> hardirq/softirq 
#                ||| / _--=> preempt-depth   
#                |||| /     delay            
#  cmd     pid   ||||| time  |   caller      
#     \   /      |||||  \    |   /         
     git-10826   2..s1 10668371us+: ip6_input_finish+0x1e8/0x3e0: skb_checksum_start_offset(skb) = 0 len = 40
     git-10826   2..s1 10668386us@: <stack trace>
 => ip6_rcv_finish+0x34/0xa0
 => ipv6_rcv+0x2b7/0x4c0
 => __netif_receive_skb_core+0x634/0x990
 => __netif_receive_skb+0x18/0x60
 => process_backlog+0x8d/0x120
 => net_rx_action+0x13a/0x300
 => __do_softirq+0xcc/0x240
 => do_softirq_own_stack+0x1c/0x30
 => do_softirq+0x31/0x40
 => __local_bh_enable_ip+0x78/0x80
 => ip6_finish_output2+0x171/0x460
 => ip6_finish_output+0x89/0xe0
 => ip6_output+0x44/0xd0
 => ip6_xmit+0x208/0x500
 => inet6_csk_xmit+0x65/0xa0
 => tcp_transmit_skb+0x494/0x860
 => tcp_connect+0x63e/0x7f0
 => tcp_v6_connect+0x2f3/0x570
 => __inet_stream_connect+0x93/0x2e0
 => inet_stream_connect+0x38/0x50
 => SYSC_connect+0x69/0xd0
 => SyS_connect+0xe/0x10
 => entry_SYSCALL_64_fastpath+0x16/0x6e
  <idle>-0       2..s. 11666764us : ip6_input_finish+0x1e8/0x3e0: skb_checksum_start_offset(skb) = 0 len = 40
  <idle>-0       2..s. 11666768us$: <stack trace>
 => ip6_rcv_finish+0x34/0xa0
 => ipv6_rcv+0x2b7/0x4c0
 => __netif_receive_skb_core+0x634/0x990
 => __netif_receive_skb+0x18/0x60
 => process_backlog+0x8d/0x120
 => net_rx_action+0x13a/0x300
 => __do_softirq+0xcc/0x240
 => irq_exit+0x8c/0xa0
 => smp_apic_timer_interrupt+0x45/0x60
 => apic_timer_interrupt+0x7f/0x90
 => start_secondary+0x103/0x130
  <idle>-0       2..s. 13670053us : ip6_input_finish+0x1e8/0x3e0: skb_checksum_start_offset(skb) = 0 len = 40
  <idle>-0       2..s. 13670058us$: <stack trace>
 => ip6_rcv_finish+0x34/0xa0
 => ipv6_rcv+0x2b7/0x4c0
 => __netif_receive_skb_core+0x634/0x990
 => __netif_receive_skb+0x18/0x60
 => process_backlog+0x8d/0x120
 => net_rx_action+0x13a/0x300
 => __do_softirq+0xcc/0x240
 => irq_exit+0x8c/0xa0
 => smp_apic_timer_interrupt+0x45/0x60
 => apic_timer_interrupt+0x7f/0x90
 => cpuidle_enter+0x17/0x20
 => call_cpuidle+0x32/0x60
 => cpu_startup_entry+0x217/0x2d0
 => start_secondary+0x103/0x130
  <idle>-0       2..s. 17676620us : ip6_input_finish+0x1e8/0x3e0: skb_checksum_start_offset(skb) = 0 len = 40
  <idle>-0       2..s. 17676625us$: <stack trace>
 => ip6_rcv_finish+0x34/0xa0
 => ipv6_rcv+0x2b7/0x4c0
 => __netif_receive_skb_core+0x634/0x990
 => __netif_receive_skb+0x18/0x60
 => process_backlog+0x8d/0x120
 => net_rx_action+0x13a/0x300
 => __do_softirq+0xcc/0x240
 => irq_exit+0x8c/0xa0
 => smp_apic_timer_interrupt+0x45/0x60
 => apic_timer_interrupt+0x7f/0x90
 => cpuidle_enter+0x17/0x20
 => call_cpuidle+0x32/0x60
 => cpu_startup_entry+0x217/0x2d0
 => start_secondary+0x103/0x130
  <idle>-0       2..s. 25697779us : ip6_input_finish+0x1e8/0x3e0: skb_checksum_start_offset(skb) = 0 len = 40
  <idle>-0       2..s. 25697783us : <stack trace>
 => ip6_rcv_finish+0x34/0xa0
 => ipv6_rcv+0x2b7/0x4c0
 => __netif_receive_skb_core+0x634/0x990
 => __netif_receive_skb+0x18/0x60
 => process_backlog+0x8d/0x120
 => net_rx_action+0x13a/0x300
 => __do_softirq+0xcc/0x240
 => irq_exit+0x8c/0xa0
 => smp_apic_timer_interrupt+0x45/0x60
 => apic_timer_interrupt+0x7f/0x90
 => cpuidle_enter+0x17/0x20
 => call_cpuidle+0x32/0x60
 => cpu_startup_entry+0x217/0x2d0
 => start_secondary+0x103/0x130
