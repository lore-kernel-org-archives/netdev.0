From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] af_unix: take receive queue lock while appending new skb
Date: Tue, 17 Nov 2015 15:10:59 +0100
Message-ID: <1447769459-30452-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37062 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754066AbbKQOLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:11:08 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 5000E209F5
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 09:11:07 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While possibly in future we don't necessarily need to use
sk_buff_head.lock this is a rather larger change, as it affects the
af_unix fd garbage collector, diag and socket cleanups. This is too much
for a stable patch.

For the time being grab sk_buff_head.lock without disabling bh and irqs,
so don't use locked skb_queue_tail.

Fixes: 869e7c62486e ("net: af_unix: implement stream sendpage support")
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I think we don't have a bug report for this and it was found by code
inspection by Eric and myself?

 net/unix/af_unix.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a8352db..955ec15 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1813,8 +1813,11 @@ alloc_skb:
 	skb->truesize += size;
 	atomic_add(size, &sk->sk_wmem_alloc);
 
-	if (newskb)
+	if (newskb) {
+		spin_lock(&other->sk_receive_queue.lock);
 		__skb_queue_tail(&other->sk_receive_queue, newskb);
+		spin_unlock(&other->sk_receive_queue.lock);
+	}
 
 	unix_state_unlock(other);
 	mutex_unlock(&unix_sk(other)->readlock);
-- 
2.5.0
