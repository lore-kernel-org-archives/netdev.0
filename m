From: Alexei Starovoitov <ast@plumgrid.com>
Subject: RFC: ixgbe+build_skb+extra performance experiments
Date: Wed,  1 Oct 2014 23:00:42 -0700
Message-ID: <1412229642-10555-1-git-send-email-ast@plumgrid.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:60071 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaJBGAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 02:00:51 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so1484743pdi.38
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 23:00:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'm trying to speed up single core packet per second.

I took dual port ixgbe and added both ports to a linux bridge.
Only one port is connected to another system running pktgen at 10G rate.
I disabled gro to measure pure RX speed of ixgbe.

Out of the box I see 6.5 Mpps and the following stack:
  21.83%    ksoftirqd/0  [kernel.kallsyms]  [k] memcpy
  17.58%    ksoftirqd/0  [ixgbe]            [k] ixgbe_clean_rx_irq
  10.07%    ksoftirqd/0  [kernel.kallsyms]  [k] build_skb
   6.40%    ksoftirqd/0  [kernel.kallsyms]  [k] __netdev_alloc_frag
   5.18%    ksoftirqd/0  [kernel.kallsyms]  [k] put_compound_page
   4.93%    ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_alloc
   4.55%    ksoftirqd/0  [kernel.kallsyms]  [k] __netif_receive_skb_core

Obviously driver spends huge amount of time copying data from
hw buffers into skb.

Then I applied buggy but working in this case patch:
http://patchwork.ozlabs.org/patch/236044/
that is trying to use build_skb() API in ixgbe.

RX speed jumped to 7.6 Mpps with the following stack:
  27.02%    ksoftirqd/0  [kernel.kallsyms]  [k] eth_type_trans
  16.68%    ksoftirqd/0  [ixgbe]            [k] ixgbe_clean_rx_irq
  11.45%    ksoftirqd/0  [kernel.kallsyms]  [k] build_skb
   5.20%    ksoftirqd/0  [kernel.kallsyms]  [k] __netif_receive_skb_core
   4.72%    ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_alloc
   3.96%    ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_free

packets no longer copied and performance is higher.
It's doing the following:
- build_skb out of hw buffer and prefetch packet data
- eth_type_trans
- napi_gro_receive

but build_skb() is too fast and cpu doesn't have enough time
to prefetch packet data before eth_type_trans() is called,
so I added mini skb bursting of 2 skbs (patch below) that does:
- build_skb1 out of hw buffer and prefetch packet data
- build_skb2 out of hw buffer and prefetch packet data
- eth_type_trans(skb1)
- napi_gro_receive(skb1)
- eth_type_trans(skb2)
- napi_gro_receive(skb2)
and performance jumped to 9.0 Mpps with stack:
  20.54%    ksoftirqd/0  [ixgbe]            [k] ixgbe_clean_rx_irq
  13.15%    ksoftirqd/0  [kernel.kallsyms]  [k] build_skb
   8.35%    ksoftirqd/0  [kernel.kallsyms]  [k] __netif_receive_skb_core
   7.16%    ksoftirqd/0  [kernel.kallsyms]  [k] eth_type_trans
   4.73%    ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_free
   4.50%    ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_alloc

with further instruction tunning inside ixgbe_clean_rx_irq()
I could push it to 9.4 Mpps.

>From 6.5 Mpps to 9.4 Mpps via build_skb() and tunning.

Is there a way to fix the issue Ben pointed a year ago?
Brute force fix could to be: avoid half-page buffers.
We'll be wasting 16Mbyte of memory. Sure, but in some cases
extra peformance might be worth it.
Other options?
I think we need to try harder to switch to build_skb()
It will open up a lot of possibilities for further performance
improvements.
Thoughts?

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   34 +++++++++++++++++++++----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 21d1a65..1d1e37f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1590,8 +1590,6 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 	}

 	skb_record_rx_queue(skb, rx_ring->queue_index);
-
-	skb->protocol = eth_type_trans(skb, dev);
 }

 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
@@ -2063,6 +2061,24 @@ dma_sync:
 	return skb;
 }

+#define BURST_SIZE 2
+static void ixgbe_rx_skb_burst(struct sk_buff *skbs[BURST_SIZE],
+			       unsigned int skb_burst,
+			       struct ixgbe_q_vector *q_vector,
+			       struct net_device *dev)
+{
+	int i;
+
+	for (i = 0; i < skb_burst; i++) {
+		struct sk_buff *skb = skbs[i];
+
+		skb->protocol = eth_type_trans(skb, dev);
+
+		skb_mark_napi_id(skb, &q_vector->napi);
+		ixgbe_rx_skb(q_vector, skb);
+	}
+}
+
 /**
  * ixgbe_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @q_vector: structure containing interrupt and ring information
@@ -2087,6 +2103,8 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	unsigned int mss = 0;
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
+	struct sk_buff *skbs[BURST_SIZE];
+	unsigned int skb_burst = 0;

 	while (likely(total_rx_packets < budget)) {
 		union ixgbe_adv_rx_desc *rx_desc;
@@ -2161,13 +2179,19 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 #endif /* IXGBE_FCOE */
-		skb_mark_napi_id(skb, &q_vector->napi);
-		ixgbe_rx_skb(q_vector, skb);
-
 		/* update budget accounting */
 		total_rx_packets++;
+		skbs[skb_burst++] = skb;
+
+		if (skb_burst == BURST_SIZE) {
+			ixgbe_rx_skb_burst(skbs, skb_burst, q_vector,
+					   rx_ring->netdev);
+			skb_burst = 0;
+		}
 	}
 
+	ixgbe_rx_skb_burst(skbs, skb_burst, q_vector, rx_ring->netdev);
+
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
-- 
1.7.9.5
