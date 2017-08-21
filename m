From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] udp: on peeking bad csum, drop packets even if not at head
Date: Mon, 21 Aug 2017 17:39:12 -0400
Message-ID: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, pabeni@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36381 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754035AbdHUVjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 17:39:16 -0400
Received: by mail-qt0-f194.google.com with SMTP id c15so15511372qta.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 14:39:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When peeking, if a bad csum is discovered, the skb is unlinked from
the queue with __sk_queue_drop_skb and the peek operation restarted.

__sk_queue_drop_skb only drops packets that match the queue head. With
sk_peek_off, the skb need not be at head, causing the call to fail and
the same skb to be found again on restart.

Walk the queue to find the correct skb. Limit the walk to sk_peek_off,
to bound cycle cost to at most twice the original skb_queue_walk in
__skb_try_recv_from_queue.

The operation may race with updates to sk_peek_off. As the operation
is retried, it will eventually succeed.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

Simpler would be to check (skb->csum_complete_sw && !sbk->csum_valid)
in __skb_try_recv_from_queue to ignore skbs with bad checksum. But
__udp_lib_checksum_complete does not update those fields if called
while peeking, because the skb is shared. I found no way around that.
---
 net/core/datagram.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index a21ca8dee5ea..5cf32b2372d3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -360,9 +360,17 @@ int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
 	int err = 0;
 
 	if (flags & MSG_PEEK) {
+		struct sk_buff *lskb;
+		int off = sk_peek_offset(sk, flags);
+
 		err = -ENOENT;
 		spin_lock_bh(&sk_queue->lock);
-		if (skb == skb_peek(sk_queue)) {
+		lskb = skb_peek(sk_queue);
+		while (lskb != skb && lskb && off >= lskb->len) {
+			off -= lskb->len;
+			lskb = skb_peek_next(lskb, sk_queue);
+		}
+		if (lskb == skb) {
 			__skb_unlink(skb, sk_queue);
 			refcount_dec(&skb->users);
 			if (destructor)
-- 
2.14.1.480.gb18f417b89-goog
