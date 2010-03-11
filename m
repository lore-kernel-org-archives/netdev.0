From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 05/13] RDS: Fix congestion issues for loopback
Date: Thu, 11 Mar 2010 15:49:59 -0800
Message-ID: <1268351407-7394-6-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17304 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab0CKXvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:51:49 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNpmi3002986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:51:49 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have two kinds of loopback: software (via loop transport)
and hardware (via IB). sw is used for 127.0.0.1, and doesn't
support rdma ops. hw is used for sends to local device IPs,
and supports rdma. Both are used in different cases.

For both of these, when there is a congestion map update, we
want to call rds_cong_map_updated() but not actually send
anything -- since loopback local and foreign congestion maps
point to the same spot, they're already in sync.

The old code never called sw loop's xmit_cong_map(),so
rds_cong_map_updated() wasn't being called for it. sw loop
ports would not work right with the congestion monitor.

Fixing that meant that hw loopback now would send congestion maps
to itself. This is also undesirable (racy), so we check for this
case in the ib-specific xmit code.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/cong.c    |    2 --
 net/rds/ib_send.c |    7 +++++++
 net/rds/loop.c    |    7 -------
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index 6d06cac..dd2711d 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -218,8 +218,6 @@ void rds_cong_queue_updates(struct rds_cong_map *map)
 	spin_lock_irqsave(&rds_cong_lock, flags);
 
 	list_for_each_entry(conn, &map->m_conn_list, c_map_item) {
-		if (conn->c_loopback)
-			continue;
 		if (!test_and_set_bit(0, &conn->c_map_queued)) {
 			rds_stats_inc(s_cong_update_queued);
 			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index f380c3f..c18228a 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -482,6 +482,13 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	BUG_ON(off % RDS_FRAG_SIZE);
 	BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));
 
+	/* Do not send cong updates to IB loopback */
+	if (conn->c_loopback
+	    && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
+		rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
+		return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+	}
+
 	/* FIXME we may overallocate here */
 	if (be32_to_cpu(rm->m_inc.i_hdr.h_len) == 0)
 		i = 1;
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 4a61997..93a45f1 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -80,16 +80,9 @@ static int rds_loop_xmit_cong_map(struct rds_connection *conn,
 				  struct rds_cong_map *map,
 				  unsigned long offset)
 {
-	unsigned long i;
-
 	BUG_ON(offset);
 	BUG_ON(map != conn->c_lcong);
 
-	for (i = 0; i < RDS_CONG_MAP_PAGES; i++) {
-		memcpy((void *)conn->c_fcong->m_page_addrs[i],
-		       (void *)map->m_page_addrs[i], PAGE_SIZE);
-	}
-
 	rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
 
 	return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
-- 
1.6.3.3

