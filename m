From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] sock: correct sk_wmem_queued accounting on efault in tcp zerocopy
Date: Thu, 19 Oct 2017 12:40:39 -0400
Message-ID: <20171019164039.20927-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:43524 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753007AbdJSQkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 12:40:43 -0400
Received: by mail-io0-f193.google.com with SMTP id 134so10480651ioo.0
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 09:40:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Syzkaller hits WARN_ON(sk->sk_wmem_queued) in sk_stream_kill_queues
after triggering an EFAULT in __zerocopy_sg_from_iter.

On this error, skb_zerocopy_stream_iter resets the skb to its state
before the operation with __pskb_trim. It cannot kfree_skb like
datagram callers, as the skb may have data from a previous send call.

__pskb_trim calls skb_condense for unowned skbs, which adjusts their
truesize. These tcp skbuffs are owned and their truesize must add up
to sk_wmem_queued. But they match because their skb->sk is NULL until
tcp_transmit_skb.

Temporarily set skb->sk when calling __pskb_trim to signal that the
skbuffs are owned and avoid the skb_condense path.

Fixes: 52267790ef52 ("sock: add MSG_ZEROCOPY")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e62476beee95..24656076906d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1124,9 +1124,13 @@ int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
 
 	err = __zerocopy_sg_from_iter(sk, skb, &msg->msg_iter, len);
 	if (err == -EFAULT || (err == -EMSGSIZE && skb->len == orig_len)) {
+		struct sock *save_sk = skb->sk;
+
 		/* Streams do not free skb on error. Reset to prev state. */
 		msg->msg_iter = orig_iter;
+		skb->sk = sk;
 		___pskb_trim(skb, orig_len);
+		skb->sk = save_sk;
 		return err;
 	}
 
-- 
2.15.0.rc1.287.g2b38de12cc-goog
