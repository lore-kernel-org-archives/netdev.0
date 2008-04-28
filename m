From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/9 net-next-2.6] [TIPC]: Fix recursive spinlock invocation in print buffer code
Date: Mon, 28 Apr 2008 15:48:40 -0400
Message-ID: <1209412126-2109-4-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33659 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933925AbYD1TwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:03 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two routines that allow the global print buffer
spinlock to be taken recursively.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/dbg.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index c680691..834319e 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -179,8 +179,10 @@ void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
 	}
 
 	if (pb_to->size < pb_from->size) {
-		tipc_printbuf_reset(pb_to);
-		tipc_printf(pb_to, "*** PRINT BUFFER MOVE ERROR ***");
+		strcpy(pb_to->buf, "*** PRINT BUFFER MOVE ERROR ***");
+		pb_to->buf[pb_to->size - 1] = ~0;
+		pb_to->crs = strchr(pb_to->buf, 0);
+		pb_to->next = NULL;
 		return;
 	}
 
@@ -405,27 +407,32 @@ struct sk_buff *tipc_log_dump(void)
 	struct sk_buff *reply;
 
 	spin_lock_bh(&print_lock);
-	if (!TIPC_LOG->buf)
+	if (!TIPC_LOG->buf) {
+		spin_unlock_bh(&print_lock);
 		reply = tipc_cfg_reply_ultra_string("log not activated\n");
-	else if (tipc_printbuf_empty(TIPC_LOG))
+	} else if (tipc_printbuf_empty(TIPC_LOG)) {
+		spin_unlock_bh(&print_lock);
 		reply = tipc_cfg_reply_ultra_string("log is empty\n");
+	}
 	else {
 		struct tlv_desc *rep_tlv;
 		struct print_buf pb;
 		int str_len;
 
 		str_len = min(TIPC_LOG->size, 32768u);
+		spin_unlock_bh(&print_lock);
 		reply = tipc_cfg_reply_alloc(TLV_SPACE(str_len));
 		if (reply) {
 			rep_tlv = (struct tlv_desc *)reply->data;
 			tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), str_len);
+			spin_lock_bh(&print_lock);
 			tipc_printbuf_move(&pb, TIPC_LOG);
+			spin_unlock_bh(&print_lock);
 			str_len = strlen(TLV_DATA(rep_tlv)) + 1;
 			skb_put(reply, TLV_SPACE(str_len));
 			TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
 		}
 	}
-	spin_unlock_bh(&print_lock);
 	return reply;
 }
 
-- 
1.5.3.2

