From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/2] tipc: fix socket flow control accounting error at tipc_send_stream
Date: Mon, 24 Apr 2017 15:00:42 +0200
Message-ID: <1493038843-30621-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:42358 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1170464AbdDXNDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now in tipc_send_stream(), we return -1 when the socket
encounters link congestion even if the socket had successfully
sent partial data. This is incorrect as the application resends
the same the partial data leading to data corruption at
receiver's end.

In this commit, we return the partially sent bytes as the return
value at link congestion.

Fixes: 10724cc7bb78 ("tipc: redesign connection-level flow control")
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7130e73bd42c..b28e94f1c739 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1083,7 +1083,7 @@ static int __tipc_sendstream(struct socket *sock, struct msghdr *m, size_t dlen)
 		}
 	} while (sent < dlen && !rc);
 
-	return rc ? rc : sent;
+	return sent ? sent : rc;
 }
 
 /**
-- 
2.1.4
