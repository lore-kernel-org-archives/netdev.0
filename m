From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master] bpf: also check elf for official e_machine value
Date: Tue, 19 Jul 2016 01:09:52 +0200
Message-ID: <a5dbe0907854c72832f0b0d745eaace921bf879e.1468882622.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35871 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbcGRXJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 19:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the official BPF ELF e_machine value that was assigned recently [1]
and will be propagated to glibc, libelf et al. LLVM will switch to it
in 3.9 release, therefore we need to prepare tc to check for EM_ELF as
well, older version still have the EM_NONE.

  [1] https://github.com/llvm-mirror/llvm/commit/36b9c09330bfb5e771914cfe307588f30d5510d2

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 86c6069..7eb1cd7 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -54,6 +54,10 @@
 #define AF_ALG 38
 #endif
 
+#ifndef EM_BPF
+#define EM_BPF 247
+#endif
+
 #ifdef HAVE_ELF
 static int bpf_obj_open(const char *path, enum bpf_prog_type type,
 			const char *sec, bool verbose);
@@ -1690,7 +1694,8 @@ static void bpf_hash_destroy(struct bpf_elf_ctx *ctx)
 static int bpf_elf_check_ehdr(const struct bpf_elf_ctx *ctx)
 {
 	if (ctx->elf_hdr.e_type != ET_REL ||
-	    ctx->elf_hdr.e_machine != 0 ||
+	    (ctx->elf_hdr.e_machine != EM_NONE &&
+	     ctx->elf_hdr.e_machine != EM_BPF) ||
 	    ctx->elf_hdr.e_version != EV_CURRENT) {
 		fprintf(stderr, "ELF format error, ELF file not for eBPF?\n");
 		return -EINVAL;
-- 
1.9.3
