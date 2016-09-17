From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 12/14] rxrpc: Don't transmit an ACK if there's no
 reason set
Date: Sun, 18 Sep 2016 00:19:07 +0100
Message-ID: <147415434767.17897.5111366020912850823.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755072AbcIQXTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:19:09 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't transmit an ACK if call->ackr_reason in unset.  There's the
possibility of a race between recvmsg() sending an ACK and the background
processing thread trying to send the same one.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/output.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index 06a9aca739d1..aa0507214b31 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -137,6 +137,11 @@ int rxrpc_send_call_packet(struct rxrpc_call *call, u8 type)
 	switch (type) {
 	case RXRPC_PACKET_TYPE_ACK:
 		spin_lock_bh(&call->lock);
+		if (!call->ackr_reason) {
+			spin_unlock_bh(&call->lock);
+			ret = 0;
+			goto out;
+		}
 		n = rxrpc_fill_out_ack(call, pkt);
 		call->ackr_reason = 0;
 
