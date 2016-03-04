From: David Howells <dhowells@redhat.com>
Subject: [PATCH 07/13] rxrpc: Be more selective about the types of received
 packets we accept
Date: Fri, 04 Mar 2016 16:37:54 +0000
Message-ID: <20160304163754.31057.25164.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, received RxRPC packets outside the range 1-13 are rejected.
There are, however, holes in the range that should also be rejected - plus
at least one type we don't yet support - so reject these also.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h |   11 +++++++++++
 net/rxrpc/ar-input.c   |    3 ++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index de1e67988ada..9ebab3a8cf0a 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -70,6 +70,17 @@ struct rxrpc_wire_header {
 
 extern const char *rxrpc_pkts[];
 
+#define RXRPC_SUPPORTED_PACKET_TYPES (			\
+		(1 << RXRPC_PACKET_TYPE_DATA) |		\
+		(1 << RXRPC_PACKET_TYPE_ACK) |		\
+		(1 << RXRPC_PACKET_TYPE_BUSY) |		\
+		(1 << RXRPC_PACKET_TYPE_ABORT) |	\
+		(1 << RXRPC_PACKET_TYPE_ACKALL) |	\
+		(1 << RXRPC_PACKET_TYPE_CHALLENGE) |	\
+		(1 << RXRPC_PACKET_TYPE_RESPONSE) |	\
+		/*(1 << RXRPC_PACKET_TYPE_DEBUG) | */	\
+		(1 << RXRPC_PACKET_TYPE_VERSION))
+
 /*****************************************************************************/
 /*
  * jumbo packet secondary header
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index e6396a8c969f..63ed75c40e29 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -728,7 +728,8 @@ void rxrpc_data_ready(struct sock *sk)
 	     sp->hdr.flags & RXRPC_CLIENT_INITIATED ? "ToServer" : "ToClient",
 	     sp->hdr.epoch, sp->hdr.cid, sp->hdr.callNumber);
 
-	if (sp->hdr.type == 0 || sp->hdr.type >= RXRPC_N_PACKET_TYPES) {
+	if (sp->hdr.type >= RXRPC_N_PACKET_TYPES ||
+	    !((RXRPC_SUPPORTED_PACKET_TYPES >> sp->hdr.type) & 1)) {
 		_proto("Rx Bad Packet Type %u", sp->hdr.type);
 		goto bad_message;
 	}
