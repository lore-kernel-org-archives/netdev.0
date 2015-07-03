From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Fix incorrect sequence numbers shown in devlog
Date: Fri,  3 Jul 2015 16:10:51 +0530
Message-ID: <1435920051-6756-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4362 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753874AbbGCF1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 01:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of commit 49aa284fe64c4c1 ("cxgb4: Add support for devlog")
change introduced a real bug where the Device Log Sequence Numbers are
no longer being converted from firmware Big-Endian to local CPU-Endian
format.

This patch moves all of the translation into the devlog_show() routine.
The only endianness code now in devlog_open() is the small loop to find the
earliest (lowest Sequence Number) Device Log entry in the circular buffer.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 25 +++++++++++-----------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 484eb8c..a11485f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -952,16 +952,23 @@ static int devlog_show(struct seq_file *seq, void *v)
 		 * eventually have to put a format interpreter in here ...
 		 */
 		seq_printf(seq, "%10d  %15llu  %8s  %8s  ",
-			   e->seqno, e->timestamp,
+			   be32_to_cpu(e->seqno),
+			   be64_to_cpu(e->timestamp),
 			   (e->level < ARRAY_SIZE(devlog_level_strings)
 			    ? devlog_level_strings[e->level]
 			    : "UNKNOWN"),
 			   (e->facility < ARRAY_SIZE(devlog_facility_strings)
 			    ? devlog_facility_strings[e->facility]
 			    : "UNKNOWN"));
-		seq_printf(seq, e->fmt, e->params[0], e->params[1],
-			   e->params[2], e->params[3], e->params[4],
-			   e->params[5], e->params[6], e->params[7]);
+		seq_printf(seq, e->fmt,
+			   be32_to_cpu(e->params[0]),
+			   be32_to_cpu(e->params[1]),
+			   be32_to_cpu(e->params[2]),
+			   be32_to_cpu(e->params[3]),
+			   be32_to_cpu(e->params[4]),
+			   be32_to_cpu(e->params[5]),
+			   be32_to_cpu(e->params[6]),
+			   be32_to_cpu(e->params[7]));
 	}
 	return 0;
 }
@@ -1043,23 +1050,17 @@ static int devlog_open(struct inode *inode, struct file *file)
 		return ret;
 	}
 
-	/* Translate log multi-byte integral elements into host native format
-	 * and determine where the first entry in the log is.
+	/* Find the earliest (lowest Sequence Number) log entry in the
+	 * circular Device Log.
 	 */
 	for (fseqno = ~((u32)0), index = 0; index < dinfo->nentries; index++) {
 		struct fw_devlog_e *e = &dinfo->log[index];
-		int i;
 		__u32 seqno;
 
 		if (e->timestamp == 0)
 			continue;
 
-		e->timestamp = (__force __be64)be64_to_cpu(e->timestamp);
 		seqno = be32_to_cpu(e->seqno);
-		for (i = 0; i < 8; i++)
-			e->params[i] =
-				(__force __be32)be32_to_cpu(e->params[i]);
-
 		if (seqno < fseqno) {
 			fseqno = seqno;
 			dinfo->first = index;
-- 
2.3.4
