From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: [PATCH v3 1/2] RDS: fix "Kernel unaligned access" on sparc64
Date: Sun,  3 Apr 2016 08:24:03 -0400
Message-ID: <1459686244-14939-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: davem@davemloft.net, shamir.rabinovitch@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26276 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbcDCMYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 08:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparc64 expect 64 bit types to be aligned to 8. This patch ensure that
memory allocated by 'rds_page_remainder_alloc' will be aligned to 8.
This patch fix issue found in 'rds_ib_cong_recv' when accessing
unaligned memory using uint64_t pointer.

Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>

Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
---
 net/rds/page.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rds/page.c b/net/rds/page.c
index 616f21f..4813e1f 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -135,8 +135,9 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
 			if (rem->r_offset != 0)
 				rds_stats_inc(s_page_remainder_hit);
 
-			rem->r_offset += bytes;
-			if (rem->r_offset == PAGE_SIZE) {
+			/* fix 'Kernel unaligned access' on sparc64 */
+			rem->r_offset += ALIGN(bytes, 8);
+			if (rem->r_offset >= PAGE_SIZE) {
 				__free_page(rem->r_page);
 				rem->r_page = NULL;
 			}
-- 
1.7.1
