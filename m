From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 1/3] rds: tcp: Take explicit refcounts on struct net
Date: Sat,  4 Mar 2017 08:57:33 -0800
Message-ID: <ca731ca5358b8bd595b1af39ba1a5e2c22429a80.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Cc: syzkaller@googlegroups.com, rds-devel@oss.oracle.com
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        santosh.shilimkar@oracle.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42063 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752457AbdCEMR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 07:17:56 -0500
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is incorrect for the rds_connection to piggyback on the
sock_net() refcount for the netns because this gives rise to
a chicken-and-egg problem during rds_conn_destroy. Instead explicitly
take a ref on the net, and hold the netns down till the connection
tear-down is complete.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |    1 +
 net/rds/rds.h        |    6 +++---
 net/rds/tcp.c        |    4 ++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 0e04dcc..1fa75ab 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -429,6 +429,7 @@ void rds_conn_destroy(struct rds_connection *conn)
 	 */
 	rds_cong_remove_conn(conn);
 
+	put_net(conn->c_net);
 	kmem_cache_free(rds_conn_slab, conn);
 
 	spin_lock_irqsave(&rds_conn_lock, flags);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 6f523dd..5dd2565 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -147,7 +147,7 @@ struct rds_connection {
 
 	/* Protocol version */
 	unsigned int		c_version;
-	possible_net_t		c_net;
+	struct net		*c_net;
 
 	struct list_head	c_map_item;
 	unsigned long		c_map_queued;
@@ -162,13 +162,13 @@ struct rds_connection {
 static inline
 struct net *rds_conn_net(struct rds_connection *conn)
 {
-	return read_pnet(&conn->c_net);
+	return conn->c_net;
 }
 
 static inline
 void rds_conn_net_set(struct rds_connection *conn, struct net *net)
 {
-	write_pnet(&conn->c_net, net);
+	conn->c_net = get_net(net);
 }
 
 #define RDS_FLAG_CONG_BITMAP	0x01
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index a973d3b..65c8e3b 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -529,7 +529,7 @@ static void rds_tcp_kill_sock(struct net *net)
 	flush_work(&rtn->rds_tcp_accept_w);
 	spin_lock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
-		struct net *c_net = read_pnet(&tc->t_cpath->cp_conn->c_net);
+		struct net *c_net = tc->t_cpath->cp_conn->c_net;
 
 		if (net != c_net || !tc->t_sock)
 			continue;
@@ -584,7 +584,7 @@ static void rds_tcp_sysctl_reset(struct net *net)
 
 	spin_lock_irq(&rds_tcp_conn_lock);
 	list_for_each_entry_safe(tc, _tc, &rds_tcp_conn_list, t_tcp_node) {
-		struct net *c_net = read_pnet(&tc->t_cpath->cp_conn->c_net);
+		struct net *c_net = tc->t_cpath->cp_conn->c_net;
 
 		if (net != c_net || !tc->t_sock)
 			continue;
-- 
1.7.1
