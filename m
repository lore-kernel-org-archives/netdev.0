From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 2 Oct 2014 15:45:23 +0300
Message-ID: <542D48E3.2090403@mellanox.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>			 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>			 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>			 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>			 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>			 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>			 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>			 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>		 <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>		 <542D06C1.6090802@mellanox.com>	 <1412250327.16704.84.camel@edumazet-glaptop2.roam.corp.google.com>	 <542D3D5F.5090900@mellanox.com> <1412251620.16704.88.camel@edumazet-glapto
 p2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Or Gerlitz" <or.gerlitz@gmail.com>, <amira@mellanox.com>,
	<idos@mellanox.com>, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<eyalpe@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:35093 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751448AbaJBMpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 08:45:36 -0400
In-Reply-To: <1412251620.16704.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/2014 3:07 PM, Eric Dumazet wrote:
> On Thu, 2014-10-02 at 14:56 +0300, Amir Vadai wrote:
>> After making sure the sender thread and the TX completions are not on
>> the same CPU, I see the expected improvement. +0.5Mpps with tx
>> optimizations.
> 
> I got 40% here.
> 
> Hmm... both cpus are on the same socket, right ?
Yes. And on a NUMA node close to the NIC

> 
> TX coalescing is properly setup ?
I will try to play with it, if it is too aggressive, the queue is stopped.
I will play again with it and the ring size to find a better spot.

> 
> What interrupt rate do you get ?
~50K per second.

> 
> You can take a look at where cycles are spent
> 
> perf record -a -g sleep 5
> perf report
> 
> 
I will.

In case your curious, I have this on the CPU doing completions:
+  44.86%      swapper  [kernel.kallsyms]  [k] consume_skb
+  21.38%      swapper  [kernel.kallsyms]  [k] mlx4_en_poll_tx_cq
+   6.81%      swapper  [kernel.kallsyms]  [k] mlx4_en_free_tx_desc.isra.24
+   6.07%      swapper  [kernel.kallsyms]  [k] intel_idle
+   2.98%      swapper  [kernel.kallsyms]  [k] __dev_kfree_skb_any
+   2.66%         rngd  rngd               [.] 0x0000000000002749
+   1.79%         rngd  [kernel.kallsyms]  [k] consume_skb
+   1.28%      swapper  [kernel.kallsyms]  [k] irq_entries_start
+   1.16%         rngd  [kernel.kallsyms]  [k] mlx4_en_poll_tx_cq
+   0.86%      swapper  [kernel.kallsyms]  [k] swiotlb_unmap_page
+   0.79%      swapper  [kernel.kallsyms]  [k] unmap_single
+   0.63%      swapper  [kernel.kallsyms]  [k] irqtime_account_irq
+   0.55%      swapper  [kernel.kallsyms]  [k] mlx4_eq_int
+   0.51%      swapper  [kernel.kallsyms]  [k] eq_set_ci.isra.14

and this on the xmit thread:
+  72.00%  kpktgend_6  [kernel.kallsyms]  [k] mlx4_en_xmit
+  13.11%  kpktgend_6  [kernel.kallsyms]  [k] pktgen_thread_worker
+   5.34%  kpktgend_6  [kernel.kallsyms]  [k] _raw_spin_lock
+   3.80%  kpktgend_6  [kernel.kallsyms]  [k] swiotlb_map_page
+   2.08%  kpktgend_6  [kernel.kallsyms]  [k] __iowrite64_copy
+   1.21%  kpktgend_6  [kernel.kallsyms]  [k] skb_clone_tx_timestamp
+   0.87%  kpktgend_6  [kernel.kallsyms]  [k] kthread_should_stop
+   0.64%  kpktgend_6  [kernel.kallsyms]  [k] swiotlb_dma_mapping_error
+   0.51%  kpktgend_6  [kernel.kallsyms]  [k] __local_bh_enable_ip

Thanks,
Amir
