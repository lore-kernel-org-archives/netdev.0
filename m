From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/3] [SCTP] Do not include ABORT chunk header in the notification.
Date: Wed,  9 May 2007 15:43:50 -0400
Message-ID: <11787398302050-git-send-email-vladislav.yasevich@hp.com>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:58266 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123AbXEITnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 15:43:51 -0400
In-Reply-To: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The socket API draft is unclear about whether to include the
chunk header or not.  Recent discussion on the sctp implementors
mailing list clarified that the chunk header shouldn't be included,
but the error parameter header still needs to be there.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ulpevent.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 661ea2d..bfecb35 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -141,11 +141,6 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 	 * an ABORT, so we need to include it in the sac_info.
 	 */
 	if (chunk) {
-		/* sctp_inqu_pop() has allready pulled off the chunk
-		 * header.  We need to put it back temporarily
-		 */
-		skb_push(chunk->skb, sizeof(sctp_chunkhdr_t));
-
 		/* Copy the chunk data to a new skb and reserve enough
 		 * head room to use as notification.
 		 */
@@ -155,9 +150,6 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 		if (!skb)
 			goto fail;
 
-		/* put back the chunk header now that we have a copy */
-		skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
-
 		/* Embed the event fields inside the cloned skb.  */
 		event = sctp_skb2event(skb);
 		sctp_ulpevent_init(event, MSG_NOTIFICATION, skb->truesize);
@@ -168,7 +160,8 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 
 		/* Trim the buffer to the right length.  */
 		skb_trim(skb, sizeof(struct sctp_assoc_change) +
-			 ntohs(chunk->chunk_hdr->length));
+			 ntohs(chunk->chunk_hdr->length) -
+			 sizeof(sctp_chunkhdr_t));
 	} else {
 		event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
 				  MSG_NOTIFICATION, gfp);
-- 
1.5.0.3.438.gc49b2

