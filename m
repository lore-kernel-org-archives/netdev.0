From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 2/3] tc, bpf: further improve error reporting
Date: Sat,  9 Apr 2016 00:32:04 +0200
Message-ID: <b17e2eeb29403a745b7ef6c4e0babef440801afb.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39615 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757932AbcDHWcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:32:20 -0400
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
References: <cover.1460153854.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it easier to spot issues when loading the object file fails. This
includes reporting in what pinned object specs differ, better indication
when we've reached instruction limits. Don't retry to load a non relo
program once we failed with bpf(2), and report out of bounds tail call key.

Also, add truncation of huge log outputs by default. Sometimes errors are
quite easy to spot by only looking at the tail of the verifier log, but
logs can get huge in size e.g. up to few MB (due to verifier checking all
possible program paths). Thus, by default limit output to the last 4096
bytes and indicate that it's truncated. For the full log, the verbose option
can be used.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 82 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 tc/tc_bpf.h |  4 +++
 2 files changed, 69 insertions(+), 17 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index d94af82..0c59427 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -184,7 +184,7 @@ static int bpf_ops_parse(int argc, char **argv, struct sock_filter *bpf_ops,
 	}
 
 	if (i != bpf_len) {
-		fprintf(stderr, "Parsed program length is less than encodedlength parameter!\n");
+		fprintf(stderr, "Parsed program length is less than encoded length parameter!\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -214,6 +214,27 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 		ops[i].jf, ops[i].k);
 }
 
+static void bpf_map_pin_report(const struct bpf_elf_map *pin,
+			       const struct bpf_elf_map *obj)
+{
+	fprintf(stderr, "Map specification differs from pinned file!\n");
+
+	if (obj->type != pin->type)
+		fprintf(stderr, " - Type:         %u (obj) != %u (pin)\n",
+			obj->type, pin->type);
+	if (obj->size_key != pin->size_key)
+		fprintf(stderr, " - Size key:     %u (obj) != %u (pin)\n",
+			obj->size_key, pin->size_key);
+	if (obj->size_value != pin->size_value)
+		fprintf(stderr, " - Size value:   %u (obj) != %u (pin)\n",
+			obj->size_value, pin->size_value);
+	if (obj->max_elem != pin->max_elem)
+		fprintf(stderr, " - Max elems:    %u (obj) != %u (pin)\n",
+			obj->max_elem, pin->max_elem);
+
+	fprintf(stderr, "\n");
+}
+
 static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 				    int length)
 {
@@ -256,7 +277,7 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 		if (!memcmp(&tmp, &zero, length))
 			return 0;
 
-		fprintf(stderr, "Map specs from pinned file differ!\n");
+		bpf_map_pin_report(&tmp, map);
 		return -EINVAL;
 	}
 }
@@ -735,7 +756,19 @@ bpf_dump_error(struct bpf_elf_ctx *ctx, const char *format, ...)
 	va_end(vl);
 
 	if (ctx->log && ctx->log[0]) {
-		fprintf(stderr, "%s\n", ctx->log);
+		if (ctx->verbose) {
+			fprintf(stderr, "%s\n", ctx->log);
+		} else {
+			unsigned int off = 0, len = strlen(ctx->log);
+
+			if (len > BPF_MAX_LOG) {
+				off = len - BPF_MAX_LOG;
+				fprintf(stderr, "Skipped %u bytes, use \'verb\' option for the full verbose log.\n[...]\n",
+					off);
+			}
+			fprintf(stderr, "%s\n", ctx->log + off);
+		}
+
 		memset(ctx->log, 0, ctx->log_size);
 	}
 }
@@ -1055,14 +1088,16 @@ static void bpf_prog_report(int fd, const char *section,
 			    const struct bpf_elf_prog *prog,
 			    struct bpf_elf_ctx *ctx)
 {
-	fprintf(stderr, "Prog section \'%s\' %s%s (%d)!\n", section,
+	unsigned int insns = prog->size / sizeof(struct bpf_insn);
+
+	fprintf(stderr, "\nProg section \'%s\' %s%s (%d)!\n", section,
 		fd < 0 ? "rejected: " : "loaded",
 		fd < 0 ? strerror(errno) : "",
 		fd < 0 ? errno : fd);
 
 	fprintf(stderr, " - Type:         %u\n", prog->type);
-	fprintf(stderr, " - Instructions: %zu\n",
-		prog->size / sizeof(struct bpf_insn));
+	fprintf(stderr, " - Instructions: %u (%u over limit)\n",
+		insns, insns > BPF_MAXINSNS ? insns - BPF_MAXINSNS : 0);
 	fprintf(stderr, " - License:      %s\n\n", prog->license);
 
 	bpf_dump_error(ctx, "Verifier analysis:\n\n");
@@ -1283,6 +1318,11 @@ static int bpf_fetch_strtab(struct bpf_elf_ctx *ctx, int section,
 	return 0;
 }
 
+static bool bpf_has_map_data(const struct bpf_elf_ctx *ctx)
+{
+	return ctx->sym_tab && ctx->str_tab && ctx->sec_maps;
+}
+
 static int bpf_fetch_ancillary(struct bpf_elf_ctx *ctx)
 {
 	struct bpf_elf_sec_data data;
@@ -1306,13 +1346,13 @@ static int bpf_fetch_ancillary(struct bpf_elf_ctx *ctx)
 			 !strcmp(data.sec_name, ".strtab"))
 			ret = bpf_fetch_strtab(ctx, i, &data);
 		if (ret < 0) {
-			fprintf(stderr, "Error parsing section %d! Perhapscheck with readelf -a?\n",
+			fprintf(stderr, "Error parsing section %d! Perhaps check with readelf -a?\n",
 				i);
 			break;
 		}
 	}
 
-	if (ctx->sym_tab && ctx->str_tab && ctx->sec_maps) {
+	if (bpf_has_map_data(ctx)) {
 		ret = bpf_maps_attach_all(ctx);
 		if (ret < 0) {
 			fprintf(stderr, "Error loading maps into kernel!\n");
@@ -1348,7 +1388,7 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section)
 
 		fd = bpf_prog_attach(section, &prog, ctx);
 		if (fd < 0)
-			continue;
+			break;
 
 		ctx->sec_done[i] = true;
 		break;
@@ -1412,7 +1452,8 @@ static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
 	return 0;
 }
 
-static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
+static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
+			       bool *lderr)
 {
 	struct bpf_elf_sec_data data_relo, data_insn;
 	struct bpf_elf_prog prog;
@@ -1442,8 +1483,10 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
 		prog.license = ctx->license;
 
 		fd = bpf_prog_attach(section, &prog, ctx);
-		if (fd < 0)
-			continue;
+		if (fd < 0) {
+			*lderr = true;
+			break;
+		}
 
 		ctx->sec_done[i]   = true;
 		ctx->sec_done[idx] = true;
@@ -1455,11 +1498,12 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
 
 static int bpf_fetch_prog_sec(struct bpf_elf_ctx *ctx, const char *section)
 {
+	bool lderr = false;
 	int ret = -1;
 
-	if (ctx->sym_tab)
-		ret = bpf_fetch_prog_relo(ctx, section);
-	if (ret < 0)
+	if (bpf_has_map_data(ctx))
+		ret = bpf_fetch_prog_relo(ctx, section, &lderr);
+	if (ret < 0 && !lderr)
 		ret = bpf_fetch_prog(ctx, section);
 
 	return ret;
@@ -1504,8 +1548,12 @@ static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 
 		ret = bpf_map_update(ctx->map_fds[idx], &key_id,
 				     &fd, BPF_ANY);
-		if (ret < 0)
-			return -ENOENT;
+		if (ret < 0) {
+			if (errno == E2BIG)
+				fprintf(stderr, "Tail call key %u for map %u out of bounds?\n",
+					key_id, map_id);
+			return -errno;
+		}
 
 		ctx->sec_done[i] = true;
 	}
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 93f7f0e..30306de 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -33,6 +33,10 @@ enum {
 #define BPF_ENV_UDS	"TC_BPF_UDS"
 #define BPF_ENV_MNT	"TC_BPF_MNT"
 
+#ifndef BPF_MAX_LOG
+# define BPF_MAX_LOG	4096
+#endif
+
 #ifndef BPF_FS_MAGIC
 # define BPF_FS_MAGIC	0xcafe4a11
 #endif
-- 
1.9.3
