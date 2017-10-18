From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/3] rxrpc: Provide functions for allowing cleaner
 handling of signals
Date: Wed, 18 Oct 2017 12:56:03 +0100
Message-ID: <150832776375.7695.8788105655004966283.stgit@warthog.procyon.org.uk>
References: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide a couple of functions to allow cleaner handling of signals in a
kernel service.  They are:

 (1) rxrpc_kernel_get_rtt()

     This allows the kernel service to find out the RTT time for a call, so
     as to better judge how large a timeout to employ.

     Note, though, that whilst this returns a value in nanoseconds, the
     timeouts can only actually be in jiffies.

 (2) rxrpc_kernel_check_life()

     This returns a number that is updated when ACKs are received from the
     peer (notably including PING RESPONSE ACKs which we can elicit by
     sending PING ACKs to see if the call still exists on the server).

     The caller should compare the numbers of two calls to see if the call
     is still alive.

These can be used to provide an extending timeout rather than returning
immediately in the case that a signal occurs that would otherwise abort an
RPC operation.  The timeout would be extended if the server is still
responsive and the call is still apparently alive on the server.

For most operations this isn't that necessary - but for FS.StoreData it is:
OpenAFS writes the data to storage as it comes in without making a backup,
so if we immediately abort it when partially complete on a CTRL+C, say, we
have no idea of the state of the file after the abort.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   24 ++++++++++++++++++++++++
 include/net/af_rxrpc.h             |    2 ++
 net/rxrpc/af_rxrpc.c               |   19 +++++++++++++++++++
 net/rxrpc/peer_object.c            |   13 +++++++++++++
 4 files changed, 58 insertions(+)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 9fb61a6bc7cf..1fb5c553aedd 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -1033,6 +1033,30 @@ The kernel interface functions are as follows:
 
      It returns 0 if the call was requeued and an error otherwise.
 
+ (*) Get call RTT.
+
+	u64 rxrpc_kernel_get_rtt(struct socket *sock, struct rxrpc_call *call);
+
+     Get the RTT time to the peer in use by a call.  The value returned is in
+     nanoseconds.
+
+ (*) Check call still alive.
+
+	u32 rxrpc_kernel_check_life(struct socket *sock,
+				    struct rxrpc_call *call);
+
+     This returns a number that is updated when ACKs are received from the peer
+     (notably including PING RESPONSE ACKs which we can elicit by sending PING
+     ACKs to see if the call still exists on the server).  The caller should
+     compare the numbers of two calls to see if the call is still alive after
+     waiting for a suitable interval.
+
+     This allows the caller to work out if the server is still contactable and
+     if the call is still alive on the server whilst waiting for the server to
+     process a client operation.
+
+     This function may transmit a PING ACK.
+
 
 =======================
 CONFIGURABLE PARAMETERS
diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 820dd365a08e..2b3a6eec4570 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -61,6 +61,7 @@ bool rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
 void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
 			   struct sockaddr_rxrpc *);
+u64 rxrpc_kernel_get_rtt(struct socket *, struct rxrpc_call *);
 int rxrpc_kernel_charge_accept(struct socket *, rxrpc_notify_rx_t,
 			       rxrpc_user_attach_call_t, unsigned long, gfp_t);
 void rxrpc_kernel_set_tx_length(struct socket *, struct rxrpc_call *, s64);
@@ -68,5 +69,6 @@ int rxrpc_kernel_retry_call(struct socket *, struct rxrpc_call *,
 			    struct sockaddr_rxrpc *, struct key *);
 int rxrpc_kernel_check_call(struct socket *, struct rxrpc_call *,
 			    enum rxrpc_call_completion *, u32 *);
+u32 rxrpc_kernel_check_life(struct socket *, struct rxrpc_call *);
 
 #endif /* _NET_RXRPC_H */
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 481f7dc90ba2..73c980e26581 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -340,6 +340,25 @@ void rxrpc_kernel_end_call(struct socket *sock, struct rxrpc_call *call)
 EXPORT_SYMBOL(rxrpc_kernel_end_call);
 
 /**
+ * rxrpc_kernel_check_life - Check to see whether a call is still alive
+ * @sock: The socket the call is on
+ * @call: The call to check
+ *
+ * Allow a kernel service to find out whether a call is still alive - ie. we're
+ * getting ACKs from the server.  Returns a number representing the life state
+ * which can be compared to that returned by a previous call.
+ *
+ * If this is a client call, ping ACKs will be sent to the server to find out
+ * whether it's still responsive and whether the call is still alive on the
+ * server.
+ */
+u32 rxrpc_kernel_check_life(struct socket *sock, struct rxrpc_call *call)
+{
+	return call->acks_latest;
+}
+EXPORT_SYMBOL(rxrpc_kernel_check_life);
+
+/**
  * rxrpc_kernel_check_call - Check a call's state
  * @sock: The socket the call is on
  * @call: The call to check
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 5787f97f5330..d02a99f37f5f 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -411,3 +411,16 @@ void rxrpc_kernel_get_peer(struct socket *sock, struct rxrpc_call *call,
 	*_srx = call->peer->srx;
 }
 EXPORT_SYMBOL(rxrpc_kernel_get_peer);
+
+/**
+ * rxrpc_kernel_get_rtt - Get a call's peer RTT
+ * @sock: The socket on which the call is in progress.
+ * @call: The call to query
+ *
+ * Get the call's peer RTT.
+ */
+u64 rxrpc_kernel_get_rtt(struct socket *sock, struct rxrpc_call *call)
+{
+	return call->peer->rtt;
+}
+EXPORT_SYMBOL(rxrpc_kernel_get_rtt);
