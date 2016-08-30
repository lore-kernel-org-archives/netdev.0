From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 6/8] rxrpc: Provide a way for AFS to ask for the
 peer address of a call
Date: Tue, 30 Aug 2016 16:42:18 +0100
Message-ID: <147257173881.6391.9354901481368899679.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a function so that kernel users, such as AFS, can ask for the peer
address of a call:

   void rxrpc_kernel_get_peer(struct rxrpc_call *call,
			      struct sockaddr_rxrpc *_srx);

In the future the kernel service won't get sk_buffs to look inside.
Further, this allows us to hide any canonicalisation inside AF_RXRPC for
when IPv6 support is added.

Also propagate this through to afs_find_server() and issue a warning if we
can't handle the address family yet.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |    7 +++++++
 fs/afs/cmservice.c                 |   20 +++++++++++---------
 fs/afs/internal.h                  |    5 ++++-
 fs/afs/rxrpc.c                     |    2 +-
 fs/afs/server.c                    |   11 ++++++++---
 include/net/af_rxrpc.h             |    2 ++
 net/rxrpc/peer_object.c            |   15 +++++++++++++++
 7 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 70c926ae212d..dfe0b008df74 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -868,6 +868,13 @@ The kernel interface functions are as follows:
      This is used to allocate a null RxRPC key that can be used to indicate
      anonymous security for a particular domain.
 
+ (*) Get the peer address of a call.
+
+	void rxrpc_kernel_get_peer(struct socket *sock, struct rxrpc_call *call,
+				   struct sockaddr_rxrpc *_srx);
+
+     This is used to find the remote peer address of a call.
+
 
 =======================
 CONFIGURABLE PARAMETERS
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index ca32d891bbc3..77ee481059ac 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -167,9 +167,9 @@ static void SRXAFSCB_CallBack(struct work_struct *work)
 static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 				   bool last)
 {
+	struct sockaddr_rxrpc srx;
 	struct afs_callback *cb;
 	struct afs_server *server;
-	struct in_addr addr;
 	__be32 *bp;
 	u32 tmp;
 	int ret, loop;
@@ -178,6 +178,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 
 	switch (call->unmarshall) {
 	case 0:
+		rxrpc_kernel_get_peer(afs_socket, call->rxcall, &srx);
 		call->offset = 0;
 		call->unmarshall++;
 
@@ -282,8 +283,7 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 
 	/* we'll need the file server record as that tells us which set of
 	 * vnodes to operate upon */
-	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
-	server = afs_find_server(&addr);
+	server = afs_find_server(&srx);
 	if (!server)
 		return -ENOTCONN;
 	call->server = server;
@@ -314,12 +314,14 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
 					       struct sk_buff *skb,
 					       bool last)
 {
+	struct sockaddr_rxrpc srx;
 	struct afs_server *server;
-	struct in_addr addr;
 	int ret;
 
 	_enter(",{%u},%d", skb->len, last);
 
+	rxrpc_kernel_get_peer(afs_socket, call->rxcall, &srx);
+
 	ret = afs_data_complete(call, skb, last);
 	if (ret < 0)
 		return ret;
@@ -329,8 +331,7 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
 
 	/* we'll need the file server record as that tells us which set of
 	 * vnodes to operate upon */
-	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
-	server = afs_find_server(&addr);
+	server = afs_find_server(&srx);
 	if (!server)
 		return -ENOTCONN;
 	call->server = server;
@@ -347,11 +348,13 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call,
 						struct sk_buff *skb,
 						bool last)
 {
+	struct sockaddr_rxrpc srx;
 	struct afs_server *server;
-	struct in_addr addr;
 
 	_enter(",{%u},%d", skb->len, last);
 
+	rxrpc_kernel_get_peer(afs_socket, call->rxcall, &srx);
+
 	/* There are some arguments that we ignore */
 	afs_data_consumed(call, skb);
 	if (!last)
@@ -362,8 +365,7 @@ static int afs_deliver_cb_init_call_back_state3(struct afs_call *call,
 
 	/* we'll need the file server record as that tells us which set of
 	 * vnodes to operate upon */
-	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
-	server = afs_find_server(&addr);
+	server = afs_find_server(&srx);
 	if (!server)
 		return -ENOTCONN;
 	call->server = server;
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index df976b2a7f40..d97552de9c59 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -20,6 +20,7 @@
 #include <linux/sched.h>
 #include <linux/fscache.h>
 #include <linux/backing-dev.h>
+#include <net/af_rxrpc.h>
 
 #include "afs.h"
 #include "afs_vl.h"
@@ -607,6 +608,8 @@ extern void afs_proc_cell_remove(struct afs_cell *);
 /*
  * rxrpc.c
  */
+extern struct socket *afs_socket;
+
 extern int afs_open_socket(void);
 extern void afs_close_socket(void);
 extern void afs_data_consumed(struct afs_call *, struct sk_buff *);
@@ -654,7 +657,7 @@ do {								\
 
 extern struct afs_server *afs_lookup_server(struct afs_cell *,
 					    const struct in_addr *);
-extern struct afs_server *afs_find_server(const struct in_addr *);
+extern struct afs_server *afs_find_server(const struct sockaddr_rxrpc *);
 extern void afs_put_server(struct afs_server *);
 extern void __exit afs_purge_servers(void);
 
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 14d04c848465..a1916750e2f9 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -16,7 +16,7 @@
 #include "internal.h"
 #include "afs_cm.h"
 
-static struct socket *afs_socket; /* my RxRPC socket */
+struct socket *afs_socket; /* my RxRPC socket */
 static struct workqueue_struct *afs_async_calls;
 static atomic_t afs_outstanding_calls;
 static atomic_t afs_outstanding_skbs;
diff --git a/fs/afs/server.c b/fs/afs/server.c
index f342acf3547d..d4066ab7dd55 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -178,13 +178,18 @@ server_in_two_cells:
 /*
  * look up a server by its IP address
  */
-struct afs_server *afs_find_server(const struct in_addr *_addr)
+struct afs_server *afs_find_server(const struct sockaddr_rxrpc *srx)
 {
 	struct afs_server *server = NULL;
 	struct rb_node *p;
-	struct in_addr addr = *_addr;
+	struct in_addr addr = srx->transport.sin.sin_addr;
 
-	_enter("%pI4", &addr.s_addr);
+	_enter("{%d,%pI4}", srx->transport.family, &addr.s_addr);
+
+	if (srx->transport.family != AF_INET) {
+		WARN(true, "AFS does not yes support non-IPv4 addresses\n");
+		return NULL;
+	}
 
 	read_lock(&afs_servers_lock);
 
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 7b0f88699b25..f9224e835d43 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -49,5 +49,7 @@ int rxrpc_kernel_get_error_number(struct sk_buff *);
 void rxrpc_kernel_free_skb(struct sk_buff *);
 struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long);
 int rxrpc_kernel_reject_call(struct socket *);
+void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
+			   struct sockaddr_rxrpc *);
 
 #endif /* _NET_RXRPC_H */
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 538e9831c699..aebc73ac16dc 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -313,3 +313,18 @@ void __rxrpc_put_peer(struct rxrpc_peer *peer)
 
 	kfree_rcu(peer, rcu);
 }
+
+/**
+ * rxrpc_kernel_get_peer - Get the peer address of a call
+ * @sock: The socket on which the call is in progress.
+ * @call: The call to query
+ * @_srx: Where to place the result
+ *
+ * Get the address of the remote peer in a call.
+ */
+void rxrpc_kernel_get_peer(struct socket *sock, struct rxrpc_call *call,
+			   struct sockaddr_rxrpc *_srx)
+{
+	*_srx = call->peer->srx;
+}
+EXPORT_SYMBOL(rxrpc_kernel_get_peer);
