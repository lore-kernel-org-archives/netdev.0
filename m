From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix bug in bundled buffer reception
Date: Fri, 17 Oct 2014 15:25:28 -0400
Message-ID: <1413573928-17954-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:42293 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298AbaJQTZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 15:25:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit ec8a2e5621db2da24badb3969eda7fd359e1869f ("tipc: same receive
code path for connection protocol and data messages") we omitted the
the possiblilty that an arriving message extracted from a bundle buffer
may be a multicast message. Such messages need to be to be delivered to
the socket via a separate function, tipc_sk_mcast_rcv(). As a result,
small multicast messages arriving as members of a bundle buffer will be
silently dropped.

This commit corrects the error by considering this case in the function
tipc_link_bundle_rcv().

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 65410e1..1db162a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1924,7 +1924,12 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 		}
 		omsg = buf_msg(obuf);
 		pos += align(msg_size(omsg));
-		if (msg_isdata(omsg) || (msg_user(omsg) == CONN_MANAGER)) {
+		if (msg_isdata(omsg)) {
+			if (unlikely(msg_type(omsg) == TIPC_MCAST_MSG))
+				tipc_sk_mcast_rcv(obuf);
+			else
+				tipc_sk_rcv(obuf);
+		} else if (msg_user(omsg) == CONN_MANAGER) {
 			tipc_sk_rcv(obuf);
 		} else if (msg_user(omsg) == NAME_DISTRIBUTOR) {
 			tipc_named_rcv(obuf);
-- 
1.9.1
