From: David Howells <dhowells@redhat.com>
Subject: [PATCH 5/8] af_rxrpc: Improve ACK production [ver #2]
Date: Thu, 06 Mar 2014 12:46:50 +0000
Message-ID: <20140306124650.16645.99916.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve ACK production by the following means:

 (1) Don't send an ACK_REQUESTED ack immediately even if the RXRPC_MORE_PACKETS
     flag isn't set on a data packet that has also has RXRPC_REQUEST_ACK set.

     MORE_PACKETS just means that the sender just emptied its Tx data buffer.
     More data will be forthcoming unless RXRPC_LAST_PACKET is also flagged.

     It is possible to see runs of DATA packets with MORE_PACKETS unset that
     aren't waiting for an ACK.

     It is therefore better to wait a small instant to see if we can combine an
     ACK for several packets.

 (2) Don't send an ACK_IDLE ack immediately unless we're responding to the
     terminal data packet of a call.

     Whilst sending an ACK_IDLE mid-call serves to let the other side know
     that we won't be asking it to resend certain Tx buffers and that it can
     discard them, spamming it with loads of acks just because we've
     temporarily run out of data just distracts it.

 (3) Put the ACK_IDLE ack generation timeout up to half a second rather than a
     single jiffy.  Just because we haven't been given more data immediately
     doesn't mean that more isn't forthcoming.  The other side may be busily
     finding the data to send to us.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c    |    2 +-
 net/rxrpc/ar-input.c  |    3 +--
 net/rxrpc/ar-skbuff.c |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 732b82f540c5..1a490d976e7e 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -41,7 +41,7 @@ unsigned rxrpc_soft_ack_delay = 1 * HZ;
  * further packets aren't immediately received to decide when to send an IDLE
  * ACK let the other end know that it can free up its Tx buffer space.
  */
-unsigned rxrpc_idle_ack_delay = 1;
+unsigned rxrpc_idle_ack_delay = 0.5 * HZ;
 
 static const char *rxrpc_acks(u8 reason)
 {
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 540c03d338c9..e449c675c36a 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -347,8 +347,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	 * it */
 	if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
 		_proto("ACK Requested on %%%u", serial);
-		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED, sp->hdr.serial,
-				  !(sp->hdr.flags & RXRPC_MORE_PACKETS));
+		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED, sp->hdr.serial, false);
 	}
 
 	switch (sp->hdr.type) {
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index af9f4fd2a365..4cfab49e329d 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -90,7 +90,7 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 		 */
 		_debug("send Rx idle ACK");
 		__rxrpc_propose_ACK(call, RXRPC_ACK_IDLE, sp->hdr.serial,
-				    true);
+				    false);
 	}
 
 	spin_unlock_bh(&call->lock);
