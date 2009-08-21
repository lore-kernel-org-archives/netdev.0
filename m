From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 4/5] RDS: Track transports via an array, not a list
Date: Fri, 21 Aug 2009 15:28:34 -0700
Message-ID: <1250893715-21939-5-git-send-email-andy.grover@oracle.com>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:59348 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbZHUW2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:51 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMSIKZ015445
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:28:20 GMT
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that transports can be loaded in arbitrary order,
it is important for rds_trans_get_preferred() to look
for them in a particular order, instead of walking the list
until it finds a transport that works for a given address.
Now, each transport registers for a specific transport slot,
and these are ordered so that preferred transports come first,
and then if they are not loaded, other transports are queried.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c        |    1 +
 net/rds/iw.c        |    1 +
 net/rds/rds.h       |    6 ++++++
 net/rds/tcp.c       |    1 +
 net/rds/transport.c |   29 +++++++++++++++++++----------
 5 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 868559a..536ebe5 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -282,6 +282,7 @@ struct rds_transport rds_ib_transport = {
 	.flush_mrs		= rds_ib_flush_mrs,
 	.t_owner		= THIS_MODULE,
 	.t_name			= "infiniband",
+	.t_type			= RDS_TRANS_IB
 };
 
 int __init rds_ib_init(void)
diff --git a/net/rds/iw.c b/net/rds/iw.c
index f5e9a29..db224f7 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -284,6 +284,7 @@ struct rds_transport rds_iw_transport = {
 	.flush_mrs		= rds_iw_flush_mrs,
 	.t_owner		= THIS_MODULE,
 	.t_name			= "iwarp",
+	.t_type			= RDS_TRANS_IWARP,
 	.t_prefer_loopback	= 1,
 };
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 290566c..85d6f89 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -311,11 +311,17 @@ struct rds_notifier {
  * 		   flag and header.
  */
 
+#define RDS_TRANS_IB	0
+#define RDS_TRANS_IWARP	1
+#define RDS_TRANS_TCP	2
+#define RDS_TRANS_COUNT	3
+
 struct rds_transport {
 	char			t_name[TRANSNAMSIZ];
 	struct list_head	t_item;
 	struct module		*t_owner;
 	unsigned int		t_prefer_loopback:1;
+	unsigned int		t_type;
 
 	int (*laddr_check)(__be32 addr);
 	int (*conn_alloc)(struct rds_connection *conn, gfp_t gfp);
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index e0ac900..b5198ae 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -271,6 +271,7 @@ struct rds_transport rds_tcp_transport = {
 	.exit			= rds_tcp_exit,
 	.t_owner		= THIS_MODULE,
 	.t_name			= "tcp",
+	.t_type			= RDS_TRANS_TCP,
 	.t_prefer_loopback	= 1,
 };
 
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 56a5309..7e10679 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -37,7 +37,7 @@
 #include "rds.h"
 #include "loop.h"
 
-static LIST_HEAD(rds_transports);
+static struct rds_transport *transports[RDS_TRANS_COUNT];
 static DECLARE_RWSEM(rds_trans_sem);
 
 int rds_trans_register(struct rds_transport *trans)
@@ -46,8 +46,13 @@ int rds_trans_register(struct rds_transport *trans)
 
 	down_write(&rds_trans_sem);
 
-	list_add_tail(&trans->t_item, &rds_transports);
-	printk(KERN_INFO "Registered RDS/%s transport\n", trans->t_name);
+	if (transports[trans->t_type])
+		printk(KERN_ERR "RDS Transport type %d already registered\n",
+			trans->t_type);
+	else {
+		transports[trans->t_type] = trans;
+		printk(KERN_INFO "Registered RDS/%s transport\n", trans->t_name);
+	}
 
 	up_write(&rds_trans_sem);
 
@@ -59,7 +64,7 @@ void rds_trans_unregister(struct rds_transport *trans)
 {
 	down_write(&rds_trans_sem);
 
-	list_del_init(&trans->t_item);
+	transports[trans->t_type] = NULL;
 	printk(KERN_INFO "Unregistered RDS/%s transport\n", trans->t_name);
 
 	up_write(&rds_trans_sem);
@@ -68,16 +73,17 @@ EXPORT_SYMBOL_GPL(rds_trans_unregister);
 
 struct rds_transport *rds_trans_get_preferred(__be32 addr)
 {
-	struct rds_transport *trans;
 	struct rds_transport *ret = NULL;
+	int i;
 
 	if (IN_LOOPBACK(ntohl(addr)))
 		return &rds_loop_transport;
 
 	down_read(&rds_trans_sem);
-	list_for_each_entry(trans, &rds_transports, t_item) {
-		if (trans->laddr_check(addr) == 0) {
-			ret = trans;
+	for (i = 0; i < RDS_TRANS_COUNT; i++)
+	{
+		if (transports[i] && (transports[i]->laddr_check(addr) == 0)) {
+			ret = transports[i];
 			break;
 		}
 	}
@@ -99,12 +105,15 @@ unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 	struct rds_transport *trans;
 	unsigned int total = 0;
 	unsigned int part;
+	int i;
 
 	rds_info_iter_unmap(iter);
 	down_read(&rds_trans_sem);
 
-	list_for_each_entry(trans, &rds_transports, t_item) {
-		if (trans->stats_info_copy == NULL)
+	for (i = 0; i < RDS_TRANS_COUNT; i++)
+	{
+		trans = transports[i];
+		if (!trans || !trans->stats_info_copy)
 			continue;
 
 		part = trans->stats_info_copy(iter, avail);
-- 
1.6.0.4

