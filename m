From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: don't abort splice() after small transfers
Date: Sun, 02 Dec 2012 13:49:27 -0800
Message-ID: <1354484967.20109.1167.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:43289 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab2LBVtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 16:49:32 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so1229752vcd.19
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2012 13:49:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>

TCP coalescing added a regression in splice(socket->pipe) performance,
for some workloads because of the way tcp_read_sock() is implemented.

The reason for this is the break when (offset + 1 != skb->len).

As we released the socket lock, this condition is possible if TCP stack
added a fragment to the skb, which can happen with TCP coalescing.

So let's go back to the beginning of the loop when this happens,
to give a chance to splice more frags per system call.

Doing so fixes the issue and makes GRO 10% faster than LRO
on CPU-bound splice() workloads instead of the opposite.

Signed-off-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1aca02c..8fc5b3bd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1494,15 +1494,19 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				copied += used;
 				offset += used;
 			}
-			/*
-			 * If recv_actor drops the lock (e.g. TCP splice
+			/* If recv_actor drops the lock (e.g. TCP splice
 			 * receive) the skb pointer might be invalid when
 			 * getting here: tcp_collapse might have deleted it
 			 * while aggregating skbs from the socket queue.
 			 */
-			skb = tcp_recv_skb(sk, seq-1, &offset);
-			if (!skb || (offset+1 != skb->len))
+			skb = tcp_recv_skb(sk, seq - 1, &offset);
+			if (!skb)
 				break;
+			/* TCP coalescing might have appended data to the skb.
+			 * Try to splice more frags
+			 */
+			if (offset + 1 != skb->len)
+				continue;
 		}
 		if (tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, false);
