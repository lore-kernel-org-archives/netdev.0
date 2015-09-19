From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 11/15] RDS: fix the rds_ib_fmr_wq kick call
Date: Sat, 19 Sep 2015 19:04:48 -0400
Message-ID: <1442703892-26692-12-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36458 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbbISXF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 19:05:29 -0400
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS IB mr pool has its own workqueue 'rds_ib_fmr_wq', so we need
to use queue_delayed_work() to kick the work. This was hurting
the performance since pool maintenance was less often triggered
from other path.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 872f523..b6644fa 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -319,7 +319,7 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 	int err = 0, iter = 0;
 
 	if (atomic_read(&pool->dirty_count) >= pool->max_items / 10)
-		schedule_delayed_work(&pool->flush_worker, 10);
+		queue_delayed_work(rds_ib_fmr_wq, &pool->flush_worker, 10);
 
 	while (1) {
 		ibmr = rds_ib_reuse_fmr(pool);
-- 
1.9.1
