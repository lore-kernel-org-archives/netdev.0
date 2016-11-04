From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] sock: fix sendmmsg for partial sendmsg
Date: Fri,  4 Nov 2016 15:36:49 -0400
Message-ID: <1478288209-30893-1-git-send-email-soheil.kdev@gmail.com>
Cc: edumazet@google.com, willemb@google.com, ncardwell@google.com,
        Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33348 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbcKDThF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 15:37:05 -0400
Received: by mail-qk0-f195.google.com with SMTP id x190so6589126qkb.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 12:37:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Do not send the next message in sendmmsg for partial sendmsg
invocations.

sendmmsg assumes that it can continue sending the next message
when the return value of the individual sendmsg invocations
is positive. It results in corrupting the data for TCP,
SCTP, and UNIX streams.

For example, sendmmsg([["abcd"], ["efgh"]]) can result in a stream
of "aefgh" if the first sendmsg invocation sends only the first
byte while the second sendmsg goes through.

Datagram sockets either send the entire datagram or fail, so
this patch affects only sockets of type SOCK_STREAM and
SOCK_SEQPACKET.

Fixes: 228e548e6020 ("net: Add sendmmsg socket system call")
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/socket.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index 5a9bf5e..272518b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2038,6 +2038,8 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		if (err)
 			break;
 		++datagrams;
+		if (msg_data_left(&msg_sys))
+			break;
 		cond_resched();
 	}
 
-- 
2.8.0.rc3.226.g39d4020
