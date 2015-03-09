From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: fix inconsistent signal handling regression
Date: Mon, 9 Mar 2015 10:43:42 +0100
Message-ID: <1425894222-22650-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <richard.alpe@ericsson.com>,
	<laszlo.benedek@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:43188 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbbCIJrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:47:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Erik Hugne <erik.hugne@ericsson.com>

Commit 9bbb4ecc6819 ("tipc: standardize recvmsg routine") changed
the sleep/wakeup behaviour for sockets entering recv() or accept().
In this process the order of reporting -EAGAIN/-EINTR was reversed.
This caused problems with wrong errno being reported back if the
timeout expires. The same problem happens if the socket is
nonblocking and recv()/accept() is called when the process have
pending signals. If there is no pending data read or connections to
accept, -EINTR will be returned instead of -EAGAIN.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reported-by L=C3=A1szl=C3=B3 Benedek <laszlo.benedek@ericsson.com>
---
 net/tipc/socket.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 95c514a..934947f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1318,12 +1318,12 @@ static int tipc_wait_for_rcvmsg(struct socket *=
sock, long *timeop)
 		err =3D 0;
 		if (!skb_queue_empty(&sk->sk_receive_queue))
 			break;
-		err =3D sock_intr_errno(timeo);
-		if (signal_pending(current))
-			break;
 		err =3D -EAGAIN;
 		if (!timeo)
 			break;
+		err =3D sock_intr_errno(timeo);
+		if (signal_pending(current))
+			break;
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	*timeop =3D timeo;
@@ -2026,12 +2026,12 @@ static int tipc_wait_for_accept(struct socket *=
sock, long timeo)
 		err =3D -EINVAL;
 		if (sock->state !=3D SS_LISTENING)
 			break;
-		err =3D sock_intr_errno(timeo);
-		if (signal_pending(current))
-			break;
 		err =3D -EAGAIN;
 		if (!timeo)
 			break;
+		err =3D sock_intr_errno(timeo);
+		if (signal_pending(current))
+			break;
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	return err;
--=20
2.1.4
