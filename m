From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 10/13] RDS: only put sockets that have seen congestion on the poll_waitq
Date: Thu, 11 Mar 2010 15:50:04 -0800
Message-ID: <1268351407-7394-11-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45090 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab0CKXu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:58 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet11.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNouIp023385
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:57 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_poll_waitq's listeners will be awoken if we receive a congestion
notification. Bad performance may result because *all* polled sockets
contend for this single lock. However, it should not be necessary to
wake pollers when a congestion update arrives if they have never
experienced congestion, and not putting these on the waitq will
hopefully greatly reduce contention.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/af_rds.c |    7 ++++++-
 net/rds/rds.h    |    2 ++
 net/rds/send.c   |    4 +++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 853c52b..937ecda 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -159,7 +159,8 @@ static unsigned int rds_poll(struct file *file, struct socket *sock,
 
 	poll_wait(file, sk->sk_sleep, wait);
 
-	poll_wait(file, &rds_poll_waitq, wait);
+	if (rs->rs_seen_congestion)
+		poll_wait(file, &rds_poll_waitq, wait);
 
 	read_lock_irqsave(&rs->rs_recv_lock, flags);
 	if (!rs->rs_cong_monitor) {
@@ -181,6 +182,10 @@ static unsigned int rds_poll(struct file *file, struct socket *sock,
 		mask |= (POLLOUT | POLLWRNORM);
 	read_unlock_irqrestore(&rs->rs_recv_lock, flags);
 
+	/* clear state any time we wake a seen-congested socket */
+	if (mask)
+		rs->rs_seen_congestion = 0;
+
 	return mask;
 }
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 85d6f89..4bec6e2 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -388,6 +388,8 @@ struct rds_sock {
 
 	/* flag indicating we were congested or not */
 	int			rs_congested;
+	/* seen congestion (ENOBUFS) when sending? */
+	int			rs_seen_congestion;
 
 	/* rs_lock protects all these adjacent members before the newline */
 	spinlock_t		rs_lock;
diff --git a/net/rds/send.c b/net/rds/send.c
index 192a480..51e2def 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -894,8 +894,10 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
 
 	ret = rds_cong_wait(conn->c_fcong, dport, nonblock, rs);
-	if (ret)
+	if (ret) {
+		rs->rs_seen_congestion = 1;
 		goto out;
+	}
 
 	while (!rds_send_queue_rm(rs, conn, rm, rs->rs_bound_port,
 				  dport, &queued)) {
-- 
1.6.3.3

