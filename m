From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] network driver skb allocations
Date: Mon, 03 May 2010 19:06:24 +0200
Message-ID: <1272906384.2226.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34696 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab0ECRGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 13:06:31 -0400
Received: by bwz19 with SMTP id 19so1443383bwz.21
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 10:06:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some performance idea about drivers and skb allocations :

-----------------------------------------------------------------------------------------------------------
   PerfTop:     954 irqs/sec  kernel:99.5% [1000Hz cycles],  (all, cpu: 0)
-----------------------------------------------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ _________________

             2378.00 16.3% __alloc_skb                   [kernel.kallsyms]
             1962.00 13.5% eth_type_trans                [kernel.kallsyms]
             1472.00 10.1% __kmalloc_track_caller        [kernel.kallsyms]
              991.00  6.8% __slab_alloc                  [kernel.kallsyms]
              938.00  6.4% _raw_spin_lock                [kernel.kallsyms]
              914.00  6.3% __netdev_alloc_skb            [kernel.kallsyms]
              876.00  6.0% kmem_cache_alloc              [kernel.kallsyms]
              519.00  3.6% tg3_poll_work                 [kernel.kallsyms]
              416.00  2.9% tg3_read32                    [kernel.kallsyms]
              394.00  2.7% get_rps_cpu                   [kernel.kallsyms]

Current logic for drivers is to :

allocate skbs (sk_buff + data) and put them in a ring buffer.

When rx interrupt comes, get the skb and give it to stack.

Allocate a new skb (sk_buff + data) and put it in rx fat ring buffer (511 entries for tg3 )

This is suboptimal, because sk_buff will probably be cold 512 rx later...
Also, NUMA info might be wrong : sk_buff should be allocated on current node,
not on the device preferred node.

Drivers should allocate only the data part for NIC, and at the time of interrupt,
allocate the skb_buff and link it to buffer filled by NIC.

With a prefetch(first_cache_line_of_data) before doing sk_buff allocation and init,
eth_type_trans() / get_rps_cpus() would be much faster.






