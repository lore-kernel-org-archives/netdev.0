From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: SYN packets are now simply consumed
Date: Thu, 21 Apr 2016 22:13:01 -0700
Message-ID: <1461301981.7627.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:35918 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbcDVFNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 01:13:05 -0400
Received: by mail-vk0-f45.google.com with SMTP id n67so107593459vkf.3
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 22:13:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We now have proper per-listener but also per network namespace counters
for SYN packets that might be dropped.

We replace the kfree_skb() by consume_skb() to be drop monitor [1]
friendly, and remove an obsolete comment.
FastOpen SYN packets can carry payload in them just fine.

[1] perf record -a -g -e skb:kfree_skb sleep 1; perf report

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |   19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 90e0d9256b74..ab674cd99827 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5813,24 +5813,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 			if (icsk->icsk_af_ops->conn_request(sk, skb) < 0)
 				return 1;
 
-			/* Now we have several options: In theory there is
-			 * nothing else in the frame. KA9Q has an option to
-			 * send data with the syn, BSD accepts data with the
-			 * syn up to the [to be] advertised window and
-			 * Solaris 2.1 gives you a protocol error. For now
-			 * we just ignore it, that fits the spec precisely
-			 * and avoids incompatibilities. It would be nice in
-			 * future to drop through and process the data.
-			 *
-			 * Now that TTCP is starting to be used we ought to
-			 * queue this data.
-			 * But, this leaves one open to an easy denial of
-			 * service attack, and SYN cookies can't defend
-			 * against this problem. So, we drop the data
-			 * in the interest of security over speed unless
-			 * it's still in use.
-			 */
-			kfree_skb(skb);
+			consume_skb(skb);
 			return 0;
 		}
 		goto discard;
