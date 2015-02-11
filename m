From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/7] ebpf: constify various function pointer structs
Date: Wed, 11 Feb 2015 01:15:13 +0100
Message-ID: <1be48c6154312f8c3fd239c26fae856fa3416bd8.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56168 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbBKAPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:34 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can move bpf_map_ops and bpf_verifier_ops and other structs
into RO section, bpf_map_type_list and bpf_prog_type_list into
read mostly.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h   | 14 +++++++-------
 kernel/bpf/arraymap.c |  6 +++---
 kernel/bpf/hashtab.c  |  6 +++---
 kernel/bpf/helpers.c  |  6 +++---
 net/core/filter.c     |  6 +++---
 5 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index bbfceb7..7844686 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -32,13 +32,13 @@ struct bpf_map {
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
-	struct bpf_map_ops *ops;
+	const struct bpf_map_ops *ops;
 	struct work_struct work;
 };
 
 struct bpf_map_type_list {
 	struct list_head list_node;
-	struct bpf_map_ops *ops;
+	const struct bpf_map_ops *ops;
 	enum bpf_map_type type;
 };
 
@@ -109,7 +109,7 @@ struct bpf_verifier_ops {
 
 struct bpf_prog_type_list {
 	struct list_head list_node;
-	struct bpf_verifier_ops *ops;
+	const struct bpf_verifier_ops *ops;
 	enum bpf_prog_type type;
 };
 
@@ -121,7 +121,7 @@ struct bpf_prog_aux {
 	atomic_t refcnt;
 	bool is_gpl_compatible;
 	enum bpf_prog_type prog_type;
-	struct bpf_verifier_ops *ops;
+	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	u32 used_map_cnt;
 	struct bpf_prog *prog;
@@ -138,8 +138,8 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
 /* verifier prototypes for helper functions called from eBPF programs */
-extern struct bpf_func_proto bpf_map_lookup_elem_proto;
-extern struct bpf_func_proto bpf_map_update_elem_proto;
-extern struct bpf_func_proto bpf_map_delete_elem_proto;
+extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
+extern const struct bpf_func_proto bpf_map_update_elem_proto;
+extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 9eb4d8a..8a66165 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -134,7 +134,7 @@ static void array_map_free(struct bpf_map *map)
 	kvfree(array);
 }
 
-static struct bpf_map_ops array_ops = {
+static const struct bpf_map_ops array_ops = {
 	.map_alloc = array_map_alloc,
 	.map_free = array_map_free,
 	.map_get_next_key = array_map_get_next_key,
@@ -143,14 +143,14 @@ static struct bpf_map_ops array_ops = {
 	.map_delete_elem = array_map_delete_elem,
 };
 
-static struct bpf_map_type_list tl = {
+static struct bpf_map_type_list array_type __read_mostly = {
 	.ops = &array_ops,
 	.type = BPF_MAP_TYPE_ARRAY,
 };
 
 static int __init register_array_map(void)
 {
-	bpf_register_map_type(&tl);
+	bpf_register_map_type(&array_type);
 	return 0;
 }
 late_initcall(register_array_map);
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index b3ba436..83c209d 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -345,7 +345,7 @@ static void htab_map_free(struct bpf_map *map)
 	kfree(htab);
 }
 
-static struct bpf_map_ops htab_ops = {
+static const struct bpf_map_ops htab_ops = {
 	.map_alloc = htab_map_alloc,
 	.map_free = htab_map_free,
 	.map_get_next_key = htab_map_get_next_key,
@@ -354,14 +354,14 @@ static struct bpf_map_ops htab_ops = {
 	.map_delete_elem = htab_map_delete_elem,
 };
 
-static struct bpf_map_type_list tl = {
+static struct bpf_map_type_list htab_type __read_mostly = {
 	.ops = &htab_ops,
 	.type = BPF_MAP_TYPE_HASH,
 };
 
 static int __init register_htab_map(void)
 {
-	bpf_register_map_type(&tl);
+	bpf_register_map_type(&htab_type);
 	return 0;
 }
 late_initcall(register_htab_map);
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 9e3414d..a3c7701 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -41,7 +41,7 @@ static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return (unsigned long) value;
 }
 
-struct bpf_func_proto bpf_map_lookup_elem_proto = {
+const struct bpf_func_proto bpf_map_lookup_elem_proto = {
 	.func = bpf_map_lookup_elem,
 	.gpl_only = false,
 	.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
@@ -60,7 +60,7 @@ static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return map->ops->map_update_elem(map, key, value, r4);
 }
 
-struct bpf_func_proto bpf_map_update_elem_proto = {
+const struct bpf_func_proto bpf_map_update_elem_proto = {
 	.func = bpf_map_update_elem,
 	.gpl_only = false,
 	.ret_type = RET_INTEGER,
@@ -80,7 +80,7 @@ static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return map->ops->map_delete_elem(map, key);
 }
 
-struct bpf_func_proto bpf_map_delete_elem_proto = {
+const struct bpf_func_proto bpf_map_delete_elem_proto = {
 	.func = bpf_map_delete_elem,
 	.gpl_only = false,
 	.ret_type = RET_INTEGER,
diff --git a/net/core/filter.c b/net/core/filter.c
index ec9baea..e823da5 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1159,19 +1159,19 @@ static bool sock_filter_is_valid_access(int off, int size, enum bpf_access_type
 	return false;
 }
 
-static struct bpf_verifier_ops sock_filter_ops = {
+static const struct bpf_verifier_ops sock_filter_ops = {
 	.get_func_proto = sock_filter_func_proto,
 	.is_valid_access = sock_filter_is_valid_access,
 };
 
-static struct bpf_prog_type_list tl = {
+static struct bpf_prog_type_list sock_filter_type __read_mostly = {
 	.ops = &sock_filter_ops,
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 static int __init register_sock_filter_ops(void)
 {
-	bpf_register_prog_type(&tl);
+	bpf_register_prog_type(&sock_filter_type);
 	return 0;
 }
 late_initcall(register_sock_filter_ops);
-- 
1.9.3
