From: Thomas Graf <tgraf@redhat.com>
Subject: [PATCH] sctp: Do not account for sizeof(struct sk_buff) in estimated rwnd
Date: Mon, 19 Dec 2011 15:11:40 +0100
Message-ID: <1324303900-8360-1-git-send-email-tgraf@redhat.com>
Cc: linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@redhat.com>
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1LSONF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 09:13:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When checking whether a DATA chunk fits into the estimated rwnd a
full sizeof(struct sk_buff) is added to the needed chunk size. This
quickly exhausts the available rwnd space and leads to packets being
sent which are much below the PMTU limit. This can lead to much worse
performance.

The reason for this behaviour was to avoid putting too much memory
pressure on the receiver. The concept is not completely irational
because a Linux receiver does in fact clone an skb for each DATA chunk
delivered. However, Linux also reserves half the available socket
buffer space for data structures therefore usage of it is already
accounted for.

When proposing to change this the last time it was noted that this
behaviour was introduced to solve a performance issue caused by rwnd
overusage in combination with small DATA chunks.

Trying to reproduce this I found that with the sk_buff overhead removed,
the performance would improve significantly unless socket buffer limits
are increased.

The following numbers have been gathered using a patched iperf
supporting SCTP over a live 1 Gbit ethernet network. The -l option
was used to limit DATA chunk sizes. The numbers listed are based on
the average of 3 test runs each. Default values have been used for
sk_(r|w)mem.

Chunk
Size    Unpatched     No Overhead
-------------------------------------
   4    15.2 Kbit [!]   12.2 Mbit [!]
   8    35.8 Kbit [!]   26.0 Mbit [!]
  16    95.5 Kbit [!]   54.4 Mbit [!]
  32   106.7 Mbit      102.3 Mbit
  64   189.2 Mbit      188.3 Mbit
 128   331.2 Mbit      334.8 Mbit
 256   537.7 Mbit      536.0 Mbit
 512   766.9 Mbit      766.6 Mbit
1024   810.1 Mbit      808.6 Mbit

Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
 net/sctp/output.c   |    8 +-------
 net/sctp/outqueue.c |    6 ++----
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 08b3cea..817174e 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -697,13 +697,7 @@ static void sctp_packet_append_data(struct sctp_packet *packet,
 	/* Keep track of how many bytes are in flight to the receiver. */
 	asoc->outqueue.outstanding_bytes += datasize;
 
-	/* Update our view of the receiver's rwnd. Include sk_buff overhead
-	 * while updating peer.rwnd so that it reduces the chances of a
-	 * receiver running out of receive buffer space even when receive
-	 * window is still open. This can happen when a sender is sending
-	 * sending small messages.
-	 */
-	datasize += sizeof(struct sk_buff);
+	/* Update our view of the receiver's rwnd. */
 	if (datasize < rwnd)
 		rwnd -= datasize;
 	else
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 14c2b06..cfeb1d4 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -411,8 +411,7 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 					chunk->transport->flight_size -=
 							sctp_data_size(chunk);
 				q->outstanding_bytes -= sctp_data_size(chunk);
-				q->asoc->peer.rwnd += (sctp_data_size(chunk) +
-							sizeof(struct sk_buff));
+				q->asoc->peer.rwnd += sctp_data_size(chunk);
 			}
 			continue;
 		}
@@ -432,8 +431,7 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 			 * (Section 7.2.4)), add the data size of those
 			 * chunks to the rwnd.
 			 */
-			q->asoc->peer.rwnd += (sctp_data_size(chunk) +
-						sizeof(struct sk_buff));
+			q->asoc->peer.rwnd += sctp_data_size(chunk);
 			q->outstanding_bytes -= sctp_data_size(chunk);
 			if (chunk->transport)
 				transport->flight_size -= sctp_data_size(chunk);
-- 
1.7.7.4
