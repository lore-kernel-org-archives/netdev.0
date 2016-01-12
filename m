From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 3/4] bpf: bpf_htab: Add syscall to iterate percpu value of a key
Date: Tue, 12 Jan 2016 00:20:51 -0800
Message-ID: <1452586852-1575604-4-git-send-email-kafai@fb.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>,
	FB Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add map_lookup_percpu_elem() syscall to lookup value
of a particular CPU.

The user is expected to loop through all CPU values by:
for (cpu = 0; cpu < sysconf(_SC_NPROCESSORS_CONF); cpu++) {
	if (!bpf_map_lookup_percpu_elem(map, &key, &value, cpu))
		total_value += value;
}

* If the cpu is offline, errno == ENXIO
* If the key is deleted before the iteration is done,
  errno == ENOENT.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/syscall.c     | 93 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 43ae40c..2c73c09 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -73,6 +73,7 @@ enum bpf_cmd {
 	BPF_PROG_LOAD,
 	BPF_OBJ_PIN,
 	BPF_OBJ_GET,
+	BPF_MAP_LOOKUP_PERCPU_ELEM,
 };
 
 enum bpf_map_type {
@@ -115,6 +116,7 @@ union bpf_attr {
 			__aligned_u64 next_key;
 		};
 		__u64		flags;
+		__u32		cpu;
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_LOAD command */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6373970..ba1172b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -289,6 +289,96 @@ err_put:
 	return err;
 }
 
+/* last field in 'union bpf_attr' used by this command */
+#define BPF_MAP_LOOKUP_PERCPU_ELEM_LAST_FIELD cpu
+
+struct percpu_map_value_info {
+	struct bpf_map *map;
+	void *key;
+	void *value;
+	bool found;
+};
+
+static void percpu_map_lookup_value(void *i)
+{
+	struct percpu_map_value_info *info = (struct percpu_map_value_info *)i;
+	struct bpf_map *map = info->map;
+	void *ptr;
+
+	rcu_read_lock();
+	ptr = map->ops->map_lookup_elem(map, info->key);
+	if (ptr) {
+		memcpy(info->value, ptr, map->value_size);
+		info->found = true;
+	} else {
+		info->found = false;
+	}
+	rcu_read_unlock();
+}
+
+static int map_lookup_percpu_elem(union bpf_attr *attr)
+{
+	void __user *ukey = u64_to_ptr(attr->key);
+	void __user *uvalue = u64_to_ptr(attr->value);
+	u32 __user ucpu = attr->cpu;
+	int ufd = attr->map_fd;
+	struct percpu_map_value_info value_info;
+	struct bpf_map *map;
+	void *key, *value;
+	struct fd f;
+	int err;
+
+	if (CHECK_ATTR(BPF_MAP_LOOKUP_PERCPU_ELEM) ||
+	    ucpu >= num_possible_cpus())
+		return -EINVAL;
+
+	f = fdget(ufd);
+	map = __bpf_map_get(f);
+	if (IS_ERR(map))
+		return PTR_ERR(map);
+
+	err = -ENOMEM;
+	key = kmalloc(map->key_size, GFP_USER);
+	if (!key)
+		goto err_put;
+
+	err = -EFAULT;
+	if (copy_from_user(key, ukey, map->key_size) != 0)
+		goto free_key;
+
+	err = -ENOMEM;
+	value = kmalloc(map->value_size, GFP_USER | __GFP_NOWARN);
+	if (!value)
+		goto free_key;
+
+	value_info.map = map;
+	value_info.key = key;
+	value_info.value = value;
+
+	err = smp_call_function_single(ucpu, percpu_map_lookup_value,
+				       &value_info, 1);
+	if (err)
+		goto free_value;
+
+	err = -ENOENT;
+	if (!value_info.found)
+		goto free_value;
+
+	err = -EFAULT;
+	if (copy_to_user(uvalue, value, map->value_size) != 0)
+		goto free_value;
+
+	err = 0;
+
+free_value:
+	kfree(value);
+free_key:
+	kfree(key);
+err_put:
+	fdput(f);
+	return err;
+}
+
 #define BPF_MAP_UPDATE_ELEM_LAST_FIELD flags
 
 static int map_update_elem(union bpf_attr *attr)
@@ -792,6 +882,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_OBJ_GET:
 		err = bpf_obj_get(&attr);
 		break;
+	case BPF_MAP_LOOKUP_PERCPU_ELEM:
+		err = map_lookup_percpu_elem(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.5.1
