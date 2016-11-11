From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 2/6] bpf: Add percpu LRU list
Date: Fri, 11 Nov 2016 10:55:07 -0800
Message-ID: <1478890511-1346984-3-git-send-email-kafai@fb.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40831 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934321AbcKKSzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 13:55:24 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uABIpqKN031874
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:23 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 26nk23gek0-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:55:23 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 65afe4bca84011e691a20002c9521c9e-652eca50 for <netdev@vger.kernel.org>;        Fri,
 11 Nov 2016 10:55:22 -0800
In-Reply-To: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having a common LRU list, this patch allows a
percpu LRU list which can be selected by specifying a map
attribute.  The map attribute will be added in the later
patch.

While the common use case for LRU is #reads >> #updates,
percpu LRU list allows bpf prog to absorb unusual #updates
under pathological case (e.g. external traffic facing machine which
could be under attack).

Each percpu LRU is isolated from each other.  The LRU nodes (including
free nodes) cannot be moved across different LRU Lists.

Here are the update performance comparison between
common LRU list and percpu LRU list (the test code is
at the last patch):

[root@kerneltest003.31.prn1 ~]# for i in 1 4 8; do echo -n "$i cpus: "; \
./map_perf_test 16 $i | awk '{r += $3}END{print r " updates"}'; done
 1 cpus: 2934082 updates
 4 cpus: 7391434 updates
 8 cpus: 6500576 updates

[root@kerneltest003.31.prn1 ~]# for i in 1 4 8; do echo -n "$i cpus: "; \
./map_perf_test 32 $i | awk '{r += $3}END{printr " updates"}'; done
  1 cpus: 2896553 updates
  4 cpus: 9766395 updates
  8 cpus: 17460553 updates

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/bpf_lru_list.c | 162 +++++++++++++++++++++++++++++++++++++++++-----
 kernel/bpf/bpf_lru_list.h |   8 ++-
 2 files changed, 151 insertions(+), 19 deletions(-)

diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
index 73f6709..bfebff0 100644
--- a/kernel/bpf/bpf_lru_list.c
+++ b/kernel/bpf/bpf_lru_list.c
@@ -13,6 +13,9 @@
 #define LOCAL_FREE_TARGET		(128)
 #define LOCAL_NR_SCANS			LOCAL_FREE_TARGET
 
+#define PERCPU_FREE_TARGET		(16)
+#define PERCPU_NR_SCANS			PERCPU_FREE_TARGET
+
 /* Helpers to get the local list index */
 #define LOCAL_LIST_IDX(t)	((t) - BPF_LOCAL_LIST_T_OFFSET)
 #define LOCAL_FREE_LIST_IDX	LOCAL_LIST_IDX(BPF_LRU_LOCAL_LIST_T_FREE)
@@ -396,7 +399,40 @@ struct bpf_lru_node *__local_list_pop_pending(struct bpf_lru *lru,
 	return NULL;
 }
 
-struct bpf_lru_node *bpf_lru_pop_free(struct bpf_lru *lru, u32 hash)
+static struct bpf_lru_node *bpf_percpu_lru_pop_free(struct bpf_lru *lru,
+						    u32 hash)
+{
+	struct list_head *free_list;
+	struct bpf_lru_node *node = NULL;
+	struct bpf_lru_list *l;
+	unsigned long flags;
+	int cpu = raw_smp_processor_id();
+
+	l = per_cpu_ptr(lru->percpu_lru, cpu);
+
+	raw_spin_lock_irqsave(&l->lock, flags);
+
+	__bpf_lru_list_rotate(lru, l);
+
+	free_list = &l->lists[BPF_LRU_LIST_T_FREE];
+	if (list_empty(free_list))
+		__bpf_lru_list_shrink(lru, l, PERCPU_FREE_TARGET, free_list,
+				      BPF_LRU_LIST_T_FREE);
+
+	if (!list_empty(free_list)) {
+		node = list_first_entry(free_list, struct bpf_lru_node, list);
+		*(u32 *)((void *)node + lru->hash_offset) = hash;
+		node->ref = 0;
+		__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_INACTIVE);
+	}
+
+	raw_spin_unlock_irqrestore(&l->lock, flags);
+
+	return node;
+}
+
+static struct bpf_lru_node *bpf_common_lru_pop_free(struct bpf_lru *lru,
+						    u32 hash)
 {
 	struct bpf_lru_locallist *loc_l, *steal_loc_l;
 	struct bpf_common_lru *clru = &lru->common_lru;
@@ -458,7 +494,16 @@ struct bpf_lru_node *bpf_lru_pop_free(struct bpf_lru *lru, u32 hash)
 	return node;
 }
 
-void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node)
+struct bpf_lru_node *bpf_lru_pop_free(struct bpf_lru *lru, u32 hash)
+{
+	if (lru->percpu)
+		return bpf_percpu_lru_pop_free(lru, hash);
+	else
+		return bpf_common_lru_pop_free(lru, hash);
+}
+
+static void bpf_common_lru_push_free(struct bpf_lru *lru,
+				     struct bpf_lru_node *node)
 {
 	unsigned long flags;
 
@@ -490,8 +535,31 @@ void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node)
 	bpf_lru_list_push_free(&lru->common_lru.lru_list, node);
 }
 
-void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
-		      u32 elem_size, u32 nr_elems)
+static void bpf_percpu_lru_push_free(struct bpf_lru *lru,
+				     struct bpf_lru_node *node)
+{
+	struct bpf_lru_list *l;
+	unsigned long flags;
+
+	l = per_cpu_ptr(lru->percpu_lru, node->cpu);
+
+	raw_spin_lock_irqsave(&l->lock, flags);
+
+	__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_FREE);
+
+	raw_spin_unlock_irqrestore(&l->lock, flags);
+}
+
+void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node)
+{
+	if (lru->percpu)
+		bpf_percpu_lru_push_free(lru, node);
+	else
+		bpf_common_lru_push_free(lru, node);
+}
+
+void bpf_common_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
+			     u32 elem_size, u32 nr_elems)
 {
 	struct bpf_lru_list *l = &lru->common_lru.lru_list;
 	u32 i;
@@ -507,6 +575,47 @@ void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
 	}
 }
 
+void bpf_percpu_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
+			     u32 elem_size, u32 nr_elems)
+{
+	u32 i, pcpu_entries;
+	int cpu;
+	struct bpf_lru_list *l;
+
+	pcpu_entries = nr_elems / num_possible_cpus();
+
+	i = 0;
+
+	for_each_possible_cpu(cpu) {
+		struct bpf_lru_node *node;
+
+		l = per_cpu_ptr(lru->percpu_lru, cpu);
+again:
+		node = (struct bpf_lru_node *)(buf + node_offset);
+		node->cpu = cpu;
+		node->type = BPF_LRU_LIST_T_FREE;
+		node->ref = 0;
+		list_add(&node->list, &l->lists[BPF_LRU_LIST_T_FREE]);
+		i++;
+		buf += elem_size;
+		if (i == nr_elems)
+			break;
+		if (i % pcpu_entries)
+			goto again;
+	}
+}
+
+void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
+		      u32 elem_size, u32 nr_elems)
+{
+	if (lru->percpu)
+		bpf_percpu_lru_populate(lru, buf, node_offset, elem_size,
+					nr_elems);
+	else
+		bpf_common_lru_populate(lru, buf, node_offset, elem_size,
+					nr_elems);
+}
+
 static void bpf_lru_locallist_init(struct bpf_lru_locallist *loc_l, int cpu)
 {
 	int i;
@@ -534,26 +643,42 @@ static void bpf_lru_list_init(struct bpf_lru_list *l)
 	raw_spin_lock_init(&l->lock);
 }
 
-int bpf_lru_init(struct bpf_lru *lru, u32 hash_offset,
+int bpf_lru_init(struct bpf_lru *lru, bool percpu, u32 hash_offset,
 		 del_from_htab_func del_from_htab, void *del_arg)
 {
 	int cpu;
-	struct bpf_common_lru *clru = &lru->common_lru;
 
-	clru->local_list = alloc_percpu(struct bpf_lru_locallist);
-	if (!clru->local_list)
-		return -ENOMEM;
+	if (percpu) {
+		lru->percpu_lru = alloc_percpu(struct bpf_lru_list);
+		if (!lru->percpu_lru)
+			return -ENOMEM;
 
-	for_each_possible_cpu(cpu) {
-		struct bpf_lru_locallist *loc_l;
+		for_each_possible_cpu(cpu) {
+			struct bpf_lru_list *l;
 
-		loc_l = per_cpu_ptr(clru->local_list, cpu);
-		bpf_lru_locallist_init(loc_l, cpu);
-	}
+			l = per_cpu_ptr(lru->percpu_lru, cpu);
+			bpf_lru_list_init(l);
+		}
+		lru->nr_scans = PERCPU_NR_SCANS;
+	} else {
+		struct bpf_common_lru *clru = &lru->common_lru;
 
-	bpf_lru_list_init(&clru->lru_list);
-	lru->nr_scans = LOCAL_NR_SCANS;
+		clru->local_list = alloc_percpu(struct bpf_lru_locallist);
+		if (!clru->local_list)
+			return -ENOMEM;
 
+		for_each_possible_cpu(cpu) {
+			struct bpf_lru_locallist *loc_l;
+
+			loc_l = per_cpu_ptr(clru->local_list, cpu);
+			bpf_lru_locallist_init(loc_l, cpu);
+		}
+
+		bpf_lru_list_init(&clru->lru_list);
+		lru->nr_scans = LOCAL_NR_SCANS;
+	}
+
+	lru->percpu = percpu;
 	lru->del_from_htab = del_from_htab;
 	lru->del_arg = del_arg;
 	lru->hash_offset = hash_offset;
@@ -563,5 +688,8 @@ int bpf_lru_init(struct bpf_lru *lru, u32 hash_offset,
 
 void bpf_lru_destroy(struct bpf_lru *lru)
 {
-	free_percpu(lru->common_lru.local_list);
+	if (lru->percpu)
+		free_percpu(lru->percpu_lru);
+	else
+		free_percpu(lru->common_lru.local_list);
 }
diff --git a/kernel/bpf/bpf_lru_list.h b/kernel/bpf/bpf_lru_list.h
index aaa2445..5c35a98 100644
--- a/kernel/bpf/bpf_lru_list.h
+++ b/kernel/bpf/bpf_lru_list.h
@@ -53,11 +53,15 @@ struct bpf_common_lru {
 typedef bool (*del_from_htab_func)(void *arg, struct bpf_lru_node *node);
 
 struct bpf_lru {
-	struct bpf_common_lru common_lru;
+	union {
+		struct bpf_common_lru common_lru;
+		struct bpf_lru_list __percpu *percpu_lru;
+	};
 	del_from_htab_func del_from_htab;
 	void *del_arg;
 	unsigned int hash_offset;
 	unsigned int nr_scans;
+	bool percpu;
 };
 
 static inline void bpf_lru_node_set_ref(struct bpf_lru_node *node)
@@ -68,7 +72,7 @@ static inline void bpf_lru_node_set_ref(struct bpf_lru_node *node)
 	node->ref = 1;
 }
 
-int bpf_lru_init(struct bpf_lru *lru, u32 hash_offset,
+int bpf_lru_init(struct bpf_lru *lru, bool percpu, u32 hash_offset,
 		 del_from_htab_func del_from_htab, void *delete_arg);
 void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
 		      u32 elem_size, u32 nr_elems);
-- 
2.5.1
