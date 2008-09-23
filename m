From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Make SCTP use SKB queue interfaces.
Date: Mon, 22 Sep 2008 22:18:25 -0700 (PDT)
Message-ID: <20080922.221825.245591874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751302AbYIWFSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:18:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 66977C8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 22:18:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of pretending that SKB lists are already using
struct list_head :-/

sctp: Use skb_queue_walk_safe() and skb_queue_split_tail_init().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sctp/sctp.h |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 17b932b..703305d 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -406,10 +406,7 @@ struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id);
 
 /* A macro to walk a list of skbs.  */
 #define sctp_skb_for_each(pos, head, tmp) \
-for (pos = (head)->next;\
-     tmp = (pos)->next, pos != ((struct sk_buff *)(head));\
-     pos = tmp)
-
+	skb_queue_walk_safe(head, pos, tmp)
 
 /* A helper to append an entire skb list (list) to another (head). */
 static inline void sctp_skb_list_tail(struct sk_buff_head *list,
@@ -420,10 +417,7 @@ static inline void sctp_skb_list_tail(struct sk_buff_head *list,
 	sctp_spin_lock_irqsave(&head->lock, flags);
 	sctp_spin_lock(&list->lock);
 
-	list_splice((struct list_head *)list, (struct list_head *)head->prev);
-
-	head->qlen += list->qlen;
-	list->qlen = 0;
+	skb_queue_splice_tail_init(list, head);
 
 	sctp_spin_unlock(&list->lock);
 	sctp_spin_unlock_irqrestore(&head->lock, flags);
-- 
1.5.6.5

