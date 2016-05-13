From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sock: propagate __sock_cmsg_send() error
Date: Fri, 13 May 2016 06:14:37 -0700
Message-ID: <1463145277.23934.186.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com, willemb@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33491 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbcEMNOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 09:14:41 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so9365917pfb.0
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 06:14:40 -0700 (PDT)
In-Reply-To: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__sock_cmsg_send() might return different error codes, not only -EINVAL.

Fixes: 24025c465f77 ("ipv4: process socket-level control messages in IPv4")
Fixes: ad1e46a83716 ("ipv6: process socket-level control messages in IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/ip_sockglue.c |    5 +++--
 net/ipv6/datagram.c    |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5805762d7fc79a702f1d67e802992b822f66f000..71a52f4d4cffba2db9353f43dc817689bf4fab10 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -247,8 +247,9 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 		}
 #endif
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			if (__sock_cmsg_send(sk, msg, cmsg, &ipc->sockc))
-				return -EINVAL;
+			err = __sock_cmsg_send(sk, msg, cmsg, &ipc->sockc);
+			if (err)
+				return err;
 			continue;
 		}
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 00d0c2903173a96571983216f2839a93059cad22..37874e2f30edf98f31e2a5097761143d507d5b95 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -746,8 +746,9 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 		}
 
 		if (cmsg->cmsg_level == SOL_SOCKET) {
-			if (__sock_cmsg_send(sk, msg, cmsg, sockc))
-				return -EINVAL;
+			err = __sock_cmsg_send(sk, msg, cmsg, sockc);
+			if (err)
+				return err;
 			continue;
 		}
 
