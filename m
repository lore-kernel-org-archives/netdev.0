From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/9] bpf: introduce percpu_freelist
Date: Sun, 6 Mar 2016 17:58:30 -0800
Message-ID: <1457315917-1970307-3-git-send-email-ast@fb.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51466 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922AbcCGB6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 20:58:42 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u271sU67014710
	for <netdev@vger.kernel.org>; Sun, 6 Mar 2016 17:58:41 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21g18wm9ar-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 17:58:41 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 1c4ce088e40811e5a76924be0595f910-73ed8270 for <netdev@vger.kernel.org>;	Sun,
 06 Mar 2016 17:58:39 -0800
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce simple percpu_freelist to keep single list of elements
spread across per-cpu singly linked lists.

/* push element into the list */
void pcpu_freelist_push(struct pcpu_freelist *, struct pcpu_freelist_node *);

/* pop element from the list */
struct pcpu_freelist_node *pcpu_freelist_pop(struct pcpu_freelist *);

The object is pushed to the current cpu list.
Pop first trying to get the object from the current cpu list,
if it's empty goes to the neigbour cpu list.

For bpf program usage pattern the collision rate is very low,
since programs push and pop the objects typically on the same cpu.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/Makefile          |  2 +-
 kernel/bpf/percpu_freelist.c | 81 ++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/percpu_freelist.h | 31 +++++++++++++++++
 3 files changed, 113 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/percpu_freelist.c
 create mode 100644 kernel/bpf/percpu_freelist.h

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 8a932d079c24..eed911d091da 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,7 +1,7 @@
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
-obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o
+obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
 endif
diff --git a/kernel/bpf/percpu_freelist.c b/kernel/bpf/percpu_freelist.c
new file mode 100644
index 000000000000..250e45c223a1
--- /dev/null
+++ b/kernel/bpf/percpu_freelist.c
@@ -0,0 +1,81 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include "percpu_freelist.h"
+
+int pcpu_freelist_init(struct pcpu_freelist *s)
+{
+	int cpu;
+
+	s->freelist = alloc_percpu(struct pcpu_freelist_head);
+	if (!s->freelist)
+		return -ENOMEM;
+
+	for_each_possible_cpu(cpu) {
+		struct pcpu_freelist_head *head = per_cpu_ptr(s->freelist, cpu);
+
+		raw_spin_lock_init(&head->lock);
+		head->first = NULL;
+	}
+	return 0;
+}
+
+void pcpu_freelist_destroy(struct pcpu_freelist *s)
+{
+	free_percpu(s->freelist);
+}
+
+static inline void __pcpu_freelist_push(struct pcpu_freelist_head *head,
+					struct pcpu_freelist_node *node)
+{
+	raw_spin_lock(&head->lock);
+	node->next = head->first;
+	head->first = node;
+	raw_spin_unlock(&head->lock);
+}
+
+/* must be called with preemption disabled */
+void pcpu_freelist_push(struct pcpu_freelist *s,
+			struct pcpu_freelist_node *node)
+{
+	struct pcpu_freelist_head *head = this_cpu_ptr(s->freelist);
+
+	__pcpu_freelist_push(head, node);
+}
+
+void pcpu_freelist_push_cpu(struct pcpu_freelist *s,
+			    struct pcpu_freelist_node *node, int cpu)
+{
+	struct pcpu_freelist_head *head = per_cpu_ptr(s->freelist, cpu);
+
+	__pcpu_freelist_push(head, node);
+}
+
+/* must be called with preemption disabled */
+struct pcpu_freelist_node *pcpu_freelist_pop(struct pcpu_freelist *s)
+{
+	struct pcpu_freelist_head *head;
+	struct pcpu_freelist_node *node;
+	int orig_cpu, cpu;
+
+	orig_cpu = cpu = raw_smp_processor_id();
+	while (1) {
+		head = per_cpu_ptr(s->freelist, cpu);
+		raw_spin_lock(&head->lock);
+		node = head->first;
+		if (node) {
+			head->first = node->next;
+			raw_spin_unlock(&head->lock);
+			return node;
+		}
+		raw_spin_unlock(&head->lock);
+		cpu = cpumask_next(cpu, cpu_possible_mask);
+		if (cpu >= nr_cpu_ids)
+			cpu = 0;
+		if (cpu == orig_cpu)
+			return NULL;
+	}
+}
diff --git a/kernel/bpf/percpu_freelist.h b/kernel/bpf/percpu_freelist.h
new file mode 100644
index 000000000000..4150da61dd13
--- /dev/null
+++ b/kernel/bpf/percpu_freelist.h
@@ -0,0 +1,31 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef __PERCPU_FREELIST_H__
+#define __PERCPU_FREELIST_H__
+#include <linux/spinlock.h>
+#include <linux/percpu.h>
+
+struct pcpu_freelist_head {
+	struct pcpu_freelist_node *first;
+	raw_spinlock_t lock;
+};
+
+struct pcpu_freelist {
+	struct pcpu_freelist_head __percpu *freelist;
+};
+
+struct pcpu_freelist_node {
+	struct pcpu_freelist_node *next;
+};
+
+void pcpu_freelist_push(struct pcpu_freelist *, struct pcpu_freelist_node *);
+void pcpu_freelist_push_cpu(struct pcpu_freelist *, struct pcpu_freelist_node *,
+			    int);
+struct pcpu_freelist_node *pcpu_freelist_pop(struct pcpu_freelist *);
+int pcpu_freelist_init(struct pcpu_freelist *);
+void pcpu_freelist_destroy(struct pcpu_freelist *s);
+#endif
-- 
2.6.5
