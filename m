From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/16] tipc: handle <0.0.0> as an alias for this node on outgoing msgs
Date: Fri, 20 Apr 2012 17:05:22 -0400
Message-ID: <1334955924-907-15-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62205 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591Ab2DTVFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:43 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Revises handling of send routines for payload messages to ensure that
they are processed properly even if the node's network address is
changed in mid-operation. The routines now treat the default node
address of <0.0.0> as an alias for "this node" when determining where
to send an outgoing message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index dc7f916..c50819b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1217,7 +1217,7 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect,
 	p_ptr->congested = 1;
 	if (!tipc_port_congested(p_ptr)) {
 		destnode = port_peernode(p_ptr);
-		if (likely(destnode != tipc_own_addr))
+		if (likely(!in_own_node(destnode)))
 			res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
 							   total_len, destnode);
 		else
@@ -1267,7 +1267,7 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	msg_set_destport(msg, destport);
 
 	if (likely(destport || destnode)) {
-		if (likely(destnode == tipc_own_addr))
+		if (likely(in_own_node(destnode)))
 			res = tipc_port_recv_sections(p_ptr, num_sect,
 						      msg_sect, total_len);
 		else if (tipc_own_addr)
@@ -1315,7 +1315,7 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, BASIC_H_SIZE);
 
-	if (dest->node == tipc_own_addr)
+	if (in_own_node(dest->node))
 		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect,
 					       total_len);
 	else if (tipc_own_addr)
@@ -1362,7 +1362,7 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 	skb_push(buf, BASIC_H_SIZE);
 	skb_copy_to_linear_data(buf, msg, BASIC_H_SIZE);
 
-	if (dest->node == tipc_own_addr)
+	if (in_own_node(dest->node))
 		res = tipc_port_recv_msg(buf);
 	else
 		res = tipc_send_buf_fast(buf, dest->node);
-- 
1.7.9.3
