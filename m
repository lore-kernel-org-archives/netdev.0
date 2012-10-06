From: Jeff Liu <jeff.liu@oracle.com>
Subject: [PATCH] RDS: Fix spinlock recursion for rds over tcp transmit
Date: Sat, 06 Oct 2012 13:42:37 +0800
Message-ID: <506FC4CD.7070509@oracle.com>
Reply-To: jeff.liu@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Dan Carpenter <dan.carpenter@oracle.com>, davem@davemloft.net,
	James Morris <james.l.morris@oracle.com>,
	netdev@vger.kernel.org
To: rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30155 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab2JFFnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 01:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

RDS ping/pong over TCP feature has broke for years(2.6.39 to 3.6.0) since we have to set TCP cork and
call kerenel_sendmsg() to reply a ping requirement which both need to lock "struct sock *sk".
However, this lock has already been hold before our rda_tcp_data_ready() callback is triggerred.
As a result, we always facing spinlock recursion which would resulting in system panic...

Given that RDS ping is a special kind of message, we don't need to reply it as
soon as possible, IMHO, we can schedule it to work queue as a delayed response to
make TCP transport totally works.  Also, I think we can using the system default
work queue to serve it to reduce the possible impact on general TCP transmit.

With below patch, I have run rds-ping(run multiple ping between two hosts at the same time) and
rds-stress(hostA listen, hostB send packets) for half day, it works to me.

Thanks,
-Jeff


Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
CC: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
CC: David S. Miller <davem@davemloft.net>
CC: James Morris <james.l.morris@oracle.com>
Signed-off-by: Jie Liu <jeff.liu@oracle.com>

---
 net/rds/send.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 net/rds/tcp.h  |    7 +++++
 2 files changed, 82 insertions(+), 5 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 96531d4..011006e 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -38,8 +38,10 @@
 #include <linux/list.h>
 #include <linux/ratelimit.h>
 #include <linux/export.h>
+#include <linux/workqueue.h>
 
 #include "rds.h"
+#include "tcp.h"
 
 /* When transmitting messages in rds_send_xmit, we need to emerge from
  * time to time and briefly release the CPU. Otherwise the softlock watchdog
@@ -55,6 +57,12 @@ static int send_batch_count = 64;
 module_param(send_batch_count, int, 0444);
 MODULE_PARM_DESC(send_batch_count, " batch factor when working the send queue");
 
+/* RDS over TCP ping/pong */
+static void rds_tcp_pong_worker(struct work_struct *work);
+static DEFINE_SPINLOCK(rds_tcp_pong_lock);
+static LIST_HEAD(rds_tcp_pong_list);
+static DECLARE_WORK(rds_tcp_pong_work, rds_tcp_pong_worker);
+
 static void rds_send_remove_from_sock(struct list_head *messages, int status);
 
 /*
@@ -1082,11 +1090,7 @@ out:
 	return ret;
 }
 
-/*
- * Reply to a ping packet.
- */
-int
-rds_send_pong(struct rds_connection *conn, __be16 dport)
+static int rds_tcp_send_pong(struct rds_connection *conn, __be16 dport)
 {
 	struct rds_message *rm;
 	unsigned long flags;
@@ -1132,3 +1136,69 @@ out:
 		rds_message_put(rm);
 	return ret;
 }
+
+static void rds_tcp_pong_worker(struct work_struct *work)
+{
+	struct rds_tcp_pong *tp;
+	struct rds_connection *conn;
+	__be16 dport;
+
+	spin_lock(&rds_tcp_pong_lock);
+	if (list_empty(&rds_tcp_pong_list))
+		goto out_unlock;
+
+	/*
+	 * Process on tcp pong once one time to reduce the possbile impact
+	 * on normal transmit.
+	 */
+	tp = list_entry(rds_tcp_pong_list.next, struct rds_tcp_pong, tp_node);
+	conn = tp->tp_conn;
+	dport = tp->tp_dport;
+	list_del(&tp->tp_node);
+	spin_unlock(&rds_tcp_pong_lock);
+
+	kfree(tp);
+	rds_tcp_send_pong(conn, dport);
+	goto out;
+
+out_unlock:
+	spin_unlock(&rds_tcp_pong_lock);
+out:
+	return;
+}
+
+/*
+ * RDS over TCP transport support ping/pong message.  However, it
+ * always resulting in sock spinlock recursion up to 3.7.0.  To solve
+ * this issue, we can shedule it to work queue as a delayed response.
+ * Here we using the system default work queue.
+ */
+int rds_tcp_pong(struct rds_connection *conn, __be16 dport)
+{
+	struct rds_tcp_pong *tp;
+	int ret = 0;
+
+	tp = kmalloc(sizeof(*tp), GFP_ATOMIC);
+	if (!tp) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	tp->tp_conn = conn;
+	tp->tp_dport = dport;
+	spin_lock(&rds_tcp_pong_lock);
+	list_add_tail(&tp->tp_node, &rds_tcp_pong_list);
+	spin_unlock(&rds_tcp_pong_lock);
+	schedule_work(&rds_tcp_pong_work);
+
+out:
+	return ret;
+}
+
+/*
+ * Reply to a ping package, TCP only.
+ */
+int rds_send_pong(struct rds_connection *conn, __be16 dport)
+{
+	return rds_tcp_pong(conn, dport);
+}
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 9cf2927..c4c7e01 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -3,6 +3,13 @@
 
 #define RDS_TCP_PORT	16385
 
+/* RDS over TCP ping/pong message entry */
+struct rds_tcp_pong {
+	struct list_head	tp_node;
+	struct rds_connection	*tp_conn;
+	__be16			tp_dport;
+};
+
 struct rds_tcp_incoming {
 	struct rds_incoming	ti_inc;
 	struct sk_buff_head	ti_skb_list;
-- 
1.7.9.5
