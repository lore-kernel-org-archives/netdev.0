From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 3.12 70/76] VSOCK: do not disconnect socket when peer has shutdown SEND only
Date: Thu, 19 May 2016 11:08:32 +0200
Message-ID: <fa9ba455d380badcb2688846048a65a55811f264.1463648873.git.jslaby@suse.cz>
References: <c4ec97c341630e22e546c1a628a3664f17f7ffc8.1463648873.git.jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@docker.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Jorgen Hansen <jhansen@vmware.com>,
	Adit Ranadive <aditr@vmware.com>, netdev@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>
To: stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4ec97c341630e22e546c1a628a3664f17f7ffc8.1463648873.git.jslaby@suse.cz>
In-Reply-To: <cover.1463648873.git.jslaby@suse.cz>
References: <cover.1463648873.git.jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@docker.com>

3.12-stable review patch.  If anyone has any objections, please let me know.

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
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 net/vmw_vsock/af_vsock.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 85d232bed87d..e8d3313ea2c9 100644
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
2.8.2
