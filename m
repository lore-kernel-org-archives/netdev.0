From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 2/6] tools lib bpf: Add bpf_map__pin()
Date: Thu, 26 Jan 2017 13:19:57 -0800
Message-ID: <20170126212001.14103-3-joe@ovn.org>
References: <20170126212001.14103-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126212001.14103-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new API to pin a BPF map to the filesystem. The user can
specify the path full path within a BPF filesystem to pin the map.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v3: No change.
v2: Don't automount BPF filesystem
    Split program, map, object pinning into separate APIs and separate
    patches.
---
 tools/lib/bpf/libbpf.c | 22 ++++++++++++++++++++++
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 23 insertions(+)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index d1d7638b7c21..ce987c02363e 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1349,6 +1349,28 @@ int bpf_program__pin(struct bpf_program *prog, const char *path)
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
2.11.0
