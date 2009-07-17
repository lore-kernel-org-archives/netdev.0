From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 11/15] RDS: Fix completion notifications on blocking sockets
Date: Fri, 17 Jul 2009 16:13:32 -0700
Message-ID: <1247872416-17834-12-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:17730 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030AbZGQXOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:14:08 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNFhQG022716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:15:44 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Completion or congestion notifications were not being checked
if the socket went to sleep. This patch fixes that.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/recv.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/rds/recv.c b/net/rds/recv.c
index f2118c5..86bc1a0 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -409,18 +409,18 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (msg_flags & MSG_OOB)
 		goto out;
 
-	/* If there are pending notifications, do those - and nothing else */
-	if (!list_empty(&rs->rs_notify_queue)) {
-		ret = rds_notify_queue_get(rs, msg);
-		goto out;
-	}
+	while (1) {
+		/* If there are pending notifications, do those - and nothing else */
+		if (!list_empty(&rs->rs_notify_queue)) {
+			ret = rds_notify_queue_get(rs, msg);
+			break;
+		}
 
-	if (rs->rs_cong_notify) {
-		ret = rds_notify_cong(rs, msg);
-		goto out;
-	}
+		if (rs->rs_cong_notify) {
+			ret = rds_notify_cong(rs, msg);
+			break;
+		}
 
-	while (1) {
 		if (!rds_next_incoming(rs, &inc)) {
 			if (nonblock) {
 				ret = -EAGAIN;
@@ -428,7 +428,9 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 			}
 
 			timeo = wait_event_interruptible_timeout(*sk->sk_sleep,
-						rds_next_incoming(rs, &inc),
+						(!list_empty(&rs->rs_notify_queue)
+						|| rs->rs_cong_notify
+						|| rds_next_incoming(rs, &inc)),
 						timeo);
 			rdsdebug("recvmsg woke inc %p timeo %ld\n", inc,
 				 timeo);
-- 
1.6.0.4

