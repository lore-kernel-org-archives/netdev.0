From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 4/4] tipc: change lock_sock order in connect()
Date: Thu, 12 Dec 2013 09:36:42 +0800
Message-ID: <1386812202-11956-5-git-send-email-wangweidong1@huawei.com>
References: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2662 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab3LLBh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:37:29 -0500
In-Reply-To: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of reaquiring the socket lock and taking the normal exit
path when a connection times out, we bail out early with a
return -ETIMEDOUT.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/tipc/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 844bf34..83f466e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1507,14 +1507,12 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 				sock->state != SS_CONNECTING,
 				timeout ? (long)msecs_to_jiffies(timeout)
 					: MAX_SCHEDULE_TIMEOUT);
-		lock_sock(sk);
 		if (res <= 0) {
 			if (res == 0)
 				res = -ETIMEDOUT;
-			else
-				; /* leave "res" unchanged */
-			goto exit;
+			return res;
 		}
+		lock_sock(sk);
 	}
 
 	if (unlikely(sock->state == SS_DISCONNECTING))
-- 
1.7.12
