From: Sasha Levin <sasha.levin@oracle.com>
Subject: [added to the 3.18 stable tree] VSOCK: do not disconnect socket when peer has shutdown SEND only
Date: Mon, 11 Jul 2016 23:00:37 -0400
Message-ID: <1468292479-23684-185-git-send-email-sasha.levin@oracle.com>
References: <1468292479-23684-1-git-send-email-sasha.levin@oracle.com>
Cc: Ian Campbell <ian.campbell@docker.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Jorgen Hansen <jhansen@vmware.com>,
	Adit Ranadive <aditr@vmware.com>, netdev@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: stable@vger.kernel.org, stable-commits@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25406 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934093AbcGLDEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 23:04:51 -0400
In-Reply-To: <1468292479-23684-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@docker.com>

This patch has been added to the 3.18 stable tree. If you have any
objections, please let us know.

===============

[ Upstream commit dedc58e067d8c379a15a8a183c5db318201295bb ]

The peer may be expecting a reply having sent a request and then done a
shutdown(SHUT_WR), so tearing down the whole socket at this point seems
wrong and breaks for me with a client which does a SHUT_WR.

Looking at other socket family's stream_recvmsg callbacks doing a shutdown
here does not seem to be the norm and removing it does not seem to have
had any adverse effects that I can see.

I'm using Stefan's RFC virtio transport patches, I'm unsure of the impact
on the vmci transport.

Signed-off-by: Ian Campbell <ian.campbell@docker.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: Andy King <acking@vmware.com>
Cc: Dmitry Torokhov <dtor@vmware.com>
Cc: Jorgen Hansen <jhansen@vmware.com>
Cc: Adit Ranadive <aditr@vmware.com>
Cc: netdev@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/vmw_vsock/af_vsock.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 85d232b..e8d3313 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1796,27 +1796,8 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 	else if (sk->sk_shutdown & RCV_SHUTDOWN)
 		err = 0;
 
-	if (copied > 0) {
-		/* We only do these additional bookkeeping/notification steps
-		 * if we actually copied something out of the queue pair
-		 * instead of just peeking ahead.
-		 */
-
-		if (!(flags & MSG_PEEK)) {
-			/* If the other side has shutdown for sending and there
-			 * is nothing more to read, then modify the socket
-			 * state.
-			 */
-			if (vsk->peer_shutdown & SEND_SHUTDOWN) {
-				if (vsock_stream_has_data(vsk) <= 0) {
-					sk->sk_state = SS_UNCONNECTED;
-					sock_set_flag(sk, SOCK_DONE);
-					sk->sk_state_change(sk);
-				}
-			}
-		}
+	if (copied > 0)
 		err = copied;
-	}
 
 out_wait:
 	finish_wait(sk_sleep(sk), &wait);
-- 
2.5.0
