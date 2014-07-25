From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: make tipc_buf_append() more robust
Date: Fri, 25 Jul 2014 14:48:09 -0400
Message-ID: <1406314089-5446-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.ne1.yahoo.com ([98.138.207.10]:34871 "EHLO
	smtp103.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751565AbaGYSsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per comment from David Miller, we try to make the buffer reassembly
function more resilient to user errors than it is today.

- We check that the "*buf" parameter always is set, since this is
  mandatory input.

- We ensure that *buf->next always is set to NULL before linking in
  the buffer, instead of relying of the caller to have done this.

- We ensure that the "tail" pointer in the head buffer's control
  block is initialized to NULL when the first fragment arrives.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index b6f45d0..9680be6 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -72,27 +72,38 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 	struct sk_buff *head = *headbuf;
 	struct sk_buff *frag = *buf;
 	struct sk_buff *tail;
-	struct tipc_msg *msg = buf_msg(frag);
-	u32 fragid = msg_type(msg);
-	bool headstolen;
+	struct tipc_msg *msg;
+	u32 fragid;
 	int delta;
+	bool headstolen;
 
+	if (!frag)
+		goto err;
+
+	msg = buf_msg(frag);
+	fragid = msg_type(msg);
+	frag->next = NULL;
 	skb_pull(frag, msg_hdr_sz(msg));
 
 	if (fragid == FIRST_FRAGMENT) {
-		if (head || skb_unclone(frag, GFP_ATOMIC))
-			goto out_free;
+		if (unlikely(head))
+			goto err;
+		if (unlikely(skb_unclone(frag, GFP_ATOMIC)))
+			goto err;
 		head = *headbuf = frag;
 		skb_frag_list_init(head);
+		TIPC_SKB_CB(head)->tail = NULL;
 		*buf = NULL;
 		return 0;
 	}
+
 	if (!head)
-		goto out_free;
-	tail = TIPC_SKB_CB(head)->tail;
+		goto err;
+
 	if (skb_try_coalesce(head, frag, &headstolen, &delta)) {
 		kfree_skb_partial(frag, headstolen);
 	} else {
+		tail = TIPC_SKB_CB(head)->tail;
 		if (!skb_has_frag_list(head))
 			skb_shinfo(head)->frag_list = frag;
 		else
@@ -102,6 +113,7 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 		head->len += frag->len;
 		TIPC_SKB_CB(head)->tail = frag;
 	}
+
 	if (fragid == LAST_FRAGMENT) {
 		*buf = head;
 		TIPC_SKB_CB(head)->tail = NULL;
@@ -110,7 +122,8 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 	}
 	*buf = NULL;
 	return 0;
-out_free:
+
+err:
 	pr_warn_ratelimited("Unable to build fragment list\n");
 	kfree_skb(*buf);
 	kfree_skb(*headbuf);
-- 
1.7.9.5
