From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Kernel calls get stuck in recvmsg
Date: Fri, 24 Feb 2017 21:57:13 +0000
Message-ID: <148797343389.26520.13921866303222644134.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calls made through the in-kernel interface can end up getting stuck because
of a missed variable update in a loop in rxrpc_recvmsg_data().  The problem
is like this:

 (1) A new packet comes in and doesn't cause a notification to be given to
     the client as there's still another packet in the ring - the
     assumption being that if the client will keep drawing off data until
     the ring is empty.

 (2) The client is in rxrpc_recvmsg_data(), inside the big while loop that
     iterates through the packets.  This copies the window pointers into
     variables rather than using the information in the call struct
     because:

     (a) MSG_PEEK might be in effect;

     (b) we need a barrier after reading call->rx_top to pair with the
     	 barrier in the softirq routine that loads the buffer.

 (3) The reading of call->rx_top is done outside of the loop, and top is
     never updated whilst we're in the loop.  This means that even through
     there's a new packet available, we don't see it and may return -EFAULT
     to the caller - who will happily return to the scheduler and await the
     next notification.

 (4) No further notifications are forthcoming until there's an abort as the
     ring isn't empty.

The fix is to move the read of call->rx_top inside the loop - but it needs
to be done before the condition is checked.

Reported-by: Marc Dionne <marc.dionne@auristor.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Tested-by: Marc Dionne <marc.dionne@auristor.com>
---

 net/rxrpc/recvmsg.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index c29362d50a92..f3a688e10843 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -320,8 +320,10 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 
 	/* Barriers against rxrpc_input_data(). */
 	hard_ack = call->rx_hard_ack;
-	top = smp_load_acquire(&call->rx_top);
-	for (seq = hard_ack + 1; before_eq(seq, top); seq++) {
+	seq = hard_ack + 1;
+	while (top = smp_load_acquire(&call->rx_top),
+	       before_eq(seq, top)
+	       ) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		skb = call->rxtx_buffer[ix];
 		if (!skb) {
@@ -394,6 +396,8 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 			ret = 1;
 			goto out;
 		}
+
+		seq++;
 	}
 
 out:
