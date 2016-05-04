From: Ian Campbell <ian.campbell@docker.com>
Subject: [PATCH] VSOCK: do not disconnect socket when peer has shutdown SEND only
Date: Wed,  4 May 2016 14:21:53 +0100
Message-ID: <1462368113-5493-1-git-send-email-ian.campbell@docker.com>
Cc: Ian Campbell <ian.campbell@docker.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Jorgen Hansen <jhansen@vmware.com>,
	Adit Ranadive <aditr@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37500 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcEDNV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 09:21:57 -0400
Received: by mail-wm0-f54.google.com with SMTP id a17so94045707wme.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 06:21:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/vmw_vsock/af_vsock.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 1e5f5ed..7a25150 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1789,27 +1789,8 @@ vsock_stream_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
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
 
 out:
 	release_sock(sk);
-- 
2.8.1
