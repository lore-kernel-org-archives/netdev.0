From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Fri, 01 May 2015 01:01:14 +0200
Message-ID: <5542B43A.6020201@iogearbox.net>
References: <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain> <554191F9.3010301@mojatatu.com> <20150430031138.GA8950@acer.localdomain> <5542182A.800@mojatatu.com> <20150430153317.GA3230@salvia> <554253B5.40801@iogearbox.net> <20150430163634.GA3814@salvia> <55427F81.4080807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <55427F81.4080807@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/30/2015 09:16 PM, Daniel Borkmann wrote:
> On 04/30/2015 06:36 PM, Pablo Neira Ayuso wrote:
> ...
>> But where are the barriers? These unfounded performance claims are
>> simply absurd, qdisc ingress barely performs a bit better just because
>> it executes a bit less code and only in the single CPU scenario with
>> no rules at all.
>
> I think we're going in circles a bit. :( You are right in saying that
> currently, there's a central spinlock, which is worked on to get rid
> of, you've seen the patch on the list floating around already. Single
> CPU, artificial micro-benchmark, which were done show that you see on
> your machine ~613Kpps to ~545Kpps, others have seen it more amplified
> as 22.4Mpps to 18.0Mpps drop from __netif_receive_skb_core() up to an
> empty dummy u32_classify() rule, which has already been acknowledged
> that this gap needs to be improved. Lets call it unfounded then. I
> think we wouldn't even have this discussion if we wouldn't try brute
> forcing both worlds behind this single static key, or, have both
> invoked from within the same layer/list.

Ok, out of curiosity, I did the same as both of you: I'm using a pretty
standard Supermicro X10SLM-F/X10SLM-F, Xeon E3-1240 v3.

*** ingress + dummy u32, net-next:

w/o perf:
...
Result: OK: 5157948(c5157388+d559) usec, 100000000 (60byte,0frags)
   19387551pps 9306Mb/sec (9306024480bps) errors: 100000000

perf record -C0 -ecycles:k ./pktgen.sh p1p1
...
Result: OK: 5182638(c5182057+d580) usec, 100000000 (60byte,0frags)
   19295191pps 9261Mb/sec (9261691680bps) errors: 100000000

   26.07%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
   14.39%   kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
   13.69%   kpktgend_0  [cls_u32]          [k] u32_classify
   11.75%   kpktgend_0  [kernel.kallsyms]  [k] _raw_spin_lock
    5.34%   kpktgend_0  [sch_ingress]      [k] ingress_enqueue
    5.21%   kpktgend_0  [kernel.kallsyms]  [k] tc_classify_compat
    4.93%   kpktgend_0  [kernel.kallsyms]  [k] skb_defer_rx_timestamp
    3.41%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
    3.21%   kpktgend_0  [pktgen]           [k] pktgen_thread_worker
    3.16%   kpktgend_0  [kernel.kallsyms]  [k] tc_classify
    3.08%   kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
    2.05%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
    1.60%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
    1.15%   kpktgend_0  [kernel.kallsyms]  [k] classify
    0.45%   kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip

*** nf hook infra + ingress + dummy u32, net-next:

w/o perf:
...
Result: OK: 6555903(c6555744+d159) usec, 100000000 (60byte,0frags)
   15253426pps 7321Mb/sec (7321644480bps) errors: 100000000

perf record -C0 -ecycles:k ./pktgen.sh p1p1
...
Result: OK: 6591291(c6591153+d138) usec, 100000000 (60byte,0frags)
   15171532pps 7282Mb/sec (7282335360bps) errors: 100000000

   25.94%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
   12.19%  kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
   11.00%  kpktgend_0  [kernel.kallsyms]  [k] _raw_spin_lock
   10.58%  kpktgend_0  [cls_u32]          [k] u32_classify
    5.34%  kpktgend_0  [sch_ingress]      [k] handle_ing
    4.68%  kpktgend_0  [kernel.kallsyms]  [k] nf_iterate
    4.33%  kpktgend_0  [kernel.kallsyms]  [k] tc_classify_compat
    4.32%  kpktgend_0  [sch_ingress]      [k] ingress_enqueue
    3.62%  kpktgend_0  [kernel.kallsyms]  [k] skb_defer_rx_timestamp
    2.95%  kpktgend_0  [kernel.kallsyms]  [k] nf_hook_slow
    2.75%  kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
    2.60%  kpktgend_0  [kernel.kallsyms]  [k] tc_classify
    2.52%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
    2.50%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
    1.77%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
    1.28%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
    0.94%  kpktgend_0  [kernel.kallsyms]  [k] classify
    0.38%  kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip

*** drop ingress spinlock (patch w/ bstats addition) + ingress +
     dummy u32, net-next:

w/o perf:
...
Result: OK: 4789828(c4789353+d474) usec, 100000000 (60byte,0frags)
   20877576pps 10021Mb/sec (10021236480bps) errors: 100000000

perf record -C0 -ecycles:k ./pktgen.sh p1p1
...
Result: OK: 4829276(c4828437+d839) usec, 100000000 (60byte,0frags)
   20707036pps 9939Mb/sec (9939377280bps) errors: 100000000

   33.11%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
   15.27%   kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
   14.60%   kpktgend_0  [cls_u32]          [k] u32_classify
    6.06%   kpktgend_0  [sch_ingress]      [k] ingress_enqueue
    5.55%   kpktgend_0  [kernel.kallsyms]  [k] tc_classify_compat
    5.31%   kpktgend_0  [kernel.kallsyms]  [k] skb_defer_rx_timestamp
    3.77%   kpktgend_0  [pktgen]           [k] pktgen_thread_worker
    3.45%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
    3.33%   kpktgend_0  [kernel.kallsyms]  [k] tc_classify
    3.33%   kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
    2.34%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
    1.78%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
    1.15%   kpktgend_0  [kernel.kallsyms]  [k] classify
    0.48%   kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip

That means, here, moving ingress behind nf hooks, I see a similar
slowdown in this micro-benchmark as Alexei of really worst case
of ~27%.

Now in real world that might probably just end up as a few percent
depending on the use case, but really, why should we go down that
path if we can just avoid that?

If you find a way, where both tc/nf hooks are triggered from within
the same list, then that would probably look better already. Or,
as a start, as mentioned, with a second static key for netfilter,
which can later on then still be reworked for a better integration,
although I agree with you that it's less clean and I see the point
of consolidating code.

If you want, I'm happy to provide numbers if you have a next set as
well, feel free to ping me.

Thanks,
Daniel
