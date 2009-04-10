From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 03/12] RDS/IW+IB: Set the RDS_LL_SEND_FULL bit when we're throttled.
Date: Thu,  9 Apr 2009 17:09:38 -0700
Message-ID: <1239322187-3764-4-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Steve Wise <swise@opengridcomputing.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53250 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937005AbZDJAKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:03 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

The RDS_LL_SEND_FULL bit should be set when we stop transmitted due to
flow control.  Otherwise the send worker will keep trying as opposed to
sleeping until we unthrottle.  Saves CPU.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_send.c |    2 +-
 net/rds/iw_send.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index cb6c52c..fa684b7 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -506,7 +506,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 			flow_controlled++;
 		}
 		if (work_alloc == 0) {
-			rds_ib_ring_unalloc(&ic->i_send_ring, work_alloc);
+			set_bit(RDS_LL_SEND_FULL, &conn->c_flags);
 			rds_ib_stats_inc(s_ib_tx_throttle);
 			ret = -ENOMEM;
 			goto out;
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 22dd38f..626290b 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -549,7 +549,7 @@ int rds_iw_xmit(struct rds_connection *conn, struct rds_message *rm,
 			flow_controlled++;
 		}
 		if (work_alloc == 0) {
-			rds_iw_ring_unalloc(&ic->i_send_ring, work_alloc);
+			set_bit(RDS_LL_SEND_FULL, &conn->c_flags);
 			rds_iw_stats_inc(s_iw_tx_throttle);
 			ret = -ENOMEM;
 			goto out;
-- 
1.5.6.3

