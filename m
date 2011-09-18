From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/28] tipc: Enhance cleanup of broadcast link when contact with node is lost
Date: Sat, 17 Sep 2011 23:32:05 -0400
Message-ID: <1316316744-29514-10-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49973 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192Ab1IRDcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:47 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Enhances cleanup of broadcast link-related information when contact
with a node is lost.

1) All broadcast link-related cleanup now occurs only if the lost node
   was capable of communicating over the broadcast link.

2) Following cleanup, the lost node is marked as no longer supporting
   the broadcast link, ensuring that any remaining broadcast messages
   received from that node prior to the re-establishment of a normal
   communication link are ignored.

Thanks to Surya [Suryanarayana.Garlapati@emerson.com] for contributing
a prototype version of this patch.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 2d106ef..810b395 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -331,28 +331,32 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	char addr_string[16];
 	u32 i;
 
-	/* Clean up broadcast reception remains */
-	n_ptr->bclink.gap_after = n_ptr->bclink.gap_to = 0;
-	while (n_ptr->bclink.deferred_head) {
-		struct sk_buff *buf = n_ptr->bclink.deferred_head;
-		n_ptr->bclink.deferred_head = buf->next;
-		buf_discard(buf);
-	}
-	if (n_ptr->bclink.defragm) {
-		buf_discard(n_ptr->bclink.defragm);
-		n_ptr->bclink.defragm = NULL;
-	}
+	info("Lost contact with %s\n",
+	     tipc_addr_string_fill(addr_string, n_ptr->addr));
+
+	/* Flush broadcast link info associated with lost node */
 
 	if (n_ptr->bclink.supported) {
+		n_ptr->bclink.gap_after = n_ptr->bclink.gap_to = 0;
+		while (n_ptr->bclink.deferred_head) {
+			struct sk_buff *buf = n_ptr->bclink.deferred_head;
+			n_ptr->bclink.deferred_head = buf->next;
+			buf_discard(buf);
+		}
+
+		if (n_ptr->bclink.defragm) {
+			buf_discard(n_ptr->bclink.defragm);
+			n_ptr->bclink.defragm = NULL;
+		}
+
 		tipc_bclink_acknowledge(n_ptr,
 					mod(n_ptr->bclink.acked + 10000));
 		tipc_nmap_remove(&tipc_bcast_nmap, n_ptr->addr);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag--;
-	}
 
-	info("Lost contact with %s\n",
-	     tipc_addr_string_fill(addr_string, n_ptr->addr));
+		n_ptr->bclink.supported = 0;
+	}
 
 	/* Abort link changeover */
 	for (i = 0; i < MAX_BEARERS; i++) {
-- 
1.7.4.4
