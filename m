From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/16] tipc: make tipc_link_send_sections_fast exit earlier
Date: Mon, 17 Jun 2013 10:54:49 -0400
Message-ID: <1371480891-5264-15-git-send-email-paul.gortmaker@windriver.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42771 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab3FQOzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:22 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Once message build request function returns invalid code, the
process of sending message cannot continue. So in case of message
build failure, tipc_link_send_sections_fast() should return
immediately.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b6de1aa..b6ffa9f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1082,6 +1082,9 @@ again:
 	 */
 	res = tipc_msg_build(hdr, msg_sect, num_sect, total_len,
 			     sender->max_pkt, &buf);
+	/* Exit if build request was invalid */
+	if (unlikely(res < 0))
+		return res;
 
 	read_lock_bh(&tipc_net_lock);
 	node = tipc_node_find(destaddr);
@@ -1098,10 +1101,6 @@ exit:
 				return res;
 			}
 
-			/* Exit if build request was invalid */
-			if (unlikely(res < 0))
-				goto exit;
-
 			/* Exit if link (or bearer) is congested */
 			if (link_congested(l_ptr) ||
 			    tipc_bearer_blocked(l_ptr->b_ptr)) {
-- 
1.8.1.2
