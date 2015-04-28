From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master] tc: {m,f}_ebpf: add option for dumping verifier log
Date: Tue, 28 Apr 2015 13:37:42 +0200
Message-ID: <b312101ba95af54ffd2f4c56694c0b44ccbfa051.1430220466.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38011 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965554AbbD1Lhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 07:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, only on error we get a log dump, but I found it useful when
working with eBPF to have an option to also dump the log on success.
Also spotted a typo in a header comment, which is fixed here as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 tc/f_bpf.c  | 14 +++++++++++---
 tc/m_bpf.c  | 16 ++++++++++++----
 tc/tc_bpf.c | 19 ++++++++++++++-----
 tc/tc_bpf.h |  4 ++--
 4 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 11d6db0..597ef60 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -40,7 +40,8 @@ static void explain(void)
 	fprintf(stderr, " bytecode-file FILE\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "eBPF use case:\n");
-	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]\n");
+	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]");
+	fprintf(stderr, " [ verbose ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Common remaining options:\n");
 	fprintf(stderr, " [ action ACTION_SPEC ]\n");
@@ -94,12 +95,13 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
 			struct sock_filter bpf_ops[BPF_MAXINSNS];
-			bool from_file, ebpf;
+			bool from_file, ebpf, bpf_verbose;
 			int ret;
 
 			NEXT_ARG();
 opt_bpf:
 			bpf_sec_name = bpf_default_section(bpf_type);
+			bpf_verbose = false;
 			ebpf = false;
 			seen_run = true;
 
@@ -135,11 +137,17 @@ opt_bpf:
 					bpf_uds_name = *argv;
 					NEXT_ARG();
 				}
+				if (strcmp(*argv, "verbose") == 0 ||
+				    strcmp(*argv, "verb") == 0) {
+					bpf_verbose = true;
+					NEXT_ARG();
+				}
 
 				PREV_ARG();
 			}
 
-			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name) :
+			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name,
+						     bpf_verbose) :
 				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
 			if (ret < 0) {
 				fprintf(stderr, "%s\n", ebpf ?
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 16468f2..0621157 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -1,5 +1,5 @@
 /*
- * m_bpf.c	BFP based action module
+ * m_bpf.c	BPF based action module
  *
  *              This program is free software; you can redistribute it and/or
  *              modify it under the terms of the GNU General Public License
@@ -35,7 +35,8 @@ static void explain(void)
 	fprintf(stderr, " bytecode-file FILE\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "eBPF use case:\n");
-	fprintf(stderr, " object-file FILE [ section ACT_NAME ] [ export UDS_FILE ]\n");
+	fprintf(stderr, " object-file FILE [ section ACT_NAME ] [ export UDS_FILE ]");
+	fprintf(stderr, " [ verbose ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
 	fprintf(stderr, "c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
@@ -78,12 +79,13 @@ static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
-			bool from_file;
+			bool from_file, bpf_verbose;
 			int ret;
 
 			NEXT_ARG();
 opt_bpf:
 			bpf_sec_name = bpf_default_section(bpf_type);
+			bpf_verbose = false;
 			seen_run = true;
 
 			if (strcmp(*argv, "bytecode-file") == 0 ||
@@ -118,11 +120,17 @@ opt_bpf:
 					bpf_uds_name = *argv;
 					NEXT_ARG();
 				}
+				if (strcmp(*argv, "verbose") == 0 ||
+				    strcmp(*argv, "verb") == 0) {
+					bpf_verbose = true;
+					NEXT_ARG();
+				}
 
 				PREV_ARG();
 			}
 
-			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name) :
+			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name,
+						     bpf_verbose) :
 				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
 			if (ret < 0) {
 				fprintf(stderr, "%s\n", ebpf ?
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 7c282aa..7a8b602 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -192,6 +192,7 @@ struct bpf_map_data {
  * verifier we still want to hand something descriptive to the user.
  */
 static char bpf_log_buf[65536];
+static bool bpf_verbose;
 
 static struct bpf_elf_st bpf_st;
 
@@ -207,8 +208,10 @@ static void bpf_dump_error(const char *format, ...)
 	vfprintf(stderr, format, vl);
 	va_end(vl);
 
-	fprintf(stderr, "%s\n", bpf_log_buf);
-	memset(bpf_log_buf, 0, sizeof(bpf_log_buf));
+	if (bpf_log_buf[0]) {
+		fprintf(stderr, "%s\n", bpf_log_buf);
+		memset(bpf_log_buf, 0, sizeof(bpf_log_buf));
+	}
 }
 
 static void bpf_save_finfo(int file_fd)
@@ -284,8 +287,11 @@ static int bpf_prog_attach(enum bpf_prog_type type, const struct bpf_insn *insns
 {
 	int prog_fd = bpf_prog_load(type, insns, size, license);
 
-	if (prog_fd < 0)
-		bpf_dump_error("BPF program rejected: %s\n", strerror(errno));
+	if (prog_fd < 0 || bpf_verbose) {
+		bpf_dump_error("%s: %s\n", prog_fd < 0 ?
+			       "BPF program rejected" :
+			       "BPF program verification", strerror(errno));
+	}
 
 	return prog_fd;
 }
@@ -555,7 +561,8 @@ static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 	return prog_fd;
 }
 
-int bpf_open_object(const char *path, enum bpf_prog_type type, const char *sec)
+int bpf_open_object(const char *path, enum bpf_prog_type type,
+		    const char *sec, bool verbose)
 {
 	char license[ELF_MAX_LICENSE_LEN];
 	int file_fd, prog_fd = -1, ret;
@@ -589,6 +596,8 @@ int bpf_open_object(const char *path, enum bpf_prog_type type, const char *sec)
 	}
 
 	memset(license, 0, sizeof(license));
+	bpf_verbose = verbose;
+
 	if (!bpf_may_skip_map_creation(file_fd))
 		bpf_maps_init();
 
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 4a239aa..5a697e5 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -36,7 +36,7 @@ const char *bpf_default_section(const enum bpf_prog_type type);
 
 #ifdef HAVE_ELF
 int bpf_open_object(const char *path, enum bpf_prog_type type,
-		    const char *sec);
+		    const char *sec, bool verbose);
 
 int bpf_send_map_fds(const char *path, const char *obj);
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
@@ -59,7 +59,7 @@ static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 }
 #else
 static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
-				  const char *sec)
+				  const char *sec, bool verbose)
 {
 	fprintf(stderr, "No ELF library support compiled in.\n");
 	errno = ENOSYS;
-- 
1.9.3
