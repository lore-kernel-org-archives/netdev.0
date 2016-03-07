From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/9] bpf: prevent kprobe+bpf deadlocks
Date: Sun, 6 Mar 2016 17:58:29 -0800
Message-ID: <1457315917-1970307-2-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if kprobe is placed within update or delete hash map helpers
that hold bucket spin lock and triggered bpf program is trying to
grab the spinlock for the same bucket on the same cpu, it will
deadlock.
Fix it by extending existing recursion prevention mechanism.

Note, map_lookup and other tracing helpers don't have this problem,
since they don't hold any locks and don't modify global data.
bpf_trace_printk has its own recursive check and ok as well.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  3 +++
 kernel/bpf/syscall.c     | 13 +++++++++++++
 kernel/trace/bpf_trace.c |  2 --
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 51e498e5470e..4b070827200d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -10,6 +10,7 @@
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
 #include <linux/file.h>
+#include <linux/percpu.h>
 
 struct bpf_map;
 
@@ -163,6 +164,8 @@ bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *f
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
 #ifdef CONFIG_BPF_SYSCALL
+DECLARE_PER_CPU(int, bpf_prog_active);
+
 void bpf_register_prog_type(struct bpf_prog_type_list *tl);
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c95a753c2007..dc99f6a000f5 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -18,6 +18,8 @@
 #include <linux/filter.h>
 #include <linux/version.h>
 
+DEFINE_PER_CPU(int, bpf_prog_active);
+
 int sysctl_unprivileged_bpf_disabled __read_mostly;
 
 static LIST_HEAD(bpf_map_types);
@@ -347,6 +349,11 @@ static int map_update_elem(union bpf_attr *attr)
 	if (copy_from_user(value, uvalue, value_size) != 0)
 		goto free_value;
 
+	/* must increment bpf_prog_active to avoid kprobe+bpf triggering from
+	 * inside bpf map update or delete otherwise deadlocks are possible
+	 */
+	preempt_disable();
+	__this_cpu_inc(bpf_prog_active);
 	if (map->map_type == BPF_MAP_TYPE_PERCPU_HASH) {
 		err = bpf_percpu_hash_update(map, key, value, attr->flags);
 	} else if (map->map_type == BPF_MAP_TYPE_PERCPU_ARRAY) {
@@ -356,6 +363,8 @@ static int map_update_elem(union bpf_attr *attr)
 		err = map->ops->map_update_elem(map, key, value, attr->flags);
 		rcu_read_unlock();
 	}
+	__this_cpu_dec(bpf_prog_active);
+	preempt_enable();
 
 free_value:
 	kfree(value);
@@ -394,9 +403,13 @@ static int map_delete_elem(union bpf_attr *attr)
 	if (copy_from_user(key, ukey, map->key_size) != 0)
 		goto free_key;
 
+	preempt_disable();
+	__this_cpu_inc(bpf_prog_active);
 	rcu_read_lock();
 	err = map->ops->map_delete_elem(map, key);
 	rcu_read_unlock();
+	__this_cpu_dec(bpf_prog_active);
+	preempt_enable();
 
 free_key:
 	kfree(key);
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4b8caa392b86..3e4ffb3ace5f 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -13,8 +13,6 @@
 #include <linux/ctype.h>
 #include "trace.h"
 
-static DEFINE_PER_CPU(int, bpf_prog_active);
-
 /**
  * trace_call_bpf - invoke BPF program
  * @prog: BPF program
-- 
2.6.5
