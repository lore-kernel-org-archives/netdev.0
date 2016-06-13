From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 03/17] RDS: recv path gets the conn_path from rds_incoming for MP capable transports
Date: Mon, 13 Jun 2016 09:44:28 -0700
Message-ID: <1db17f2c3112d5cf743c75c0e7edd2620017600d.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40941 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965088AbcFMQpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:10 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Transports that are t_mp_capable should set the rds_conn_path
on which the datagram was recived in the ->i_conn_path field
of struct rds_incoming.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h  |    1 +
 net/rds/recv.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index 28f001c..7c85b2d 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -231,6 +231,7 @@ struct rds_incoming {
 	atomic_t		i_refcount;
 	struct list_head	i_item;
 	struct rds_connection	*i_conn;
+	struct rds_conn_path	*i_conn_path;
 	struct rds_header	i_hdr;
 	unsigned long		i_rx_jiffies;
 	__be32			i_saddr;
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 78b5c43..e36652c 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -38,7 +38,6 @@
 #include <linux/time.h>
 #include <linux/rds.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 
 void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
@@ -165,13 +164,18 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 	struct rds_sock *rs = NULL;
 	struct sock *sk;
 	unsigned long flags;
+	struct rds_conn_path *cp;
 
 	inc->i_conn = conn;
 	inc->i_rx_jiffies = jiffies;
+	if (conn->c_trans->t_mp_capable)
+		cp = inc->i_conn_path;
+	else
+		cp = &conn->c_path[0];
 
 	rdsdebug("conn %p next %llu inc %p seq %llu len %u sport %u dport %u "
 		 "flags 0x%x rx_jiffies %lu\n", conn,
-		 (unsigned long long)conn->c_next_rx_seq,
+		 (unsigned long long)cp->cp_next_rx_seq,
 		 inc,
 		 (unsigned long long)be64_to_cpu(inc->i_hdr.h_sequence),
 		 be32_to_cpu(inc->i_hdr.h_len),
@@ -200,12 +204,12 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 	 * XXX we could spend more on the wire to get more robust failure
 	 * detection, arguably worth it to avoid data corruption.
 	 */
-	if (be64_to_cpu(inc->i_hdr.h_sequence) < conn->c_next_rx_seq &&
+	if (be64_to_cpu(inc->i_hdr.h_sequence) < cp->cp_next_rx_seq &&
 	    (inc->i_hdr.h_flags & RDS_FLAG_RETRANSMITTED)) {
 		rds_stats_inc(s_recv_drop_old_seq);
 		goto out;
 	}
-	conn->c_next_rx_seq = be64_to_cpu(inc->i_hdr.h_sequence) + 1;
+	cp->cp_next_rx_seq = be64_to_cpu(inc->i_hdr.h_sequence) + 1;
 
 	if (rds_sysctl_ping_enable && inc->i_hdr.h_dport == 0) {
 		rds_stats_inc(s_recv_ping);
-- 
1.7.1
