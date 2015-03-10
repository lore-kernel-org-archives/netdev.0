From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 0/2] introduce dma frag allocation and reduce dma mapping
Date: Tue, 10 Mar 2015 23:13:02 +0530
Message-ID: <1426009384-11544-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:56860 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbbCJRnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 13:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series tries to address these two problem in dma buff allocation.

* Memory wastage because of large 9k allocation using kmalloc:
  For 9k dma buffer, netdev_alloc_skb_ip_align internally calls kmalloc for
  size > 4096. In case of 9k buff, kmalloc returns pages for order 2, 16k.
  And we use only ~9k of 16k. 7k memory wasted. Using the frag the frag
  allocator in patch 1/2, we can allocate three 9k buffs in a 32k page size.
  Typical enic configuration has 8 rq, and desc ring of size 4096.
  Thats 8 * 4096 * (16*1024) = 512 MB. Using this frag allocator:
  8 * 4096 * (32*1024/3) = 341 MB. Thats 171 MB of memory save.

* frequent dma_map() calls:
  we call dma_map() for every buff we allocate. When iommu is on, This is very
  time consuming. From my testing, most of the cpu cycles are wasted spinning on
  spin_lock_irqsave(&iovad->iova_rbtree_lock, flags) in
  intel_map_page() .. -> ..__alloc_and_insert_iova_range()

With this patch, we call dma_map() once for 32k page. i.e once for every three
9k desc, and once every twenty 1500 bytes desc.

Here are my testing result with 8 rq, 4096 ring size and 9k mtu. irq of each rq
is affinitized with different CPU. Ran iperf with 32 threads. Link is 10G.
iommu is on.

		CPU utilization		throughput
without patch	100%			1.8 Gbps
with patch	13%			9.8 Gbps

v3:
Make this facility more generic so that other drivers can use it.

v2:
Remove changing order facility

Govindarajulu Varadarajan (2):
  net: implement dma cache skb allocator
  enic: use netdev_dma_alloc

 drivers/net/ethernet/cisco/enic/enic_main.c |  31 ++---
 drivers/net/ethernet/cisco/enic/vnic_rq.c   |   3 +
 drivers/net/ethernet/cisco/enic/vnic_rq.h   |   3 +
 include/linux/skbuff.h                      |  22 +++
 net/core/skbuff.c                           | 209 ++++++++++++++++++++++++++++
 5 files changed, 246 insertions(+), 22 deletions(-)

-- 
2.3.2
