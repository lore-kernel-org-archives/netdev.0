From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 0/2] improve rq buff allocation and reduce dma mapping
Date: Wed, 11 Feb 2015 18:29:16 +0530
Message-ID: <1423659558-32523-1-git-send-email-_govind@gmx.com>
Cc: benve@cisco.com, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:57756 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbbBKM7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 07:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series tries to address these two problem in rq buff allocation.

* Memory wastage because of large 9k allocation using kmalloc:
  For 9k mtu buffer, netdev_alloc_skb_ip_align internally calls kmalloc for
  size > 4096. In case of 9k buff, kmalloc returns pages for order 2, 16k.
  And we use only ~9k of 16k. 7k memory wasted. Using the frag the frag
  allocator in patch 1/2, we can allocate three 9k buffs in a 32k page size.
  Typical enic configuration has 8 rq, and desc ring of size 4096.
  Thats 8 * 4096 * (16*1024) = 512 MB. Using this frag allocator:
  8 * 4096 * (32*1024/3) = 341 MB. Thats 171 MB of memory save.

* frequent dma_map() calls:
  we call dma_map() for every buff we allocate. When iommu is on, This is very
  cpu time consuming. From my testing, most of the cpu cycles are wasted
  spinning on spin_lock_irqsave(&iovad->iova_rbtree_lock, flags) in
  intel_map_page() .. -> ..__alloc_and_insert_iova_range()

  With this patch, we call dma_map() once for 32k page. i.e once for every three
  9k desc, and once every twenty 1500 bytes desc.

Here are testing result with 8 rq, 4096 ring size and 9k mtu. irq of each rq
is affinitized with different CPU. Ran iperf with 32 threads. Link is 10G.
iommu is on.

		CPU utilization		throughput
without patch	100%			1.8 Gbps                                
with patch	13%			9.8 Gbps 

v2:
Remove changing order facility

Govindarajulu Varadarajan (2):
  enic: implement frag allocator
  enic: Add rq allocation failure stats

 drivers/net/ethernet/cisco/enic/enic.h         |  15 +++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   2 +
 drivers/net/ethernet/cisco/enic/enic_main.c    | 158 +++++++++++++++++++++----
 drivers/net/ethernet/cisco/enic/vnic_rq.c      |  13 ++
 drivers/net/ethernet/cisco/enic/vnic_rq.h      |   2 +
 drivers/net/ethernet/cisco/enic/vnic_stats.h   |   2 +
 6 files changed, 168 insertions(+), 24 deletions(-)

-- 
2.3.0
