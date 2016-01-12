From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 1/2] tc, bpf: check section names and type everywhere
Date: Tue, 12 Jan 2016 02:03:07 +0100
Message-ID: <3947559fab4ac91c5b017170b80b2288a4c086c7.1452559602.git.daniel@iogearbox.net>
References: <cover.1452559602.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32852 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757960AbcALBDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 20:03:12 -0500
In-Reply-To: <cover.1452559602.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452559602.git.daniel@iogearbox.net>
References: <cover.1452559602.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When extracting sections, we better check for name and type. Noticed
that some llvm versions emit .strtab and .shstrtab (e.g. saw it on pre
3.7), while more recent ones only seem to emit .strtab. Thus, make sure
we get the right sections.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tc/tc_bpf.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index f9b2b00..677dd62 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -1237,14 +1237,17 @@ static int bpf_fetch_ancillary(struct bpf_elf_ctx *ctx)
 		if (ret < 0)
 			continue;
 
-		if (!strcmp(data.sec_name, ELF_SECTION_MAPS))
+		if (data.sec_hdr.sh_type == SHT_PROGBITS &&
+		    !strcmp(data.sec_name, ELF_SECTION_MAPS))
 			ret = bpf_fetch_maps(ctx, i, &data);
-		else if (!strcmp(data.sec_name, ELF_SECTION_LICENSE))
+		else if (data.sec_hdr.sh_type == SHT_PROGBITS &&
+			 !strcmp(data.sec_name, ELF_SECTION_LICENSE))
 			ret = bpf_fetch_license(ctx, i, &data);
-		else if (data.sec_hdr.sh_type == SHT_SYMTAB)
+		else if (data.sec_hdr.sh_type == SHT_SYMTAB &&
+			 !strcmp(data.sec_name, ".symtab"))
 			ret = bpf_fetch_symtab(ctx, i, &data);
 		else if (data.sec_hdr.sh_type == SHT_STRTAB &&
-			 i != ctx->elf_hdr.e_shstrndx)
+			 !strcmp(data.sec_name, ".strtab"))
 			ret = bpf_fetch_strtab(ctx, i, &data);
 		if (ret < 0) {
 			fprintf(stderr, "Error parsing section %d! Perhaps"
@@ -1275,7 +1278,10 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section)
 			continue;
 
 		ret = bpf_fill_section_data(ctx, i, &data);
-		if (ret < 0 || strcmp(data.sec_name, section))
+		if (ret < 0 ||
+		    !(data.sec_hdr.sh_type == SHT_PROGBITS &&
+		      data.sec_hdr.sh_flags & SHF_EXECINSTR &&
+		      !strcmp(data.sec_name, section)))
 			continue;
 
 		memset(&prog, 0, sizeof(prog));
@@ -1353,7 +1359,10 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
 
 		idx = data_relo.sec_hdr.sh_info;
 		ret = bpf_fill_section_data(ctx, idx, &data_insn);
-		if (ret < 0 || strcmp(data_insn.sec_name, section))
+		if (ret < 0 ||
+		    !(data_insn.sec_hdr.sh_type == SHT_PROGBITS &&
+		      data_insn.sec_hdr.sh_flags & SHF_EXECINSTR &&
+		      !strcmp(data_insn.sec_name, section)))
 			continue;
 
 		ret = bpf_apply_relo_data(ctx, &data_relo, &data_insn);
-- 
1.9.3
