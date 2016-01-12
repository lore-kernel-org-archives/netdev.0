From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 2/2] tc, bpf: more header checks on loading elf
Date: Tue, 12 Jan 2016 02:03:08 +0100
Message-ID: <b98e37d1d4df7d90f7102d89d3a528a6f243109a.1452559602.git.daniel@iogearbox.net>
References: <cover.1452559602.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32854 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759365AbcALBDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 20:03:12 -0500
In-Reply-To: <cover.1452559602.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452559602.git.daniel@iogearbox.net>
References: <cover.1452559602.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

eBPF llvm backend can support different BPF formats, make sure the object
we're trying to load matches with regards to endiannes and while at it, also
check for other attributes related to BPF ELFs.

  # llc --version
  LLVM (http://llvm.org/):
    LLVM version 3.8.0svn
    Optimized build.
    Built Jan  9 2016 (02:08:10).
    Default target: x86_64-unknown-linux-gnu
    Host CPU: ivybridge

    Registered Targets:
      bpf    - BPF (host endian)
      bpfeb  - BPF (big endian)
      bpfel  - BPF (little endian)
      [...]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tc/tc_bpf.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 677dd62..42c8841 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -39,6 +39,8 @@
 #include <linux/filter.h>
 #include <linux/if_alg.h>
 
+#include <arpa/inet.h>
+
 #include "utils.h"
 
 #include "bpf_elf.h"
@@ -1564,6 +1566,38 @@ static void bpf_hash_destroy(struct bpf_elf_ctx *ctx)
 	}
 }
 
+static int bpf_elf_check_ehdr(const struct bpf_elf_ctx *ctx)
+{
+	if (ctx->elf_hdr.e_type != ET_REL ||
+	    ctx->elf_hdr.e_machine != 0 ||
+	    ctx->elf_hdr.e_version != EV_CURRENT) {
+		fprintf(stderr, "ELF format error, ELF file not for eBPF?\n");
+		return -EINVAL;
+	}
+
+	switch (ctx->elf_hdr.e_ident[EI_DATA]) {
+	default:
+		fprintf(stderr, "ELF format error, wrong endianness info?\n");
+		return -EINVAL;
+	case ELFDATA2LSB:
+		if (htons(1) == 1) {
+			fprintf(stderr,
+				"We are big endian, eBPF object is little endian!\n");
+			return -EIO;
+		}
+		break;
+	case ELFDATA2MSB:
+		if (htons(1) != 1) {
+			fprintf(stderr,
+				"We are little endian, eBPF object is big endian!\n");
+			return -EIO;
+		}
+		break;
+	}
+
+	return 0;
+}
+
 static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 			    enum bpf_prog_type type, bool verbose)
 {
@@ -1587,12 +1621,21 @@ static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 		goto out_fd;
 	}
 
+	if (elf_kind(ctx->elf_fd) != ELF_K_ELF) {
+		ret = -EINVAL;
+		goto out_fd;
+	}
+
 	if (gelf_getehdr(ctx->elf_fd, &ctx->elf_hdr) !=
 	    &ctx->elf_hdr) {
 		ret = -EIO;
 		goto out_elf;
 	}
 
+	ret = bpf_elf_check_ehdr(ctx);
+	if (ret < 0)
+		goto out_elf;
+
 	ctx->sec_done = calloc(ctx->elf_hdr.e_shnum,
 			       sizeof(*(ctx->sec_done)));
 	if (!ctx->sec_done) {
-- 
1.9.3
