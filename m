From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RESEND PATCH iproute2] tc: fix compilation with old gcc (< 4.6) (bis)
Date: Wed,  3 Feb 2016 09:25:00 +0100
Message-ID: <1454487900-20175-1-git-send-email-nicolas.dichtel@6wind.com>
References: <56B08760.7040204@6wind.com>
Cc: netdev@vger.kernel.org, julien.floret@6wind.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:40271 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbcBCIZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:25:25 -0500
In-Reply-To: <56B08760.7040204@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") was reverted
to ease the merge of the net-next branch.

Here is the new version.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 58 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 33 insertions(+), 25 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 42c8841869f5..219ffa582c1a 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -49,6 +49,10 @@
 #include "tc_util.h"
 #include "tc_bpf.h"
 
+#ifndef AF_ALG
+#define AF_ALG 38
+#endif
+
 #ifdef HAVE_ELF
 static int bpf_obj_open(const char *path, enum bpf_prog_type type,
 			const char *sec, bool verbose);
@@ -81,12 +85,13 @@ static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 static int bpf_map_update(int fd, const void *key, const void *value,
 			  uint64_t flags)
 {
-	union bpf_attr attr = {
-		.map_fd		= fd,
-		.key		= bpf_ptr_to_u64(key),
-		.value		= bpf_ptr_to_u64(value),
-		.flags		= flags,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+	attr.value = bpf_ptr_to_u64(value);
+	attr.flags = flags;
 
 	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
@@ -745,12 +750,13 @@ static __check_format_string(1, 2) void bpf_dump_error(const char *format, ...)
 static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 			  unsigned int size_value, unsigned int max_elem)
 {
-	union bpf_attr attr = {
-		.map_type	= type,
-		.key_size	= size_key,
-		.value_size	= size_value,
-		.max_entries	= max_elem,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.map_type = type;
+	attr.key_size = size_key;
+	attr.value_size = size_value;
+	attr.max_entries = max_elem;
 
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
@@ -758,15 +764,16 @@ static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 			 size_t size, const char *license)
 {
-	union bpf_attr attr = {
-		.prog_type	= type,
-		.insns		= bpf_ptr_to_u64(insns),
-		.insn_cnt	= size / sizeof(struct bpf_insn),
-		.license	= bpf_ptr_to_u64(license),
-		.log_buf	= bpf_ptr_to_u64(bpf_log_buf),
-		.log_size	= sizeof(bpf_log_buf),
-		.log_level	= 1,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.prog_type = type;
+	attr.insns = bpf_ptr_to_u64(insns);
+	attr.insn_cnt = size / sizeof(struct bpf_insn);
+	attr.license = bpf_ptr_to_u64(license);
+	attr.log_buf = bpf_ptr_to_u64(bpf_log_buf);
+	attr.log_size = sizeof(bpf_log_buf);
+	attr.log_level = 1;
 
 	if (getenv(BPF_ENV_NOLOG)) {
 		attr.log_buf	= 0;
@@ -779,10 +786,11 @@ static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 
 static int bpf_obj_pin(int fd, const char *pathname)
 {
-	union bpf_attr attr = {
-		.pathname	= bpf_ptr_to_u64(pathname),
-		.bpf_fd		= fd,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.pathname = bpf_ptr_to_u64(pathname);
+	attr.bpf_fd = fd;
 
 	return bpf(BPF_OBJ_PIN, &attr, sizeof(attr));
 }
-- 
2.4.2
