From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each CHUNK
 is too aggressive
Date: Fri, 24 Jun 2011 06:15:35 -0400
Message-ID: <20110624101535.GB9222@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40800 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab1FXKPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 06:15:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we subtract sizeof(struct sk_buff) of our view of the
receiver's rwnd for each DATA chunk appended to a sctp packet.
Reducing the rwnd by >200 bytes for each DATA chunk quickly
consumes the available window and prevents max MTU sized packets
(for large MTU values) from being generated in combination with
small DATA chunks. The sender has to wait for the next SACK to
be processed for the rwnd to be corrected.

Accounting for data structures required for rx is the responsibility
of the stack which is why we announce a rwnd of sk_rcvbuf/2.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff --git a/net/sctp/output.c b/net/sctp/output.c
index b4f3cf0..ceb55b2 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -700,13 +700,7 @@ static void sctp_packet_append_data(struct sctp_packet *packet,
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
