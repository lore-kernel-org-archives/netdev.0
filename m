From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] sock: ignore SCM_RIGHTS and SCM_CREDENTIALS in __sock_cmsg_send
Date: Sun, 10 Jul 2016 12:51:46 -0400
Message-ID: <1468169506-27038-1-git-send-email-soheil.kdev@gmail.com>
Cc: slyfox@gentoo.org, Soheil Hassas Yeganeh <soheil@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35353 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757139AbcGJQwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 12:52:30 -0400
Received: by mail-qk0-f193.google.com with SMTP id q62so1631657qkf.2
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 09:52:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Sergei Trofimovich reported that pulse audio sends SCM_CREDENTIALS
as a control message to TCP. Since __sock_cmsg_send does not
support SCM_RIGHTS and SCM_CREDENTIALS, it returns an error and
hence breaks pulse audio over TCP.

SCM_RIGHTS and SCM_CREDENTIALS are sent on the SOL_SOCKET layer
but they semantically belong to SOL_UNIX. Since all
cmsg-processing functions including sock_cmsg_send ignore control
messages of other layers, it is best to ignore SCM_RIGHTS
and SCM_CREDENTIALS for consistency (and also for fixing pulse
audio over TCP).

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Reported-by: Sergei Trofimovich <slyfox@gentoo.org>
Tested-by: Sergei Trofimovich <slyfox@gentoo.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/sock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 08bf97e..b7f1263 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1938,6 +1938,10 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 		sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
 		sockc->tsflags |= tsflags;
 		break;
+	/* SCM_RIGHTS and SCM_CREDENTIALS are semantically in SOL_UNIX. */
+	case SCM_RIGHTS:
+	case SCM_CREDENTIALS:
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.8.0.rc3.226.g39d4020
