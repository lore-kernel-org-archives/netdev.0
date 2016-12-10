From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 2/8] bpf: export bpf_prog_load
Date: Sat, 10 Dec 2016 09:47:43 -0800
Message-ID: <1481392069-3138-3-git-send-email-dsa@cumulusnetworks.com>
References: <1481392069-3138-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33133 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752727AbcLJRr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 12:47:58 -0500
Received: by mail-pg0-f46.google.com with SMTP id 3so19380486pgd.0
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 09:47:57 -0800 (PST)
In-Reply-To: <1481392069-3138-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move only; no functional change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/bpf_util.h |  3 +++
 lib/bpf.c          | 40 ++++++++++++++++++++--------------------
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 49b96bbc208f..dcbdca6978d6 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -75,6 +75,9 @@ int bpf_trace_pipe(void);
 
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
+int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
+		  size_t size_insns, const char *license, char *log,
+		  size_t size_log);
 int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type);
 int bpf_prog_detach(int target_fd, enum bpf_attach_type type);
 
diff --git a/lib/bpf.c b/lib/bpf.c
index 103fc1ef0593..b04c3a678b9c 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -871,6 +871,26 @@ int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 	return bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
 }
 
+int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
+		  size_t size_insns, const char *license, char *log,
+		  size_t size_log)
+{
+	union bpf_attr attr = {};
+
+	attr.prog_type = type;
+	attr.insns = bpf_ptr_to_u64(insns);
+	attr.insn_cnt = size_insns / sizeof(struct bpf_insn);
+	attr.license = bpf_ptr_to_u64(license);
+
+	if (size_log > 0) {
+		attr.log_buf = bpf_ptr_to_u64(log);
+		attr.log_size = size_log;
+		attr.log_level = 1;
+	}
+
+	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
 #ifdef HAVE_ELF
 struct bpf_elf_prog {
 	enum bpf_prog_type	type;
@@ -988,26 +1008,6 @@ static int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
-			 size_t size_insns, const char *license, char *log,
-			 size_t size_log)
-{
-	union bpf_attr attr = {};
-
-	attr.prog_type = type;
-	attr.insns = bpf_ptr_to_u64(insns);
-	attr.insn_cnt = size_insns / sizeof(struct bpf_insn);
-	attr.license = bpf_ptr_to_u64(license);
-
-	if (size_log > 0) {
-		attr.log_buf = bpf_ptr_to_u64(log);
-		attr.log_size = size_log;
-		attr.log_level = 1;
-	}
-
-	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
-}
-
 static int bpf_obj_pin(int fd, const char *pathname)
 {
 	union bpf_attr attr = {};
-- 
2.1.4
