From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/5] bpf: allow to specify log level and reduce it for test_verifier
Date: Fri, 21 Jul 2017 00:00:22 +0200
Message-ID: <f06ddbde1b38574eb6d79edc24c0f80e566fca63.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Cc: ast@fb.com, ecree@solarflare.com, josef@toxicpanda.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45851 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936279AbdGTWEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:04:05 -0400
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500586732.git.daniel@iogearbox.net>
References: <cover.1500586732.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the test_verifier case, it's quite hard to parse log level 2 to
figure out what's causing an issue when used to log level 1. We do
want to use bpf_verify_program() in order to simulate some of the
tests with strict alignment. So just add an argument to pass the level
and put it to 1 for test_verifier.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/lib/bpf/bpf.c                         | 4 ++--
 tools/lib/bpf/bpf.h                         | 2 +-
 tools/testing/selftests/bpf/test_align.c    | 2 +-
 tools/testing/selftests/bpf/test_verifier.c | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 7e0405e..412a7c8 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -120,7 +120,7 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		       size_t insns_cnt, int strict_alignment,
 		       const char *license, __u32 kern_version,
-		       char *log_buf, size_t log_buf_sz)
+		       char *log_buf, size_t log_buf_sz, int log_level)
 {
 	union bpf_attr attr;
 
@@ -131,7 +131,7 @@ int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	attr.license = ptr_to_u64(license);
 	attr.log_buf = ptr_to_u64(log_buf);
 	attr.log_size = log_buf_sz;
-	attr.log_level = 2;
+	attr.log_level = log_level;
 	log_buf[0] = 0;
 	attr.kern_version = kern_version;
 	attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 16de44a..418c86e 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -38,7 +38,7 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		       size_t insns_cnt, int strict_alignment,
 		       const char *license, __u32 kern_version,
-		       char *log_buf, size_t log_buf_sz);
+		       char *log_buf, size_t log_buf_sz, int log_level);
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index bccebd9..2979369 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -380,7 +380,7 @@ static int do_test_single(struct bpf_align_test *test)
 	prog_len = probe_filter_length(prog);
 	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				     prog, prog_len, 1, "GPL", 0,
-				     bpf_vlog, sizeof(bpf_vlog));
+				     bpf_vlog, sizeof(bpf_vlog), 2);
 	if (fd_prog < 0) {
 		printf("Failed to load program.\n");
 		printf("%s", bpf_vlog);
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 404aec5..f4d0a1d 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5633,7 +5633,7 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				     prog, prog_len, test->flags & F_LOAD_WITH_STRICT_ALIGNMENT,
-				     "GPL", 0, bpf_vlog, sizeof(bpf_vlog));
+				     "GPL", 0, bpf_vlog, sizeof(bpf_vlog), 1);
 
 	expected_ret = unpriv && test->result_unpriv != UNDEF ?
 		       test->result_unpriv : test->result;
-- 
1.9.3
