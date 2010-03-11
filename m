From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 06/13] RDS: Fix send locking issue
Date: Thu, 11 Mar 2010 15:50:00 -0800
Message-ID: <1268351407-7394-7-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Tina Yang <Tina.Yang@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45107 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521Ab0CKXu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:58 -0500
Received: from rcsinet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rcsinet11.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNovLp023443
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:58 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tina Yang <Tina.Yang@oracle.com>

Fix a deadlock between rds_rdma_send_complete() and
rds_send_remove_from_sock() when rds socket lock and
rds message lock are acquired out-of-order.

Signed-off-by: Tina Yang <Tina.Yang@oracle.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/send.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index ad2e469..1a2ef24 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -533,14 +533,13 @@ void rds_send_remove_from_sock(struct list_head *messages, int status)
 
 		if (rs != rm->m_rs) {
 			if (rs) {
-				spin_unlock(&rs->rs_lock);
 				rds_wake_sk_sleep(rs);
 				sock_put(rds_rs_to_sk(rs));
 			}
 			rs = rm->m_rs;
-			spin_lock(&rs->rs_lock);
 			sock_hold(rds_rs_to_sk(rs));
 		}
+		spin_lock(&rs->rs_lock);
 
 		if (test_and_clear_bit(RDS_MSG_ON_SOCK, &rm->m_flags)) {
 			struct rds_rdma_op *ro = rm->m_rdma_op;
@@ -560,6 +559,7 @@ void rds_send_remove_from_sock(struct list_head *messages, int status)
 			rds_message_put(rm);
 			rm->m_rs = NULL;
 		}
+		spin_unlock(&rs->rs_lock);
 
 unlock_and_drop:
 		spin_unlock(&rm->m_rs_lock);
@@ -567,7 +567,6 @@ unlock_and_drop:
 	}
 
 	if (rs) {
-		spin_unlock(&rs->rs_lock);
 		rds_wake_sk_sleep(rs);
 		sock_put(rds_rs_to_sk(rs));
 	}
-- 
1.6.3.3

