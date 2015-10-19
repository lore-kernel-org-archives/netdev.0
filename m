From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: allow non-linear first fragment buffer
Date: Mon, 19 Oct 2015 11:33:00 -0400
Message-ID: <1445268780-29020-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:45386 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754117AbbJSPdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 11:33:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code for message reassembly is erroneously assuming that
the the first arriving fragment buffer always is linear, and then goes
ahead resetting the fragment list of that buffer in anticipation of
more arriving fragments.

However, if the buffer already happens to be non-linear, we will
inadvertently drop the already attached fragment list, and later
on trig a BUG() in __pskb_pull_tail().

We see this happen when running fragmented TIPC multicast across UDP,
something made possible since
commit d0f91938bede ("tipc: add ip/udp media type")

We fix this by not resetting the fragment list when the buffer is non-
linear, and by initiatlizing our private fragment list tail pointer to
the tail of the existing fragment list.

Fixes: commit d0f91938bede ("tipc: add ip/udp media type")
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index c5ac436..5f73450 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -121,7 +121,7 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 {
 	struct sk_buff *head = *headbuf;
 	struct sk_buff *frag = *buf;
-	struct sk_buff *tail;
+	struct sk_buff *tail = NULL;
 	struct tipc_msg *msg;
 	u32 fragid;
 	int delta;
@@ -141,9 +141,15 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
 		if (unlikely(skb_unclone(frag, GFP_ATOMIC)))
 			goto err;
 		head = *headbuf = frag;
-		skb_frag_list_init(head);
-		TIPC_SKB_CB(head)->tail = NULL;
 		*buf = NULL;
+		TIPC_SKB_CB(head)->tail = NULL;
+		if (skb_is_nonlinear(head)) {
+			skb_walk_frags(head, tail) {
+				TIPC_SKB_CB(head)->tail = tail;
+			}
+		} else {
+			skb_frag_list_init(head);
+		}
 		return 0;
 	}
 
-- 
1.9.1
