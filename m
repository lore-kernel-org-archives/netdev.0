From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 1/3] [TIPC]: Improved support for Ethernet
	traffic filtering
Date: Thu, 17 May 2007 20:33:47 -0400
Message-ID: <11794484292891-git-send-email-jon.maloy@ericsson.com>
References: <1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Paul Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch simplifies TIPC's Ethernet receive routine to take
advantage of information already present in each incoming sk_buff
indicating whether the packet was explicitly sent to the interface,
has been broadcast to all interfaces, or was picked up because the
interface is in promiscous mode.

This new approach also fixes the problem of TIPC accepting unwanted
traffic through UML's multicast-based Ethernet interfaces (which
deliver traffic in a promiscuous manner even if the interface is
not configured to be promiscuous).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 net/tipc/eth_media.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index c73c206..19a71cf 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -1,8 +1,8 @@
 /*
  * net/tipc/eth_media.c: Ethernet bearer support for TIPC
  *
- * Copyright (c) 2001-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2001-2007, Ericsson AB
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -87,6 +87,9 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 /**
  * recv_msg - handle incoming TIPC message from an Ethernet interface
  *
+ * Accept only packets explicitly sent to this node, or broadcast packets;
+ * ignores packets sent using Ethernet multicast, and traffic sent to other
+ * nodes (which can happen if interface is running in promiscuous mode).
  * Routine truncates any Ethernet padding/CRC appended to the message,
  * and ensures message size matches actual length
  */
@@ -98,9 +101,7 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 	u32 size;
 
 	if (likely(eb_ptr->bearer)) {
-	       if (likely(!dev->promiscuity) ||
-		   !memcmp(skb_mac_header(buf), dev->dev_addr, ETH_ALEN) ||
-		   !memcmp(skb_mac_header(buf), dev->broadcast, ETH_ALEN)) {
+		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			size = msg_size((struct tipc_msg *)buf->data);
 			skb_trim(buf, size);
 			if (likely(buf->len == size)) {
-- 
1.5.0.5


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
