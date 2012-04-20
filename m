From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/16] tipc: properly handle off-node send requests with invalid addr
Date: Fri, 20 Apr 2012 17:05:21 -0400
Message-ID: <1334955924-907-14-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65473 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab2DTVFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:42 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

There are two send routines that might conceivably be asked by an
application to send a message off-node when the node is still using
the default network address.  These now have an added check that
detects this and rejects the message gracefully.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 616c72f..dc7f916 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1270,10 +1270,14 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 		if (likely(destnode == tipc_own_addr))
 			res = tipc_port_recv_sections(p_ptr, num_sect,
 						      msg_sect, total_len);
-		else
+		else if (tipc_own_addr)
 			res = tipc_link_send_sections_fast(p_ptr, msg_sect,
 							   num_sect, total_len,
 							   destnode);
+		else
+			res = tipc_port_reject_sections(p_ptr, msg, msg_sect,
+							num_sect, total_len,
+							TIPC_ERR_NO_NODE);
 		if (likely(res != -ELINKCONG)) {
 			if (res > 0)
 				p_ptr->sent++;
@@ -1314,9 +1318,12 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	if (dest->node == tipc_own_addr)
 		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect,
 					       total_len);
-	else
+	else if (tipc_own_addr)
 		res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
 						   total_len, dest->node);
+	else
+		res = tipc_port_reject_sections(p_ptr, msg, msg_sect, num_sect,
+						total_len, TIPC_ERR_NO_NODE);
 	if (likely(res != -ELINKCONG)) {
 		if (res > 0)
 			p_ptr->sent++;
-- 
1.7.9.3
