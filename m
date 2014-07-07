From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix a memleak when sending data
Date: Sun,  6 Jul 2014 20:38:50 -0400
Message-ID: <1404693530-2531-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.gq1.yahoo.com ([98.137.12.181]:46138 "HELO
	smtp106.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751996AbaGGAj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2014 20:39:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

This fixes a regression bug caused by:
067608e9d019d6477fd45dd948e81af0e5bf599f ("tipc: introduce direct
iovec to buffer chain fragmentation function")

If data is sent on a nonblocking socket and the destination link
is congested, the buffer chain is leaked. We fix this by freeing
the chain in this case.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ede78b1..8c5600c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -784,8 +784,9 @@ new_mtu:
 			break;
 
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
+		if (rc)
+			kfree_skb_list(buf);
 	} while (!rc);
-
 exit:
 	if (iocb)
 		release_sock(sk);
@@ -898,6 +899,8 @@ next:
 				break;
 		}
 		rc = tipc_wait_for_sndpkt(sock, &timeo);
+		if (rc)
+			kfree_skb_list(buf);
 	} while (!rc);
 exit:
 	if (iocb)
-- 
1.7.9.5
