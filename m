From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 2/6] tipc: fix connection refcount leak
Date: Thu, 6 Mar 2014 14:40:17 +0100
Message-ID: <1394113221-30100-3-git-send-email-erik.hugne@ericsson.com>
References: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:63600 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751921AbaCFNjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:39:48 -0500
In-Reply-To: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When tipc_conn_sendmsg() calls tipc_conn_lookup() to query a
connection instance, its reference count value is increased if
it's found. But subsequently if it's found that the connection is
closed, the work of sending message is not queued into its server
send workqueue, and the connection reference count is not decreased.
This will cause a reference count leak. To reproduce this problem,
an application would need to open and closes topology server
connections with high intensity.

We fix this by immediately decrementing the connection reference
count if a send fails due to the connection being closed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/server.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index bbaa8f5..646a930 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -427,10 +427,12 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
 	list_add_tail(&e->list, &con->outqueue);
 	spin_unlock_bh(&con->outqueue_lock);
 
-	if (test_bit(CF_CONNECTED, &con->flags))
+	if (test_bit(CF_CONNECTED, &con->flags)) {
 		if (!queue_work(s->send_wq, &con->swork))
 			conn_put(con);
-
+	} else {
+		conn_put(con);
+	}
 	return 0;
 }
 
-- 
1.8.3.2
