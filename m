From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 5/7] tools lib bpf: Add bpf_program__pin()
Date: Sun, 22 Jan 2017 17:11:26 -0800
Message-ID: <20170123011128.26534-6-joe@ovn.org>
References: <20170123011128.26534-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123011128.26534-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new API to pin a BPF program to the filesystem. The user can
specify the path full path within a BPF filesystem to pin the program.
Programs with multiple instances are pinned as 'foo', 'foo_1', 'foo_2',
and so on.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v2: Don't automount BPF filesystem
    Split program, map, object pinning into separate APIs and separate
    patches.
---
 tools/lib/bpf/libbpf.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 77 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index e6cd62b1264b..eea5c74808f7 100644
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
@@ -31,7 +33,10 @@
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/bpf.h>
+#include <linux/magic.h>
 #include <linux/list.h>
+#include <linux/limits.h>
+#include <sys/vfs.h>
 #include <libelf.h>
 #include <gelf.h>
 
@@ -1237,6 +1242,77 @@ int bpf_object__load(struct bpf_object *obj)
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
+	if (bpf_obj_pin(prog->instances.fds[0], path)) {
+		pr_warning("failed to pin program: %s\n", strerror(errno));
+		return -errno;
+	}
+	pr_debug("pinned program '%s'\n", path);
+
+	for (i = 1; i < prog->instances.nr; i++) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s_%d", path, i);
+		if (len < 0)
+			return -EINVAL;
+		else if (len > PATH_MAX)
+			return -ENAMETOOLONG;
+
+		if (bpf_obj_pin(prog->instances.fds[i], buf)) {
+			pr_warning("failed to pin program: %s\n",
+				   strerror(errno));
+			return -errno;
+		}
+		pr_debug("pinned program '%s'\n", buf);
+	}
+
+	return 0;
+}
+
 void bpf_object__close(struct bpf_object *obj)
 {
 	size_t i;
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index 4014d1ba5e3d..7973087c377b 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -106,6 +106,7 @@ void *bpf_program__priv(struct bpf_program *prog);
 const char *bpf_program__title(struct bpf_program *prog, bool needs_copy);
 
 int bpf_program__fd(struct bpf_program *prog);
+int bpf_program__pin(struct bpf_program *prog, const char *path);
 
 struct bpf_insn;
 
-- 
2.11.0
