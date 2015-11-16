From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] af_unix: don't append consumed skbs to sk_receive_queue
Date: Mon, 16 Nov 2015 16:25:56 +0100
Message-ID: <1447687556-22712-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36593 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751606AbbKPP0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 10:26:12 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 39E77207B1
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 10:26:09 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case multiple writes to a unix stream socket race we could end up in a
situation where we pre-allocate a new skb for use in unix_stream_sendpage
but have to free it again in the locked section because another skb
has been appended meanwhile, which we must use. Accidentally we didn't
clear the pointer after consuming it and so we touched freed memory
while appending it to the sk_receive_queue. So, clear the pointer after
consuming the skb.

This bug has been found with syzkaller
(http://github.com/google/syzkaller) by Dmitry Vyukov.

Fixes: 869e7c62486e ("net: af_unix: implement stream sendpage support")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/unix/af_unix.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aaa0b58..c6eb2e8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1799,6 +1799,7 @@ alloc_skb:
 		 * this - does no harm
 		 */
 		consume_skb(newskb);
+		newskb = NULL;
 	}
 
 	if (skb_append_pagefrags(skb, page, offset, size)) {
-- 
2.5.0
