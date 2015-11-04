From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] VSOCK: call sk->sk_data_ready() on accept()
Date: Wed,  4 Nov 2015 12:58:42 +0000
Message-ID: <1446641922-32243-1-git-send-email-stefanha@redhat.com>
Cc: Thomas Hellstrom <thellstrom@vmware.com>,
	Aditya Asarwade <asarwade@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jorgen Hansen <jhansen@vmware.com>,
	linux-kernel@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a listen socket enqueues a connection for userspace to accept(),
the sk->sk_data_ready() callback should be invoked.  In-kernel socket
users rely on this callback to detect when incoming connections are
available.

Currently the sk->sk_state_change() callback is invoked by
vmci_transport.c.  This happens to work for userspace applications since
sk->sk_state_change = sock_def_wakeup() and sk->sk_data_ready =
sock_def_readable() both wake up the accept() waiter.  In-kernel socket
users, on the other hand, fail to detect incoming connections.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/vmw_vsock/vmci_transport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 7555cad..9363abb 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1236,7 +1236,7 @@ vmci_transport_recv_connecting_server(struct sock *listener,
 	/* Callers of accept() will be be waiting on the listening socket, not
 	 * the pending socket.
 	 */
-	listener->sk_state_change(listener);
+	listener->sk_data_ready(listener);
 
 	return 0;
 
-- 
2.5.0
