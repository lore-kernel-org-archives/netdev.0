From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Mon, 16 Apr 2007 12:10:51 -0700
Message-ID: <1176750651.6217.3.camel@dell>
References: <20070402014319.GA8345@zip.com.au>
 <20070402001300.3b66007d.akpm@linux-foundation.org>
 <20070402074108.GB8345@zip.com.au> <1176596401.5847.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "CaT" <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2095 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754153AbXDPSZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 14:25:24 -0400
In-Reply-To: <1176596401.5847.7.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-04-14 at 17:20 -0700, Michael Chan wrote:

> I also like Andi's idea of using change_page_attr() to isolate the
> problem.  I'll try to send you a debug patch in the next few days to try
> that out.  Thanks.
> 
Here's the debug patch for x86 only that will change the statistics
memory block to read-only.  If the kernel is corrupting it, you should
get a page fault that will crash the system.  If you continue to see
bogus counters, it is definitely a firmware or hardware problem.  Please
try it and let me know.  Thanks.

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0b7aded..b7d491b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -47,6 +47,7 @@
 #include <linux/prefetch.h>
 #include <linux/cache.h>
 #include <linux/zlib.h>
+#include <asm/cacheflush.h>
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
@@ -436,6 +437,8 @@ bnx2_free_mem(struct bnx2 *bp)
 		}
 	}
 	if (bp->status_blk) {
+		change_page_attr(virt_to_page(bp->status_blk), 1, PAGE_KERNEL);
+		global_flush_tlb();
 		pci_free_consistent(bp->pdev, bp->status_stats_size,
 				    bp->status_blk, bp->status_blk_mapping);
 		bp->status_blk = NULL;
@@ -501,6 +504,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bp->status_stats_size = status_blk_size +
 				sizeof(struct statistics_block);
 
+	bp->status_stats_size = PAGE_SIZE;
 	bp->status_blk = pci_alloc_consistent(bp->pdev, bp->status_stats_size,
 					      &bp->status_blk_mapping);
 	if (bp->status_blk == NULL)
@@ -508,6 +512,10 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	memset(bp->status_blk, 0, bp->status_stats_size);
 
+	/* x86 debug code to see if the kernel is corrupting the statistics */
+	change_page_attr(virt_to_page(bp->status_blk), 1, PAGE_KERNEL_RO);
+	global_flush_tlb();
+
 	bp->stats_blk = (void *) ((unsigned long) bp->status_blk +
 				  status_blk_size);
 
@@ -4307,7 +4315,9 @@ bnx2_timer(unsigned long data)
 	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
 	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
 
+#if 0
 	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
+#endif
 
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)


