From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/4] tipc: Minor optimizations to name table translation code
Date: Fri,  3 Sep 2010 14:33:39 -0400
Message-ID: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54530 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab0ICSdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 14:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Optimizes TIPC's name table translation code to avoid unnecessary
manipulation of the node address field of the resulting port id when
name translation fails.  This change is possible because a valid port
id cannot have a reference field of zero, so examining the reference
only is sufficient to determine if the translation was successful.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    4 +---
 net/tipc/port.c       |    4 ++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index d504e49..c13c2c7 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -613,8 +613,7 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 }
 
 /*
- * tipc_nametbl_translate(): Translate tipc_name -> tipc_portid.
- *                      Very time-critical.
+ * tipc_nametbl_translate - translate name to port id
  *
  * Note: on entry 'destnode' is the search domain used during translation;
  *       on exit it passes back the node address of the matching port (if any)
@@ -685,7 +684,6 @@ found:
 	}
 	spin_unlock_bh(&seq->lock);
 not_found:
-	*destnode = 0;
 	read_unlock_bh(&tipc_nametbl_lock);
 	return 0;
 }
diff --git a/net/tipc/port.c b/net/tipc/port.c
index ebcbc21..d760336 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1464,7 +1464,7 @@ int tipc_forward2name(u32 ref,
 	msg_set_destnode(msg, destnode);
 	msg_set_destport(msg, destport);
 
-	if (likely(destport || destnode)) {
+	if (likely(destport)) {
 		p_ptr->sent++;
 		if (likely(destnode == tipc_own_addr))
 			return tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
@@ -1542,7 +1542,7 @@ int tipc_forward_buf2name(u32 ref,
 	skb_push(buf, LONG_H_SIZE);
 	skb_copy_to_linear_data(buf, msg, LONG_H_SIZE);
 	msg_dbg(buf_msg(buf),"PREP:");
-	if (likely(destport || destnode)) {
+	if (likely(destport)) {
 		p_ptr->sent++;
 		if (destnode == tipc_own_addr)
 			return tipc_port_recv_msg(buf);
-- 
1.7.2.1

