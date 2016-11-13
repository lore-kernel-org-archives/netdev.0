From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1] bpf: Use u64_to_user_ptr()
Date: Sun, 13 Nov 2016 19:44:03 +0100
Message-ID: <20161113184403.15222-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta123.mx.infomaniak.ch ([84.16.70.124]:58662 "EHLO
        mta123.mx.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932803AbcKMSom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 13:44:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the custom u64_to_ptr() function with the u64_to_user_ptr()
macro.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 237f3d6a7ddc..4281a9560c05 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -17,6 +17,7 @@
 #include <linux/license.h>
 #include <linux/filter.h>
 #include <linux/version.h>
+#include <linux/kernel.h>
 
 DEFINE_PER_CPU(int, bpf_prog_active);
 
@@ -254,12 +255,6 @@ struct bpf_map *bpf_map_get_with_uref(u32 ufd)
 	return map;
 }
 
-/* helper to convert user pointers passed inside __aligned_u64 fields */
-static void __user *u64_to_ptr(__u64 val)
-{
-	return (void __user *) (unsigned long) val;
-}
-
 int __weak bpf_stackmap_copy(struct bpf_map *map, void *key, void *value)
 {
 	return -ENOTSUPP;
@@ -270,8 +265,8 @@ int __weak bpf_stackmap_copy(struct bpf_map *map, void *key, void *value)
 
 static int map_lookup_elem(union bpf_attr *attr)
 {
-	void __user *ukey = u64_to_ptr(attr->key);
-	void __user *uvalue = u64_to_ptr(attr->value);
+	void __user *ukey = u64_to_user_ptr(attr->key);
+	void __user *uvalue = u64_to_user_ptr(attr->value);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
 	void *key, *value, *ptr;
@@ -344,8 +339,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 
 static int map_update_elem(union bpf_attr *attr)
 {
-	void __user *ukey = u64_to_ptr(attr->key);
-	void __user *uvalue = u64_to_ptr(attr->value);
+	void __user *ukey = u64_to_user_ptr(attr->key);
+	void __user *uvalue = u64_to_user_ptr(attr->value);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
 	void *key, *value;
@@ -422,7 +417,7 @@ static int map_update_elem(union bpf_attr *attr)
 
 static int map_delete_elem(union bpf_attr *attr)
 {
-	void __user *ukey = u64_to_ptr(attr->key);
+	void __user *ukey = u64_to_user_ptr(attr->key);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
 	struct fd f;
@@ -466,8 +461,8 @@ static int map_delete_elem(union bpf_attr *attr)
 
 static int map_get_next_key(union bpf_attr *attr)
 {
-	void __user *ukey = u64_to_ptr(attr->key);
-	void __user *unext_key = u64_to_ptr(attr->next_key);
+	void __user *ukey = u64_to_user_ptr(attr->key);
+	void __user *unext_key = u64_to_user_ptr(attr->next_key);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
 	void *key, *next_key;
@@ -732,7 +727,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		return -EINVAL;
 
 	/* copy eBPF program license from user space */
-	if (strncpy_from_user(license, u64_to_ptr(attr->license),
+	if (strncpy_from_user(license, u64_to_user_ptr(attr->license),
 			      sizeof(license) - 1) < 0)
 		return -EFAULT;
 	license[sizeof(license) - 1] = 0;
@@ -762,7 +757,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	prog->len = attr->insn_cnt;
 
 	err = -EFAULT;
-	if (copy_from_user(prog->insns, u64_to_ptr(attr->insns),
+	if (copy_from_user(prog->insns, u64_to_user_ptr(attr->insns),
 			   prog->len * sizeof(struct bpf_insn)) != 0)
 		goto free_prog;
 
@@ -813,7 +808,7 @@ static int bpf_obj_pin(const union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_OBJ))
 		return -EINVAL;
 
-	return bpf_obj_pin_user(attr->bpf_fd, u64_to_ptr(attr->pathname));
+	return bpf_obj_pin_user(attr->bpf_fd, u64_to_user_ptr(attr->pathname));
 }
 
 static int bpf_obj_get(const union bpf_attr *attr)
@@ -821,7 +816,7 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_OBJ) || attr->bpf_fd != 0)
 		return -EINVAL;
 
-	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
+	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname));
 }
 
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
-- 
2.10.2
