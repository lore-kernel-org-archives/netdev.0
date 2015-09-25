From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] f_bpf: allow for optional classid and add flags
Date: Fri, 25 Sep 2015 12:32:41 +0200
Message-ID: <efad6a0f1fc08df554d5b0d0b36fb3dde4afe131.1443176477.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50334 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbIYKcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 06:32:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When having optional classid, most minimal command can be sth
like:

  tc filter add dev foo parent X: bpf obj prog.o

Therefore, adapt the code so that a next argument will not be
enforced as the case currently.

Also, minor cleanup on the classid, where we should rather
have used addattr32(), and add flags for exec configuration,
for example (using short notation):

  tc filter add dev foo parent X: bpf da obj prog.o

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/utils.h |  1 +
 tc/f_bpf.c      | 43 ++++++++++++++++++++++++++++++-------------
 2 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index f77edeb..668d159 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -47,6 +47,7 @@ void incomplete_command(void) __attribute__((noreturn));
 
 #define NEXT_ARG() do { argv++; if (--argc <= 0) incomplete_command(); } while(0)
 #define NEXT_ARG_OK() (argc - 1 > 0)
+#define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
 #define PREV_ARG() do { argv--; argc++; } while(0)
 
 typedef struct
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 490dc6b..ac77af5 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -41,7 +41,7 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "eBPF use case:\n");
 	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]");
-	fprintf(stderr, " [ verbose ]\n");
+	fprintf(stderr, " [ verbose ] [ direct-action ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Common remaining options:\n");
 	fprintf(stderr, " [ action ACTION_SPEC ]\n");
@@ -69,6 +69,7 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 	struct tcmsg *t = NLMSG_DATA(n);
 	const char *bpf_uds_name = NULL;
 	const char *bpf_sec_name = NULL;
+	unsigned int bpf_flags = 0;
 	char *bpf_obj = NULL;
 	struct rtattr *tail;
 	bool seen_run = false;
@@ -124,25 +125,28 @@ opt_bpf:
 			if (ebpf) {
 				bpf_uds_name = getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
-				NEXT_ARG();
 
-				if (strcmp(*argv, "section") == 0 ||
-				    strcmp(*argv, "sec") == 0) {
+				NEXT_ARG_FWD();
+
+				if (argc > 0 &&
+				    (strcmp(*argv, "section") == 0 ||
+				     strcmp(*argv, "sec") == 0)) {
 					NEXT_ARG();
 					bpf_sec_name = *argv;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
-				if (!bpf_uds_name &&
+				if (argc > 0 && !bpf_uds_name &&
 				    (strcmp(*argv, "export") == 0 ||
 				     strcmp(*argv, "exp") == 0)) {
 					NEXT_ARG();
 					bpf_uds_name = *argv;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
-				if (strcmp(*argv, "verbose") == 0 ||
-				    strcmp(*argv, "verb") == 0) {
+				if (argc > 0 &&
+				    (strcmp(*argv, "verbose") == 0 ||
+				     strcmp(*argv, "verb") == 0)) {
 					bpf_verbose = true;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
 
 				PREV_ARG();
@@ -182,7 +186,10 @@ opt_bpf:
 				fprintf(stderr, "Illegal \"classid\"\n");
 				return -1;
 			}
-			addattr_l(n, MAX_MSG, TCA_BPF_CLASSID, &handle, 4);
+			addattr32(n, MAX_MSG, TCA_BPF_CLASSID, handle);
+		} else if (matches(*argv, "direct-action") == 0 ||
+			   matches(*argv, "da") == 0) {
+			bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_BPF_ACT, n)) {
@@ -208,10 +215,13 @@ opt_bpf:
 			explain();
 			return -1;
 		}
-		argc--;
-		argv++;
+
+		NEXT_ARG_FWD();
 	}
 
+	if (bpf_obj && bpf_flags)
+		addattr32(n, MAX_MSG, TCA_BPF_FLAGS, bpf_flags);
+
 	tail->rta_len = (((void *)n) + n->nlmsg_len) - (void *)tail;
 
 	if (bpf_uds_name)
@@ -244,6 +254,13 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 	else if (tb[TCA_BPF_FD])
 		fprintf(f, "pfd %u ", rta_getattr_u32(tb[TCA_BPF_FD]));
 
+	if (tb[TCA_BPF_FLAGS]) {
+		unsigned int flags = rta_getattr_u32(tb[TCA_BPF_FLAGS]);
+
+		if (flags & TCA_BPF_FLAG_ACT_DIRECT)
+			fprintf(f, "direct-action ");
+	}
+
 	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN]) {
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
-- 
1.9.3
