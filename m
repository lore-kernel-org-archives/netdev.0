From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Mon, 11 May 2015 14:58:03 +0200
Message-ID: <5550A75B.3010003@iogearbox.net>
References: <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia> <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia> <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia> <554FCE24.8020904@iogearbox.net> <554FD12F.2020607@iogearbox.net> <20150510234313.GA3176@salvia> <555044D8.3080606@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Alexei Starovoitov <ast@plumgrid.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35076 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbbEKM6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 08:58:07 -0400
In-Reply-To: <555044D8.3080606@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2015 07:57 AM, Alexei Starovoitov wrote:
...
> It sounds like you're saying that code that not even being executed
> is somehow affecting the speed? How is that possible ?
> What kind of benchmark do you run? I really want to get to the bottom
> of it.

I'm also curious and would like to get it clarified, so I've added the
below silly test patch.

Since ingress path is *not* executed by the static key, it just bloats up
the handle_ing code, which is the whole purpose of this test.

The claim is : since handle_ing() is inlined it adds up on run time
performance *even* if static keys prevents execution of it.

 From the disassembly, I've verified that the below printk's are not
optimized out and that handle_ing() is inlined.

The *disabled* code path gets added below the normal execution path of
__netif_receive_skb_core(), in other words, after the return location
of 'expected' execution.

    text	   data	    bss	    dec	    hex	filename
   57036	   2204	   2858	  62098	   f292	net/core/dev.o.before-printk
   60180	   2204	   2858	  65242	   feda	net/core/dev.o.after-printk

Before printk change:

Samples: 50K of event 'cycles:k', Event count (approx.): 45068616248
+   40.51%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
+   31.28%   kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
+    6.79%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
+    6.65%   kpktgend_0  [pktgen]           [k] pktgen_thread_worker
+    6.62%   kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
+    3.41%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
+    3.21%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
+    0.95%   kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip
+    0.40%   kpktgend_0  [kernel.kallsyms]  [k] kthread_should_stop
+    0.02%   kpktgend_0  [kernel.kallsyms]  [k] _cond_resched

After printk-change:

Samples: 50K of event 'cycles:k', Event count (approx.): 45200368743
+   40.11%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
+   31.09%   kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
+    6.93%   kpktgend_0  [pktgen]           [k] pktgen_thread_worker
+    6.75%   kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
+    6.58%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
+    3.49%   kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
+    3.39%   kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
+    0.96%   kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip
+    0.49%   kpktgend_0  [kernel.kallsyms]  [k] kthread_should_stop
+    0.04%   kpktgend_0  [kernel.kallsyms]  [k] _cond_resched

I would consider the stuff after comma as noise.

After your patch set:

Samples: 50K of event 'cycles:k', Event count (approx.): 45160667741
+   40.49%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb_core
+   31.21%  kpktgend_0  [kernel.kallsyms]  [k] kfree_skb
+    6.94%  kpktgend_0  [pktgen]           [k] pktgen_thread_worker
+    6.63%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_internal
+    6.63%  kpktgend_0  [kernel.kallsyms]  [k] ip_rcv
+    3.30%  kpktgend_0  [kernel.kallsyms]  [k] netif_receive_skb_sk
+    3.30%  kpktgend_0  [kernel.kallsyms]  [k] __netif_receive_skb
+    0.96%  kpktgend_0  [kernel.kallsyms]  [k] __local_bh_enable_ip
+    0.37%  kpktgend_0  [kernel.kallsyms]  [k] kthread_should_stop
+    0.03%  kpktgend_0  [kernel.kallsyms]  [k] _cond_resched

For *all* three, I reliably get ~40.0 Mpps with the benchmark.

In your perf report I see in addition ...

     18.46%  kpktgend_0  [kernel.kallsyms]  [k] atomic_dec_and_test
     15.87%  kpktgend_0  [kernel.kallsyms]  [k] deliver_ptype_list_skb

... so I have no idea how/where that possibly interferes to your before/after
numbers.

Best & thanks,
Daniel

diff --git a/net/core/dev.c b/net/core/dev.c
index 862875e..7ec18fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3545,11 +3545,178 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
  	return result;
  }

-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
+static __always_inline struct sk_buff *handle_ing(struct sk_buff *skb,
  					 struct packet_type **pt_prev,
  					 int *ret, struct net_device *orig_dev)
  {
  	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+	int i = 0;
+
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);
+	printk("XXX %d\n", i++);

  	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
  		return skb;
