From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 09/13] RDS: Fix locking in rds_send_drop_to()
Date: Thu, 11 Mar 2010 15:50:03 -0800
Message-ID: <1268351407-7394-10-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Tina Yang <tina.yang@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39383 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786Ab0CKXvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:51:49 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet11.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNpm6o019761
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:51:49 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tina Yang <tina.yang@oracle.com>

It seems rds_send_drop_to() called
__rds_rdma_send_complete(rs, rm, RDS_RDMA_CANCELED)
with only rds_sock lock, but not rds_message lock. It raced with
other threads that is attempting to modify the rds_message as well,
such as from within rds_rdma_send_complete().

Signed-off-by: Tina Yang <tina.yang@oracle.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/send.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 1a2ef24..192a480 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -632,9 +632,6 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 		list_move(&rm->m_sock_item, &list);
 		rds_send_sndbuf_remove(rs, rm);
 		clear_bit(RDS_MSG_ON_SOCK, &rm->m_flags);
-
-		/* If this is a RDMA operation, notify the app. */
-		__rds_rdma_send_complete(rs, rm, RDS_RDMA_CANCELED);
 	}
 
 	/* order flag updates with the rs lock */
@@ -643,9 +640,6 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 
 	spin_unlock_irqrestore(&rs->rs_lock, flags);
 
-	if (wake)
-		rds_wake_sk_sleep(rs);
-
 	conn = NULL;
 
 	/* now remove the messages from the conn list as needed */
@@ -653,6 +647,10 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 		/* We do this here rather than in the loop above, so that
 		 * we don't have to nest m_rs_lock under rs->rs_lock */
 		spin_lock_irqsave(&rm->m_rs_lock, flags2);
+		/* If this is a RDMA operation, notify the app. */
+		spin_lock(&rs->rs_lock);
+		__rds_rdma_send_complete(rs, rm, RDS_RDMA_CANCELED);
+		spin_unlock(&rs->rs_lock);
 		rm->m_rs = NULL;
 		spin_unlock_irqrestore(&rm->m_rs_lock, flags2);
 
@@ -681,6 +679,9 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 	if (conn)
 		spin_unlock_irqrestore(&conn->c_lock, flags);
 
+	if (wake)
+		rds_wake_sk_sleep(rs);
+
 	while (!list_empty(&list)) {
 		rm = list_entry(list.next, struct rds_message, m_sock_item);
 		list_del_init(&rm->m_sock_item);
-- 
1.6.3.3

