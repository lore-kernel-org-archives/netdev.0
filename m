From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: order:1 failure in ipoib_cm_alloc_rx_skb
Date: Thu, 21 Aug 2014 14:29:09 -0700 (PDT)
Message-ID: <b2996322-2711-466b-8c41-7f4c13c7c0dc@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29271 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520AbaHUV3M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 17:29:12 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s7LLTBur009296
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 21:29:11 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by ucsinet22.oracle.com (8.14.5+Sun/8.14.5) with ESMTP id s7LLTAXh028238
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 21:29:11 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s7LLTABr022818
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 21:29:10 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

Many of our customers have hit this order:1 failure in ipoib_cm_alloc_rx_skb causing softlockup:
....
        skb = dev_alloc_skb(IPOIB_CM_HEAD_SIZE + 12);
....

IPOIB_CM_HEAD_SIZE is defined as
      IPOIB_ENCAP_LEN     = 4,
	IPOIB_CM_MTU	  = 0x10000 - 0x10, /* padding to align header to 16 */
 	IPOIB_CM_BUF_SIZE	  = IPOIB_CM_MTU  + IPOIB_ENCAP_LEN,
	IPOIB_CM_HEAD_SIZE  = IPOIB_CM_BUF_SIZE % PAGE_SIZE,

For a 4kb PAGE_SIZE IPOIB_CM_HEAD_SIZE ends up as
(65536 - 16 + 4) % 4096 = 4084 bytes for a dev_alloc_skb(4084 + 12) or dev_alloc_skb(4096).

Redefining IPOIB_CM_HEAD_SIZE and IPOIB_CM_RX_SG as 
	IPOIB_CM_HEAD_SIZE  = SKB_MAX_HEAD(NET_SKB_PAD + 12),
	IPOIB_CM_RX_SG = ALIGN(IPOIB_CM_BUF_SIZE-IPOIB_CM_HEAD_SIZE,PAGE_SIZE)/PAGE_SIZE + 1,
resolves the problem by avoiding the order:1 allocation.

But in releases where NET_SKB_PAD is defined with max() as
#define NET_SKB_PAD     max(32, L1_CACHE_BYTES)
we get compilation error:
  CC [M]  drivers/infiniband/ulp/ipoib/ipoib_main.o
In file included from drivers/infiniband/ulp/ipoib/ipoib_main.c:35:
drivers/infiniband/ulp/ipoib/ipoib.h:76: error: braced-group within expression allowed only inside a function

Changing it to a #define moves the error to when IPOIB_CM_RX_SG is used.
#define IPOIB_CM_HEAD_SIZE SKB_MAX_HEAD(NET_SKB_PAD + 12)
#define IPOIB_CM_RX_SG  ALIGN(IPOIB_CM_BUF_SIZE-IPOIB_CM_HEAD_SIZE,PAGE_SIZE)/PAGE_SIZE + 1

The same compilation error comes from the "u64 mapping[IPOIB_CM_RX_SG];" line in 
struct ipoib_cm_rx_buf {
        struct sk_buff *skb;
        u64 mapping[IPOIB_CM_RX_SG];
};

How should I fix this compilation problem without having to make too many changes ?

I am including the stack trace of the order:1 failure:
 kswapd0: page allocation failure. order:1, mode:0x20 
 Pid: 273, comm: kswapd0 Not tainted 2.6.32-400.11.1.el5uek #1 
 Call Trace: 
  <IRQ>  [<ffffffff810ddf74>] __alloc_pages_nodemask+0x524/0x595 
  [<ffffffff8110da3f>] kmem_getpages+0x4f/0xf4 
  [<ffffffff8110dc3c>] fallback_alloc+0x158/0x1ce 
  [<ffffffff8110ddd3>] ____cache_alloc_node+0x121/0x134 
  [<ffffffff8110e3f3>] kmem_cache_alloc_node_notrace+0x84/0xb9 
  [<ffffffff8110e46e>] __kmalloc_node+0x46/0x73 
  [<ffffffff813b9aa8>] ? __alloc_skb+0x72/0x13d 
  [<ffffffff813b9aa8>] __alloc_skb+0x72/0x13d 
  [<ffffffff813b9bdb>] alloc_skb+0x13/0x15 
  [<ffffffff813b9f11>] dev_alloc_skb+0x1b/0x38 
  [<ffffffffa029e722>] ipoib_cm_alloc_rx_skb+0x31/0x1de [ib_ipoib] 
  [<ffffffffa029fd04>] ipoib_cm_handle_rx_wc+0x3a1/0x5b8 [ib_ipoib] 
  [<ffffffffa0191bdc>] ? mlx4_ib_free_srq_wqe+0x27/0x54 [mlx4_ib] 
  [<ffffffffa01894d4>] ? mlx4_ib_poll_cq+0x620/0x65e [mlx4_ib] 
  [<ffffffff813b9015>] ? __kfree_skb+0x79/0x7e 
  [<ffffffffa029e9f7>] ? netif_tx_lock+0x44/0x71 [ib_ipoib] 
  [<ffffffffa029ae97>] ipoib_poll+0x87/0x128 [ib_ipoib] 
  [<ffffffff813c4b69>] net_rx_action+0xc6/0x1cd 
  [<ffffffff8105e8cd>] __do_softirq+0xd7/0x19e 
  [<ffffffff810aefdc>] ? handle_IRQ_event+0x66/0x120 
  [<ffffffff81012eec>] call_softirq+0x1c/0x30 
  [<ffffffff81014695>] do_softirq+0x46/0x89 
  [<ffffffff8105e752>] irq_exit+0x3b/0x7a 
  [<ffffffff8145bea1>] do_IRQ+0x99/0xb0 
  [<ffffffff81012713>] ret_from_intr+0x0/0x11 
  <EOI>  [<ffffffff812379a3>] ? radix_tree_delete+0x8f/0x194 
  [<ffffffffa03693b3>] ? __nfs_access_zap_cache+0x75/0xb0 [nfs] 
  [<ffffffff81207d05>] ? ima_inode_free+0x35/0x55 
  [<ffffffff8112fd9c>] ? __destroy_inode+0x26/0x66 
  [<ffffffff8112fdf2>] ? destroy_inode+0x16/0x44 
  [<ffffffff81130074>] ? dispose_list+0xb2/0xe1 
  [<ffffffff81130251>] ? shrink_icache_memory+0x1ae/0x1e0 
  [<ffffffff810e3f83>] ? shrink_slab+0xe1/0x153 
  [<ffffffff810e5063>] ? kswapd+0x3dd/0x516 
  [<ffffffff810e26f3>] ? isolate_pages_global+0x0/0x1ba 
  [<ffffffff810432be>] ? need_resched+0x23/0x2d 
  [<ffffffff81077030>] ? autoremove_wake_function+0x0/0x3d 
  [<ffffffff810e4c86>] ? kswapd+0x0/0x516 
  [<ffffffff81076c87>] ? kthread+0x6e/0x76 
  [<ffffffff81012dea>] ? child_rip+0xa/0x20 
  [<ffffffff81076c19>] ? kthread+0x0/0x76 
  [<ffffffff81012de0>] ? child_rip+0x0/0x20

Thanks.

Venkat
