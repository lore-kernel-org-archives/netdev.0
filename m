From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 4/5] RDS: Do not send congestion updates to loopback connections
Date: Fri, 30 Oct 2009 11:51:56 -0700
Message-ID: <1256928717-17757-4-git-send-email-andy.grover@oracle.com>
References: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:21685 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757140AbZJ3SxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 14:53:10 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9UIsmxm031367
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 18:54:49 GMT
In-Reply-To: <1256928717-17757-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This issue was discovered by HP's Pradeep and fixed in OFED
1.3, but not fixed in later versions, since the fix's implementation
was not immediately applyable to the later code. This patch should
do the trick for 1.4+ codebases.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/cong.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index dd2711d..6d06cac 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -218,6 +218,8 @@ void rds_cong_queue_updates(struct rds_cong_map *map)
 	spin_lock_irqsave(&rds_cong_lock, flags);
 
 	list_for_each_entry(conn, &map->m_conn_list, c_map_item) {
+		if (conn->c_loopback)
+			continue;
 		if (!test_and_set_bit(0, &conn->c_map_queued)) {
 			rds_stats_inc(s_cong_update_queued);
 			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
-- 
1.6.3.3

