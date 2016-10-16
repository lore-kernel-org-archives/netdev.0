From: Eric Leblond <eric@regit.org>
Subject: [PATCH 5/8] tools lib bpf: add missing functions
Date: Sun, 16 Oct 2016 23:18:31 +0200
Message-ID: <20161016211834.11732-6-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45263 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757189AbcJPVVS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:18 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some functions were missing in the library to be able to use it
in the case where the userspace is handling the maps in kernel.

The patch also renames functions to have a homogeneous naming
convention.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/bpf.c    | 35 ++++++++++++++++++++++++++++++++++-
 tools/lib/bpf/bpf.h    |  2 --
 tools/lib/bpf/libbpf.h |  5 +++++
 3 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 4212ed6..c0e07bd 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -25,6 +25,7 @@
 #include <asm/unistd.h>
 #include <linux/bpf.h>
 #include "bpf.h"
+#include "libbpf.h"
 
 /*
  * When building perf, unistd.h is overrided. __NR_bpf is
@@ -97,7 +98,7 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-int bpf_map_update_elem(int fd, void *key, void *value,
+int bpf_map__update_elem(int fd, void *key, void *value,
 			u64 flags)
 {
 	union bpf_attr attr;
@@ -110,3 +111,35 @@ int bpf_map_update_elem(int fd, void *key, void *value,
 
 	return sys_bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
+
+int bpf_map__lookup_elem(int fd, void *key, void *value)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+	};
+
+	return sys_bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_map__delete_elem(int fd, void *key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+	};
+
+	return sys_bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_map__get_next_key(int fd, void *key, void *next_key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.next_key = ptr_to_u64(next_key),
+	};
+
+	return sys_bpf(BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
+}
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index e8ba540..5ca834a 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -33,6 +33,4 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 		     u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
 
-int bpf_map_update_elem(int fd, void *key, void *value,
-			u64 flags);
 #endif
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index a18783b..dfb46d0 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -207,6 +207,11 @@ bpf_map__next(struct bpf_map *map, struct bpf_object *obj);
 int bpf_map__fd(struct bpf_map *map);
 const struct bpf_map_def *bpf_map__def(struct bpf_map *map);
 const char *bpf_map__name(struct bpf_map *map);
+int bpf_map__update_elem(int fd, void *key, void *value,
+			uint64_t flags);
+int bpf_map__lookup_elem(int fd, void *key, void *value);
+int bpf_map__delete_elem(int fd, void *key);
+int bpf_map__get_next_key(int fd, void *key, void *next_key);
 
 typedef void (*bpf_map_clear_priv_t)(struct bpf_map *, void *);
 int bpf_map__set_priv(struct bpf_map *map, void *priv,
-- 
2.9.3
