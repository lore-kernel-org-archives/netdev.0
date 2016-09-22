From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/9] rxrpc: Reduce the number of ACK-Requests sent
 [ver #2]
Date: Thu, 22 Sep 2016 09:22:56 +0100
Message-ID: <147453257603.14579.17423610462110152925.stgit@warthog.procyon.org.uk>
References: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of ACK-Requests we set on DATA packets that we're sending
to reduce network traffic.  We set the flag on odd-numbered DATA packets to
start off the RTT cache until we have at least three entries in it and then
probe once per second thereafter to keep it topped up.

This could be made tunable in future.

Note that from this point, the RXRPC_REQUEST_ACK flag is set on DATA
packets as we transmit them and not stored statically in the sk_buff.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/output.c      |   13 +++++++++++--
 net/rxrpc/peer_object.c |    1 +
 net/rxrpc/sendmsg.c     |    2 --
 4 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 1c4597b2c6cd..b13754a6dd7a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -255,6 +255,7 @@ struct rxrpc_peer {
 
 	/* calculated RTT cache */
 #define RXRPC_RTT_CACHE_SIZE 32
+	ktime_t			rtt_last_req;	/* Time of last RTT request */
 	u64			rtt;		/* Current RTT estimate (in nS) */
 	u64			rtt_sum;	/* Sum of cache contents */
 	u64			rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* Determined RTT cache */
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index db01fbb70d23..282cb1e36d06 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -270,6 +270,12 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	msg.msg_controllen = 0;
 	msg.msg_flags = 0;
 
+	/* If our RTT cache needs working on, request an ACK. */
+	if ((call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
+	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
+			 ktime_get_real()))
+		whdr.flags |= RXRPC_REQUEST_ACK;
+
 	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
 		static int lose;
 		if ((lose++ & 7) == 7) {
@@ -301,11 +307,14 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb)
 
 done:
 	if (ret >= 0) {
-		skb->tstamp = ktime_get_real();
+		ktime_t now = ktime_get_real();
+		skb->tstamp = now;
 		smp_wmb();
 		sp->hdr.serial = serial;
-		if (whdr.flags & RXRPC_REQUEST_ACK)
+		if (whdr.flags & RXRPC_REQUEST_ACK) {
+			call->peer->rtt_last_req = now;
 			trace_rxrpc_rtt_tx(call, rxrpc_rtt_tx_data, serial);
+		}
 	}
 	_leave(" = %d [%u]", ret, call->peer->maxdata);
 	return ret;
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index f3e5766910fd..941b724d523b 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -244,6 +244,7 @@ static void rxrpc_init_peer(struct rxrpc_peer *peer, unsigned long hash_key)
 	peer->hash_key = hash_key;
 	rxrpc_assess_MTU_size(peer);
 	peer->mtu = peer->if_mtu;
+	peer->rtt_last_req = ktime_get_real();
 
 	switch (peer->srx.transport.family) {
 	case AF_INET:
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 607223f4f871..ca7c3be60ad2 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -299,8 +299,6 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			else if (call->tx_top - call->tx_hard_ack <
 				 call->tx_winsize)
 				sp->hdr.flags |= RXRPC_MORE_PACKETS;
-			if (seq & 1)
-				sp->hdr.flags |= RXRPC_REQUEST_ACK;
 
 			ret = conn->security->secure_packet(
 				call, skb, skb->mark, skb->head);
