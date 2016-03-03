From: Ed Schouten <ed@nuxi.nl>
Subject: [PATCH 1/3] Make listen() on an unbound UNIX socket return EDESTADDRREQ.
Date: Thu,  3 Mar 2016 12:23:00 +0100
Message-ID: <1457004183-24933-1-git-send-email-ed@nuxi.nl>
Cc: Ed Schouten <ed@nuxi.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34084 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502AbcCCLXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:23:08 -0500
Received: by mail-wm0-f53.google.com with SMTP id p65so30020736wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 03:23:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a UNIX socket does not have an address associated with it, it may
either be that a socket has been created through socket() and is still
in its initial state, or it has connected to a peer (e.g. by using
socketpair()). In both those cases listen() should fail.

Though the condition used to test for condition this is all right, POSIX
requires that two different error codes are returned: EINVAL if already
connected and EDESTADDRREQ if not bound.

Reference:
http://pubs.opengroup.org/onlinepubs/009695399/functions/listen.html

Signed-off-by: Ed Schouten <ed@nuxi.nl>
---
 net/unix/af_unix.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f75f847..d810815 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -609,9 +609,9 @@ static int unix_listen(struct socket *sock, int backlog)
 	err = -EOPNOTSUPP;
 	if (sock->type != SOCK_STREAM && sock->type != SOCK_SEQPACKET)
 		goto out;	/* Only stream/seqpacket sockets accept */
-	err = -EINVAL;
+	err = unix_peer(sk) == NULL ? -EDESTADDRREQ : -EINVAL;
 	if (!u->addr)
-		goto out;	/* No listens on an unbound socket */
+		goto out;	/* No listen on a connected or unbound socket */
 	unix_state_lock(sk);
 	if (sk->sk_state != TCP_CLOSE && sk->sk_state != TCP_LISTEN)
 		goto out_unlock;
-- 
2.5.0
