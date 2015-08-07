From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] m_bpf: add frontend support for late binding
Date: Fri,  7 Aug 2015 11:36:50 +0200
Message-ID: <6a0435db24466adf0c0f85165e69e98a91183676.1438939738.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44138 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbbHGJg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 05:36:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frontend support for kernel commit a5c90b29e5cc ("act_bpf: properly
support late binding of bpf action to a classifier").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/m_bpf.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index c51f44f..e1bb6a4 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -28,7 +28,7 @@ static const enum bpf_prog_type bpf_type = BPF_PROG_TYPE_SCHED_ACT;
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... bpf ...\n");
+	fprintf(stderr, "Usage: ... bpf ... [ index INDEX ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "BPF use case:\n");
 	fprintf(stderr, " bytecode BPF_BYTECODE\n");
@@ -49,6 +49,9 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where UDS_FILE points to a unix domain socket file in order\n");
 	fprintf(stderr, "to hand off control of all created eBPF maps to an agent.\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where optionally INDEX points to an existing action, or\n");
+	fprintf(stderr, "explicitly specifies an action index upon creation.\n");
 }
 
 static void usage(void)
@@ -64,6 +67,7 @@ static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 	struct rtattr *tail;
 	struct tc_act_bpf parm = { 0 };
 	struct sock_filter bpf_ops[BPF_MAXINSNS];
+	bool ebpf_fill = false, bpf_fill = false;
 	bool ebpf = false, seen_run = false;
 	const char *bpf_uds_name = NULL;
 	const char *bpf_sec_name = NULL;
@@ -148,11 +152,15 @@ opt_bpf:
 					 bpf_obj, bpf_sec_name);
 
 				bpf_fd = ret;
+				ebpf_fill = true;
 			} else {
 				bpf_len = ret;
+				bpf_fill = true;
 			}
 		} else if (matches(*argv, "help") == 0) {
 			usage();
+		} else if (matches(*argv, "index") == 0) {
+			break;
 		} else {
 			if (!seen_run)
 				goto opt_bpf;
@@ -200,21 +208,15 @@ opt_bpf:
 		}
 	}
 
-	if ((!bpf_len && !ebpf) || (!bpf_fd && ebpf)) {
-		fprintf(stderr, "bpf: Bytecode needs to be passed\n");
-		explain();
-		return -1;
-	}
-
 	tail = NLMSG_TAIL(n);
 
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_ACT_BPF_PARMS, &parm, sizeof(parm));
 
-	if (ebpf) {
+	if (ebpf_fill) {
 		addattr32(n, MAX_MSG, TCA_ACT_BPF_FD, bpf_fd);
 		addattrstrz(n, MAX_MSG, TCA_ACT_BPF_NAME, bpf_name);
-	} else {
+	} else if (bpf_fill) {
 		addattr16(n, MAX_MSG, TCA_ACT_BPF_OPS_LEN, bpf_len);
 		addattr_l(n, MAX_MSG, TCA_ACT_BPF_OPS, &bpf_ops,
 			  bpf_len * sizeof(struct sock_filter));
-- 
1.9.3
