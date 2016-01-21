From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master] tc, bpf: make sure relo is in relation with map section
Date: Fri, 22 Jan 2016 00:46:28 +0100
Message-ID: <6f06b68f62c89489ec1afea5ba1c328ef51efd10.1453418999.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58972 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcAUXqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 18:46:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a test that symbol from relocation entry is actually related
to map section and bail out with an error message if it's not the
case; in relation to [1].

  [1] https://llvm.org/bugs/show_bug.cgi?id=26243

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 219ffa5..3c97cdb 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -1336,6 +1336,12 @@ static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
 
 		if (gelf_getsym(ctx->sym_tab, GELF_R_SYM(relo.r_info), &sym) != &sym)
 			return -EIO;
+		if (sym.st_shndx != ctx->sec_maps) {
+			fprintf(stderr, "ELF contains non-map related relo data in "
+				"entry %u pointing to section %u! Compiler bug?!\n",
+				relo_ent, sym.st_shndx);
+			return -EIO;
+		}
 
 		rmap = sym.st_value / sizeof(struct bpf_elf_map);
 		if (rmap >= ARRAY_SIZE(ctx->map_fds))
-- 
1.9.3
