From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 01/13 net-next-2.6] [TIPC]: Fix bug in connection setup via native API
Date: Fri, 30 May 2008 14:20:36 -0400
Message-ID: <1212171648-27122-2-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50490 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbYE3SXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:07 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug that prevented TIPC from receiving a
connection setup request message on a native TIPC port.
The revised connection setup logic ensures that validation
of the source of a connection-based message is skipped if
the port is not yet connected to a peer.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/port.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2c64ad8..0bd3e61 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -842,13 +842,10 @@ static void port_dispatcher_sigh(void *dummy)
 
 				tipc_port_unlock(p_ptr);
 				if (unlikely(!connected)) {
-					if (unlikely(published))
+					if (tipc_connect2port(dref, &orig))
 						goto reject;
-					tipc_connect2port(dref,&orig);
-				}
-				if (unlikely(msg_origport(msg) != peer_port))
-					goto reject;
-				if (unlikely(msg_orignode(msg) != peer_node))
+				} else if ((msg_origport(msg) != peer_port) ||
+					   (msg_orignode(msg) != peer_node))
 					goto reject;
 				if (unlikely(!cb))
 					goto reject;
-- 
1.5.3.2

