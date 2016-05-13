From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next] sock: ignore TIMESTAMP, RXQ_OVFL, WIFI_STATUS in sock_cmsg_send
Date: Fri, 13 May 2016 00:47:10 -0400
Message-ID: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Cc: edumazet@google.com, maze@google.com, willemb@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35630 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbcEMErX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 00:47:23 -0400
Received: by mail-qg0-f65.google.com with SMTP id b14so6422599qge.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 21:47:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

SO_TIMESTAMP(NS), RXQ_OVFL, and WIFI_STATUS can be returned as
receive-side control messages from recvmsg(). Although invalid,
some applications may reflect those receive-side control messages
back to sendmsg(). Since socket-level control messages were being
ignored in ipv4 and ipv6, such applications would not get an error.

24025c4 (ipv4: process socket-level control messages in IPv4) and
ad1e46 (ipv6: process socket-level control messages in IPv6) add
support for socket-level control messages in ipv4 and ipv6 on
sendmsg(). This results in getting -EINVAL, if the application
passes in a message with SO_WIFI_STATUS, SO_RXQ_OVFL, SO_TIMESTAMP
and/or SO_TIMESTAMPNS that might have been received in recvmsg().

Ignore SO_WIFI_STATUS, SO_TIMESTAMP(NS), and SO_RXQ_OVFL when
processing socket-level control messages in send-side to remain
backward compatible.
---
 net/core/sock.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 08bf97e..1e0bcd0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1938,6 +1938,12 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 		sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
 		sockc->tsflags |= tsflags;
 		break;
+	/* Ignore the following types on send to remain backward compatible. */
+	case SO_RXQ_OVFL:	/* Fall through */
+	case SO_TIMESTAMP:	/* Fall through */
+	case SO_TIMESTAMPNS:	/* Fall through */
+	case SO_WIFI_STATUS:
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.8.0.rc3.226.g39d4020
