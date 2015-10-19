From: yalin wang <yalin.wang2010@gmail.com>
Subject: [RFC] bpf: change bpf syacall to use u64 temp variables
Date: Mon, 19 Oct 2015 15:10:46 +0800
Message-ID: <1445238646-9379-1-git-send-email-yalin.wang2010@gmail.com>
Cc: yalin wang <yalin.wang2010@gmail.com>
To: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch change map_lookup_elem() and map_update_elem() function
to use u64 temp variable if the key_size or value_size is less than
u64, we don't need use kmalloc() for these small variables.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 kernel/bpf/syscall.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index f640e5f..c82d7bf 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -189,7 +189,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 	void __user *uvalue = u64_to_ptr(attr->value);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
-	void *key, *value, *ptr;
+	u64 key_buf, value_buf;
+	void *key = &key_buf, *value = &value_buf, *ptr;
 	struct fd f;
 	int err;
 
@@ -202,7 +203,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		return PTR_ERR(map);
 
 	err = -ENOMEM;
-	key = kmalloc(map->key_size, GFP_USER);
+	if (map->key_size > sizeof(u64))
+		key = kmalloc(map->key_size, GFP_USER);
 	if (!key)
 		goto err_put;
 
@@ -211,7 +213,8 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_key;
 
 	err = -ENOMEM;
-	value = kmalloc(map->value_size, GFP_USER);
+	if (map->value_size > sizeof(u64))
+		value = kmalloc(map->value_size, GFP_USER);
 	if (!value)
 		goto free_key;
 
@@ -232,9 +235,11 @@ static int map_lookup_elem(union bpf_attr *attr)
 	err = 0;
 
 free_value:
-	kfree(value);
+	if (value != &value_buf)
+		kfree(value);
 free_key:
-	kfree(key);
+	if (key != &key_buf)
+		kfree(key);
 err_put:
 	fdput(f);
 	return err;
@@ -248,7 +253,8 @@ static int map_update_elem(union bpf_attr *attr)
 	void __user *uvalue = u64_to_ptr(attr->value);
 	int ufd = attr->map_fd;
 	struct bpf_map *map;
-	void *key, *value;
+	u64 key_buf, value_buf;
+	void *key = &key_buf, *value = &value_buf;
 	struct fd f;
 	int err;
 
@@ -261,7 +267,8 @@ static int map_update_elem(union bpf_attr *attr)
 		return PTR_ERR(map);
 
 	err = -ENOMEM;
-	key = kmalloc(map->key_size, GFP_USER);
+	if (map->key_size > sizeof(u64))
+		key = kmalloc(map->key_size, GFP_USER);
 	if (!key)
 		goto err_put;
 
@@ -270,7 +277,8 @@ static int map_update_elem(union bpf_attr *attr)
 		goto free_key;
 
 	err = -ENOMEM;
-	value = kmalloc(map->value_size, GFP_USER);
+	if (map->value_size > sizeof(u64))
+		value = kmalloc(map->value_size, GFP_USER);
 	if (!value)
 		goto free_key;
 
@@ -286,9 +294,11 @@ static int map_update_elem(union bpf_attr *attr)
 	rcu_read_unlock();
 
 free_value:
-	kfree(value);
+	if (value != &value_buf)
+		kfree(value);
 free_key:
-	kfree(key);
+	if (key != &key_buf)
+		kfree(key);
 err_put:
 	fdput(f);
 	return err;
-- 
1.9.1
