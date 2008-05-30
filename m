From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 12/13 net-next-2.6] [TIPC]: Fix bugs in rejection of message with short header
Date: Fri, 30 May 2008 14:20:47 -0400
Message-ID: <1212171648-27122-13-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50571 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205AbYE3SXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:14 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that TIPC doesn't try to access non-existent
message header fields when rejecting a message with a short header.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/port.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 93014f9..2e0cff4 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -448,13 +448,15 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	msg_set_errcode(rmsg, err);
 	msg_set_destport(rmsg, msg_origport(msg));
 	msg_set_origport(rmsg, msg_destport(msg));
-	if (msg_short(msg))
+	if (msg_short(msg)) {
 		msg_set_orignode(rmsg, tipc_own_addr);
-	else
+		/* leave name type & instance as zeroes */
+	} else {
 		msg_set_orignode(rmsg, msg_destnode(msg));
+		msg_set_nametype(rmsg, msg_nametype(msg));
+		msg_set_nameinst(rmsg, msg_nameinst(msg));
+	}
 	msg_set_size(rmsg, data_sz + hdr_sz);
-	msg_set_nametype(rmsg, msg_nametype(msg));
-	msg_set_nameinst(rmsg, msg_nameinst(msg));
 	skb_copy_to_linear_data_offset(rbuf, hdr_sz, msg_data(msg), data_sz);
 
 	/* send self-abort message when rejecting on a connected port */
-- 
1.5.3.2

