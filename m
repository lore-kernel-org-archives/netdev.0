From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 3/6] tools lib bpf: Add bpf_object__pin()
Date: Thu, 26 Jan 2017 13:19:58 -0800
Message-ID: <20170126212001.14103-4-joe@ovn.org>
References: <20170126212001.14103-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:58797 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753907AbdAZVUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 16:20:21 -0500
In-Reply-To: <20170126212001.14103-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new API to pin a BPF object to the filesystem. The user can
specify the path within a BPF filesystem to pin the object.
Programs will be pinned under a subdirectory named the same as the
program, with each instance appearing as a numbered file under that
directory, and maps will be pinned under the path using the name of
the map as the file basename.

For example, with the directory '/sys/fs/bpf/foo' and a BPF object which
contains two instances of a program named 'bar', and a map named 'baz':
/sys/fs/bpf/foo/bar/0
/sys/fs/bpf/foo/bar/1
/sys/fs/bpf/foo/baz

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: Mount to PATH/MAPNAME, PATH/PROGNAME/N (N = instance number)
v2: Don't automount BPF filesystem
    Split program, map, object pinning into separate APIs and separate
    patches.
---
 tools/lib/bpf/libbpf.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index ce987c02363e..703cfa986b34 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -36,6 +36,7 @@
 #include <linux/magic.h>
 #include <linux/list.h>
 #include <linux/limits.h>
+#include <sys/stat.h>
 #include <sys/vfs.h>
 #include <libelf.h>
 #include <gelf.h>
@@ -1371,6 +1372,59 @@ int bpf_map__pin(struct bpf_map *map, const char *path)
 	return 0;
 }
 
+int bpf_object__pin(struct bpf_object *obj, const char *path)
+{
+	struct bpf_program *prog;
+	struct bpf_map *map;
+	int err;
+
+	if (!obj)
+		return -ENOENT;
+
+	if (!obj->loaded) {
+		pr_warning("object not yet loaded; load it first\n");
+		return -ENOENT;
+	}
+
+	err = make_dir(path);
+	if (err)
+		return err;
+
+	bpf_map__for_each(map, obj) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s/%s", path,
+			       bpf_map__name(map));
+		if (len < 0)
+			return -EINVAL;
+		else if (len > PATH_MAX)
+			return -ENAMETOOLONG;
+
+		err = bpf_map__pin(map, buf);
+		if (err)
+			return err;
+	}
+
+	bpf_object__for_each_program(prog, obj) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s/%s", path,
+			       prog->section_name);
+		if (len < 0)
+			return -EINVAL;
+		else if (len > PATH_MAX)
+			return -ENAMETOOLONG;
+
+		err = bpf_program__pin(prog, buf);
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
index 2addf9d5b13c..b30394f9947a 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -65,6 +65,7 @@ struct bpf_object *bpf_object__open(const char *path);
 struct bpf_object *bpf_object__open_buffer(void *obj_buf,
 					   size_t obj_buf_sz,
 					   const char *name);
+int bpf_object__pin(struct bpf_object *object, const char *path);
 void bpf_object__close(struct bpf_object *object);
 
 /* Load/unload object into/from kernel */
-- 
2.11.0
