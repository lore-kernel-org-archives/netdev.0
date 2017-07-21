From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 1/2] bpf: improve error reporting around tail calls
Date: Fri, 21 Jul 2017 21:13:06 +0200
Message-ID: <b0bf43dac3babbb1a78fabeeb2a3a069db4f262c.1500663605.git.daniel@iogearbox.net>
References: <cover.1500663605.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58989 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754141AbdGUTNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 15:13:22 -0400
In-Reply-To: <cover.1500663605.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500663605.git.daniel@iogearbox.net>
References: <cover.1500663605.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, it's still quite hard to figure out if a prog passed the
verifier, but later gets rejected due to different tail call ownership.
Figure out whether that is the case and provide appropriate error
messages to the user.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 226 ++++++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 169 insertions(+), 57 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 7eb5cd9..4f6421a 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -344,15 +344,50 @@ static void bpf_map_pin_report(const struct bpf_elf_map *pin,
 	fprintf(stderr, "\n");
 }
 
-static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
-				    int length, enum bpf_prog_type type)
+struct bpf_prog_data {
+	unsigned int type;
+	unsigned int jited;
+};
+
+struct bpf_map_ext {
+	struct bpf_prog_data owner;
+};
+
+static int bpf_derive_prog_from_fdinfo(int fd, struct bpf_prog_data *prog)
+{
+	char file[PATH_MAX], buff[4096];
+	unsigned int val;
+	FILE *fp;
+
+	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
+	memset(prog, 0, sizeof(*prog));
+
+	fp = fopen(file, "r");
+	if (!fp) {
+		fprintf(stderr, "No procfs support?!\n");
+		return -EIO;
+	}
+
+	while (fgets(buff, sizeof(buff), fp)) {
+		if (sscanf(buff, "prog_type:\t%u", &val) == 1)
+			prog->type = val;
+		else if (sscanf(buff, "prog_jited:\t%u", &val) == 1)
+			prog->jited = val;
+	}
+
+	fclose(fp);
+	return 0;
+}
+
+static int bpf_derive_elf_map_from_fdinfo(int fd, struct bpf_elf_map *map,
+					  struct bpf_map_ext *ext)
 {
+	unsigned int val, owner_type = 0, owner_jited = 0;
 	char file[PATH_MAX], buff[4096];
-	struct bpf_elf_map tmp = {}, zero = {};
-	unsigned int val, owner_type = 0;
 	FILE *fp;
 
 	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
+	memset(map, 0, sizeof(*map));
 
 	fp = fopen(file, "r");
 	if (!fp) {
@@ -362,27 +397,48 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 
 	while (fgets(buff, sizeof(buff), fp)) {
 		if (sscanf(buff, "map_type:\t%u", &val) == 1)
-			tmp.type = val;
+			map->type = val;
 		else if (sscanf(buff, "key_size:\t%u", &val) == 1)
-			tmp.size_key = val;
+			map->size_key = val;
 		else if (sscanf(buff, "value_size:\t%u", &val) == 1)
-			tmp.size_value = val;
+			map->size_value = val;
 		else if (sscanf(buff, "max_entries:\t%u", &val) == 1)
-			tmp.max_elem = val;
+			map->max_elem = val;
 		else if (sscanf(buff, "map_flags:\t%i", &val) == 1)
-			tmp.flags = val;
+			map->flags = val;
 		else if (sscanf(buff, "owner_prog_type:\t%i", &val) == 1)
 			owner_type = val;
+		else if (sscanf(buff, "owner_jited:\t%i", &val) == 1)
+			owner_jited = val;
 	}
 
 	fclose(fp);
+	if (ext) {
+		memset(ext, 0, sizeof(*ext));
+		ext->owner.type  = owner_type;
+		ext->owner.jited = owner_jited;
+	}
+
+	return 0;
+}
+
+static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
+				    struct bpf_map_ext *ext, int length,
+				    enum bpf_prog_type type)
+{
+	struct bpf_elf_map tmp, zero = {};
+	int ret;
+
+	ret = bpf_derive_elf_map_from_fdinfo(fd, &tmp, ext);
+	if (ret < 0)
+		return ret;
 
 	/* The decision to reject this is on kernel side eventually, but
 	 * at least give the user a chance to know what's wrong.
 	 */
-	if (owner_type && owner_type != type)
+	if (ext->owner.type && ext->owner.type != type)
 		fprintf(stderr, "Program array map owner types differ: %u (obj) != %u (pin)\n",
-			type, owner_type);
+			type, ext->owner.type);
 
 	if (!memcmp(&tmp, map, length)) {
 		return 0;
@@ -882,6 +938,7 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
 		.argc		= argc,
 		.argv		= argv,
 	};
+	struct bpf_map_ext ext = {};
 	int ret, prog_fd, map_fd;
 	enum bpf_mode mode;
 	uint32_t map_key;
@@ -908,7 +965,7 @@ int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
 		goto out_prog;
 	}
 
-	ret = bpf_map_selfcheck_pinned(map_fd, &test,
+	ret = bpf_map_selfcheck_pinned(map_fd, &test, &ext,
 				       offsetof(struct bpf_elf_map, max_elem),
 				       type);
 	if (ret < 0) {
@@ -981,7 +1038,12 @@ struct bpf_hash_entry {
 	struct bpf_hash_entry	*next;
 };
 
+struct bpf_config {
+	unsigned int		jit_enabled;
+};
+
 struct bpf_elf_ctx {
+	struct bpf_config	cfg;
 	Elf			*elf_fd;
 	GElf_Ehdr		elf_hdr;
 	Elf_Data		*sym_tab;
@@ -989,6 +1051,7 @@ struct bpf_elf_ctx {
 	int			obj_fd;
 	int			map_fds[ELF_MAX_MAPS];
 	struct bpf_elf_map	maps[ELF_MAX_MAPS];
+	struct bpf_map_ext	maps_ext[ELF_MAX_MAPS];
 	int			sym_num;
 	int			map_num;
 	int			map_len;
@@ -1425,39 +1488,6 @@ static int bpf_find_map_id(const struct bpf_elf_ctx *ctx, uint32_t id)
 	return -ENOENT;
 }
 
-static int bpf_derive_elf_map_from_fdinfo(int fd, struct bpf_elf_map *map)
-{
-	char file[PATH_MAX], buff[4096];
-	unsigned int val;
-	FILE *fp;
-
-	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
-
-	memset(map, 0, sizeof(*map));
-
-	fp = fopen(file, "r");
-	if (!fp) {
-		fprintf(stderr, "No procfs support?!\n");
-		return -EIO;
-	}
-
-	while (fgets(buff, sizeof(buff), fp)) {
-		if (sscanf(buff, "map_type:\t%u", &val) == 1)
-			map->type = val;
-		else if (sscanf(buff, "key_size:\t%u", &val) == 1)
-			map->size_key = val;
-		else if (sscanf(buff, "value_size:\t%u", &val) == 1)
-			map->size_value = val;
-		else if (sscanf(buff, "max_entries:\t%u", &val) == 1)
-			map->max_elem = val;
-		else if (sscanf(buff, "map_flags:\t%i", &val) == 1)
-			map->flags = val;
-	}
-
-	fclose(fp);
-	return 0;
-}
-
 static void bpf_report_map_in_map(int outer_fd, int inner_fd, uint32_t idx)
 {
 	struct bpf_elf_map outer_map;
@@ -1465,7 +1495,7 @@ static void bpf_report_map_in_map(int outer_fd, int inner_fd, uint32_t idx)
 
 	fprintf(stderr, "Cannot insert map into map! ");
 
-	ret = bpf_derive_elf_map_from_fdinfo(outer_fd, &outer_map);
+	ret = bpf_derive_elf_map_from_fdinfo(outer_fd, &outer_map, NULL);
 	if (!ret) {
 		if (idx >= outer_map.max_elem &&
 		    outer_map.type == BPF_MAP_TYPE_ARRAY_OF_MAPS) {
@@ -1484,14 +1514,15 @@ static bool bpf_is_map_in_map_type(const struct bpf_elf_map *map)
 	       map->type == BPF_MAP_TYPE_HASH_OF_MAPS;
 }
 
-static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
-			  struct bpf_elf_ctx *ctx, int *have_map_in_map)
+static int bpf_map_attach(const char *name, struct bpf_elf_ctx *ctx,
+			  const struct bpf_elf_map *map, struct bpf_map_ext *ext,
+			  int *have_map_in_map)
 {
 	int fd, ret, map_inner_fd = 0;
 
 	fd = bpf_probe_pinned(name, ctx, map->pinning);
 	if (fd > 0) {
-		ret = bpf_map_selfcheck_pinned(fd, map,
+		ret = bpf_map_selfcheck_pinned(fd, map, ext,
 					       offsetof(struct bpf_elf_map,
 							id), ctx->type);
 		if (ret < 0) {
@@ -1581,8 +1612,8 @@ static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 		if (!map_name)
 			return -EIO;
 
-		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
-				    &have_map_in_map);
+		fd = bpf_map_attach(map_name, ctx, &ctx->maps[i],
+				    &ctx->maps_ext[i], &have_map_in_map);
 		if (fd < 0)
 			return fd;
 
@@ -1597,8 +1628,8 @@ static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 		if (!map_name)
 			return -EIO;
 
-		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
-				    NULL);
+		fd = bpf_map_attach(map_name, ctx, &ctx->maps[i],
+				    &ctx->maps_ext[i], NULL);
 		if (fd < 0)
 			return fd;
 
@@ -1901,9 +1932,15 @@ static int bpf_fetch_prog(struct bpf_elf_ctx *ctx, const char *section,
 	return fd;
 }
 
+struct bpf_tail_call_props {
+	unsigned int total;
+	unsigned int jited;
+};
+
 static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
 			       struct bpf_elf_sec_data *data_relo,
-			       struct bpf_elf_sec_data *data_insn)
+			       struct bpf_elf_sec_data *data_insn,
+			       struct bpf_tail_call_props *props)
 {
 	Elf_Data *idata = data_insn->sec_data;
 	GElf_Shdr *rhdr = &data_relo->sec_hdr;
@@ -1943,6 +1980,13 @@ static int bpf_apply_relo_data(struct bpf_elf_ctx *ctx,
 			return -EINVAL;
 		if (!ctx->map_fds[rmap])
 			return -EINVAL;
+		if (ctx->maps[rmap].type == BPF_MAP_TYPE_PROG_ARRAY) {
+			props->total++;
+			if (ctx->maps_ext[rmap].owner.jited ||
+			    (ctx->maps_ext[rmap].owner.type == 0 &&
+			     ctx->cfg.jit_enabled))
+				props->jited++;
+		}
 
 		if (ctx->verbose)
 			fprintf(stderr, "Map \'%s\' (%d) injected into prog section \'%s\' at offset %u!\n",
@@ -1964,6 +2008,8 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
 	int ret, idx, i, fd = -1;
 
 	for (i = 1; i < ctx->elf_hdr.e_shnum; i++) {
+		struct bpf_tail_call_props props = {};
+
 		ret = bpf_fill_section_data(ctx, i, &data_relo);
 		if (ret < 0 || data_relo.sec_hdr.sh_type != SHT_REL)
 			continue;
@@ -1979,7 +2025,7 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
 
 		*sseen = true;
 
-		ret = bpf_apply_relo_data(ctx, &data_relo, &data_insn);
+		ret = bpf_apply_relo_data(ctx, &data_relo, &data_insn, &props);
 		if (ret < 0) {
 			*lderr = true;
 			return ret;
@@ -1994,6 +2040,16 @@ static int bpf_fetch_prog_relo(struct bpf_elf_ctx *ctx, const char *section,
 		fd = bpf_prog_attach(section, &prog, ctx);
 		if (fd < 0) {
 			*lderr = true;
+			if (props.total) {
+				if (ctx->cfg.jit_enabled &&
+				    props.total != props.jited)
+					fprintf(stderr, "JIT enabled, but only %u/%u tail call maps in the program have JITed owner!\n",
+						props.jited, props.total);
+				if (!ctx->cfg.jit_enabled &&
+				    props.jited)
+					fprintf(stderr, "JIT disabled, but %u/%u tail call maps in the program have JITed owner!\n",
+						props.jited, props.total);
+			}
 			return fd;
 		}
 
@@ -2031,6 +2087,25 @@ static int bpf_find_map_by_id(struct bpf_elf_ctx *ctx, uint32_t id)
 	return -1;
 }
 
+struct bpf_jited_aux {
+	int prog_fd;
+	int map_fd;
+	struct bpf_prog_data prog;
+	struct bpf_map_ext map;
+};
+
+static int bpf_tail_call_get_aux(struct bpf_jited_aux *aux)
+{
+	struct bpf_elf_map tmp;
+	int ret;
+
+	ret = bpf_derive_elf_map_from_fdinfo(aux->map_fd, &tmp, &aux->map);
+	if (!ret)
+		ret = bpf_derive_prog_from_fdinfo(aux->prog_fd, &aux->prog);
+
+	return ret;
+}
+
 static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 {
 	struct bpf_elf_sec_data data;
@@ -2060,10 +2135,31 @@ static int bpf_fill_prog_arrays(struct bpf_elf_ctx *ctx)
 		ret = bpf_map_update(ctx->map_fds[idx], &key_id,
 				     &fd, BPF_ANY);
 		if (ret < 0) {
-			if (errno == E2BIG)
+			struct bpf_jited_aux aux = {};
+
+			ret = -errno;
+			if (errno == E2BIG) {
 				fprintf(stderr, "Tail call key %u for map %u out of bounds?\n",
 					key_id, map_id);
-			return -errno;
+				return ret;
+			}
+
+			aux.map_fd  = ctx->map_fds[idx];
+			aux.prog_fd = fd;
+
+			if (bpf_tail_call_get_aux(&aux))
+				return ret;
+			if (!aux.map.owner.type)
+				return ret;
+
+			if (aux.prog.type != aux.map.owner.type)
+				fprintf(stderr, "Tail call map owned by prog type %u, but prog type is %u!\n",
+					aux.map.owner.type, aux.prog.type);
+			if (aux.prog.jited != aux.map.owner.jited)
+				fprintf(stderr, "Tail call map %s jited, but prog %s!\n",
+					aux.map.owner.jited ? "is" : "not",
+					aux.prog.jited ? "is" : "not");
+			return ret;
 		}
 
 		ctx->sec_done[i] = true;
@@ -2221,6 +2317,21 @@ static int bpf_elf_check_ehdr(const struct bpf_elf_ctx *ctx)
 	return 0;
 }
 
+static void bpf_get_cfg(struct bpf_elf_ctx *ctx)
+{
+	static const char *path_jit = "/proc/sys/net/core/bpf_jit_enable";
+	int fd;
+
+	fd = open(path_jit, O_RDONLY);
+	if (fd > 0) {
+		char tmp[16] = {};
+
+		if (read(fd, tmp, sizeof(tmp)) > 0)
+			ctx->cfg.jit_enabled = atoi(tmp);
+		close(fd);
+	}
+}
+
 static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 			    enum bpf_prog_type type, bool verbose)
 {
@@ -2231,6 +2342,7 @@ static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 		return ret;
 
 	memset(ctx, 0, sizeof(*ctx));
+	bpf_get_cfg(ctx);
 	ctx->verbose = verbose;
 	ctx->type    = type;
 
-- 
1.9.3
