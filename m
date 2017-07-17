From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 2/3] bpf: support loading map in map from obj
Date: Mon, 17 Jul 2017 17:18:51 +0200
Message-ID: <6b79daad1db04af060d2d895dd17fc1695867220.1500301061.git.daniel@iogearbox.net>
References: <cover.1500301061.git.daniel@iogearbox.net>
Cc: kafai@fb.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48060 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdGQPTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:19:06 -0400
In-Reply-To: <cover.1500301061.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500301061.git.daniel@iogearbox.net>
References: <cover.1500301061.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for map in map in the loader and add a small example program.
The outer map uses inner_id to reference a bpf_elf_map with a given ID
as the inner type. Loading maps is done in three passes, i) all non-map
in map maps are loaded, ii) all map in map maps are loaded based on the
inner_id map spec of a non-map in map with corresponding id, and iii)
related inner maps are attached to the map in map with given inner_idx
key. Pinned objetcs are assumed to be managed externally, so they are
only retrieved from BPF fs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 examples/bpf/bpf_map_in_map.c |  56 +++++++++++++++
 include/bpf_elf.h             |   2 +
 lib/bpf.c                     | 157 +++++++++++++++++++++++++++++++++++++++---
 3 files changed, 205 insertions(+), 10 deletions(-)
 create mode 100644 examples/bpf/bpf_map_in_map.c

diff --git a/examples/bpf/bpf_map_in_map.c b/examples/bpf/bpf_map_in_map.c
new file mode 100644
index 0000000..ff0e623
--- /dev/null
+++ b/examples/bpf/bpf_map_in_map.c
@@ -0,0 +1,56 @@
+#include "../../include/bpf_api.h"
+
+#define MAP_INNER_ID	42
+
+struct bpf_elf_map __section_maps map_inner = {
+	.type		= BPF_MAP_TYPE_ARRAY,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.id		= MAP_INNER_ID,
+	.inner_idx	= 0,
+	.pinning	= PIN_GLOBAL_NS,
+	.max_elem	= 1,
+};
+
+struct bpf_elf_map __section_maps map_outer = {
+	.type		= BPF_MAP_TYPE_ARRAY_OF_MAPS,
+	.size_key	= sizeof(uint32_t),
+	.size_value	= sizeof(uint32_t),
+	.inner_id	= MAP_INNER_ID,
+	.pinning	= PIN_GLOBAL_NS,
+	.max_elem	= 1,
+};
+
+__section("egress")
+int emain(struct __sk_buff *skb)
+{
+	struct bpf_elf_map *map_inner;
+	int key = 0, *val;
+
+	map_inner = map_lookup_elem(&map_outer, &key);
+	if (map_inner) {
+		val = map_lookup_elem(map_inner, &key);
+		if (val)
+			lock_xadd(val, 1);
+	}
+
+	return BPF_H_DEFAULT;
+}
+
+__section("ingress")
+int imain(struct __sk_buff *skb)
+{
+	struct bpf_elf_map *map_inner;
+	int key = 0, *val;
+
+	map_inner = map_lookup_elem(&map_outer, &key);
+	if (map_inner) {
+		val = map_lookup_elem(map_inner, &key);
+		if (val)
+			printt("map val: %d\n", *val);
+	}
+
+	return BPF_H_DEFAULT;
+}
+
+BPF_LICENSE("GPL");
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
index 239a0f3..406c308 100644
--- a/include/bpf_elf.h
+++ b/include/bpf_elf.h
@@ -36,6 +36,8 @@ struct bpf_elf_map {
 	__u32 flags;
 	__u32 id;
 	__u32 pinning;
+	__u32 inner_id;
+	__u32 inner_idx;
 };
 
 #endif /* __BPF_ELF__ */
diff --git a/lib/bpf.c b/lib/bpf.c
index 6b5a96d..45747d2 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -1023,15 +1023,16 @@ static int bpf_log_realloc(struct bpf_elf_ctx *ctx)
 
 static int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
 			  uint32_t size_value, uint32_t max_elem,
-			  uint32_t flags)
+			  uint32_t flags, int inner_fd)
 {
 	union bpf_attr attr = {};
 
 	attr.map_type = type;
 	attr.key_size = size_key;
-	attr.value_size = size_value;
+	attr.value_size = inner_fd ? sizeof(int) : size_value;
 	attr.max_entries = max_elem;
 	attr.map_flags = flags;
+	attr.inner_map_fd = inner_fd;
 
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
@@ -1343,7 +1344,7 @@ retry:
 
 static void bpf_map_report(int fd, const char *name,
 			   const struct bpf_elf_map *map,
-			   struct bpf_elf_ctx *ctx)
+			   struct bpf_elf_ctx *ctx, int inner_fd)
 {
 	fprintf(stderr, "Map object \'%s\' %s%s (%d)!\n", name,
 		fd < 0 ? "rejected: " : "loaded",
@@ -1354,15 +1355,91 @@ static void bpf_map_report(int fd, const char *name,
 	fprintf(stderr, " - Identifier:   %u\n", map->id);
 	fprintf(stderr, " - Pinning:      %u\n", map->pinning);
 	fprintf(stderr, " - Size key:     %u\n", map->size_key);
-	fprintf(stderr, " - Size value:   %u\n", map->size_value);
+	fprintf(stderr, " - Size value:   %u\n",
+		inner_fd ? (int)sizeof(int) : map->size_value);
 	fprintf(stderr, " - Max elems:    %u\n", map->max_elem);
 	fprintf(stderr, " - Flags:        %#x\n\n", map->flags);
 }
 
+static int bpf_find_map_id(const struct bpf_elf_ctx *ctx, uint32_t id)
+{
+	int i;
+
+	for (i = 0; i < ctx->map_num; i++) {
+		if (ctx->maps[i].id != id)
+			continue;
+		if (ctx->map_fds[i] < 0)
+			return -EINVAL;
+
+		return ctx->map_fds[i];
+	}
+
+	return -ENOENT;
+}
+
+static int bpf_derive_elf_map_from_fdinfo(int fd, struct bpf_elf_map *map)
+{
+	char file[PATH_MAX], buff[4096];
+	unsigned int val;
+	FILE *fp;
+
+	snprintf(file, sizeof(file), "/proc/%d/fdinfo/%d", getpid(), fd);
+
+	memset(map, 0, sizeof(*map));
+
+	fp = fopen(file, "r");
+	if (!fp) {
+		fprintf(stderr, "No procfs support?!\n");
+		return -EIO;
+	}
+
+	while (fgets(buff, sizeof(buff), fp)) {
+		if (sscanf(buff, "map_type:\t%u", &val) == 1)
+			map->type = val;
+		else if (sscanf(buff, "key_size:\t%u", &val) == 1)
+			map->size_key = val;
+		else if (sscanf(buff, "value_size:\t%u", &val) == 1)
+			map->size_value = val;
+		else if (sscanf(buff, "max_entries:\t%u", &val) == 1)
+			map->max_elem = val;
+		else if (sscanf(buff, "map_flags:\t%i", &val) == 1)
+			map->flags = val;
+	}
+
+	fclose(fp);
+	return 0;
+}
+
+static void bpf_report_map_in_map(int outer_fd, int inner_fd, uint32_t idx)
+{
+	struct bpf_elf_map outer_map;
+	int ret;
+
+	fprintf(stderr, "Cannot insert map into map! ");
+
+	ret = bpf_derive_elf_map_from_fdinfo(outer_fd, &outer_map);
+	if (!ret) {
+		if (idx >= outer_map.max_elem &&
+		    outer_map.type == BPF_MAP_TYPE_ARRAY_OF_MAPS) {
+			fprintf(stderr, "Outer map has %u elements, index %u is invalid!\n",
+				outer_map.max_elem, idx);
+			return;
+		}
+	}
+
+	fprintf(stderr, "Different map specs used for outer and inner map?\n");
+}
+
+static bool bpf_is_map_in_map_type(const struct bpf_elf_map *map)
+{
+	return map->type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
+	       map->type == BPF_MAP_TYPE_HASH_OF_MAPS;
+}
+
 static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
-			  struct bpf_elf_ctx *ctx)
+			  struct bpf_elf_ctx *ctx, int *have_map_in_map)
 {
-	int fd, ret;
+	int fd, ret, map_inner_fd = 0;
 
 	fd = bpf_probe_pinned(name, ctx, map->pinning);
 	if (fd > 0) {
@@ -1381,11 +1458,29 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 		return fd;
 	}
 
+	if (have_map_in_map && bpf_is_map_in_map_type(map)) {
+		(*have_map_in_map)++;
+		if (map->inner_id)
+			return 0;
+		fprintf(stderr, "Map \'%s\' cannot be created since no inner map ID defined!\n",
+			name);
+		return -EINVAL;
+	}
+
+	if (!have_map_in_map && bpf_is_map_in_map_type(map)) {
+		map_inner_fd = bpf_find_map_id(ctx, map->inner_id);
+		if (map_inner_fd < 0) {
+			fprintf(stderr, "Map \'%s\' cannot be loaded. Inner map with ID %u not found!\n",
+				name, map->inner_id);
+			return -EINVAL;
+		}
+	}
+
 	errno = 0;
 	fd = bpf_map_create(map->type, map->size_key, map->size_value,
-			    map->max_elem, map->flags);
+			    map->max_elem, map->flags, map_inner_fd);
 	if (fd < 0 || ctx->verbose) {
-		bpf_map_report(fd, name, map, ctx);
+		bpf_map_report(fd, name, map, ctx, map_inner_fd);
 		if (fd < 0)
 			return fd;
 	}
@@ -1430,21 +1525,63 @@ static const char *bpf_map_fetch_name(struct bpf_elf_ctx *ctx, int which)
 
 static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 {
+	int i, j, ret, fd, inner_fd, inner_idx, have_map_in_map = 0;
 	const char *map_name;
-	int i, fd;
 
 	for (i = 0; i < ctx->map_num; i++) {
 		map_name = bpf_map_fetch_name(ctx, i);
 		if (!map_name)
 			return -EIO;
 
-		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx);
+		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
+				    &have_map_in_map);
+		if (fd < 0)
+			return fd;
+
+		ctx->map_fds[i] = !fd ? -1 : fd;
+	}
+
+	for (i = 0; have_map_in_map && i < ctx->map_num; i++) {
+		if (ctx->map_fds[i] >= 0)
+			continue;
+
+		map_name = bpf_map_fetch_name(ctx, i);
+		if (!map_name)
+			return -EIO;
+
+		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
+				    NULL);
 		if (fd < 0)
 			return fd;
 
 		ctx->map_fds[i] = fd;
 	}
 
+	for (i = 0; have_map_in_map && i < ctx->map_num; i++) {
+		if (!ctx->maps[i].id ||
+		    ctx->maps[i].inner_id ||
+		    ctx->maps[i].inner_idx == -1)
+			continue;
+
+		inner_fd  = ctx->map_fds[i];
+		inner_idx = ctx->maps[i].inner_idx;
+
+		for (j = 0; j < ctx->map_num; j++) {
+			if (!bpf_is_map_in_map_type(&ctx->maps[j]))
+				continue;
+			if (ctx->maps[j].inner_id != ctx->maps[i].id)
+				continue;
+
+			ret = bpf_map_update(ctx->map_fds[j], &inner_idx,
+					     &inner_fd, BPF_ANY);
+			if (ret < 0) {
+				bpf_report_map_in_map(ctx->map_fds[j],
+						      inner_fd, inner_idx);
+				return ret;
+			}
+		}
+	}
+
 	return 0;
 }
 
-- 
1.9.3
