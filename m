From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] net: sched: run ingress qdisc without locks
Date: Mon, 4 May 2015 13:04:05 +0200
Message-ID: <20150504130405.3ff6672e@redhat.com>
References: <1430544448-19777-1-git-send-email-ast@plumgrid.com>
	<20150503174208.5b1548ba@redhat.com>
	<5546FFCB.50903@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	brouer@redhat.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbbEDLEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 07:04:12 -0400
In-Reply-To: <5546FFCB.50903@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 03 May 2015 22:12:43 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> On 5/3/15 8:42 AM, Jesper Dangaard Brouer wrote:
> >
> > I was actually expecting to see a higher performance boost.
>  > improvement diff     = -2.85 ns
> ...
> > The patch is removing two atomic operations, spin_{un,}lock, which I
> > have benchmarked[1] to cost approx 14ns on my system.  Your system
> > likely is faster, but not that much (p.s. benchmark your own system
> > with [1])
> >
> > [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c
> 
> have tried you tight loop spin_lock test on my box and it showed:
> time_bench: Type:spin_lock_unlock Per elem: 40 cycles(tsc) 11.070 ns
> and yet the total single cpu gain from removal of spin_lock/unlock
> in ingress path is smaller than 11ns. I think this observation is
> telling us that tight loop benchmarking is inherently flawed.
> I'm guessing that uops that cmpxchg is broken into can execute in
> parallel with uops of other insns, so tight loops of the same sequence
> of uops has more alu dependencies whereas in more normal insn flow
> these uops can mix and match better. Would be great if intel microarch
> experts can chime in.

How do you activate the ingress code path?

I'm just doing (is this enough?):
 export DEV=eth4
 tc qdisc add dev $DEV handle ffff: ingress
 

I re-ran the experiment, and I can also only show a 2.68ns
improvement.  This is rather strange, and I cannot explain it.

The lock clearly shows up in perf report[1] with 12.23% raw_spin_lock,
and perf report[2] it clearly gone, but we don't see a 12% improvement
in performance, but around 4.7%.

Before activating qdisc ingress code : 25.3Mpps (25398057)
Activating qdisc ingress with lock   : 16.9Mpps (16989315)
Activating qdisc ingress without lock: 17.8Mpps (17800496)

(1/17800496*10^9)-(1/16989315*10^9) = -2.68 ns

The "cost" of activating the ingress qdisc is also interesting:
 (1/25398057*10^9)-(1/16989315*10^9) = -19.49 ns
 (1/25398057*10^9)-(1/17800496*10^9) = -16.81 ns

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

My setup
 * Tested on top of commit 4749c3ef854
 * gcc version 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC)
 * CPU E5-2695(ES) @ 2.8GHz

[1] perf report with ingress qlock

 Samples: 2K of event 'cycles', Event count (approx.): 1762298819
   Overhead  Command        Shared Object     Symbol
 +   35.86%  kpktgend_0     [kernel.vmlinux]  [k] __netif_receive_skb_core
 +   17.81%  kpktgend_0     [kernel.vmlinux]  [k] kfree_skb
 +   12.23%  kpktgend_0     [kernel.vmlinux]  [k] _raw_spin_lock
    - _raw_spin_lock
       + 93.54% __netif_receive_skb_core
       + 6.46% __netif_receive_skb
 +    5.45%  kpktgend_0     [sch_ingress]     [k] ingress_enqueue
 +    4.65%  kpktgend_0     [pktgen]          [k] pktgen_thread_worker
 +    4.23%  kpktgend_0     [kernel.vmlinux]  [k] ip_rcv
 +    3.95%  kpktgend_0     [kernel.vmlinux]  [k] tc_classify_compat
 +    3.71%  kpktgend_0     [kernel.vmlinux]  [k] tc_classify
 +    3.03%  kpktgend_0     [kernel.vmlinux]  [k] netif_receive_skb_internal
 +    2.65%  kpktgend_0     [kernel.vmlinux]  [k] netif_receive_skb_sk
 +    1.97%  kpktgend_0     [kernel.vmlinux]  [k] __netif_receive_skb
 +    0.71%  kpktgend_0     [kernel.vmlinux]  [k] __local_bh_enable_ip
 +    0.28%  kpktgend_0     [kernel.vmlinux]  [k] kthread_should_stop

[2] perf report without ingress qlock

 Samples: 2K of event 'cycles', Event count (approx.): 1633499063
   Overhead  Command       Shared Object        Symbol
 +   39.29%  kpktgend_0    [kernel.vmlinux]     [k] __netif_receive_skb_core
 +   19.24%  kpktgend_0    [kernel.vmlinux]     [k] kfree_skb
 +   11.05%  kpktgend_0    [sch_ingress]        [k] ingress_enqueue
 +    4.69%  kpktgend_0    [kernel.vmlinux]     [k] tc_classify
 +    4.48%  kpktgend_0    [kernel.vmlinux]     [k] ip_rcv
 +    4.43%  kpktgend_0    [kernel.vmlinux]     [k] tc_classify_compat
 +    4.19%  kpktgend_0    [pktgen]             [k] pktgen_thread_worker
 +    3.50%  kpktgend_0    [kernel.vmlinux]     [k] netif_receive_skb_internal
 +    2.61%  kpktgend_0    [kernel.vmlinux]     [k] netif_receive_skb_sk
 +    2.26%  kpktgend_0    [kernel.vmlinux]     [k] __netif_receive_skb
 +    0.43%  kpktgend_0    [kernel.vmlinux]     [k] __local_bh_enable_ip
 +    0.13%  swapper       [kernel.vmlinux]     [k] mwait_idle
