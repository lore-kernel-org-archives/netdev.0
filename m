From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 4/9] RDS: TCP: Refactor connection destruction to handle multiple paths
Date: Thu, 30 Jun 2016 16:11:13 -0700
Message-ID: <d2625bd51b8959092cdce7c8266462f4c974cd07.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44452 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbcF3XMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:17 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNCBAi007302
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:11 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A single rds_connection may have multiple rds_conn_paths that have
to be carefully and correctly destroyed, for both rmmod and
netns-delete cases.

For both cases, we extract a single rds_tcp_connection for
each conn into a temporary list, and then invoke rds_conn_destroy()
which iteratively dismantles every path in the rds_connection.

For the netns deletion case, we additionally have to make sure
that we do not leave a socket in TIME_WAIT state, as this will
hold up the netns deletion. Thus we call rds_tcp_conn_paths_destroy()
to reset state quickly.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp.c |   46 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index c6b47f6..b327727 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -323,6 +323,17 @@ static void rds_tcp_conn_free(void *arg)
 	kmem_cache_free(rds_tcp_conn_slab, tc);
 }
 
+static bool list_has_conn(struct list_head *list, struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc, *_tc;
+
+	list_for_each_entry_safe(tc, _tc, list, t_tcp_node) {
+		if (tc->t_cpath->cp_conn == conn)
+			return true;
+	}
+	return false;
+}
+
 static void rds_tcp_destroy_conns(void)
 {
 	struct rds_tcp_connection *tc, *_tc;
@@ -330,8 +341,10 @@ static void rds_tcp_destroy_conns(void)
 
 	/* avoid calling conn_destroy with irqs off */
 	spin_lock_irq(&rds_tcp_conn_lock);
-	list_splice(&rds_tcp_conn_list, &tmp_list);
-	INIT_LIST_HEAD(&rds_tcp_conn_list);
+	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
+		if (!list_has_conn(&tmp_list, tc->t_cpath->cp_conn))
+			list_move_tail(&tc->t_tcp_node, &tmp_list);
+	}
 	spin_unlock_irq(&rds_tcp_conn_lock);
 
 	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node)
@@ -491,10 +504,30 @@ static struct pernet_operations rds_tcp_net_ops = {
 	.size = sizeof(struct rds_tcp_net),
 };
 
+/* explicitly send a RST on each socket, thereby releasing any socket refcnts
+ * that may otherwise hold up netns deletion.
+ */
+static void rds_tcp_conn_paths_destroy(struct rds_connection *conn)
+{
+	struct rds_conn_path *cp;
+	struct rds_tcp_connection *tc;
+	int i;
+	struct sock *sk;
+
+	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
+		cp = &conn->c_path[i];
+		tc = cp->cp_transport_data;
+		if (!tc->t_sock)
+			continue;
+		sk = tc->t_sock->sk;
+		sk->sk_prot->disconnect(sk, 0);
+		tcp_done(sk);
+	}
+}
+
 static void rds_tcp_kill_sock(struct net *net)
 {
 	struct rds_tcp_connection *tc, *_tc;
-	struct sock *sk;
 	LIST_HEAD(tmp_list);
 	struct rds_tcp_net *rtn = net_generic(net, rds_tcp_netid);
 
@@ -507,13 +540,12 @@ static void rds_tcp_kill_sock(struct net *net)
 
 		if (net != c_net || !tc->t_sock)
 			continue;
-		list_move_tail(&tc->t_tcp_node, &tmp_list);
+		if (!list_has_conn(&tmp_list, tc->t_cpath->cp_conn))
+			list_move_tail(&tc->t_tcp_node, &tmp_list);
 	}
 	spin_unlock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node) {
-		sk = tc->t_sock->sk;
-		sk->sk_prot->disconnect(sk, 0);
-		tcp_done(sk);
+		rds_tcp_conn_paths_destroy(tc->t_cpath->cp_conn);
 		rds_conn_destroy(tc->t_cpath->cp_conn);
 	}
 }
-- 
1.7.1
