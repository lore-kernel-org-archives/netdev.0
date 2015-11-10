From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] af-unix: fix use-after-free with concurrent readers while splicing
Date: Tue, 10 Nov 2015 15:26:35 +0100
Message-ID: <1447165595-28340-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53563 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752173AbbKJO0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 09:26:42 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 2834620B67
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 09:26:42 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During splicing an af-unix socket to a pipe we have to drop all
af-unix socket locks. While doing so we allow another reader to enter
unix_stream_read_generic which can read, copy and finally free another
skb. If exactly this skb is just in process of being spliced we get a
use-after-free report by kasan.

First, we must make sure to not have a free while the skb is used during
the splice operation. We simply increment its use counter before unlocking
the reader lock.

Stream sockets have the nice characteristic that we don't care about
zero length writes and they never reach the peer socket's queue. That
said, we can take the UNIXCB.consumed field as the indicator if the
skb was already freed from the socket's receive queue. If the skb was
fully consumed after we locked the reader side again we know it has been
dropped by a second reader. We indicate a short read to user space and
abort the current splice operation.

This bug has been found with syzkaller
(http://github.com/google/syzkaller) by Dmitry Vyukov.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/unix/af_unix.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aaa0b58..b2c4131 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -441,6 +441,7 @@ static void unix_release_sock(struct sock *sk, int embrion)
 		if (state == TCP_LISTEN)
 			unix_release_sock(skb->sk, 1);
 		/* passed fds are erased in the kfree_skb hook	      */
+		UNIXCB(skb).consumed = skb->len;
 		kfree_skb(skb);
 	}
 
@@ -2152,7 +2153,7 @@ unlock:
 		}
 
 		chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
-		chunk = state->recv_actor(skb, skip, chunk, state);
+		chunk = state->recv_actor(skb_get(skb), skip, chunk, state);
 		if (chunk < 0) {
 			if (copied == 0)
 				copied = -EFAULT;
@@ -2161,6 +2162,21 @@ unlock:
 		copied += chunk;
 		size -= chunk;
 
+		if (!unix_skb_len(skb)) {
+			/* the skb was touched by a concurrent reader;
+			 * we should not expect anything from this skb
+			 * anymore and assume it invalid - we can be
+			 * sure it was dropped from the socket queue
+			 *
+			 * let's report a short read
+			 */
+			consume_skb(skb);
+			err = 0;
+			break;
+		}
+
+		consume_skb(skb);
+
 		/* Mark read part of skb as used */
 		if (!(flags & MSG_PEEK)) {
 			UNIXCB(skb).consumed += chunk;
-- 
2.5.0
