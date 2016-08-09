From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 3/6] rxrpc: Don't access connection from call if pointer
 is NULL
Date: Tue, 09 Aug 2016 17:33:33 +0100
Message-ID: <147076041310.13232.12860102197671636278.stgit@warthog.procyon.org.uk>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The call state machine processor sets up the message parameters for a UDP
message that it might need to transmit in advance on the basis that there's
a very good chance it's going to have to transmit either an ACK or an
ABORT.  This requires it to look in the connection struct to retrieve some
of the parameters.

However, if the call is complete, the call connection pointer may be NULL
to dissuade the processor from transmitting a message.  However, there are
some situations where the processor is still going to be called - and it's
still going to set up message parameters whether it needs them or not.

This results in a NULL pointer dereference at:

	net/rxrpc/call_event.c:837

To fix this, skip the message pre-initialisation if there's no connection
attached.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index f5e99163a09e..e60cf65c2232 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -837,6 +837,9 @@ void rxrpc_process_call(struct work_struct *work)
 		return;
 	}
 
+	if (!call->conn)
+		goto skip_msg_init;
+
 	/* there's a good chance we're going to have to send a message, so set
 	 * one up in advance */
 	msg.msg_name	= &call->conn->params.peer->srx.transport;
@@ -859,6 +862,7 @@ void rxrpc_process_call(struct work_struct *work)
 	memset(iov, 0, sizeof(iov));
 	iov[0].iov_base	= &whdr;
 	iov[0].iov_len	= sizeof(whdr);
+skip_msg_init:
 
 	/* deal with events of a final nature */
 	if (test_bit(RXRPC_CALL_EV_RCVD_ERROR, &call->events)) {
