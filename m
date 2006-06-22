From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 2/32] [TIPC] Prevent name table corruption if no room for new publication
Date: Thu, 22 Jun 2006 15:59:15 +0200
Message-ID: <1150984785234-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:25238 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030641AbWFVN7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Now exits cleanly if attempt to allocate larger array of subsequences fails,
without losing track of pointer to existing array.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/name_table.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index d129422..0511436 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -284,18 +284,18 @@ static struct publication *tipc_nameseq_
 		/* Ensure there is space for new sub-sequence */
 
 		if (nseq->first_free == nseq->alloc) {
-			struct sub_seq *sseqs = nseq->sseqs;
-			nseq->sseqs = tipc_subseq_alloc(nseq->alloc * 2);
-			if (nseq->sseqs != NULL) {
-				memcpy(nseq->sseqs, sseqs,
-				       nseq->alloc * sizeof (struct sub_seq));
-				kfree(sseqs);
-				dbg("Allocated %u sseqs\n", nseq->alloc);
-				nseq->alloc *= 2;
-			} else {
+			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
+
+			if (!sseqs) {
 				warn("Memory squeeze; failed to create sub-sequence\n");
 				return NULL;
 			}
+			dbg("Allocated %u more sseqs\n", nseq->alloc);
+			memcpy(sseqs, nseq->sseqs,
+			       nseq->alloc * sizeof(struct sub_seq));
+			kfree(nseq->sseqs);
+			nseq->sseqs = sseqs;
+			nseq->alloc *= 2;
 		}
 		dbg("Have %u sseqs for type %u\n", nseq->alloc, type);
 
-- 
1.4.0

