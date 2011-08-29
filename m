From: Jonathan Lallinger <jonathan@ogc.us>
Subject: [PATCH] RDSRDMA: Fix to PAGE_MASK interpretation
Date: Mon, 29 Aug 2011 14:28:54 -0500
Message-ID: <20110829192853.32358.39323.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40167 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655Ab1H2T2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 15:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RDS_RDMA rds_iw_map_scatterlist function assumed PAGE_MASK was the bitwise
compliment of what it actually is. This problem was introduced in commit
404bb72a56e553febe1055f98347a7a3e3145759 when the variable dma_mask was replaced
by PAGE_MASK, however dma_mask represented the compliment of what PAGE_MASK
represents.

This fix corrects the logic by flipping the compliments on all uses of PAGE_MASK
int rds_iw_map_scatterlist.

Signed-off by: Jonathan Lallinger <jonathan@ogc.us>
---

 net/rds/iw_rdma.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 6deaa77..92f4efc 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -287,15 +287,15 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 		sg->bytes += dma_len;
 
 		end_addr = dma_addr + dma_len;
-		if (dma_addr & PAGE_MASK) {
+		if (dma_addr & ~PAGE_MASK) {
 			if (i > 0)
 				goto out_unmap;
-			dma_addr &= ~PAGE_MASK;
+			dma_addr &= PAGE_MASK;
 		}
-		if (end_addr & PAGE_MASK) {
+		if (end_addr & ~PAGE_MASK) {
 			if (i < sg->dma_len - 1)
 				goto out_unmap;
-			end_addr = (end_addr + PAGE_MASK) & ~PAGE_MASK;
+			end_addr = (end_addr + ~PAGE_MASK) & PAGE_MASK;
 		}
 
 		sg->dma_npages += (end_addr - dma_addr) >> PAGE_SHIFT;
@@ -317,7 +317,7 @@ static u64 *rds_iw_map_scatterlist(struct rds_iw_device *rds_iwdev,
 		u64 end_addr;
 
 		end_addr = dma_addr + dma_len;
-		dma_addr &= ~PAGE_MASK;
+		dma_addr &= PAGE_MASK;
 		for (; dma_addr < end_addr; dma_addr += PAGE_SIZE)
 			dma_pages[j++] = dma_addr;
 		BUG_ON(j > sg->dma_npages);
