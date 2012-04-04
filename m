From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] mlx4: allocate just enough pages instead of always 4 pages
Date: Wed,  4 Apr 2012 16:40:40 -0300
Message-ID: <1333568440-14494-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: davem@davemloft.net, roland@kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.co.il, alexg@mellanox.co.il,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:33121 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401Ab2DDTlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 15:41:04 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Wed, 4 Apr 2012 16:41:02 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 65BB5352004B
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2012 16:40:57 -0300 (BRT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q34Je4no2007122
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 16:40:04 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q34Jevga018416
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2012 16:40:58 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver uses a 2-order allocation, which is too much on architectures
like ppc64, which has a 64KiB page. This particular allocation is used
for large packet fragments that may have a size of 512, 1024, 4096 or
fill the whole allocation. So, a minimum size of 16384 is good enough
and will be the same size that is used in architectures of 4KiB sized
pages.

This will avoid allocation failures that we see when the system is under
stress, but still has plenty of memory, like the one below.

This will also allow us to set the interface MTU to higher values like
9000, which was not possible on ppc64 without this patch.

Node 1 DMA: 737*64kB 37*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB = 51904kB
83137 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 10420096kB
Total swap = 10420096kB
107776 pages RAM
1184 pages reserved
147343 pages shared
28152 pages non-shared
netstat: page allocation failure. order:2, mode:0x4020
Call Trace:
[c0000001a4fa3770] [c000000000012f04] .show_stack+0x74/0x1c0 (unreliable)
[c0000001a4fa3820] [c00000000016af38] .__alloc_pages_nodemask+0x618/0x930
[c0000001a4fa39a0] [c0000000001a71a0] .alloc_pages_current+0xb0/0x170
[c0000001a4fa3a40] [d00000000dcc3e00] .mlx4_en_alloc_frag+0x200/0x240 [mlx4_en]
[c0000001a4fa3b10] [d00000000dcc3f8c] .mlx4_en_complete_rx_desc+0x14c/0x250 [mlx4_en]
[c0000001a4fa3be0] [d00000000dcc4eec] .mlx4_en_process_rx_cq+0x62c/0x850 [mlx4_en]
[c0000001a4fa3d20] [d00000000dcc5150] .mlx4_en_poll_rx_cq+0x40/0x90 [mlx4_en]
[c0000001a4fa3dc0] [c0000000004e2bb8] .net_rx_action+0x178/0x450
[c0000001a4fa3eb0] [c00000000009c9b8] .__do_softirq+0x118/0x290
[c0000001a4fa3f90] [c000000000031df8] .call_do_softirq+0x14/0x24
[c000000184c3b520] [c00000000000e700] .do_softirq+0xf0/0x110
[c000000184c3b5c0] [c00000000009c6d4] .irq_exit+0xb4/0xc0
[c000000184c3b640] [c00000000000e964] .do_IRQ+0x144/0x230

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Tested-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9e2b911..d69fee4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -83,8 +83,9 @@
 
 #define MLX4_EN_WATCHDOG_TIMEOUT	(15 * HZ)
 
-#define MLX4_EN_ALLOC_ORDER	2
-#define MLX4_EN_ALLOC_SIZE	(PAGE_SIZE << MLX4_EN_ALLOC_ORDER)
+/* Use the maximum between 16384 and a single page */
+#define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
+#define MLX4_EN_ALLOC_ORDER	get_order(MLX4_EN_ALLOC_SIZE)
 
 #define MLX4_EN_MAX_LRO_DESCRIPTORS	32
 
-- 
1.7.4.4
