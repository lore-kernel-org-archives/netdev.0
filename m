From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/11] rxrpc: Add config to inject packet loss
Date: Sun, 18 Sep 2016 00:22:47 +0100
Message-ID: <147415456698.18436.9557149460694248243.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44770 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934188AbcIQXWt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:22:49 -0400
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a configuration option to inject packet loss by discarding
approximately every 8th packet received and approximately every 8th DATA
packet transmitted.

Note that no locking is used, but it shouldn't really matter.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Kconfig  |    7 +++++++
 net/rxrpc/input.c  |    8 ++++++++
 net/rxrpc/output.c |    9 +++++++++
 3 files changed, 24 insertions(+)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 13396c74b5c1..86f8853a038c 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -26,6 +26,13 @@ config AF_RXRPC_IPV6
 	  Say Y here to allow AF_RXRPC to use IPV6 UDP as well as IPV4 UDP as
 	  its network transport.
 
+config AF_RXRPC_INJECT_LOSS
+	bool "Inject packet loss into RxRPC packet stream"
+	depends on AF_RXRPC
+	help
+	  Say Y here to inject packet loss by discarding some received and some
+	  transmitted packets.
+
 
 config AF_RXRPC_DEBUG
 	bool "RxRPC dynamic debugging"
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 84bb16d47b85..7ac1edf3aac7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -712,6 +712,14 @@ void rxrpc_data_ready(struct sock *udp_sk)
 	skb_orphan(skb);
 	sp = rxrpc_skb(skb);
 
+	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
+		static int lose;
+		if ((lose++ & 7) == 7) {
+			rxrpc_lose_skb(skb, rxrpc_skb_rx_lost);
+			return;
+		}
+	}
+
 	_net("Rx UDP packet from %08x:%04hu",
 	     ntohl(ip_hdr(skb)->saddr), ntohs(udp_hdr(skb)->source));
 
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index a2cad5ce7416..16e18a94ffa6 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -225,6 +225,15 @@ int rxrpc_send_data_packet(struct rxrpc_connection *conn, struct sk_buff *skb)
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
 
+	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
+		static int lose;
+		if ((lose++ & 7) == 7) {
+			rxrpc_lose_skb(skb, rxrpc_skb_tx_lost);
+			_leave(" = 0 [lose]");
+			return 0;
+		}
+	}
+
 	/* send the packet with the don't fragment bit set if we currently
 	 * think it's small enough */
 	if (skb->len - sizeof(struct rxrpc_wire_header) < conn->params.peer->maxdata) {
