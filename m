From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc 3/4] net-timestamp: tcp sockets return v6 errors on v6 sockets
Date: Tue, 25 Nov 2014 12:58:05 -0500
Message-ID: <1416938286-14147-4-git-send-email-willemb@google.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:62679 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbaKYR6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:58:14 -0500
Received: by mail-yk0-f175.google.com with SMTP id 200so505831ykr.6
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:58:13 -0800 (PST)
In-Reply-To: <1416938286-14147-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
It always passed errorqueue requests onto ip_recv_error, but the
same tcp_recvmsg code may also be called for IPv6 sockets. In that
case, pass to ipv6_recv_error.

Tested by asking for PKTINFO with

  Documentation/networking/timestamping/txtimestamp -I

Before this change, IPv6 sockets would return AF_INET/IP_PKTINFO
after the change, these sockets return AF_INET6/IPV6_PKTINFO

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c239f47..04ea9b2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1597,8 +1597,12 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
-	if (unlikely(flags & MSG_ERRQUEUE))
-		return ip_recv_error(sk, msg, len, addr_len);
+	if (unlikely(flags & MSG_ERRQUEUE)) {
+		if (sk->sk_family == AF_INET6)
+			return ipv6_recv_error(sk, msg, len, addr_len);
+		else
+			return ip_recv_error(sk, msg, len, addr_len);
+	}
 
 	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
 	    (sk->sk_state == TCP_ESTABLISHED))
-- 
2.1.0.rc2.206.gedb03e5
