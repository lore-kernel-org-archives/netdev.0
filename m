From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Ignore BUSY packets on old calls
Date: Thu, 16 Mar 2017 16:27:10 +0000
Message-ID: <148968163004.20909.2389917167977671935.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57792 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752181AbdCPQ1O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 12:27:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we receive a BUSY packet for a call we think we've just completed, the
packet is handed off to the connection processor to deal with - but the
connection processor doesn't expect a BUSY packet and so flags a protocol
error.

Fix this by simply ignoring the BUSY packet for the moment.

The symptom of this may appear as a system call failing with EPROTO.  This
may be triggered by pressing ctrl-C under some circumstances.

This comes about we abort calls due to interruption by a signal (which we
shouldn't do, but that's going to be a large fix and mostly in fs/afs/).
What happens is that we abort the call and may also abort follow up calls
too (this needs offloading somehoe).  So we see a transmission of something
like the following sequence of packets:

	DATA for call N
	ABORT call N
	DATA for call N+1
	ABORT call N+1

in very quick succession on the same channel.  However, the peer may have
deferred the processing of the ABORT from the call N to a background thread
and thus sees the DATA message from the call N+1 coming in before it has
cleared the channel.  Thus it sends a BUSY packet[*].

[*] Note that some implementations (OpenAFS, for example) mark the BUSY
    packet with one plus the callNumber of the call prior to call N.
    Ordinarily, this would be call N, but there's no requirement for the
    calls on a channel to be numbered strictly sequentially (the number is
    required to increase).

    This is wrong and means that the callNumber in the BUSY packet should
    be ignored (it really ought to be N+1 since that's what it's in
    response to).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_event.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 3f9d8d7ec632..b099b64366f3 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -275,6 +275,10 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		rxrpc_conn_retransmit_call(conn, skb);
 		return 0;
 
+	case RXRPC_PACKET_TYPE_BUSY:
+		/* Just ignore BUSY packets for now. */
+		return 0;
+
 	case RXRPC_PACKET_TYPE_ABORT:
 		if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
 				  &wtmp, sizeof(wtmp)) < 0)
