From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 05/14] bpf: add lookup/update/delete/iterate methods to BPF maps
Date: Fri, 27 Jun 2014 17:05:57 -0700
Message-ID: <1403913966-4927-6-git-send-email-ast@plumgrid.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'maps' is a generic storage of different types for sharing data between kernel
and userspace.

The maps are accessed from user space via BPF syscall, which has commands:

- create a map with given id, type and attributes
  map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
  returns positive map id or negative error

- delete map with given map id
  err = bpf_map_delete(int map_id)
  returns zero or negative error

- lookup key in a given map referenced by map_id
  err = bpf_map_lookup_elem(int map_id, void *key, void *value)
  returns zero and stores found elem into value or negative error

- create or update key/value pair in a given map
  err = bpf_map_update_elem(int map_id, void *key, void *value)
  returns zero or negative error

- find and delete element by key in a given map
  err = bpf_map_delete_elem(int map_id, void *key)

- iterate map elements (based on input key return next_key)
  err = bpf_map_get_next_key(int map_id, void *key, void *next_key)

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |    6 ++
 include/uapi/linux/bpf.h |   25 +++++++
 kernel/bpf/syscall.c     |  180 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 211 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6448b9beea89..19cd394bdbcc 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -18,6 +18,12 @@ struct bpf_map_ops {
 	/* funcs callable from userspace (via syscall) */
 	struct bpf_map *(*map_alloc)(struct nlattr *attrs[BPF_MAP_ATTR_MAX + 1]);
 	void (*map_free)(struct bpf_map *);
+	int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
+
+	/* funcs callable from userspace and from eBPF programs */
+	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
+	int (*map_update_elem)(struct bpf_map *map, void *key, void *value);
+	int (*map_delete_elem)(struct bpf_map *map, void *key);
 };
 
 struct bpf_map {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 04374e57c290..faed2ce2d25a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -315,6 +315,31 @@ enum bpf_cmd {
 	 * returns zero or negative error
 	 */
 	BPF_MAP_DELETE,
+
+	/* lookup key in a given map referenced by map_id
+	 * err = bpf_map_lookup_elem(int map_id, void *key, void *value)
+	 * returns zero and stores found elem into value
+	 * or negative error
+	 */
+	BPF_MAP_LOOKUP_ELEM,
+
+	/* create or update key/value pair in a given map
+	 * err = bpf_map_update_elem(int map_id, void *key, void *value)
+	 * returns zero or negative error
+	 */
+	BPF_MAP_UPDATE_ELEM,
+
+	/* find and delete elem by key in a given map
+	 * err = bpf_map_delete_elem(int map_id, void *key)
+	 * returns zero or negative error
+	 */
+	BPF_MAP_DELETE_ELEM,
+
+	/* lookup key in a given map and return next key
+	 * err = bpf_map_get_elem(int map_id, void *key, void *next_key)
+	 * returns zero and stores next key or negative error
+	 */
+	BPF_MAP_GET_NEXT_KEY,
 };
 
 enum bpf_map_attributes {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index b9509923b16f..1a48da23a939 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -219,6 +219,174 @@ static int map_delete(int map_id)
 	return 0;
 }
 
+static int map_lookup_elem(int map_id, void __user *ukey, void __user *uvalue)
+{
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
+
+	if (map_id < 0)
+		return -EINVAL;
+
+	rcu_read_lock();
+	map = idr_find(&bpf_map_id_idr, map_id);
+	err = -EINVAL;
+	if (!map)
+		goto err_unlock;
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_ATOMIC);
+	if (!key)
+		goto err_unlock;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ESRCH;
+	value = map->ops->map_lookup_elem(map, key);
+	if (!value)
+		goto free_key;
+
+	err = -EFAULT;
+	if (copy_to_user(uvalue, value, map->value_size) != 0)
+		goto free_key;
+
+	err = 0;
+
+free_key:
+	kfree(key);
+err_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int map_update_elem(int map_id, void __user *ukey, void __user *uvalue)
+{
+	struct bpf_map *map;
+	void *key, *value;
+	int err;
+
+	if (map_id < 0)
+		return -EINVAL;
+
+	rcu_read_lock();
+	map = idr_find(&bpf_map_id_idr, map_id);
+	err = -EINVAL;
+	if (!map)
+		goto err_unlock;
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_ATOMIC);
+	if (!key)
+		goto err_unlock;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ENOMEM;
+	value = kmalloc(map->value_size, GFP_ATOMIC);
+	if (!value)
+		goto free_key;
+
+	err = -EFAULT;
+	if (copy_from_user(value, uvalue, map->value_size) != 0)
+		goto free_value;
+
+	err = map->ops->map_update_elem(map, key, value);
+
+free_value:
+	kfree(value);
+free_key:
+	kfree(key);
+err_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int map_delete_elem(int map_id, void __user *ukey)
+{
+	struct bpf_map *map;
+	void *key;
+	int err;
+
+	if (map_id < 0)
+		return -EINVAL;
+
+	rcu_read_lock();
+	map = idr_find(&bpf_map_id_idr, map_id);
+	err = -EINVAL;
+	if (!map)
+		goto err_unlock;
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_ATOMIC);
+	if (!key)
+		goto err_unlock;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = map->ops->map_delete_elem(map, key);
+
+free_key:
+	kfree(key);
+err_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int map_get_next_key(int map_id, void __user *ukey,
+			    void __user *unext_key)
+{
+	struct bpf_map *map;
+	void *key, *next_key;
+	int err;
+
+	if (map_id < 0)
+		return -EINVAL;
+
+	rcu_read_lock();
+	map = idr_find(&bpf_map_id_idr, map_id);
+	err = -EINVAL;
+	if (!map)
+		goto err_unlock;
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_ATOMIC);
+	if (!key)
+		goto err_unlock;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ENOMEM;
+	next_key = kmalloc(map->key_size, GFP_ATOMIC);
+	if (!next_key)
+		goto free_key;
+
+	err = map->ops->map_get_next_key(map, key, next_key);
+	if (err)
+		goto free_next_key;
+
+	err = -EFAULT;
+	if (copy_to_user(unext_key, next_key, map->key_size) != 0)
+		goto free_next_key;
+
+	err = 0;
+
+free_next_key:
+	kfree(next_key);
+free_key:
+	kfree(key);
+err_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
 SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -232,6 +400,18 @@ SYSCALL_DEFINE5(bpf, int, cmd, unsigned long, arg2, unsigned long, arg3,
 	case BPF_MAP_DELETE:
 		return map_delete((int) arg2);
 
+	case BPF_MAP_LOOKUP_ELEM:
+		return map_lookup_elem((int) arg2, (void __user *) arg3,
+				       (void __user *) arg4);
+	case BPF_MAP_UPDATE_ELEM:
+		return map_update_elem((int) arg2, (void __user *) arg3,
+				       (void __user *) arg4);
+	case BPF_MAP_DELETE_ELEM:
+		return map_delete_elem((int) arg2, (void __user *) arg3);
+
+	case BPF_MAP_GET_NEXT_KEY:
+		return map_get_next_key((int) arg2, (void __user *) arg3,
+					(void __user *) arg4);
 	default:
 		return -EINVAL;
 	}
-- 
1.7.9.5
