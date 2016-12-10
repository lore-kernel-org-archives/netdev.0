From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 1/8] lib bpf: Add support for BPF_PROG_ATTACH and BPF_PROG_DETACH
Date: Sat, 10 Dec 2016 09:47:42 -0800
Message-ID: <1481392069-3138-2-git-send-email-dsa@cumulusnetworks.com>
References: <1481392069-3138-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33132 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcLJRr5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 12:47:57 -0500
Received: by mail-pg0-f45.google.com with SMTP id 3so19380428pgd.0
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 09:47:57 -0800 (PST)
In-Reply-To: <1481392069-3138-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For consistency with other bpf commands, the functions are named
bpf_prog_attach and bpf_prog_detach. The existing bpf_prog_attach is
renamed to bpf_prog_load_and_report since it calls bpf_prog_load and
bpf_prog_report.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/bpf_util.h |  3 +++
 lib/bpf.c          | 31 ++++++++++++++++++++++++++-----
 2 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 05baeecda57f..49b96bbc208f 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -75,6 +75,9 @@ int bpf_trace_pipe(void);
 
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type);
+int bpf_prog_detach(int target_fd, enum bpf_attach_type type);
+
 #ifdef HAVE_ELF
 int bpf_send_map_fds(const char *path, const char *obj);
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
diff --git a/lib/bpf.c b/lib/bpf.c
index 2a8cd51d4dae..103fc1ef0593 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -850,6 +850,27 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
 	return ret;
 }
 
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_bpf_fd = prog_fd,
+		.attach_type = type,
+	};
+
+	return bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
+}
+
+int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_type = type,
+	};
+
+	return bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
+}
+
 #ifdef HAVE_ELF
 struct bpf_elf_prog {
 	enum bpf_prog_type	type;
@@ -1262,9 +1283,9 @@ static void bpf_prog_report(int fd, const char *section,
 	bpf_dump_error(ctx, "Verifier analysis:\n\n");
 }
 
-static int bpf_prog_attach(const char *section,
-			   const struct bpf_elf_prog *prog,
-			   struct bpf_elf_ctx *ctx)
+static int bpf_prog_load_and_report(const char *section,
+				    const struct bpf_elf_prog *prog,
+				    struct bpf_elf_ctx *ctx)
 {
 	int tries = 0, fd;
 retry:
@@ -1656,7 +1677,7 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section,
 		prog.size    = data.sec_data->d_size;
 		prog.license = ctx->license;
 
-		fd = bpf_prog_attach(section, &prog, ctx);
+		fd = bpf_prog_load_and_report(section, &prog, ctx);
 		if (fd < 0)
 			return fd;
 
@@ -1755,7 +1776,7 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
 		prog.size    = data_insn.sec_data->d_size;
 		prog.license = ctx->license;
 
-		fd = bpf_prog_attach(section, &prog, ctx);
+		fd = bpf_prog_load_and_report(section, &prog, ctx);
 		if (fd < 0) {
 			*lderr = true;
 			return fd;
-- 
2.1.4
