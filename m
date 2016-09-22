From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/9] rxrpc: Expedite ping response transmission
Date: Thu, 22 Sep 2016 01:39:43 +0100
Message-ID: <147450478367.14691.17054292632652692452.stgit@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expedite the transmission of a response to a PING ACK by sending it from
sendmsg if one is pending.  We're most likely to see a PING ACK during the
client call Tx phase as the other side may use it to determine a number of
parameters, such as the client's receive window size, the RTT and whether
the client is doing slow start (similar to RFC5681).

If we don't expedite it, it's left to the background processing thread to
transmit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 814b17f23971..3c969de3ef05 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -180,6 +180,10 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 	copied = 0;
 	do {
+		/* Check to see if there's a ping ACK to reply to. */
+		if (call->ackr_reason == RXRPC_ACK_PING_RESPONSE)
+			rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ACK);
+
 		if (!skb) {
 			size_t size, chunk, max, space;
 
