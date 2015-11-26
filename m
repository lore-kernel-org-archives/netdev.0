From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 4/5] {f,m}_bpf: allow updates on program arrays
Date: Thu, 26 Nov 2015 13:58:32 +0100
Message-ID: <02e8e281c22e73a63f1209194ac55b03323156ab.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37258 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbKZM6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:58:43 -0500
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
In-Reply-To: <cover.1448541097.git.daniel@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have all infrastructure in place now, allow atomic live updates
on program arrays. This can be very useful e.g. in case programs that are
being tail-called need to be replaced, f.e. when classifier functionality
needs to be changed, new protocols added/removed during runtime, etc.

Thus, provide a way for in-place code updates, minimal example: Given is
an object file cls.o that contains the entry point in section 'classifier',
has a globally pinned program array 'jmp' with 2 slots and id of 0, and
two tail called programs under section '0/0' (prog array key 0) and '0/1'
(prog array key 1), the section encoding for the loader is <id/key>.
Adding the filter loads everything into cls_bpf:

  tc filter add dev foo parent ffff: bpf da obj cls.o

Now, the program under section '0/1' needs to be replaced with an updated
version that resides in the same section (also full path to tc's subfolder
of the mount point can be passed, e.g. /sys/fs/bpf/tc/globals/jmp):

  tc exec bpf graft m:globals/jmp obj cls.o sec 0/1

In case the program resides under a different section 'foo', it can also
be injected into the program array like:

  tc exec bpf graft m:globals/jmp key 1 obj cls.o sec foo

If the new tail called classifier program is already available as a pinned
object somewhere (here: /sys/fs/bpf/tc/progs/parser), it can be injected
into the prog array like:

  tc exec bpf graft m:globals/jmp key 1 fd m:progs/parser

In the kernel, the program on key 1 is being atomically replaced and the
old one's refcount dropped.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tc/e_bpf.c  |  30 ++++-
 tc/tc_bpf.c | 424 +++++++++++++++++++++++++++++++++++++++---------------------
 tc/tc_bpf.h |   1 +
 3 files changed, 306 insertions(+), 149 deletions(-)

diff --git a/tc/e_bpf.c b/tc/e_bpf.c
index 1f386c3..2d650a4 100644
--- a/tc/e_bpf.c
+++ b/tc/e_bpf.c
@@ -26,10 +26,19 @@ static char *argv_default[] = { BPF_DEFAULT_CMD, NULL };
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... bpf [ import UDS_FILE ] [ run CMD ] [ debug ]\n\n");
+	fprintf(stderr, "Usage: ... bpf [ import UDS_FILE ] [ run CMD ]\n");
+	fprintf(stderr, "       ... bpf [ debug ]\n");
+	fprintf(stderr, "       ... bpf [ graft MAP_FILE ] [ key KEY ]\n");
+	fprintf(stderr, "          `... [ object-file OBJ_FILE ] [ type TYPE ] [ section NAME ] [ verbose ]\n");
+	fprintf(stderr, "          `... [ object-pinned PROG_FILE ]\n");
+	fprintf(stderr, "\n");
 	fprintf(stderr, "Where UDS_FILE provides the name of a unix domain socket file\n");
 	fprintf(stderr, "to import eBPF maps and the optional CMD denotes the command\n");
 	fprintf(stderr, "to be executed (default: \'%s\').\n", BPF_DEFAULT_CMD);
+	fprintf(stderr, "Where MAP_FILE points to a pinned map, OBJ_FILE to an object file\n");
+	fprintf(stderr, "and PROG_FILE to a pinned program. TYPE can be {cls, act}, where\n");
+	fprintf(stderr, "\'cls\' is default. KEY is optional and can be inferred from the\n");
+	fprintf(stderr, "section name, otherwise it needs to be provided.\n");
 }
 
 static int bpf_num_env_entries(void)
@@ -67,6 +76,25 @@ static int parse_bpf(struct exec_util *eu, int argc, char **argv)
 				fprintf(stderr,
 					"No trace pipe, tracefs not mounted?\n");
 			return -1;
+		} else if (matches(*argv, "graft") == 0) {
+			const char *bpf_map_path;
+			bool has_key = false;
+			uint32_t key;
+
+			NEXT_ARG();
+			bpf_map_path = *argv;
+			NEXT_ARG();
+			if (matches(*argv, "key") == 0) {
+				NEXT_ARG();
+				if (get_unsigned(&key, *argv, 0)) {
+					fprintf(stderr, "Illegal \"key\"\n");
+					return -1;
+				}
+				has_key = true;
+				NEXT_ARG();
+			}
+			return bpf_graft_map(bpf_map_path, has_key ?
+					     &key : NULL, argc, argv);
 		} else {
 			explain();
 			return -1;
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 17498c1..b9e9593 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -76,13 +76,17 @@ static int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 #endif
 }
 
-static int bpf_obj_get(const char *pathname)
+static int bpf_map_update(int fd, const void *key, const void *value,
+			  uint64_t flags)
 {
 	union bpf_attr attr = {
-		.pathname	= bpf_ptr_to_u64(pathname),
+		.map_fd		= fd,
+		.key		= bpf_ptr_to_u64(key),
+		.value		= bpf_ptr_to_u64(value),
+		.flags		= flags,
 	};
 
-	return bpf(BPF_OBJ_GET, &attr, sizeof(attr));
+	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
 static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
@@ -205,7 +209,8 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 		ops[i].jf, ops[i].k);
 }
 
-static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map)
+static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
+				    int length)
 {
 	char file[PATH_MAX], buff[4096];
 	struct bpf_elf_map tmp, zero;
@@ -234,7 +239,7 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map)
 
 	fclose(fp);
 
-	if (!memcmp(&tmp, map, offsetof(struct bpf_elf_map, id))) {
+	if (!memcmp(&tmp, map, length)) {
 		return 0;
 	} else {
 		memset(&zero, 0, sizeof(zero));
@@ -243,7 +248,7 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map)
 		 * case, everything is 0. It is guaranteed that no such map exists
 		 * since map type of 0 is unloadable BPF_MAP_TYPE_UNSPEC.
 		 */
-		if (!memcmp(&tmp, &zero, offsetof(struct bpf_elf_map, id)))
+		if (!memcmp(&tmp, &zero, length))
 			return 0;
 
 		fprintf(stderr, "Map specs from pinned file differ!\n");
@@ -251,6 +256,35 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map)
 	}
 }
 
+static int bpf_mnt_fs(const char *target)
+{
+	bool bind_done = false;
+
+	while (mount("", target, "none", MS_PRIVATE | MS_REC, NULL)) {
+		if (errno != EINVAL || bind_done) {
+			fprintf(stderr, "mount --make-private %s failed: %s\n",
+				target,	strerror(errno));
+			return -1;
+		}
+
+		if (mount(target, target, "none", MS_BIND, NULL)) {
+			fprintf(stderr, "mount --bind %s %s failed: %s\n",
+				target,	target, strerror(errno));
+			return -1;
+		}
+
+		bind_done = true;
+	}
+
+	if (mount("bpf", target, "bpf", 0, NULL)) {
+		fprintf(stderr, "mount -t bpf bpf %s failed: %s\n",
+			target,	strerror(errno));
+		return -1;
+	}
+
+	return 0;
+}
+
 static int bpf_valid_mntpt(const char *mnt, unsigned long magic)
 {
 	struct statfs st_fs;
@@ -342,6 +376,79 @@ int bpf_trace_pipe(void)
 	return 0;
 }
 
+static const char *bpf_get_tc_dir(void)
+{
+	static bool bpf_mnt_cached = false;
+	static char bpf_tc_dir[PATH_MAX];
+	static const char *mnt;
+	static const char * const bpf_known_mnts[] = {
+		BPF_DIR_MNT,
+		0,
+	};
+	char bpf_mnt[PATH_MAX] = BPF_DIR_MNT;
+	char bpf_glo_dir[PATH_MAX];
+	int ret;
+
+	if (bpf_mnt_cached)
+		goto done;
+
+	mnt = bpf_find_mntpt("bpf", BPF_FS_MAGIC, bpf_mnt, sizeof(bpf_mnt),
+			     bpf_known_mnts);
+	if (!mnt) {
+		mnt = getenv(BPF_ENV_MNT);
+		if (!mnt)
+			mnt = BPF_DIR_MNT;
+		ret = bpf_mnt_fs(mnt);
+		if (ret) {
+			mnt = NULL;
+			goto out;
+		}
+	}
+
+	snprintf(bpf_tc_dir, sizeof(bpf_tc_dir), "%s/%s", mnt, BPF_DIR_TC);
+	ret = mkdir(bpf_tc_dir, S_IRWXU);
+	if (ret && errno != EEXIST) {
+		fprintf(stderr, "mkdir %s failed: %s\n", bpf_tc_dir,
+			strerror(errno));
+		mnt = NULL;
+		goto out;
+	}
+
+	snprintf(bpf_glo_dir, sizeof(bpf_glo_dir), "%s/%s",
+		 bpf_tc_dir, BPF_DIR_GLOBALS);
+	ret = mkdir(bpf_glo_dir, S_IRWXU);
+	if (ret && errno != EEXIST) {
+		fprintf(stderr, "mkdir %s failed: %s\n", bpf_glo_dir,
+			strerror(errno));
+		mnt = NULL;
+		goto out;
+	}
+
+	mnt = bpf_tc_dir;
+out:
+	bpf_mnt_cached = true;
+done:
+	return mnt;
+}
+
+static int bpf_obj_get(const char *pathname)
+{
+	union bpf_attr attr;
+	char tmp[PATH_MAX];
+
+	if (strlen(pathname) > 2 && pathname[0] == 'm' &&
+	    pathname[1] == ':' && bpf_get_tc_dir()) {
+		snprintf(tmp, sizeof(tmp), "%s/%s",
+			 bpf_get_tc_dir(), pathname + 2);
+		pathname = tmp;
+	}
+
+	memset(&attr, 0, sizeof(attr));
+	attr.pathname = bpf_ptr_to_u64(pathname);
+
+	return bpf(BPF_OBJ_GET, &attr, sizeof(attr));
+}
+
 const char *bpf_default_section(const enum bpf_prog_type type)
 {
 	switch (type) {
@@ -354,37 +461,45 @@ const char *bpf_default_section(const enum bpf_prog_type type)
 	}
 }
 
-int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
-		     enum bpf_prog_type type, const char **ptr_object,
-		     const char **ptr_uds_name, struct nlmsghdr *n)
+enum bpf_mode {
+	CBPF_BYTECODE = 0,
+	CBPF_FILE,
+	EBPF_OBJECT,
+	EBPF_PINNED,
+	__BPF_MODE_MAX,
+#define BPF_MODE_MAX	__BPF_MODE_MAX
+};
+
+static int bpf_parse(int *ptr_argc, char ***ptr_argv, const bool *opt_tbl,
+		     enum bpf_prog_type *type, enum bpf_mode *mode,
+		     const char **ptr_object, const char **ptr_section,
+		     const char **ptr_uds_name, struct sock_filter *opcodes)
 {
-	struct sock_filter opcodes[BPF_MAXINSNS];
 	const char *file, *section, *uds_name;
-	char **argv = *ptr_argv;
-	int argc = *ptr_argc;
-	char annotation[256];
 	bool verbose = false;
-	int ret;
-	enum bpf_mode {
-		CBPF_BYTECODE,
-		CBPF_FILE,
-		EBPF_OBJECT,
-		EBPF_PINNED,
-	} mode;
-
-	if (matches(*argv, "bytecode") == 0 ||
-	    strcmp(*argv, "bc") == 0) {
-		mode = CBPF_BYTECODE;
-	} else if (matches(*argv, "bytecode-file") == 0 ||
-		   strcmp(*argv, "bcf") == 0) {
-		mode = CBPF_FILE;
-	} else if (matches(*argv, "object-file") == 0 ||
-		   strcmp(*argv, "obj") == 0) {
-		mode = EBPF_OBJECT;
-	} else if (matches(*argv, "object-pinned") == 0 ||
-		   matches(*argv, "pinned") == 0 ||
-		   matches(*argv, "fd") == 0) {
-		mode = EBPF_PINNED;
+	int ret, argc;
+	char **argv;
+
+	argv = *ptr_argv;
+	argc = *ptr_argc;
+
+	if (opt_tbl[CBPF_BYTECODE] &&
+	    (matches(*argv, "bytecode") == 0 ||
+	     strcmp(*argv, "bc") == 0)) {
+		*mode = CBPF_BYTECODE;
+	} else if (opt_tbl[CBPF_FILE] &&
+		   (matches(*argv, "bytecode-file") == 0 ||
+		    strcmp(*argv, "bcf") == 0)) {
+		*mode = CBPF_FILE;
+	} else if (opt_tbl[EBPF_OBJECT] &&
+		   (matches(*argv, "object-file") == 0 ||
+		    strcmp(*argv, "obj") == 0)) {
+		*mode = EBPF_OBJECT;
+	} else if (opt_tbl[EBPF_PINNED] &&
+		   (matches(*argv, "object-pinned") == 0 ||
+		    matches(*argv, "pinned") == 0 ||
+		    matches(*argv, "fd") == 0)) {
+		*mode = EBPF_PINNED;
 	} else {
 		fprintf(stderr, "What mode is \"%s\"?\n", *argv);
 		return -1;
@@ -392,11 +507,29 @@ int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
 
 	NEXT_ARG();
 	file = section = uds_name = NULL;
-	if (mode == EBPF_OBJECT || mode == EBPF_PINNED) {
+	if (*mode == EBPF_OBJECT || *mode == EBPF_PINNED) {
 		file = *argv;
 		NEXT_ARG_FWD();
 
-		section = bpf_default_section(type);
+		if (*type == BPF_PROG_TYPE_UNSPEC) {
+			if (argc > 0 && matches(*argv, "type") == 0) {
+				NEXT_ARG();
+				if (matches(*argv, "cls") == 0) {
+					*type = BPF_PROG_TYPE_SCHED_CLS;
+				} else if (matches(*argv, "act") == 0) {
+					*type = BPF_PROG_TYPE_SCHED_ACT;
+				} else {
+					fprintf(stderr, "What type is \"%s\"?\n",
+						*argv);
+					return -1;
+				}
+				NEXT_ARG_FWD();
+			} else {
+				*type = BPF_PROG_TYPE_SCHED_CLS;
+			}
+		}
+
+		section = bpf_default_section(*type);
 		if (argc > 0 && matches(*argv, "section") == 0) {
 			NEXT_ARG();
 			section = *argv;
@@ -419,35 +552,125 @@ int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
 		PREV_ARG();
 	}
 
-	if (mode == CBPF_BYTECODE || mode == CBPF_FILE)
-		ret = bpf_ops_parse(argc, argv, opcodes, mode == CBPF_FILE);
-	else if (mode == EBPF_OBJECT)
-		ret = bpf_obj_open(file, type, section, verbose);
-	else if (mode == EBPF_PINNED)
+	if (*mode == CBPF_BYTECODE || *mode == CBPF_FILE)
+		ret = bpf_ops_parse(argc, argv, opcodes, *mode == CBPF_FILE);
+	else if (*mode == EBPF_OBJECT)
+		ret = bpf_obj_open(file, *type, section, verbose);
+	else if (*mode == EBPF_PINNED)
 		ret = bpf_obj_get(file);
-	if (ret < 0)
+	else
 		return -1;
 
+	if (ptr_object)
+		*ptr_object = file;
+	if (ptr_section)
+		*ptr_section = section;
+	if (ptr_uds_name)
+		*ptr_uds_name = uds_name;
+
+	*ptr_argc = argc;
+	*ptr_argv = argv;
+
+	return ret;
+}
+
+int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
+		     enum bpf_prog_type type, const char **ptr_object,
+		     const char **ptr_uds_name, struct nlmsghdr *n)
+{
+	struct sock_filter opcodes[BPF_MAXINSNS];
+	const bool opt_tbl[BPF_MODE_MAX] = {
+		[CBPF_BYTECODE]	= true,
+		[CBPF_FILE]	= true,
+		[EBPF_OBJECT]	= true,
+		[EBPF_PINNED]	= true,
+	};
+	char annotation[256];
+	const char *section;
+	enum bpf_mode mode;
+	int ret;
+
+	ret = bpf_parse(ptr_argc, ptr_argv, opt_tbl, &type, &mode,
+			ptr_object, &section, ptr_uds_name, opcodes);
+	if (ret < 0)
+		return ret;
+
 	if (mode == CBPF_BYTECODE || mode == CBPF_FILE) {
 		addattr16(n, MAX_MSG, nla_tbl[BPF_NLA_OPS_LEN], ret);
 		addattr_l(n, MAX_MSG, nla_tbl[BPF_NLA_OPS], opcodes,
 			  ret * sizeof(struct sock_filter));
-	} else if (mode == EBPF_OBJECT || mode == EBPF_PINNED) {
+	}
+
+	if (mode == EBPF_OBJECT || mode == EBPF_PINNED) {
 		snprintf(annotation, sizeof(annotation), "%s:[%s]",
-			 basename(file), mode == EBPF_PINNED ? "*fsobj" :
-			 section);
+			 basename(*ptr_object), mode == EBPF_PINNED ?
+			 "*fsobj" : section);
 
 		addattr32(n, MAX_MSG, nla_tbl[BPF_NLA_FD], ret);
 		addattrstrz(n, MAX_MSG, nla_tbl[BPF_NLA_NAME], annotation);
 	}
 
-	*ptr_object = file;
-	*ptr_uds_name = uds_name;
+	return 0;
+}
 
-	*ptr_argc = argc;
-	*ptr_argv = argv;
+int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv)
+{
+	enum bpf_prog_type type = BPF_PROG_TYPE_UNSPEC;
+	const bool opt_tbl[BPF_MODE_MAX] = {
+		[CBPF_BYTECODE]	= false,
+		[CBPF_FILE]	= false,
+		[EBPF_OBJECT]	= true,
+		[EBPF_PINNED]	= true,
+	};
+	const struct bpf_elf_map test = {
+		.type		= BPF_MAP_TYPE_PROG_ARRAY,
+		.size_key	= sizeof(int),
+		.size_value	= sizeof(int),
+	};
+	int ret, prog_fd, map_fd;
+	const char *section;
+	enum bpf_mode mode;
+	uint32_t map_key;
+
+	prog_fd = bpf_parse(&argc, &argv, opt_tbl, &type, &mode,
+			    NULL, &section, NULL, NULL);
+	if (prog_fd < 0)
+		return prog_fd;
+	if (key) {
+		map_key = *key;
+	} else {
+		ret = sscanf(section, "%*i/%i", &map_key);
+		if (ret != 1) {
+			fprintf(stderr, "Couldn\'t infer map key from section "
+				"name! Please provide \'key\' argument!\n");
+			ret = -EINVAL;
+			goto out_prog;
+		}
+	}
 
-	return 0;
+	map_fd = bpf_obj_get(map_path);
+	if (map_fd < 0) {
+		fprintf(stderr, "Couldn\'t retrieve pinned map \'%s\': %s\n",
+			map_path, strerror(errno));
+		ret = map_fd;
+		goto out_prog;
+	}
+
+	ret = bpf_map_selfcheck_pinned(map_fd, &test,
+				       offsetof(struct bpf_elf_map, max_elem));
+	if (ret < 0) {
+		fprintf(stderr, "Map \'%s\' self-check failed!\n", map_path);
+		goto out_map;
+	}
+
+	ret = bpf_map_update(map_fd, &map_key, &prog_fd, BPF_ANY);
+	if (ret < 0)
+		fprintf(stderr, "Map update failed: %s\n", strerror(errno));
+out_map:
+	close(map_fd);
+out_prog:
+	close(prog_fd);
+	return ret;
 }
 
 #ifdef HAVE_ELF
@@ -530,19 +753,6 @@ static int bpf_map_create(enum bpf_map_type type, unsigned int size_key,
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-static int bpf_map_update(int fd, const void *key, const void *value,
-			  uint64_t flags)
-{
-	union bpf_attr attr = {
-		.map_fd		= fd,
-		.key		= bpf_ptr_to_u64(key),
-		.value		= bpf_ptr_to_u64(value),
-		.flags		= flags,
-	};
-
-	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
-}
-
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 			 size_t size, const char *license)
 {
@@ -672,90 +882,6 @@ done:
 	return bpf_uid;
 }
 
-static int bpf_mnt_fs(const char *target)
-{
-	bool bind_done = false;
-
-	while (mount("", target, "none", MS_PRIVATE | MS_REC, NULL)) {
-		if (errno != EINVAL || bind_done) {
-			fprintf(stderr, "mount --make-private %s failed: %s\n",
-				target,	strerror(errno));
-			return -1;
-		}
-
-		if (mount(target, target, "none", MS_BIND, NULL)) {
-			fprintf(stderr, "mount --bind %s %s failed: %s\n",
-				target,	target, strerror(errno));
-			return -1;
-		}
-
-		bind_done = true;
-	}
-
-	if (mount("bpf", target, "bpf", 0, NULL)) {
-		fprintf(stderr, "mount -t bpf bpf %s failed: %s\n",
-			target,	strerror(errno));
-		return -1;
-	}
-
-	return 0;
-}
-
-static const char *bpf_get_tc_dir(void)
-{
-	static bool bpf_mnt_cached = false;
-	static char bpf_tc_dir[PATH_MAX];
-	static const char *mnt;
-	static const char * const bpf_known_mnts[] = {
-		BPF_DIR_MNT,
-		0,
-	};
-	char bpf_mnt[PATH_MAX] = BPF_DIR_MNT;
-	char bpf_glo_dir[PATH_MAX];
-	int ret;
-
-	if (bpf_mnt_cached)
-		goto done;
-
-	mnt = bpf_find_mntpt("bpf", BPF_FS_MAGIC, bpf_mnt, sizeof(bpf_mnt),
-			     bpf_known_mnts);
-	if (!mnt) {
-		mnt = getenv(BPF_ENV_MNT);
-		if (!mnt)
-			mnt = BPF_DIR_MNT;
-		ret = bpf_mnt_fs(mnt);
-		if (ret) {
-			mnt = NULL;
-			goto out;
-		}
-	}
-
-	snprintf(bpf_tc_dir, sizeof(bpf_tc_dir), "%s/%s", mnt, BPF_DIR_TC);
-	ret = mkdir(bpf_tc_dir, S_IRWXU);
-	if (ret && errno != EEXIST) {
-		fprintf(stderr, "mkdir %s failed: %s\n", bpf_tc_dir,
-			strerror(errno));
-		mnt = NULL;
-		goto out;
-	}
-
-	snprintf(bpf_glo_dir, sizeof(bpf_glo_dir), "%s/%s",
-		 bpf_tc_dir, BPF_DIR_GLOBALS);
-	ret = mkdir(bpf_glo_dir, S_IRWXU);
-	if (ret && errno != EEXIST) {
-		fprintf(stderr, "mkdir %s failed: %s\n", bpf_glo_dir,
-			strerror(errno));
-		mnt = NULL;
-		goto out;
-	}
-
-	mnt = bpf_tc_dir;
-out:
-	bpf_mnt_cached = true;
-done:
-	return mnt;
-}
-
 static int bpf_init_env(const char *pathname)
 {
 	struct rlimit limit = {
@@ -931,7 +1057,9 @@ static int bpf_map_attach(const char *name, const struct bpf_elf_map *map,
 
 	fd = bpf_probe_pinned(name, ctx, map->pinning);
 	if (fd > 0) {
-		ret = bpf_map_selfcheck_pinned(fd, map);
+		ret = bpf_map_selfcheck_pinned(fd, map,
+					       offsetof(struct bpf_elf_map,
+							id));
 		if (ret < 0) {
 			close(fd);
 			fprintf(stderr, "Map \'%s\' self-check failed!\n",
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index dea3c3b..526d0b1 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -55,6 +55,7 @@ const char *bpf_default_section(const enum bpf_prog_type type);
 int bpf_parse_common(int *ptr_argc, char ***ptr_argv, const int *nla_tbl,
 		     enum bpf_prog_type type, const char **ptr_object,
 		     const char **ptr_uds_name, struct nlmsghdr *n);
+int bpf_graft_map(const char *map_path, uint32_t *key, int argc, char **argv);
 
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
-- 
1.9.3
