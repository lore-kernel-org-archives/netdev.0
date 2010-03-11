From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 07/13] RDS: Workaround for in-use MRs on close causing crash
Date: Thu, 11 Mar 2010 15:50:01 -0800
Message-ID: <1268351407-7394-8-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:49081 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab0CKXu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:59 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNovkj027513
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:59 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if a machine is shut down without closing sockets properly, and
freeing all MRs, then a BUG_ON will bring it down. This patch
changes these to WARN_ONs -- leaking MRs is not fatal (although
not ideal, and there is more work to do here for a proper fix.)

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_rdma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 4b0da86..65e668d 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -234,8 +234,8 @@ void rds_ib_destroy_mr_pool(struct rds_ib_mr_pool *pool)
 {
 	flush_workqueue(rds_wq);
 	rds_ib_flush_mr_pool(pool, 1);
-	BUG_ON(atomic_read(&pool->item_count));
-	BUG_ON(atomic_read(&pool->free_pinned));
+	WARN_ON(atomic_read(&pool->item_count));
+	WARN_ON(atomic_read(&pool->free_pinned));
 	kfree(pool);
 }
 
-- 
1.6.3.3

