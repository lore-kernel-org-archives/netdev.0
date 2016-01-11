From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 5/9] bpf: syscall: add percpu version of lookup/update elem
Date: Mon, 11 Jan 2016 23:56:57 +0800
Message-ID: <1452527821-12276-6-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare for supporting percpu map in the following patch.

Now userspace can lookup/update mapped value in one specific
CPU in case of percpu map.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/uapi/linux/bpf.h |  3 +++
 kernel/bpf/syscall.c     | 48 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2658917..63b04c6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -73,6 +73,8 @@ enum bpf_cmd {
 	BPF_PROG_LOAD,
 	BPF_OBJ_PIN,
 	BPF_OBJ_GET,
+	BPF_MAP_LOOKUP_ELEM_PERCPU,
+	BPF_MAP_UPDATE_ELEM_PERCPU,
 };
 
 enum bpf_map_type {
@@ -114,6 +116,7 @@ union bpf_attr {
 			__aligned_u64 next_key;
 		};
 		__u64		flags;
+		__u32		cpu;
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_LOAD command */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 6373970..280c93b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -231,8 +231,9 @@ static void __user *u64_to_ptr(__u64 val)
 
 /* last field in 'union bpf_attr' used by this command */
 #define BPF_MAP_LOOKUP_ELEM_LAST_FIELD value
+#define BPF_MAP_LOOKUP_ELEM_PERCPU_LAST_FIELD cpu
 
-static int map_lookup_elem(union bpf_attr *attr)
+static int map_lookup_elem(union bpf_attr *attr, bool percpu)
 {
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *uvalue = u64_to_ptr(attr->value);
@@ -242,8 +243,14 @@ static int map_lookup_elem(union bpf_attr *attr)
 	struct fd f;
 	int err;
 
-	if (CHECK_ATTR(BPF_MAP_LOOKUP_ELEM))
-		return -EINVAL;
+	if (!percpu) {
+		if (CHECK_ATTR(BPF_MAP_LOOKUP_ELEM))
+			return -EINVAL;
+	} else {
+		if (CHECK_ATTR(BPF_MAP_LOOKUP_ELEM_PERCPU) ||
+				attr->cpu >= num_possible_cpus())
+			return -EINVAL;
+	}
 
 	f = fdget(ufd);
 	map = __bpf_map_get(f);
@@ -265,7 +272,10 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_key;
 
 	rcu_read_lock();
-	ptr = map->ops->map_lookup_elem(map, key);
+	if (!percpu)
+		ptr = map->ops->map_lookup_elem(map, key);
+	else
+		ptr = map->ops->map_lookup_elem_percpu(map, key, attr->cpu);
 	if (ptr)
 		memcpy(value, ptr, map->value_size);
 	rcu_read_unlock();
@@ -290,8 +300,9 @@ err_put:
 }
 
 #define BPF_MAP_UPDATE_ELEM_LAST_FIELD flags
+#define BPF_MAP_UPDATE_ELEM_PERCPU_LAST_FIELD cpu
 
-static int map_update_elem(union bpf_attr *attr)
+static int map_update_elem(union bpf_attr *attr, bool percpu)
 {
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *uvalue = u64_to_ptr(attr->value);
@@ -301,8 +312,14 @@ static int map_update_elem(union bpf_attr *attr)
 	struct fd f;
 	int err;
 
-	if (CHECK_ATTR(BPF_MAP_UPDATE_ELEM))
-		return -EINVAL;
+	if (!percpu) {
+		if (CHECK_ATTR(BPF_MAP_UPDATE_ELEM))
+			return -EINVAL;
+	} else {
+		if (CHECK_ATTR(BPF_MAP_UPDATE_ELEM_PERCPU) ||
+				attr->cpu >= num_possible_cpus())
+			return -EINVAL;
+	}
 
 	f = fdget(ufd);
 	map = __bpf_map_get(f);
@@ -331,7 +348,12 @@ static int map_update_elem(union bpf_attr *attr)
 	 * therefore all map accessors rely on this fact, so do the same here
 	 */
 	rcu_read_lock();
-	err = map->ops->map_update_elem(map, key, value, attr->flags);
+	if (!percpu)
+		err = map->ops->map_update_elem(map, key, value, attr->flags);
+	else
+		err = map->ops->map_update_elem_percpu(map, key, value,
+				attr->flags, attr->cpu);
+
 	rcu_read_unlock();
 
 free_value:
@@ -772,10 +794,16 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 		err = map_create(&attr);
 		break;
 	case BPF_MAP_LOOKUP_ELEM:
-		err = map_lookup_elem(&attr);
+		err = map_lookup_elem(&attr, false);
+		break;
+	case BPF_MAP_LOOKUP_ELEM_PERCPU:
+		err = map_lookup_elem(&attr, true);
 		break;
 	case BPF_MAP_UPDATE_ELEM:
-		err = map_update_elem(&attr);
+		err = map_update_elem(&attr, false);
+		break;
+	case BPF_MAP_UPDATE_ELEM_PERCPU:
+		err = map_update_elem(&attr, true);
 		break;
 	case BPF_MAP_DELETE_ELEM:
 		err = map_delete_elem(&attr);
-- 
1.9.1
