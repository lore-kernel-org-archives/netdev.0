From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix a request socket leak
Date: Fri, 08 Sep 2017 12:44:47 -0700
Message-ID: <1504899887.15310.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37186 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757087AbdIHTou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 15:44:50 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so1715027pgn.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 12:44:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While the cited commit fixed a possible deadlock, it added a leak
of the request socket, since reqsk_put() must be called if the BPF
filter decided the ACK packet must be dropped.

Fixes: d624d276d1dd ("tcp: fix possible deadlock in TCP stack vs BPF filter")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
David, this is a stable candidate (linux-4.13 has this bug)

 net/ipv4/tcp_ipv4.c |    6 +++---
 net/ipv6/tcp_ipv6.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a63486afa7a7e7b4dce88b65bc27cfa872a3ba2f..d9416b5162bc1bdd1acd34fcb4da21cb6b62d0ae 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1669,9 +1669,9 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		 */
 		sock_hold(sk);
 		refcounted = true;
-		if (tcp_filter(sk, skb))
-			goto discard_and_relse;
-		nsk = tcp_check_req(sk, skb, req, false);
+		nsk = NULL;
+		if (!tcp_filter(sk, skb))
+			nsk = tcp_check_req(sk, skb, req, false);
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_and_relse;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 38f76d8b231e3e5923ad72d05b8d320b6aeb850f..64d94afa427f81fd7a505b1cfd1c0be66c273810 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1460,9 +1460,9 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 		}
 		sock_hold(sk);
 		refcounted = true;
-		if (tcp_filter(sk, skb))
-			goto discard_and_relse;
-		nsk = tcp_check_req(sk, skb, req, false);
+		nsk = NULL;
+		if (!tcp_filter(sk, skb))
+			nsk = tcp_check_req(sk, skb, req, false);
 		if (!nsk) {
 			reqsk_put(req);
 			goto discard_and_relse;
