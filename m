From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/20] tipc: Optimizations & corrections to message rejection
Date: Fri, 24 Jun 2011 18:07:13 -0400
Message-ID: <1308953247-25266-7-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34371 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757285Ab1FXWHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:44 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Optimizes the creation of a returned payload message by duplicating
the original message and then updating the small number of fields
that need to be adjusted, rather than building the new message header
from scratch. In addition, certain operations that are not always
required are relocated so that they are only done if needed.

These optimizations also have the effect of addressing other issues
that were present previously:

1) Fixes a bug that caused the socket send routines to return the
size of the returned message, rather than the size of the sent
message, when a returnable payload message was sent to a non-existent
destination port.

2) The message header of the returned message now matches that of
the original message more closely. The header is now always the same
size as the original header, and some message header fields that
weren't being initialized in the returned message header are now
populated correctly -- namely the "d" and "s" bits, and the upper
bound of a multicast name instance (where present).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   49 ++++++++++++++++++++++++-------------------------
 1 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 70ecdfd..5311817 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -358,14 +358,10 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	struct sk_buff *rbuf;
 	struct tipc_msg *rmsg;
 	int hdr_sz;
-	u32 imp = msg_importance(msg);
+	u32 imp;
 	u32 data_sz = msg_data_sz(msg);
 	u32 src_node;
-
-	if (data_sz > MAX_REJECT_SIZE)
-		data_sz = MAX_REJECT_SIZE;
-	if (msg_connected(msg) && (imp < TIPC_CRITICAL_IMPORTANCE))
-		imp++;
+	u32 rmsg_sz;
 
 	/* discard rejected message if it shouldn't be returned to sender */
 
@@ -377,30 +373,33 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	if (msg_errcode(msg) || msg_dest_droppable(msg))
 		goto exit;
 
-	/* construct rejected message */
-	if (msg_mcast(msg))
-		hdr_sz = MCAST_H_SIZE;
-	else
-		hdr_sz = LONG_H_SIZE;
-	rbuf = tipc_buf_acquire(data_sz + hdr_sz);
+	/*
+	 * construct returned message by copying rejected message header and
+	 * data (or subset), then updating header fields that need adjusting
+	 */
+
+	hdr_sz = msg_hdr_sz(msg);
+	rmsg_sz = hdr_sz + min_t(u32, data_sz, MAX_REJECT_SIZE);
+
+	rbuf = tipc_buf_acquire(rmsg_sz);
 	if (rbuf == NULL)
 		goto exit;
 
 	rmsg = buf_msg(rbuf);
-	tipc_msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
-	msg_set_errcode(rmsg, err);
-	msg_set_destport(rmsg, msg_origport(msg));
-	msg_set_origport(rmsg, msg_destport(msg));
-	if (msg_short(msg)) {
-		msg_set_orignode(rmsg, tipc_own_addr);
-		/* leave name type & instance as zeroes */
-	} else {
-		msg_set_orignode(rmsg, msg_destnode(msg));
-		msg_set_nametype(rmsg, msg_nametype(msg));
-		msg_set_nameinst(rmsg, msg_nameinst(msg));
+	skb_copy_to_linear_data(rbuf, msg, rmsg_sz);
+
+	if (msg_connected(rmsg)) {
+		imp = msg_importance(rmsg);
+		if (imp < TIPC_CRITICAL_IMPORTANCE)
+			msg_set_importance(rmsg, ++imp);
 	}
-	msg_set_size(rmsg, data_sz + hdr_sz);
-	skb_copy_to_linear_data_offset(rbuf, hdr_sz, msg_data(msg), data_sz);
+	msg_set_non_seq(rmsg, 0);
+	msg_set_size(rmsg, rmsg_sz);
+	msg_set_errcode(rmsg, err);
+	msg_set_prevnode(rmsg, tipc_own_addr);
+	msg_swap_words(rmsg, 4, 5);
+	if (!msg_short(rmsg))
+		msg_swap_words(rmsg, 6, 7);
 
 	/* send self-abort message when rejecting on a connected port */
 	if (msg_connected(msg)) {
-- 
1.7.4.4

