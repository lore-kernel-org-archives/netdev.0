From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 8/9] RDS: TCP: Simplify reconnect to avoid duelling reconnnect attempts
Date: Thu, 30 Jun 2016 16:11:17 -0700
Message-ID: <02e8cca5a90b5269bec03486dd9f81e2e37f30fe.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:43486 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcF3XMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:16 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNCA1h007742
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:11 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When reconnecting, the peer with the smaller IP address will initiate
the reconnect, to avoid needless duelling SYN issues.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |    4 +---
 net/rds/threads.c    |    5 +++++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 1b0c2a7..19a4fee 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -355,9 +355,7 @@ void rds_conn_shutdown(struct rds_conn_path *cp)
 	rcu_read_lock();
 	if (!hlist_unhashed(&conn->c_hash_node)) {
 		rcu_read_unlock();
-		if (conn->c_trans->t_type != RDS_TRANS_TCP ||
-		    cp->cp_outgoing == 1)
-			rds_queue_reconnect(cp);
+		rds_queue_reconnect(cp);
 	} else {
 		rcu_read_unlock();
 	}
diff --git a/net/rds/threads.c b/net/rds/threads.c
index e8f0941..bc97d67 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -125,6 +125,11 @@ void rds_queue_reconnect(struct rds_conn_path *cp)
 	  conn, &conn->c_laddr, &conn->c_faddr,
 	  cp->cp_reconnect_jiffies);
 
+	/* let peer with smaller addr initiate reconnect, to avoid duels */
+	if (conn->c_trans->t_type == RDS_TRANS_TCP &&
+	    conn->c_laddr > conn->c_faddr)
+		return;
+
 	set_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
 	if (cp->cp_reconnect_jiffies == 0) {
 		cp->cp_reconnect_jiffies = rds_sysctl_reconnect_min_jiffies;
-- 
1.7.1
