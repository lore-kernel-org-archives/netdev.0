From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/3] af_rxrpc: Prevent RxRPC peers from ABORT-storming one
 another [ver #3]
Date: Thu, 06 Mar 2014 23:18:49 +0000
Message-ID: <20140306231849.11431.66439.stgit@warthog.procyon.org.uk>
References: <20140306231835.11431.50147.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306231835.11431.50147.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Smith <tim@electronghost.co.uk>

When an ABORT is sent, aborting a connection, the sender quite reasonably
forgets about the connection.  If another frame is received, another ABORT
will be sent.  When the receiver gets it, it no longer applies to an extant
connection, so an ABORT is sent, and so on...

Prevent this by never sending a rejection for an ABORT packet.

Signed-off-by: Tim Smith <tim@electronghost.co.uk>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-input.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 529572f18d1f..eb7e16276cc1 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -606,8 +606,10 @@ dead_call:
 	}
 
 	_debug("dead call");
-	skb->priority = RX_CALL_DEAD;
-	rxrpc_reject_packet(conn->trans->local, skb);
+	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
+		skb->priority = RX_CALL_DEAD;
+		rxrpc_reject_packet(conn->trans->local, skb);
+	}
 	goto done;
 
 	/* resend last packet of a completed call
@@ -790,8 +792,10 @@ cant_route_call:
 		skb->priority = RX_CALL_DEAD;
 	}
 
-	_debug("reject");
-	rxrpc_reject_packet(local, skb);
+	if (sp->hdr.type != RXRPC_PACKET_TYPE_ABORT) {
+		_debug("reject type %d",sp->hdr.type);
+		rxrpc_reject_packet(local, skb);
+	}
 	rxrpc_put_local(local);
 	_leave(" [no call]");
 	return;
