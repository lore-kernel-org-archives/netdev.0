From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 2/5] RDS: Fix potential race around rds_i[bw]_allocation
Date: Fri, 30 Oct 2009 11:51:54 -0700
Message-ID: <1256928717-17757-2-git-send-email-andy.grover@oracle.com>
References: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55991 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757316AbZJ3SxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:53:18 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9UIr9a9012332
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 18:53:11 GMT
In-Reply-To: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From Shin Hong:

"At rds_ib_recv_refill_one(), it first executes atomic_read(&rds_ib_allocation)
for if-condition checking,

and then executes atomic_inc(&rds_ib_allocation) if the condition was
not satisfied.

However, if any other code which updates rds_ib_allocation executes
between these two atomic operation executions,
it seems that it may result race condition. (especially when
rds_ib_allocation + 1 == rds_ib_sysctl_max_recv_allocation)"

This patch fixes this by using atomic_inc_unless to eliminate the
possibility of allocating more than rds_ib_sysctl_max_recv_allocation
and then decrementing the count if the allocation fails. It also
makes an identical change to the iwarp transport.

Reported-by: Shin Hong <hongshin@gmail.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_recv.c |    7 ++++---
 net/rds/iw_recv.c |    7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index cd7a6cf..2f009d3 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -143,15 +143,16 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
 	int ret = -ENOMEM;
 
 	if (recv->r_ibinc == NULL) {
-		if (atomic_read(&rds_ib_allocation) >= rds_ib_sysctl_max_recv_allocation) {
+		if (!atomic_add_unless(&rds_ib_allocation, 1, rds_ib_sysctl_max_recv_allocation)) {
 			rds_ib_stats_inc(s_ib_rx_alloc_limit);
 			goto out;
 		}
 		recv->r_ibinc = kmem_cache_alloc(rds_ib_incoming_slab,
 						 kptr_gfp);
-		if (recv->r_ibinc == NULL)
+		if (recv->r_ibinc == NULL) {
+			atomic_dec(&rds_ib_allocation);
 			goto out;
-		atomic_inc(&rds_ib_allocation);
+		}
 		INIT_LIST_HEAD(&recv->r_ibinc->ii_frags);
 		rds_inc_init(&recv->r_ibinc->ii_inc, conn, conn->c_faddr);
 	}
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 8683f5f..9f98150 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -143,15 +143,16 @@ static int rds_iw_recv_refill_one(struct rds_connection *conn,
 	int ret = -ENOMEM;
 
 	if (recv->r_iwinc == NULL) {
-		if (atomic_read(&rds_iw_allocation) >= rds_iw_sysctl_max_recv_allocation) {
+		if (!atomic_add_unless(&rds_iw_allocation, 1, rds_iw_sysctl_max_recv_allocation)) {
 			rds_iw_stats_inc(s_iw_rx_alloc_limit);
 			goto out;
 		}
 		recv->r_iwinc = kmem_cache_alloc(rds_iw_incoming_slab,
 						 kptr_gfp);
-		if (recv->r_iwinc == NULL)
+		if (recv->r_iwinc == NULL) {
+			atomic_dec(&rds_iw_allocation);
 			goto out;
-		atomic_inc(&rds_iw_allocation);
+		}
 		INIT_LIST_HEAD(&recv->r_iwinc->ii_frags);
 		rds_inc_init(&recv->r_iwinc->ii_inc, conn, conn->c_faddr);
 	}
-- 
1.6.3.3

