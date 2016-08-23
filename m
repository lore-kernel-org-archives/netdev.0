From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/5] rxrpc: When clearing a socket,
 clear the call sets in the right order
Date: Tue, 23 Aug 2016 16:26:39 +0100
Message-ID: <147196599897.28271.2399914077654601399.stgit@warthog.procyon.org.uk>
References: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When clearing a socket, we should clear the securing-in-progress list
first, then the accept queue and last the main call tree because that's the
order in which a call progresses.  Not that a call should move from the
accept queue to the main tree whilst we're shutting down a socket, but it a
call could possibly move from sequreq to acceptq whilst we're clearing up.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 5007e7ac889f..008188103fd6 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -564,12 +564,6 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 
 	read_lock_bh(&rx->call_lock);
 
-	/* mark all the calls as no longer wanting incoming packets */
-	for (p = rb_first(&rx->calls); p; p = rb_next(p)) {
-		call = rb_entry(p, struct rxrpc_call, sock_node);
-		rxrpc_mark_call_released(call);
-	}
-
 	/* kill the not-yet-accepted incoming calls */
 	list_for_each_entry(call, &rx->secureq, accept_link) {
 		rxrpc_mark_call_released(call);
@@ -579,6 +573,12 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 		rxrpc_mark_call_released(call);
 	}
 
+	/* mark all the calls as no longer wanting incoming packets */
+	for (p = rb_first(&rx->calls); p; p = rb_next(p)) {
+		call = rb_entry(p, struct rxrpc_call, sock_node);
+		rxrpc_mark_call_released(call);
+	}
+
 	read_unlock_bh(&rx->call_lock);
 	_leave("");
 }
