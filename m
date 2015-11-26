From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2 3/5] {f,m}_bpf: allow for user-defined object pinnings
Date: Thu, 26 Nov 2015 15:38:44 +0100
Message-ID: <f3542294b48405c971f80ef984f65c51a13feb9a.1448547199.git.daniel@iogearbox.net>
References: <cover.1448547199.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49499 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbKZOiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:38:52 -0500
In-Reply-To: <cover.1448547199.git.daniel@iogearbox.net>
In-Reply-To: <cover.1448547199.git.daniel@iogearbox.net>
References: <cover.1448547199.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently introduced object pinning can be further extended in order
to allow sharing maps beyond tc namespace. F.e. maps that are being pinned
from tracing side, can be accessed through this facility as well.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 etc/iproute2/bpf_pinning |   6 ++
 include/bpf_elf.h        |   2 +-
 include/utils.h          |   4 +
 lib/rt_names.c           |   5 +-
 tc/tc_bpf.c              | 212 ++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 204 insertions(+), 25 deletions(-)
 create mode 100644 etc/iproute2/bpf_pinning

diff --git a/etc/iproute2/bpf_pinning b/etc/iproute2/bpf_pinning
new file mode 100644
index 0000000..2b39c70
--- /dev/null
+++ b/etc/iproute2/bpf_pinning
@@ -0,0 +1,6 @@
+#
+# subpath mappings from mount point for pinning
+#
+#3	tracing
+#4	foo/bar
+#5	tc/cls1
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
index 0690dd6..31a8974 100644
--- a/include/bpf_elf.h
+++ b/include/bpf_elf.h
@@ -33,7 +33,7 @@ struct bpf_elf_map {
 	__u32 size_value;
 	__u32 max_elem;
 	__u32 id;
-	__u8  pinning;
+	__u32 pinning;
 };
 
 #endif /* __BPF_ELF__ */
diff --git a/include/utils.h b/include/utils.h
index 5902a98..e830be6 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -40,6 +40,10 @@ extern bool do_all;
 #define IPSEC_PROTO_ANY	255
 #endif
 
+#ifndef CONFDIR
+#define CONFDIR		"/etc/iproute2"
+#endif
+
 #define SPRINT_BSIZE 64
 #define SPRINT_BUF(x)	char x[SPRINT_BSIZE]
 
diff --git a/lib/rt_names.c b/lib/rt_names.c
index e87c65d..3968c76 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -22,10 +22,7 @@
 #include <linux/rtnetlink.h>
 
 #include "rt_names.h"
-
-#ifndef CONFDIR
-#define CONFDIR "/etc/iproute2"
-#endif
+#include "utils.h"
 
 #define NAME_MAX_LEN 512
 
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index b44b123..17c04e9 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -458,6 +458,12 @@ struct bpf_elf_prog {
 	const char		*license;
 };
 
+struct bpf_hash_entry {
+	unsigned int		pinning;
+	const char		*subpath;
+	struct bpf_hash_entry	*next;
+};
+
 struct bpf_elf_ctx {
 	Elf			*elf_fd;
 	GElf_Ehdr		elf_hdr;
@@ -474,6 +480,7 @@ struct bpf_elf_ctx {
 	enum bpf_prog_type	type;
 	bool			verbose;
 	struct bpf_elf_st	stat;
+	struct bpf_hash_entry	*ht[256];
 };
 
 struct bpf_elf_sec_data {
@@ -771,20 +778,34 @@ static int bpf_init_env(const char *pathname)
 	return 0;
 }
 
-static bool bpf_no_pinning(int pinning)
+static const char *bpf_custom_pinning(const struct bpf_elf_ctx *ctx,
+				      uint32_t pinning)
+{
+	struct bpf_hash_entry *entry;
+
+	entry = ctx->ht[pinning & (ARRAY_SIZE(ctx->ht) - 1)];
+	while (entry && entry->pinning != pinning)
+		entry = entry->next;
+
+	return entry ? entry->subpath : NULL;
+}
+
+static bool bpf_no_pinning(const struct bpf_elf_ctx *ctx,
+			   uint32_t pinning)
 {
 	switch (pinning) {
 	case PIN_OBJECT_NS:
 	case PIN_GLOBAL_NS:
 		return false;
 	case PIN_NONE:
-	default:
 		return true;
+	default:
+		return !bpf_custom_pinning(ctx, pinning);
 	}
 }
 
 static void bpf_make_pathname(char *pathname, size_t len, const char *name,
-			      int pinning)
+			      const struct bpf_elf_ctx *ctx, uint32_t pinning)
 {
 	switch (pinning) {
 	case PIN_OBJECT_NS:
@@ -795,41 +816,89 @@ static void bpf_make_pathname(char *pathname, size_t len, const char *name,
 		snprintf(pathname, len, "%s/%s/%s", bpf_get_tc_dir(),
 			 BPF_DIR_GLOBALS, name);
 		break;
+	default:
+		snprintf(pathname, len, "%s/../%s/%s", bpf_get_tc_dir(),
+			 bpf_custom_pinning(ctx, pinning), name);
+		break;
 	}
 }
 
-static int bpf_probe_pinned(const char *name, int pinning)
+static int bpf_probe_pinned(const char *name, const struct bpf_elf_ctx *ctx,
+			    uint32_t pinning)
 {
 	char pathname[PATH_MAX];
 
-	if (bpf_no_pinning(pinning) || !bpf_get_tc_dir())
+	if (bpf_no_pinning(ctx, pinning) || !bpf_get_tc_dir())
 		return 0;
 
-	bpf_make_pathname(pathname, sizeof(pathname), name, pinning);
+	bpf_make_pathname(pathname, sizeof(pathname), name, ctx, pinning);
 	return bpf_obj_get(pathname);
 }
 
-static int bpf_place_pinned(int fd, const char *name, int pinning)
+static int bpf_make_obj_path(void)
 {
-	char pathname[PATH_MAX];
+	char tmp[PATH_MAX];
 	int ret;
 
-	if (bpf_no_pinning(pinning) || !bpf_get_tc_dir())
-		return 0;
+	snprintf(tmp, sizeof(tmp), "%s/%s", bpf_get_tc_dir(),
+		 bpf_get_obj_uid(NULL));
+
+	ret = mkdir(tmp, S_IRWXU);
+	if (ret && errno != EEXIST) {
+		fprintf(stderr, "mkdir %s failed: %s\n", tmp, strerror(errno));
+		return ret;
+	}
+
+	return 0;
+}
+
+static int bpf_make_custom_path(const char *todo)
+{
+	char tmp[PATH_MAX], rem[PATH_MAX], *sub;
+	int ret;
+
+	snprintf(tmp, sizeof(tmp), "%s/../", bpf_get_tc_dir());
+	snprintf(rem, sizeof(rem), "%s/", todo);
+	sub = strtok(rem, "/");
 
-	if (pinning == PIN_OBJECT_NS) {
-		snprintf(pathname, sizeof(pathname), "%s/%s",
-			 bpf_get_tc_dir(), bpf_get_obj_uid(NULL));
+	while (sub) {
+		if (strlen(tmp) + strlen(sub) + 2 > PATH_MAX)
+			return -EINVAL;
+
+		strcat(tmp, sub);
+		strcat(tmp, "/");
 
-		ret = mkdir(pathname, S_IRWXU);
+		ret = mkdir(tmp, S_IRWXU);
 		if (ret && errno != EEXIST) {
-			fprintf(stderr, "mkdir %s failed: %s\n", pathname,
+			fprintf(stderr, "mkdir %s failed: %s\n", tmp,
 				strerror(errno));
 			return ret;
 		}
+
+		sub = strtok(NULL, "/");
 	}
 
-	bpf_make_pathname(pathname, sizeof(pathname), name, pinning);
+	return 0;
+}
+
+static int bpf_place_pinned(int fd, const char *name,
+			    const struct bpf_elf_ctx *ctx, uint32_t pinning)
+{
+	char pathname[PATH_MAX];
+	const char *tmp;
+	int ret = 0;
+
+	if (bpf_no_pinning(ctx, pinning) || !bpf_get_tc_dir())
+		return 0;
+
+	if (pinning == PIN_OBJECT_NS)
+		ret = bpf_make_obj_path();
+	else if ((tmp = bpf_custom_pinning(ctx, pinning)))
+		ret = bpf_make_custom_path(tmp);
+	if (ret < 0)
+		return ret;
+
+	bpf_make_pathname(pathname, sizeof(pathname), name, ctx, pinning);
 	return bpf_obj_pin(fd, pathname);
 }
 
@@ -856,11 +925,11 @@ static int bpf_prog_attach(const char *section,
 }
 
 static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
-			  bool verbose)
+			  const struct bpf_elf_ctx *ctx, bool verbose)
 {
 	int fd, ret;
 
-	fd = bpf_probe_pinned(name, map->pinning);
+	fd = bpf_probe_pinned(name, ctx, map->pinning);
 	if (fd > 0) {
 		ret = bpf_map_selfcheck_pinned(fd, map);
 		if (ret < 0) {
@@ -889,7 +958,7 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 			return fd;
 	}
 
-	ret = bpf_place_pinned(fd, name, map->pinning);
+	ret = bpf_place_pinned(fd, name, ctx, map->pinning);
 	if (ret < 0 && errno != EEXIST) {
 		fprintf(stderr, "Could not pin %s map: %s\n", name,
 			strerror(errno));
@@ -940,7 +1009,8 @@ static int bpf_maps_attach_all(struct bpf_elf_ctx *ctx)
 		if (!map_name)
 			return -EIO;
 
-		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx->verbose);
+		fd = bpf_map_attach(map_name, &ctx->maps[i], ctx,
+				    ctx->verbose);
 		if (fd < 0)
 			return fd;
 
@@ -1258,6 +1328,105 @@ static void bpf_save_finfo(struct bpf_elf_ctx *ctx)
 	ctx->stat.st_ino = st.st_ino;
 }
 
+static int bpf_read_pin_mapping(FILE *fp, uint32_t *id, char *path)
+{
+	char buff[PATH_MAX];
+
+	while (fgets(buff, sizeof(buff), fp)) {
+		char *ptr = buff;
+
+		while (*ptr == ' ' || *ptr == '\t')
+			ptr++;
+
+		if (*ptr == '#' || *ptr == '\n' || *ptr == 0)
+			continue;
+
+		if (sscanf(ptr, "%i %s\n", id, path) != 2 &&
+		    sscanf(ptr, "%i %s #", id, path) != 2) {
+			strcpy(path, ptr);
+			return -1;
+		}
+
+		return 1;
+	}
+
+	return 0;
+}
+
+static bool bpf_pinning_reserved(uint32_t pinning)
+{
+	switch (pinning) {
+	case PIN_NONE:
+	case PIN_OBJECT_NS:
+	case PIN_GLOBAL_NS:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static void bpf_hash_init(struct bpf_elf_ctx *ctx, const char *db_file)
+{
+	struct bpf_hash_entry *entry;
+	char subpath[PATH_MAX];
+	uint32_t pinning;
+	FILE *fp;
+	int ret;
+
+	fp = fopen(db_file, "r");
+	if (!fp)
+		return;
+
+	memset(subpath, 0, sizeof(subpath));
+	while ((ret = bpf_read_pin_mapping(fp, &pinning, subpath))) {
+		if (ret == -1) {
+			fprintf(stderr, "Database %s is corrupted at: %s\n",
+				db_file, subpath);
+			fclose(fp);
+			return;
+		}
+
+		if (bpf_pinning_reserved(pinning)) {
+			fprintf(stderr, "Database %s, id %u is reserved - "
+				"ignoring!\n", db_file, pinning);
+			continue;
+		}
+
+		entry = malloc(sizeof(*entry));
+		if (!entry) {
+			fprintf(stderr, "No memory left for db entry!\n");
+			continue;
+		}
+
+		entry->pinning = pinning;
+		entry->subpath = strdup(subpath);
+		if (!entry->subpath) {
+			fprintf(stderr, "No memory left for db entry!\n");
+			free(entry);
+			continue;
+		}
+
+		entry->next = ctx->ht[pinning & (ARRAY_SIZE(ctx->ht) - 1)];
+		ctx->ht[pinning & (ARRAY_SIZE(ctx->ht) - 1)] = entry;
+	}
+
+	fclose(fp);
+}
+
+static void bpf_hash_destroy(struct bpf_elf_ctx *ctx)
+{
+	struct bpf_hash_entry *entry;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ctx->ht); i++) {
+		while ((entry = ctx->ht[i]) != NULL) {
+			ctx->ht[i] = entry->next;
+			free((char *)entry->subpath);
+			free(entry);
+		}
+	}
+}
+
 static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 			    enum bpf_prog_type type, bool verbose)
 {
@@ -1295,6 +1464,8 @@ static int bpf_elf_ctx_init(struct bpf_elf_ctx *ctx, const char *pathname,
 	}
 
 	bpf_save_finfo(ctx);
+	bpf_hash_init(ctx, CONFDIR "/bpf_pinning");
+
 	return 0;
 out_elf:
 	elf_end(ctx->elf_fd);
@@ -1331,6 +1502,7 @@ static void bpf_elf_ctx_destroy(struct bpf_elf_ctx *ctx, bool failure)
 	if (failure)
 		bpf_maps_teardown(ctx);
 
+	bpf_hash_destroy(ctx);
 	free(ctx->sec_done);
 	elf_end(ctx->elf_fd);
 	close(ctx->obj_fd);
-- 
1.9.3
