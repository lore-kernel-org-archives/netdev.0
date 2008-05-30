From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 09/13 net-next-2.6] [TIPC]: Add missing spinlock in name table display code
Date: Fri, 30 May 2008 14:20:44 -0400
Message-ID: <1212171648-27122-10-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50549 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbYE3SXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:11 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that the display code that traverses the
publication lists belonging to a name table entry take its
associated spinlock, to protect against a possible change to
one of its "head of list" pointers caused by a simultaneous
name table lookup operation by another thread of control.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_table.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 4455f13..096f7bd 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -74,7 +74,7 @@ struct sub_seq {
  * @first_free: array index of first unused sub-sequence entry
  * @ns_list: links to adjacent name sequences in hash chain
  * @subscriptions: list of subscriptions for this 'type'
- * @lock: spinlock controlling access to name sequence structure
+ * @lock: spinlock controlling access to publication lists of all sub-sequences
  */
 
 struct name_seq {
@@ -918,7 +918,9 @@ static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 	for (sseq = seq->sseqs; sseq != &seq->sseqs[seq->first_free]; sseq++) {
 		if ((lowbound <= sseq->upper) && (upbound >= sseq->lower)) {
 			tipc_printf(buf, "%s ", typearea);
+			spin_lock_bh(&seq->lock);
 			subseq_list(sseq, buf, depth, index);
+			spin_unlock_bh(&seq->lock);
 			sprintf(typearea, "%10s", " ");
 		}
 	}
-- 
1.5.3.2

