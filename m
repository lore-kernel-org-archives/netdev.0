From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: SCTP: Fix dead loop while received unexpected chunk with length set
 to zero
Date: Mon, 27 Aug 2007 09:06:40 +0800
Message-ID: <46D223A0.3080604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:65172 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbXH0BId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2007 21:08:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A ootb chunk such as data in close state or init-ack in estab state will 
cause SCTP to enter dead loop. Look like this:

(1)
  Endpoint A                      Endpoint B
  (Closed)                        (Closed)

  DATA      ----------------->   Kernel dead loop
  (With Length set to zero)

(2)
  Endpoint A                      Endpoint B
  (Established)                   (Established)

  INIT-ACK   ----------------->   Kernel dead loop
  (With Length set to zero)


This is beacuse when process chunks, chunk->chunk_end is set to the 
chunk->chunk_hdr plus chunk length, if chunk length is set to zero, 
chunk->chunk_end will be never changed and process enter dead loop.
Following is the patch.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/inqueue.c	2007-08-25 10:53:45.000000000 -0400
+++ b/net/sctp/inqueue.c	2007-08-26 05:45:57.000000000 -0400
@@ -165,10 +165,8 @@ struct sctp_chunk *sctp_inq_pop(struct s
 	skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
 	chunk->subh.v = NULL; /* Subheader is no longer valid.  */
 
-	if (chunk->chunk_end < skb_tail_pointer(chunk->skb)) {
-		/* This is not a singleton */
-		chunk->singleton = 0;
-	} else if (chunk->chunk_end > skb_tail_pointer(chunk->skb)) {
+	if (chunk->chunk_end > skb_tail_pointer(chunk->skb) ||
+	    chunk->chunk_end == chunk->chunk_hdr) {
 		/* RFC 2960, Section 6.10  Bundling
 		 *
 		 * Partial chunks MUST NOT be placed in an SCTP packet.
@@ -183,6 +181,9 @@ struct sctp_chunk *sctp_inq_pop(struct s
 		chunk = queue->in_progress = NULL;
 
 		return NULL;
+	} else if (chunk->chunk_end < skb_tail_pointer(chunk->skb)) {
+		/* This is not a singleton */
+		chunk->singleton = 0;
 	} else {
 		/* We are at the end of the packet, so mark the chunk
 		 * in case we need to send a SACK.


