From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 2/4] tc, bpf: improve verifier logging
Date: Tue,  2 Feb 2016 01:12:27 +0100
Message-ID: <24df553c2a0dd547a66e215c89ae75fd6818c750.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41816 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcBBAMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:12:45 -0500
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
In-Reply-To: <cover.1454370543.git.daniel@iogearbox.net>
References: <cover.1454370543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a bit larger, branchy eBPF programs f.e. already ~BPF_MAXINSNS/7 in
size, it happens rather quickly that bpf(2) rejects also valid programs
when only the verifier log buffer size we have in tc is too small.

Change that, so by default we don't do any logging, and only in error
case we retry with logging enabled. If we should fail providing a
reasonable dump of the verifier analysis, retry few times with a larger
log buffer so that we can at least give the user a chance to debug the
program.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/tc_bpf.c | 156 ++++++++++++++++++++++++++++++++++++++++++------------------
 tc/tc_bpf.h |   1 -
 2 files changed, 110 insertions(+), 47 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 3c97cdb..a1286ba 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -711,6 +711,8 @@ struct bpf_elf_ctx {
 	bool			verbose;
 	struct bpf_elf_st	stat;
 	struct bpf_hash_entry	*ht[256];
+	char			*log;
+	size_t			log_size;
 };
 
 struct bpf_elf_sec_data {
@@ -726,14 +728,8 @@ struct bpf_map_data {
 	struct bpf_elf_map	*ent;
 };
 
-/* If we provide a small buffer with log level enabled, the kernel
- * could fail program load as no buffer space is available for the
- * log and thus verifier fails. In case something doesn't pass the
- * verifier we still want to hand something descriptive to the user.
- */
-static char bpf_log_buf[65536];
-
-static __check_format_string(1, 2) void bpf_dump_error(const char *format, ...)
+static __check_format_string(2, 3) void
+bpf_dump_error(struct bpf_elf_ctx *ctx, const char *format, ...)
 {
 	va_list vl;
 
@@ -741,12 +737,35 @@ static __check_format_string(1, 2) void bpf_dump_error(const char *format, ...)
 	vfprintf(stderr, format, vl);
 	va_end(vl);
 
-	if (bpf_log_buf[0]) {
-		fprintf(stderr, "%s\n", bpf_log_buf);
-		memset(bpf_log_buf, 0, sizeof(bpf_log_buf));
+	if (ctx->log && ctx->log[0]) {
+		fprintf(stderr, "%s\n", ctx->log);
+		memset(ctx->log, 0, ctx->log_size);
 	}
 }
 
+static int bpf_log_realloc(struct bpf_elf_ctx *ctx)
+{
+	size_t log_size = ctx->log_size;
+	void *ptr;
+
+	if (!ctx->log) {
+		log_size = 65536;
+	} else {
+		log_size <<= 1;
+		if (log_size > (UINT_MAX >> 8))
+			return -EINVAL;
+	}
+
+	ptr = realloc(ctx->log, log_size);
+	if (!ptr)
+		return -ENOMEM;
+
+	ctx->log = ptr;
+	ctx->log_size = log_size;
+
+	return 0;
+}
+
 static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 			  unsigned int size_value, unsigned int max_elem)
 {
@@ -762,23 +781,21 @@ static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 }
 
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
-			 size_t size, const char *license)
+			 size_t size_insns, const char *license, char *log,
+			 size_t size_log)
 {
 	union bpf_attr attr;
 
 	memset(&attr, 0, sizeof(attr));
 	attr.prog_type = type;
 	attr.insns = bpf_ptr_to_u64(insns);
-	attr.insn_cnt = size / sizeof(struct bpf_insn);
+	attr.insn_cnt = size_insns / sizeof(struct bpf_insn);
 	attr.license = bpf_ptr_to_u64(license);
-	attr.log_buf = bpf_ptr_to_u64(bpf_log_buf);
-	attr.log_size = sizeof(bpf_log_buf);
-	attr.log_level = 1;
 
-	if (getenv(BPF_ENV_NOLOG)) {
-		attr.log_buf	= 0;
-		attr.log_size	= 0;
-		attr.log_level	= 0;
+	if (size_log > 0) {
+		attr.log_buf = bpf_ptr_to_u64(log);
+		attr.log_size = size_log;
+		attr.log_level = 1;
 	}
 
 	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
@@ -1038,30 +1055,73 @@ static int bpf_place_pinned(int fd, const char *name,
 	return bpf_obj_pin(fd, pathname);
 }
 
-static int bpf_prog_attach(const char *section,
-			   const struct bpf_elf_prog *prog, bool verbose)
+static void bpf_prog_report(int fd, const char *section,
+			    const struct bpf_elf_prog *prog,
+			    struct bpf_elf_ctx *ctx)
 {
-	int fd;
+	fprintf(stderr, "Prog section \'%s\' %s%s (%d)!\n", section,
+		fd < 0 ? "rejected: " : "loaded",
+		fd < 0 ? strerror(errno) : "",
+		fd < 0 ? errno : fd);
+
+	fprintf(stderr, " - Type:         %u\n", prog->type);
+	fprintf(stderr, " - Instructions: %zu\n",
+		prog->size / sizeof(struct bpf_insn));
+	fprintf(stderr, " - License:      %s\n\n", prog->license);
+
+	bpf_dump_error(ctx, "Verifier analysis:\n\n");
+}
 
-	/* We can add pinning here later as well, same as bpf_map_attach(). */
+static int bpf_prog_attach(const char *section,
+			   const struct bpf_elf_prog *prog,
+			   struct bpf_elf_ctx *ctx)
+{
+	int tries = 0, fd;
+retry:
 	errno = 0;
 	fd = bpf_prog_load(prog->type, prog->insns, prog->size,
-			   prog->license);
-	if (fd < 0 || verbose) {
-		bpf_dump_error("Prog section \'%s\' (type:%u insns:%zu "
-			       "license:\'%s\') %s%s (%d)!\n\n",
-			       section, prog->type,
-			       prog->size / sizeof(struct bpf_insn),
-			       prog->license, fd < 0 ? "rejected: " :
-			       "loaded", fd < 0 ? strerror(errno) : "",
-			       fd < 0 ? errno : fd);
+			   prog->license, ctx->log, ctx->log_size);
+	if (fd < 0 || ctx->verbose) {
+		/* The verifier log is pretty chatty, sometimes so chatty
+		 * on larger programs, that we could fail to dump everything
+		 * into our buffer. Still, try to give a debuggable error
+		 * log for the user, so enlarge it and re-fail.
+		 */
+		if (fd < 0 && (errno == ENOSPC || !ctx->log_size)) {
+			if (tries++ < 6 && !bpf_log_realloc(ctx))
+				goto retry;
+
+			fprintf(stderr, "Log buffer too small to dump "
+				"verifier log %zu bytes (%d tries)!\n",
+				ctx->log_size, tries);
+			return fd;
+		}
+
+		bpf_prog_report(fd, section, prog, ctx);
 	}
 
 	return fd;
 }
 
+static void bpf_map_report(int fd, const char *name,
+			   const struct bpf_elf_map *map,
+			   struct bpf_elf_ctx *ctx)
+{
+	fprintf(stderr, "Map object \'%s\' %s%s (%d)!\n", name,
+		fd < 0 ? "rejected: " : "loaded",
+		fd < 0 ? strerror(errno) : "",
+		fd < 0 ? errno : fd);
+
+	fprintf(stderr, " - Type:         %u\n", map->type);
+	fprintf(stderr, " - Identifier:   %u\n", map->id);
+	fprintf(stderr, " - Pinning:      %u\n", map->pinning);
+	fprintf(stderr, " - Size key:     %u\n", map->size_key);
+	fprintf(stderr, " - Size value:   %u\n", map->size_value);
+	fprintf(stderr, " - Max elems:    %u\n\n", map->max_elem);
+}
+
 static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
-			  const struct bpf_elf_ctx *ctx, bool verbose)
+			  struct bpf_elf_ctx *ctx)
 {
 	int fd, ret;
 
@@ -1076,7 +1136,7 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 				name);
 			return ret;
 		}
-		if (verbose)
+		if (ctx->verbose)
 			fprintf(stderr, "Map \'%s\' loaded as pinned!\n",
 				name);
 		return fd;
@@ -1085,13 +1145,8 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 	errno = 0;
 	fd = bpf_map_create(map->type, map->size_key, map->size_value,
 			    map->max_elem);
-	if (fd < 0 || verbose) {
-		bpf_dump_error("Map \'%s\' (type:%u id:%u pinning:%u "
-			       "ksize:%u vsize:%u max-elems:%u) %s%s (%d)!\n",
-			       name, map->type, map->id, map->pinning,
-			       map->size_key, map->size_value, map->max_elem,
-			       fd < 0 ? "rejected: " : "loaded", fd < 0 ?
-			       strerror(errno) : "", fd < 0 ? errno : fd);
+	if (fd < 0 || ctx->verbose) {
+		bpf_map_report(fd, name, map, ctx);
 		if (fd < 0)
 			return fd;
 	}
@@ -1147,8 +1202,7 @@ static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 		if (!map_name)
 			return -EIO;
 
-		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
-				    ctx->verbose);
+		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx);
 		if (fd < 0)
 			return fd;
 
@@ -1300,7 +1354,7 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section)
 		prog.size    = data.sec_data->d_size;
 		prog.license = ctx->license;
 
-		fd = bpf_prog_attach(section, &prog, ctx->verbose);
+		fd = bpf_prog_attach(section, &prog, ctx);
 		if (fd < 0)
 			continue;
 
@@ -1391,7 +1445,7 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section)
 		prog.size    = data_insn.sec_data->d_size;
 		prog.license = ctx->license;
 
-		fd = bpf_prog_attach(section, &prog, ctx->verbose);
+		fd = bpf_prog_attach(section, &prog, ctx);
 		if (fd < 0)
 			continue;
 
@@ -1657,10 +1711,17 @@ static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 		goto out_elf;
 	}
 
+	if (ctx->verbose && bpf_log_realloc(ctx)) {
+		ret = -ENOMEM;
+		goto out_free;
+	}
+
 	bpf_save_finfo(ctx);
 	bpf_hash_init(ctx, CONFDIR "/bpf_pinning");
 
 	return 0;
+out_free:
+	free(ctx->sec_done);
 out_elf:
 	elf_end(ctx->elf_fd);
 out_fd:
@@ -1697,7 +1758,10 @@ static void bpf_elf_ctx_destroy(struct bpf_elf_ctx *ctx, bool failure)
 		bpf_maps_teardown(ctx);
 
 	bpf_hash_destroy(ctx);
+
 	free(ctx->sec_done);
+	free(ctx->log);
+
 	elf_end(ctx->elf_fd);
 	close(ctx->obj_fd);
 }
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 526d0b1..93f7f0e 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -32,7 +32,6 @@ enum {
 
 #define BPF_ENV_UDS	"TC_BPF_UDS"
 #define BPF_ENV_MNT	"TC_BPF_MNT"
-#define BPF_ENV_NOLOG	"TC_BPF_NOLOG"
 
 #ifndef BPF_FS_MAGIC
 # define BPF_FS_MAGIC	0xcafe4a11
-- 
1.9.3
