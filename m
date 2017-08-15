From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix possible deadlock in TCP stack vs BPF filter
Date: Mon, 14 Aug 2017 17:44:43 -0700
Message-ID: <1502757883.4936.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Chenbo Feng <fengc@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37724 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752740AbdHOAop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 20:44:45 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so13100672pgb.4
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 17:44:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Filtering the ACK packet was not put at the right place.

At this place, we already allocated a child and put it
into accept queue.

We absolutely need to call tcp_child_process() to release
its spinlock, or we will deadlock at accept() or close() time.

Found by syzkaller team (Thanks a lot !)

Fixes: 8fac365f63c8 ("tcp: Add a tcp_filter hook before handle ack packet")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Chenbo Feng <fengc@google.com>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a20e7f03d5f7..e9252c7df809 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1722,6 +1722,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		 */
 		sock_hold(sk);
 		refcounted = true;
+		if (tcp_filter(sk, skb))
+			goto discard_and_relse;
 		nsk = tcp_check_req(sk, skb, req, false);
 		if (!nsk) {
 			reqsk_put(req);
@@ -1729,8 +1731,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		}
 		if (nsk == sk) {
 			reqsk_put(req);
-		} else if (tcp_filter(sk, skb)) {
-			goto discard_and_relse;
 		} else if (tcp_child_process(sk, nsk, skb)) {
 			tcp_v4_send_reset(nsk, skb);
 			goto discard_and_relse;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2521690d62d6..206210125fd7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1456,6 +1456,8 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 		}
 		sock_hold(sk);
 		refcounted = true;
+		if (tcp_filter(sk, skb))
+			goto discard_and_relse;
 		nsk = tcp_check_req(sk, skb, req, false);
 		if (!nsk) {
 			reqsk_put(req);
@@ -1464,8 +1466,6 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 		if (nsk == sk) {
 			reqsk_put(req);
 			tcp_v6_restore_cb(skb);
-		} else if (tcp_filter(sk, skb)) {
-			goto discard_and_relse;
 		} else if (tcp_child_process(sk, nsk, skb)) {
 			tcp_v6_send_reset(nsk, skb);
 			goto discard_and_relse;
