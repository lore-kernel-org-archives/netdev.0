From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 07/14] tools lib bpf: Add BPF program pinning APIs
Date: Wed,  1 Feb 2017 09:25:00 -0300
Message-ID: <20170201122507.29303-8-acme@kernel.org>
References: <20170201122507.29303-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170201122507.29303-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe@ovn.org>

Add new APIs to pin a BPF program (or specific instances) to the
filesystem.  The user can specify the path full path within a BPF
filesystem to pin the program.

bpf_program__pin_instance(prog, path, n) will pin the nth instance of
'prog' to the specified path.

bpf_program__pin(prog, path) will create the directory 'path' (if it
does not exist) and pin each instance within that directory. For
instance, path/0, path/1, path/2.

Committer notes:

- Add missing headers for mkdir()

- Check strdup() for failure

- Check snprintf >= size, not >, as == also means truncated, see 'man
  snprintf', return value.

- Conditionally define BPF_FS_MAGIC, as it isn't in magic.h in older
  systems and we're not yet having a tools/include/uapi/linux/magic.h
  copy.

- Do not include linux/magic.h, not present in older distros.

Signed-off-by: Joe Stringer <joe@ovn.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-2-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/bpf/libbpf.c | 120 +++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |   3 ++
 2 files changed, 123 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index e6cd62b1264b..c4465b2fddf6 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -4,6 +4,7 @@
  * Copyright (C) 2013-2015 Alexei Starovoitov <ast@kernel.org>
  * Copyright (C) 2015 Wang Nan <wangnan0@huawei.com>
  * Copyright (C) 2015 Huawei Inc.
+ * Copyright (C) 2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU Lesser General Public
@@ -22,6 +23,7 @@
 #include <stdlib.h>
 #include <stdio.h>
 #include <stdarg.h>
+#include <libgen.h>
 #include <inttypes.h>
 #include <string.h>
 #include <unistd.h>
@@ -32,6 +34,10 @@
 #include <linux/kernel.h>
 #include <linux/bpf.h>
 #include <linux/list.h>
+#include <linux/limits.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/vfs.h>
 #include <libelf.h>
 #include <gelf.h>
 
@@ -42,6 +48,10 @@
 #define EM_BPF 247
 #endif
 
+#ifndef BPF_FS_MAGIC
+#define BPF_FS_MAGIC		0xcafe4a11
+#endif
+
 #define __printf(a, b)	__attribute__((format(printf, a, b)))
 
 __printf(1, 2)
@@ -1237,6 +1247,116 @@ int bpf_object__load(struct bpf_object *obj)
 	return err;
 }
 
+static int check_path(const char *path)
+{
+	struct statfs st_fs;
+	char *dname, *dir;
+	int err = 0;
+
+	if (path == NULL)
+		return -EINVAL;
+
+	dname = strdup(path);
+	if (dname == NULL)
+		return -ENOMEM;
+
+	dir = dirname(dname);
+	if (statfs(dir, &st_fs)) {
+		pr_warning("failed to statfs %s: %s\n", dir, strerror(errno));
+		err = -errno;
+	}
+	free(dname);
+
+	if (!err && st_fs.f_type != BPF_FS_MAGIC) {
+		pr_warning("specified path %s is not on BPF FS\n", path);
+		err = -EINVAL;
+	}
+
+	return err;
+}
+
+int bpf_program__pin_instance(struct bpf_program *prog, const char *path,
+			      int instance)
+{
+	int err;
+
+	err = check_path(path);
+	if (err)
+		return err;
+
+	if (prog == NULL) {
+		pr_warning("invalid program pointer\n");
+		return -EINVAL;
+	}
+
+	if (instance < 0 || instance >= prog->instances.nr) {
+		pr_warning("invalid prog instance %d of prog %s (max %d)\n",
+			   instance, prog->section_name, prog->instances.nr);
+		return -EINVAL;
+	}
+
+	if (bpf_obj_pin(prog->instances.fds[instance], path)) {
+		pr_warning("failed to pin program: %s\n", strerror(errno));
+		return -errno;
+	}
+	pr_debug("pinned program '%s'\n", path);
+
+	return 0;
+}
+
+static int make_dir(const char *path)
+{
+	int err = 0;
+
+	if (mkdir(path, 0700) && errno != EEXIST)
+		err = -errno;
+
+	if (err)
+		pr_warning("failed to mkdir %s: %s\n", path, strerror(-err));
+	return err;
+}
+
+int bpf_program__pin(struct bpf_program *prog, const char *path)
+{
+	int i, err;
+
+	err = check_path(path);
+	if (err)
+		return err;
+
+	if (prog == NULL) {
+		pr_warning("invalid program pointer\n");
+		return -EINVAL;
+	}
+
+	if (prog->instances.nr <= 0) {
+		pr_warning("no instances of prog %s to pin\n",
+			   prog->section_name);
+		return -EINVAL;
+	}
+
+	err = make_dir(path);
+	if (err)
+		return err;
+
+	for (i = 0; i < prog->instances.nr; i++) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s/%d", path, i);
+		if (len < 0)
+			return -EINVAL;
+		else if (len >= PATH_MAX)
+			return -ENAMETOOLONG;
+
+		err = bpf_program__pin_instance(prog, buf, i);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 void bpf_object__close(struct bpf_object *obj)
 {
 	size_t i;
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index 4014d1ba5e3d..9f8aa63b95f4 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -106,6 +106,9 @@ void *bpf_program__priv(struct bpf_program *prog);
 const char *bpf_program__title(struct bpf_program *prog, bool needs_copy);
 
 int bpf_program__fd(struct bpf_program *prog);
+int bpf_program__pin_instance(struct bpf_program *prog, const char *path,
+			      int instance);
+int bpf_program__pin(struct bpf_program *prog, const char *path);
 
 struct bpf_insn;
 
-- 
2.9.3
