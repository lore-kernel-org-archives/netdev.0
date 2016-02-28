From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 10/13] RDS: IB: add mr reused stats
Date: Sat, 27 Feb 2016 18:19:47 -0800
Message-ID: <1456625990-4739-11-git-send-email-santosh.shilimkar@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42320 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992803AbcB1CU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 21:20:26 -0500
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MR reuse statistics to RDS IB transport.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h       | 2 ++
 net/rds/ib_rdma.c  | 7 ++++++-
 net/rds/ib_stats.c | 2 ++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index c88cb22..62fe7d5 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -259,6 +259,8 @@ struct rds_ib_statistics {
 	uint64_t	s_ib_rdma_mr_1m_pool_flush;
 	uint64_t	s_ib_rdma_mr_1m_pool_wait;
 	uint64_t	s_ib_rdma_mr_1m_pool_depleted;
+	uint64_t	s_ib_rdma_mr_8k_reused;
+	uint64_t	s_ib_rdma_mr_1m_reused;
 	uint64_t	s_ib_atomic_cswp;
 	uint64_t	s_ib_atomic_fadd;
 };
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 0e84843..ec7ea32 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -188,8 +188,13 @@ struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *pool)
 	flag = this_cpu_ptr(&clean_list_grace);
 	set_bit(CLEAN_LIST_BUSY_BIT, flag);
 	ret = llist_del_first(&pool->clean_list);
-	if (ret)
+	if (ret) {
 		ibmr = llist_entry(ret, struct rds_ib_mr, llnode);
+		if (pool->pool_type == RDS_IB_MR_8K_POOL)
+			rds_ib_stats_inc(s_ib_rdma_mr_8k_reused);
+		else
+			rds_ib_stats_inc(s_ib_rdma_mr_1m_reused);
+	}
 
 	clear_bit(CLEAN_LIST_BUSY_BIT, flag);
 	preempt_enable();
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index d77e044..7e78dca 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -73,6 +73,8 @@ static const char *const rds_ib_stat_names[] = {
 	"ib_rdma_mr_1m_pool_flush",
 	"ib_rdma_mr_1m_pool_wait",
 	"ib_rdma_mr_1m_pool_depleted",
+	"ib_rdma_mr_8k_reused",
+	"ib_rdma_mr_1m_reused",
 	"ib_atomic_cswp",
 	"ib_atomic_fadd",
 };
-- 
1.9.1
