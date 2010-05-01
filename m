From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: eth_type_trans() should inline skb_pull()
Date: Sat, 01 May 2010 08:42:25 +0200
Message-ID: <1272696145.2230.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44115 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0EAGmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 02:42:32 -0400
Received: by bwz19 with SMTP id 19so489017bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 23:42:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

840.000 pps instead of 800.000 pps on my 'old' machine, using RPS

Before patch, profile of CPU 0 (handling tg3 interrupts)

             2167.00 13.9% __alloc_skb            vmlinux
             1908.00 12.3% eth_type_trans         vmlinux
             1125.00  7.2% __kmalloc_track_caller vmlinux
              981.00  6.3% __netdev_alloc_skb     vmlinux
              925.00  5.9% _raw_spin_lock         vmlinux
              786.00  5.1% kmem_cache_alloc       vmlinux
              757.00  4.9% skb_pull               vmlinux
              698.00  4.5% tg3_read32             vmlinux
              637.00  4.1% __slab_alloc           vmlinux
              620.00  4.0% tg3_poll_work          vmlinux
              576.00  3.7% get_rps_cpu            vmlinux
              448.00  2.9% bnx2_interrupt         vmlinux

After (no more skb_pull, and eth_type_trans() not more expensive)
Predominant cost is memory allocator...

             1625.00 12.4% eth_type_trans         vmlinux
             1468.00 11.2% __alloc_skb            vmlinux
             1004.00  7.6% __kmalloc_track_caller vmlinux
              893.00  6.8% _raw_spin_lock         vmlinux
              738.00  5.6% __netdev_alloc_skb     vmlinux
              665.00  5.1% tg3_read32             vmlinux
              656.00  5.0% kmem_cache_alloc       vmlinux
              655.00  5.0% __slab_alloc           vmlinux
              509.00  3.9% bnx2_interrupt         vmlinux
              483.00  3.7% tg3_poll_work          vmlinux
              455.00  3.5% _raw_spin_lock_irqsave vmlinux
              330.00  2.5% get_rps_cpu            vmlinux
              286.00  2.2% nommu_map_page         vmlinux
              277.00  2.1% enqueue_to_backlog     vmlinux
              235.00  1.8% inet_gro_receive       vmlinux
              232.00  1.8% __copy_to_user_ll      vmlinux
              181.00  1.4% dev_gro_receive        vmlinux
              165.00  1.3% skb_gro_reset_offset   vmlinux

(bnx2_interrupt is called, because irq 16 is shared on this machine on two nics...)

Thanks !

[PATCH net-next-2.6] net: eth_type_trans() should inline skb_pull()

With RPS, this patch can give a 5 % boost in performance.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 0c0d272..763524b 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -162,7 +162,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
-	skb_pull(skb, ETH_HLEN);
+	if (likely(skb->len >= ETH_HLEN))
+		__skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {


