From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] tipc: Use bsearch library function
Date: Sat,  9 Sep 2017 05:18:19 +0200
Message-ID: <20170909031819.13622-1-thomas@m3y3r.de>
Cc: Thomas Meyer <thomas@m3y3r.de>
To: jon.maloy@ericsson.com, ying.xue@windriver.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:41878 "EHLO
        www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdIKNJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 09:09:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common library function rather than explicitly coding
some variant of it yourself.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---
 net/tipc/name_table.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index bd0aac87b41a..345454106390 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -44,6 +44,7 @@
 #include "addr.h"
 #include "node.h"
 #include <net/genetlink.h>
+#include <linux/bsearch.h>
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
@@ -168,6 +169,18 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	return nseq;
 }
 
+static int nameseq_find_subseq_cmp(const void *key, const void *elt)
+{
+	u32 instance = *(u32 *)key;
+	struct sub_seq *sseq = (struct sub_seq *)elt;
+
+	if (instance < sseq->lower)
+		return -1;
+	else if (instance > sseq->upper)
+		return 1;
+	return 0;
+}
+
 /**
  * nameseq_find_subseq - find sub-sequence (if any) matching a name instance
  *
@@ -176,21 +189,8 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 static struct sub_seq *nameseq_find_subseq(struct name_seq *nseq,
 					   u32 instance)
 {
-	struct sub_seq *sseqs = nseq->sseqs;
-	int low = 0;
-	int high = nseq->first_free - 1;
-	int mid;
-
-	while (low <= high) {
-		mid = (low + high) / 2;
-		if (instance < sseqs[mid].lower)
-			high = mid - 1;
-		else if (instance > sseqs[mid].upper)
-			low = mid + 1;
-		else
-			return &sseqs[mid];
-	}
-	return NULL;
+	return bsearch(&instance, nseq->sseqs, nseq->first_free,
+		       sizeof(struct sub_seq), nameseq_find_subseq_cmp);
 }
 
 /**
-- 
2.11.0
