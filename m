From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 4/7] tools lib bpf: Add libbpf_get_error()
Date: Sun, 22 Jan 2017 17:11:25 -0800
Message-ID: <20170123011128.26534-5-joe@ovn.org>
References: <20170123011128.26534-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123011128.26534-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function will turn a libbpf pointer into a standard error code (or
0 if the pointer is valid). This also allows removal of the dependency
on linux/err.h in the public header file, which causes problems in
userspace programs built against libbpf.

Signed-off-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
---
v2: Add ack.
---
 tools/lib/bpf/libbpf.c  | 8 ++++++++
 tools/lib/bpf/libbpf.h  | 4 +++-
 tools/perf/tests/llvm.c | 2 +-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 406838fa9c4f..e6cd62b1264b 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -28,6 +28,7 @@
 #include <fcntl.h>
 #include <errno.h>
 #include <asm/unistd.h>
+#include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/bpf.h>
 #include <linux/list.h>
@@ -1542,3 +1543,10 @@ bpf_object__find_map_by_offset(struct bpf_object *obj, size_t offset)
 	}
 	return ERR_PTR(-ENOENT);
 }
+
+long libbpf_get_error(const void *ptr)
+{
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+	return 0;
+}
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index 2188ccdc0e2d..4014d1ba5e3d 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -22,8 +22,8 @@
 #define __BPF_LIBBPF_H
 
 #include <stdio.h>
+#include <stdint.h>
 #include <stdbool.h>
-#include <linux/err.h>
 #include <sys/types.h>  // for size_t
 
 enum libbpf_errno {
@@ -234,4 +234,6 @@ int bpf_map__set_priv(struct bpf_map *map, void *priv,
 		      bpf_map_clear_priv_t clear_priv);
 void *bpf_map__priv(struct bpf_map *map);
 
+long libbpf_get_error(const void *ptr);
+
 #endif
diff --git a/tools/perf/tests/llvm.c b/tools/perf/tests/llvm.c
index 02a33ebcd992..d357dab72e68 100644
--- a/tools/perf/tests/llvm.c
+++ b/tools/perf/tests/llvm.c
@@ -13,7 +13,7 @@ static int test__bpf_parsing(void *obj_buf, size_t obj_buf_sz)
 	struct bpf_object *obj;
 
 	obj = bpf_object__open_buffer(obj_buf, obj_buf_sz, NULL);
-	if (IS_ERR(obj))
+	if (libbpf_get_error(obj))
 		return TEST_FAIL;
 	bpf_object__close(obj);
 	return TEST_OK;
-- 
2.11.0
