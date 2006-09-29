From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: rewriting skb->truesize... good or bad idea
Date: Fri, 29 Sep 2006 14:16:57 -0400
Message-ID: <451D6319.1040506@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050805020504010504020301"
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:51587 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751328AbWI2SRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 14:17:01 -0400
Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by atlrel8.hp.com (Postfix) with ESMTP id 6DBCF35D9A
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 14:16:58 -0400 (EDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050805020504010504020301
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi Folks

I was looking at SCTP performance problem that is a result of
receive buffer exhaustion and found the we severely overcharge
the receive buffer when multiple data chunks are bundled together.
This bundling usually happens at retransmit time which penalizes us
even more.

Here is what happens.  For every "data" chunk that SCTP stack receives,
we clone skb of that data chunk, charge the receive buffer for the skb,
and put the chunk on the the socket receive queue (this is skipping a
few steps, but they don't matter for the sake of this discussion).  We
charge the receive buffer with the skb->truesize.

The problem shows up when multiple data chunks are "bundled" into the
same skb.  We end up with multiple clones, and for each clone we charge
skb->truesize against the receive buffer.  However, since skb_clone()
preservers the original truesize in all clones, we end up overcharging.

One of the proposed solutions is change the skb->truesize of the clone
to just be sizeof(struct sk_buff), if and only if this is not the first
data chunk in the packet.

I've attached the patch, in case people want to look at the code.

However, we question if this is a good idea or if this is going to break
things...

Thanks
-vlad

--------------050805020504010504020301
Content-Type: text/plain;
 name="p"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p"

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5b5ae79..9bb1dbd 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5349,7 +5349,7 @@ static int sctp_eat_data(const struct sc
 	if (SCTP_CMD_CHUNK_ULP == deliver)
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
 
-	chunk->data_accepted = 1;
+	chunk->data_accepted++;
 
 	/* Note: Some chunks may get overcounted (if we drop) or overcounted
 	 * if we renege and the chunk arrives again.
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index ee23678..0e1f11d 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -685,6 +685,17 @@ struct sctp_ulpevent *sctp_ulpevent_make
 	/* Initialize event with flags 0.  */
 	sctp_ulpevent_init(event, 0);
 
+	/* Check to see if we need to fixup the truesize of the clone.
+	 * We are about to charge the receive buffer for this chunk,
+	 * and we always use skb->truesize.  However, this doesn't work
+	 * for bundled data chunks since we'll drastically overcharge.
+	 * To get around that, keep the oiginal truesize on the clone
+	 * only for the first data chunk, and update truesize for the clone
+	 * on subsequent ones.
+	 */
+	if (chunk->data_accepted > 1)
+		skb->truesize = sizeof(struct skb);
+
 	sctp_ulpevent_receive_data(event, asoc);
 
 	event->stream = ntohs(chunk->subh.data_hdr->stream);

--------------050805020504010504020301--
