From: <erik.hugne@ericsson.com>
Subject: [PATCH net v2] tipc: fix message importance range check
Date: Mon, 18 Aug 2014 09:27:21 +0200
Message-ID: <1408346841-13578-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:50119 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaHRHW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 03:22:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Commit 3b4f302d8578 ("tipc: eliminate
redundant locking") introduced a bug by removing the sanity check
for message importance, allowing programs to assign any value to
the msg_user field. This will mess up the packet reception logic
and may cause random link resets.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
v2: Fixed according to comments from Dmitry Popov, missing semicolon
and return 0 at end of function

 net/tipc/port.h   | 5 ++++-
 net/tipc/socket.c | 2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3f93454..3087da3 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -179,9 +179,12 @@ static inline int tipc_port_importance(struct tipc_port *port)
 	return msg_importance(&port->phdr);
 }
 
-static inline void tipc_port_set_importance(struct tipc_port *port, int imp)
+static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
 {
+	if (imp > TIPC_CRITICAL_IMPORTANCE)
+		return -EINVAL;
 	msg_set_importance(&port->phdr, (u32)imp);
+	return 0;
 }
 
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7d423ee..ff8c811 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1973,7 +1973,7 @@ static int tipc_setsockopt(struct socket *sock, int lvl, int opt,
 
 	switch (opt) {
 	case TIPC_IMPORTANCE:
-		tipc_port_set_importance(port, value);
+		res = tipc_port_set_importance(port, value);
 		break;
 	case TIPC_SRC_DROPPABLE:
 		if (sock->type != SOCK_STREAM)
-- 
1.8.3.2
