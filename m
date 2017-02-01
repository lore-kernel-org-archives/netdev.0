From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 09/14] tools lib bpf: Add bpf_object__pin()
Date: Wed,  1 Feb 2017 09:25:02 -0300
Message-ID: <20170201122507.29303-10-acme@kernel.org>
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
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-4-joe@ovn.org
[ Check snprintf >= for truncation, as snprintf(bf, size, ...) == size also means truncation ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/bpf/libbpf.c | 53 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 54 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 6a8c8beeb291..ac6eb863b2a4 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1379,6 +1379,59 @@ int bpf_map__pin(struct bpf_map *map, const char *path)
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
+		else if (len >= PATH_MAX)
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
+		else if (len >= PATH_MAX)
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
2.9.3
