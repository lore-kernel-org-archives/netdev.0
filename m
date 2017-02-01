From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 08/14] tools lib bpf: Add bpf_map__pin()
Date: Wed,  1 Feb 2017 09:25:01 -0300
Message-ID: <20170201122507.29303-9-acme@kernel.org>
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

Add a new API to pin a BPF map to the filesystem. The user can specify
the path full path within a BPF filesystem to pin the map.

Signed-off-by: Joe Stringer <joe@ovn.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-3-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/lib/bpf/libbpf.c | 22 ++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 23 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index c4465b2fddf6..6a8c8beeb291 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1357,6 +1357,28 @@ int bpf_program__pin(struct bpf_program *prog, const char *path)
 	return 0;
 }
 
+int bpf_map__pin(struct bpf_map *map, const char *path)
+{
+	int err;
+
+	err = check_path(path);
+	if (err)
+		return err;
+
+	if (map == NULL) {
+		pr_warning("invalid map pointer\n");
+		return -EINVAL;
+	}
+
+	if (bpf_obj_pin(map->fd, path)) {
+		pr_warning("failed to pin map: %s\n", strerror(errno));
+		return -errno;
+	}
+
+	pr_debug("pinned map '%s'\n", path);
+	return 0;
+}
+
 void bpf_object__close(struct bpf_object *obj)
 {
 	size_t i;
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index 9f8aa63b95f4..2addf9d5b13c 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -236,6 +236,7 @@ typedef void (*bpf_map_clear_priv_t)(struct bpf_map *, void *);
 int bpf_map__set_priv(struct bpf_map *map, void *priv,
 		      bpf_map_clear_priv_t clear_priv);
 void *bpf_map__priv(struct bpf_map *map);
+int bpf_map__pin(struct bpf_map *map, const char *path);
 
 long libbpf_get_error(const void *ptr);
 
-- 
2.9.3
