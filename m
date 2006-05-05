From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/4] [SCTP]: Prevent possible infinite recursion with
	multiple bundled DATA.
Date: Fri, 05 May 2006 12:14:38 -0700
Message-ID: <1146856478.7861.34.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:9687 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751207AbWEETOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 15:14:38 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k45JEbGo031147
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k45JEbP0254190
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k45JEbc6001583
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 15:14:37 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Prevent possible infinite recursion with multiple bundled DATA.

There is a rare situation that causes lksctp to go into infinite recursion
and crash the system.  The trigger is a packet that contains at least the
first two DATA fragments of a message bundled together. The recursion is
triggered when the user data buffer is smaller that the full data message.
The problem is that we clone the skb for every fragment in the message.
When reassembling the full message, we try to link skbs from the "first
fragment" clone using the frag_list. However, since the frag_list is shared
between two clones in this rare situation, we end up setting the frag_list
pointer of the second fragment to point to itself.  This causes
sctp_skb_pull() to potentially recurse indefinitely.

Proposed solution is to make a copy of the skb when attempting to link
things using frag_list.

Signed-off-by: Vladislav Yasevich <vladsilav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/sctp/ulpqueue.c |   27 +++++++++++++++++++++++++--
 1 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 2080b2d..9505c88 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -279,6 +279,7 @@ static inline void sctp_ulpq_store_reasm
 static struct sctp_ulpevent *sctp_make_reassembled_event(struct sk_buff_head *queue, struct sk_buff *f_frag, struct sk_buff *l_frag)
 {
 	struct sk_buff *pos;
+	struct sk_buff *new = NULL;
 	struct sctp_ulpevent *event;
 	struct sk_buff *pnext, *last;
 	struct sk_buff *list = skb_shinfo(f_frag)->frag_list;
@@ -297,11 +298,33 @@ static struct sctp_ulpevent *sctp_make_r
 	 */
 	if (last)
 		last->next = pos;
-	else
-		skb_shinfo(f_frag)->frag_list = pos;
+ 	else {
+ 		if (skb_cloned(f_frag)) {
+ 			/* This is a cloned skb, we can't just modify
+ 			 * the frag_list.  We need a new skb to do that.
+ 			 * Instead of calling skb_unshare(), we'll do it
+ 			 * ourselves since we need to delay the free.
+ 			 */
+ 			new = skb_copy(f_frag, GFP_ATOMIC);
+ 			if (!new)
+ 				return NULL;	/* try again later */
+ 
+ 			new->sk = f_frag->sk;
+ 
+ 			skb_shinfo(new)->frag_list = pos;
+ 		} else
+ 			skb_shinfo(f_frag)->frag_list = pos;
+ 	}
 
 	/* Remove the first fragment from the reassembly queue.  */
 	__skb_unlink(f_frag, queue);
+ 
+ 	/* if we did unshare, then free the old skb and re-assign */
+ 	if (new) {
+ 		kfree_skb(f_frag);
+ 		f_frag = new;
+ 	}
+ 
 	while (pos) {
 
 		pnext = pos->next;


