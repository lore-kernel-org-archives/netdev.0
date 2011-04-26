From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] iproute2: improve mqprio inputs for queue offsets and counts
Date: Tue, 26 Apr 2011 12:44:42 -0700
Message-ID: <20110426194441.23726.23489.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60304 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757156Ab1DZTu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 15:50:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes mqprio input format to be more user friendly.

Old usage,

# ./tc/tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1...]
                  [offset txq0 txq1 ...] [count cnt0 cnt1 ...] [hw 1|0]

New uage,

# ./tc/tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
                  [queues count1@offset1 count2@offset2 ...] [hw 1|0]

Suggested-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 tc/q_mqprio.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/tc/q_mqprio.c b/tc/q_mqprio.c
index c589b4c..bf734a0 100644
--- a/tc/q_mqprio.c
+++ b/tc/q_mqprio.c
@@ -25,8 +25,8 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]\n");
-	fprintf(stderr, "                  [offset txq0 txq1 ...] ");
-	fprintf(stderr, "[count cnt0,cnt1 ...] [hw 1|0]\n");
+	fprintf(stderr, "                  [queues count1@offset1 count2@offset2 ...] ");
+	fprintf(stderr, "[hw 1|0]\n");
 }
 
 static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
@@ -58,22 +58,29 @@ static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
 			}
 			for ( ; idx < TC_QOPT_MAX_QUEUE; idx++)
 				opt.prio_tc_map[idx] = 0;
-		} else if (strcmp(*argv, "offset") == 0) {
+		} else if (strcmp(*argv, "queues") == 0) {
+			char *tmp, *tok;
+
 			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
 				NEXT_ARG();
-				if (get_u16(&opt.offset[idx], *argv, 10)) {
+
+				tmp = strdup(*argv);
+				if (!tmp)
+					break;
+
+				tok = strtok(tmp, "@");
+				if (get_u16(&opt.count[idx], tok, 10)) {
+					free(tmp);
 					PREV_ARG();
 					break;
 				}
-				idx++;
-			}
-		} else if (strcmp(*argv, "count") == 0) {
-			while (idx < TC_QOPT_MAX_QUEUE && NEXT_ARG_OK()) {
-				NEXT_ARG();
-				if (get_u16(&opt.count[idx], *argv, 10)) {
+				tok = strtok(NULL, "@");
+				if (get_u16(&opt.offset[idx], tok, 10)) {
+					free(tmp);
 					PREV_ARG();
 					break;
 				}
+				free(tmp);
 				idx++;
 			}
 		} else if (strcmp(*argv, "hw") == 0) {

