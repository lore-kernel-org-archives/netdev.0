From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/4] rxrpc: Use rxrpc_extract_addr_from_skb()
 rather than doing this manually
Date: Tue, 13 Sep 2016 23:41:52 +0100
Message-ID: <147380651204.30728.1567481837622196506.stgit@warthog.procyon.org.uk>
References: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two places that want to transmit a packet in response to one just
received and manually pick the address to reply to out of the sk_buff.
Make them use rxrpc_extract_addr_from_skb() instead so that IPv6 is handled
automatically.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/local_event.c |   13 +++++--------
 net/rxrpc/output.c      |   32 ++++++--------------------------
 2 files changed, 11 insertions(+), 34 deletions(-)

diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index cdd58e6e9fbd..f073e932500e 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -15,8 +15,6 @@
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
-#include <linux/udp.h>
-#include <linux/ip.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <generated/utsrelease.h>
@@ -33,7 +31,7 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 {
 	struct rxrpc_wire_header whdr;
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	struct sockaddr_in sin;
+	struct sockaddr_rxrpc srx;
 	struct msghdr msg;
 	struct kvec iov[2];
 	size_t len;
@@ -41,12 +39,11 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 
 	_enter("");
 
-	sin.sin_family = AF_INET;
-	sin.sin_port = udp_hdr(skb)->source;
-	sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+	if (rxrpc_extract_addr_from_skb(&srx, skb) < 0)
+		return;
 
-	msg.msg_name	= &sin;
-	msg.msg_namelen	= sizeof(sin);
+	msg.msg_name	= &srx.transport;
+	msg.msg_namelen	= srx.transport_len;
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 90c7722d5779..ec3621f2c5c8 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -15,8 +15,6 @@
 #include <linux/gfp.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
-#include <linux/udp.h>
-#include <linux/ip.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
@@ -272,10 +270,7 @@ send_fragmentable:
  */
 void rxrpc_reject_packets(struct rxrpc_local *local)
 {
-	union {
-		struct sockaddr sa;
-		struct sockaddr_in sin;
-	} sa;
+	struct sockaddr_rxrpc srx;
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_wire_header whdr;
 	struct sk_buff *skb;
@@ -292,32 +287,21 @@ void rxrpc_reject_packets(struct rxrpc_local *local)
 	iov[1].iov_len = sizeof(code);
 	size = sizeof(whdr) + sizeof(code);
 
-	msg.msg_name = &sa;
+	msg.msg_name = &srx.transport;
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
 
-	memset(&sa, 0, sizeof(sa));
-	sa.sa.sa_family = local->srx.transport.family;
-	switch (sa.sa.sa_family) {
-	case AF_INET:
-		msg.msg_namelen = sizeof(sa.sin);
-		break;
-	default:
-		msg.msg_namelen = 0;
-		break;
-	}
-
 	memset(&whdr, 0, sizeof(whdr));
 	whdr.type = RXRPC_PACKET_TYPE_ABORT;
 
 	while ((skb = skb_dequeue(&local->reject_queue))) {
 		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
-		switch (sa.sa.sa_family) {
-		case AF_INET:
-			sa.sin.sin_port = udp_hdr(skb)->source;
-			sa.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
+
+		if (rxrpc_extract_addr_from_skb(&srx, skb) == 0) {
+			msg.msg_namelen = srx.transport_len;
+
 			code = htonl(skb->priority);
 
 			whdr.epoch	= htonl(sp->hdr.epoch);
@@ -329,10 +313,6 @@ void rxrpc_reject_packets(struct rxrpc_local *local)
 			whdr.flags	&= RXRPC_CLIENT_INITIATED;
 
 			kernel_sendmsg(local->socket, &msg, iov, 2, size);
-			break;
-
-		default:
-			break;
 		}
 
 		rxrpc_free_skb(skb);
