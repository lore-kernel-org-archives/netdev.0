From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC v2 net-next] rds-tcp: Take explicit refcounts on struct net
Date: Tue, 28 Feb 2017 08:33:21 -0800
Message-ID: <1488299601-162004-1-git-send-email-sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:43405 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdCAOAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 09:00:24 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v21Bt0fs027759
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Wed, 1 Mar 2017 11:55:01 GMT
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a test patch being supplied for a trial run on syzkaller.

It's incorrect for the rds_connection to piggyback on the
sock_net() refcount for the netns because this gives rise to
a chicken-and-egg problem during rds_conn_destroy. Instead explicitly
take a ref on the net, and hold the netns down till the connection
tear-down is complete.

Dmitry: I'm not sure whether the other 2 panics around rds_sock
use-after-free are also around netns teardown and/or directly related 
to this- they may be unrelated bugs, could we please give this one
a trial run, while watching for the others? 

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
index 07fff73..219628f 100644
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
index 57bb523..bf4c6a3 100644
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
