From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: initialize tp->copied_seq in case of cross SYN
 connection
Date: Thu, 26 Nov 2015 08:18:14 -0800
Message-ID: <1448554694.24696.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33204 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbKZQSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 11:18:16 -0500
Received: by pabfh17 with SMTP id fh17so92828652pab.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:18:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Dmitry provided a syzkaller (http://github.com/google/syzkaller)
generated program that triggers the WARNING at 
net/ipv4/tcp.c:1729 in tcp_recvmsg() :

WARN_ON(tp->copied_seq != tp->rcv_nxt &&
        !(flags & (MSG_PEEK | MSG_TRUNC)));

His program is specifically attempting a Cross SYN TCP exchange,
that we support (for the pleasure of hackers ?), but it looks we
lack proper tcp->copied_seq initialization.

Thanks again Dmitry for your report and testings.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/ipv4/tcp_input.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a4a0b6b3bcf2..2d656eef7f8e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5683,6 +5683,7 @@ discard:
 		}
 
 		tp->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
+		tp->copied_seq = tp->rcv_nxt;
 		tp->rcv_wup = TCP_SKB_CB(skb)->seq + 1;
 
 		/* RFC1323: The window in SYN & SYN/ACK segments is
