From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 1/5] sctp: move sent_count to the memory hole in sctp_chunk
Date: Wed, 28 Sep 2016 18:46:28 +0800
Message-ID: <03a642a76d02e8536404aa27561c44e348f3e3a0.1475059350.git.lucien.xin@gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34907 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752948AbcI1Kqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:46:44 -0400
In-Reply-To: <cover.1475059350.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1475059350.git.lucien.xin@gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now pahole sctp_chunk, it has 2 memory holes:
   struct sctp_chunk {
	struct list_head           list;
	atomic_t                   refcnt;
	/* XXX 4 bytes hole, try to pack */
	...
	long unsigned int          prsctp_param;
	int                        sent_count;
	/* XXX 4 bytes hole, try to pack */

This patch is to move up sent_count to fill the 1st one and eliminate
the 2nd one.

It's not just another struct compaction, it also fixes the "netperf-
Throughput_Mbps -37.2% regression" issue when overloading the CPU.

Fixes: a6c2f792873a ("sctp: implement prsctp TTL policy")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ce93c4b..4f097f5 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -554,6 +554,9 @@ struct sctp_chunk {
 
 	atomic_t refcnt;
 
+	/* How many times this chunk have been sent, for prsctp RTX policy */
+	int sent_count;
+
 	/* This is our link to the per-transport transmitted list.  */
 	struct list_head transmitted_list;
 
@@ -610,9 +613,6 @@ struct sctp_chunk {
 	 */
 	unsigned long prsctp_param;
 
-	/* How many times this chunk have been sent, for prsctp RTX policy */
-	int sent_count;
-
 	/* Which association does this belong to?  */
 	struct sctp_association *asoc;
 
-- 
2.1.0
