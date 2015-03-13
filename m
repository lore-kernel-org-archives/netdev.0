From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/7] tipc: eliminate unnecessary linearization of incoming buffers
Date: Fri, 13 Mar 2015 10:27:36 -0400
Message-ID: <1426256860-31208-4-git-send-email-jon.maloy@ericsson.com>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:31951 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbbCMO2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:28:16 -0400
In-Reply-To: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, TIPC linearizes all incoming buffers directly at reception
before passing them upwards in the stack. This is clearly a waste of
CPU resources, and must be avoided.

In this commit, we eliminate this unnecessary linearization. We still
ensure that at least the message header is linear, and that the buffer
is linearized where this is still needed, i.e. when unbundling and when
reversing messages.

In addition, we ensure that fragmented messages are validated after
reassembly before delivering them upwards in the stack.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |  5 -----
 net/tipc/msg.c  | 14 ++++++++++----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 944c8c6..8c6639d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1075,13 +1075,8 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		if (unlikely(!tipc_msg_validate(skb)))
 			goto discard;
 
-		/* Ensure message data is a single contiguous unit */
-		if (unlikely(skb_linearize(skb)))
-			goto discard;
-
 		/* Handle arrival of a non-unicast link message */
 		msg = buf_msg(skb);
-
 		if (unlikely(msg_non_seq(msg))) {
 			if (msg_user(msg) ==  LINK_CONFIG)
 				tipc_disc_rcv(net, skb, b_ptr);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 1364ceb..663ed29 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -165,6 +165,9 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 	}
 
 	if (fragid == LAST_FRAGMENT) {
+		TIPC_SKB_CB(head)->validated = false;
+		if (unlikely(!tipc_msg_validate(head)))
+			goto err;
 		*buf = head;
 		TIPC_SKB_CB(head)->tail = NULL;
 		*headbuf = NULL;
@@ -172,7 +175,6 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 	}
 	*buf = NULL;
 	return 0;
-
 err:
 	pr_warn_ratelimited("Unable to build fragment list\n");
 	kfree_skb(*buf);
@@ -376,10 +378,14 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
  */
 bool tipc_msg_extract(struct sk_buff *skb, struct sk_buff **iskb, int *pos)
 {
-	struct tipc_msg *msg = buf_msg(skb);
+	struct tipc_msg *msg;
 	int imsz;
-	struct tipc_msg *imsg = (struct tipc_msg *)(msg_data(msg) + *pos);
+	struct tipc_msg *imsg;
 
+	if (unlikely(skb_linearize(skb)))
+		return false;
+	msg = buf_msg(skb);
+	imsg = (struct tipc_msg *)(msg_data(msg) + *pos);
 	/* Is there space left for shortest possible message? */
 	if (*pos > (msg_data_sz(msg) - SHORT_H_SIZE))
 		goto none;
@@ -461,11 +467,11 @@ bool tipc_msg_reverse(u32 own_addr,  struct sk_buff *buf, u32 *dnode,
 
 	if (skb_linearize(buf))
 		goto exit;
+	msg = buf_msg(buf);
 	if (msg_dest_droppable(msg))
 		goto exit;
 	if (msg_errcode(msg))
 		goto exit;
-
 	memcpy(&ohdr, msg, msg_hdr_sz(msg));
 	imp = min_t(uint, imp + 1, TIPC_CRITICAL_IMPORTANCE);
 	if (msg_isdata(msg))
-- 
1.9.1
