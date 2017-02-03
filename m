From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: avoid infinite loop in tcp_splice_read()
Date: Fri, 03 Feb 2017 14:59:38 -0800
Message-ID: <1486162778.21871.119.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33787 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdBCXAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:00:15 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so3064869pgd.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 14:59:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Splicing from TCP socket is vulnerable when a packet with URG flag is
received and stored into receive queue.

__tcp_splice_read() returns 0, and sk_wait_data() immediately
returns since there is the problematic skb in queue.

This is a nice way to burn cpu (aka infinite loop) and trigger
soft lockups.

Again, this gem was found by syzkaller tool.

Fixes: 9c55e01c0cc8 ("[TCP]: Splice receive support.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov  <dvyukov@google.com>
Cc: Willy Tarreau <w@1wt.eu>
---
 net/ipv4/tcp.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4a044964da6670829e5c47fef52d2cd76360b59f..0efb4c7f6704f662b6c762e48698a41564add2a4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -770,6 +770,12 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 				ret = -EAGAIN;
 				break;
 			}
+			/* if __tcp_splice_read() got nothing while we have
+			 * an skb in receive queue, we do not want to loop.
+			 * This might happen with URG data.
+			 */
+			if (!skb_queue_empty(&sk->sk_receive_queue))
+				break;
 			sk_wait_data(sk, &timeo, NULL);
 			if (signal_pending(current)) {
 				ret = sock_intr_errno(timeo);
