From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 7/7] tools lib bpf: Add bpf_object__pin()
Date: Sun, 22 Jan 2017 17:11:28 -0800
Message-ID: <20170123011128.26534-8-joe@ovn.org>
References: <20170123011128.26534-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:60282 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdAWBMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 20:12:03 -0500
In-Reply-To: <20170123011128.26534-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new API to pin a BPF object to the filesystem. The user can
specify the path full path within a BPF filesystem to pin the object.
Programs will be pinned under a subdirectory 'progs', and maps will be
pinned under a subdirectory 'maps'.

For example, with the directory '/sys/fs/bpf/foo':
/sys/fs/bpf/foo/progs/PROG_NAME
/sys/fs/bpf/foo/maps/MAP_NAME

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v2: Don't automount BPF filesystem
    Split program, map, object pinning into separate APIs and separate
    patches.
---
 tools/lib/bpf/libbpf.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 74 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index c1d8b07e21d2..41645dc51fa1 100644
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
@@ -1335,6 +1336,78 @@ int bpf_map__pin(struct bpf_map *map, const char *path)
 	return 0;
 }
 
+static int make_dir(const char *path, const char *dir)
+{
+	char buf[PATH_MAX];
+	int len, err = 0;
+
+	len = snprintf(buf, PATH_MAX, "%s/%s", path, dir);
+	if (len < 0)
+		err = -EINVAL;
+	else if (len >= PATH_MAX)
+		err = -ENAMETOOLONG;
+	if (!err && mkdir(buf, 0700) && errno != EEXIST)
+		err = -errno;
+
+	if (err)
+		pr_warning("failed to make dir %s/%s: %s\n", path, dir,
+			   strerror(-err));
+	return err;
+}
+
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
+	err = make_dir(path, "maps");
+	if (err)
+		return err;
+
+	bpf_map__for_each(map, obj) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s/maps/%s", path,
+			       bpf_map__name(map));
+		if (len < 0 || len > PATH_MAX)
+			return -EINVAL;
+
+		err = bpf_map__pin(map, buf);
+		if (err)
+			return err;
+	}
+
+	err = make_dir(path, "progs");
+	if (err)
+		return err;
+
+	bpf_object__for_each_program(prog, obj) {
+		char buf[PATH_MAX];
+		int len;
+
+		len = snprintf(buf, PATH_MAX, "%s/progs/%s", path,
+			       prog->section_name);
+		if (len < 0 || len > PATH_MAX)
+			return -EINVAL;
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
index 524247cfd205..8363ee6db4a0 100644
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
