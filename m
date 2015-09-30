From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/3] RDS-TCP: Set up MSG_MORE and MSG_SENDPAGE_NOTLAST as appropriate in rds_tcp_xmit
Date: Wed, 30 Sep 2015 09:45:54 -0400
Message-ID: <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22662 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbbI3NqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:46:12 -0400
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1443569239.git.sowmini.varadhan@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the same reasons as 2f53384424 and 35f9c09fe9, rds_tcp_xmit
may have multiple pages to send, so use the MSG_MORE and
MSG_SENDPAGE_NOTLAST as hints to tcp_sendpage()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_send.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 53b17ca..5f3e3fa 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -83,6 +83,7 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 	int done = 0;
 	int ret = 0;
+	int more;
 
 	if (hdr_off == 0) {
 		/*
@@ -116,12 +117,15 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 			goto out;
 	}
 
+	more = (rm->data.op_nents > 1 ? (MSG_MORE | MSG_SENDPAGE_NOTLAST) : 0);
 	while (sg < rm->data.op_nents) {
+		int flags = (MSG_DONTWAIT | MSG_NOSIGNAL | more);
+
 		ret = tc->t_sock->ops->sendpage(tc->t_sock,
 						sg_page(&rm->data.op_sg[sg]),
 						rm->data.op_sg[sg].offset + off,
 						rm->data.op_sg[sg].length - off,
-						MSG_DONTWAIT|MSG_NOSIGNAL);
+						flags);
 		rdsdebug("tcp sendpage %p:%u:%u ret %d\n", (void *)sg_page(&rm->data.op_sg[sg]),
 			 rm->data.op_sg[sg].offset + off, rm->data.op_sg[sg].length - off,
 			 ret);
@@ -134,6 +138,8 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 			off = 0;
 			sg++;
 		}
+		if (sg == rm->data.op_nents - 1)
+			more = 0;
 	}
 
 out:
-- 
1.7.1
