From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 05/26] RDS: Info and stats
Date: Tue, 24 Feb 2009 17:30:22 -0800
Message-ID: <1235525443-9007-6-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27728 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075AbZBYBbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:05 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS currently generates a lot of stats that are accessible via
the rds-info utility. This code implements the support for this.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/info.c  |  241 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/info.h  |   30 +++++++
 net/rds/stats.c |  148 ++++++++++++++++++++++++++++++++++
 3 files changed, 419 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/info.c
 create mode 100644 net/rds/info.h
 create mode 100644 net/rds/stats.c

diff --git a/net/rds/info.c b/net/rds/info.c
new file mode 100644
index 0000000..1d88553
--- /dev/null
+++ b/net/rds/info.c
@@ -0,0 +1,241 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+
+#include "rds.h"
+
+/*
+ * This file implements a getsockopt() call which copies a set of fixed
+ * sized structs into a user-specified buffer as a means of providing
+ * read-only information about RDS.
+ *
+ * For a given information source there are a given number of fixed sized
+ * structs at a given time.  The structs are only copied if the user-specified
+ * buffer is big enough.  The destination pages that make up the buffer
+ * are pinned for the duration of the copy.
+ *
+ * This gives us the following benefits:
+ *
+ * - simple implementation, no copy "position" across multiple calls
+ * - consistent snapshot of an info source
+ * - atomic copy works well with whatever locking info source has
+ * - one portable tool to get rds info across implementations
+ * - long-lived tool can get info without allocating
+ *
+ * at the following costs:
+ *
+ * - info source copy must be pinned, may be "large"
+ */
+
+struct rds_info_iterator {
+	struct page **pages;
+	void *addr;
+	unsigned long offset;
+};
+
+static DEFINE_SPINLOCK(rds_info_lock);
+static rds_info_func rds_info_funcs[RDS_INFO_LAST - RDS_INFO_FIRST + 1];
+
+void rds_info_register_func(int optname, rds_info_func func)
+{
+	int offset = optname - RDS_INFO_FIRST;
+
+	BUG_ON(optname < RDS_INFO_FIRST || optname > RDS_INFO_LAST);
+
+	spin_lock(&rds_info_lock);
+	BUG_ON(rds_info_funcs[offset] != NULL);
+	rds_info_funcs[offset] = func;
+	spin_unlock(&rds_info_lock);
+}
+
+void rds_info_deregister_func(int optname, rds_info_func func)
+{
+	int offset = optname - RDS_INFO_FIRST;
+
+	BUG_ON(optname < RDS_INFO_FIRST || optname > RDS_INFO_LAST);
+
+	spin_lock(&rds_info_lock);
+	BUG_ON(rds_info_funcs[offset] != func);
+	rds_info_funcs[offset] = NULL;
+	spin_unlock(&rds_info_lock);
+}
+
+/*
+ * Typically we hold an atomic kmap across multiple rds_info_copy() calls
+ * because the kmap is so expensive.  This must be called before using blocking
+ * operations while holding the mapping and as the iterator is torn down.
+ */
+void rds_info_iter_unmap(struct rds_info_iterator *iter)
+{
+	if (iter->addr != NULL) {
+		kunmap_atomic(iter->addr, KM_USER0);
+		iter->addr = NULL;
+	}
+}
+
+/*
+ * get_user_pages() called flush_dcache_page() on the pages for us.
+ */
+void rds_info_copy(struct rds_info_iterator *iter, void *data,
+		   unsigned long bytes)
+{
+	unsigned long this;
+
+	while (bytes) {
+		if (iter->addr == NULL)
+			iter->addr = kmap_atomic(*iter->pages, KM_USER0);
+
+		this = min(bytes, PAGE_SIZE - iter->offset);
+
+		rdsdebug("page %p addr %p offset %lu this %lu data %p "
+			  "bytes %lu\n", *iter->pages, iter->addr,
+			  iter->offset, this, data, bytes);
+
+		memcpy(iter->addr + iter->offset, data, this);
+
+		data += this;
+		bytes -= this;
+		iter->offset += this;
+
+		if (iter->offset == PAGE_SIZE) {
+			kunmap_atomic(iter->addr, KM_USER0);
+			iter->addr = NULL;
+			iter->offset = 0;
+			iter->pages++;
+		}
+	}
+}
+
+/*
+ * @optval points to the userspace buffer that the information snapshot
+ * will be copied into.
+ *
+ * @optlen on input is the size of the buffer in userspace.  @optlen
+ * on output is the size of the requested snapshot in bytes.
+ *
+ * This function returns -errno if there is a failure, particularly -ENOSPC
+ * if the given userspace buffer was not large enough to fit the snapshot.
+ * On success it returns the positive number of bytes of each array element
+ * in the snapshot.
+ */
+int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
+			int __user *optlen)
+{
+	struct rds_info_iterator iter;
+	struct rds_info_lengths lens;
+	unsigned long nr_pages = 0;
+	unsigned long start;
+	unsigned long i;
+	rds_info_func func;
+	struct page **pages = NULL;
+	int ret;
+	int len;
+	int total;
+
+	if (get_user(len, optlen)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	/* check for all kinds of wrapping and the like */
+	start = (unsigned long)optval;
+	if (len < 0 || len + PAGE_SIZE - 1 < len || start + len < start) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* a 0 len call is just trying to probe its length */
+	if (len == 0)
+		goto call_func;
+
+	nr_pages = (PAGE_ALIGN(start + len) - (start & PAGE_MASK))
+			>> PAGE_SHIFT;
+
+	pages = kmalloc(nr_pages * sizeof(struct page *), GFP_KERNEL);
+	if (pages == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	down_read(&current->mm->mmap_sem);
+	ret = get_user_pages(current, current->mm, start, nr_pages, 1, 0,
+			     pages, NULL);
+	up_read(&current->mm->mmap_sem);
+	if (ret != nr_pages) {
+		if (ret > 0)
+			nr_pages = ret;
+		else
+			nr_pages = 0;
+		ret = -EAGAIN; /* XXX ? */
+		goto out;
+	}
+
+	rdsdebug("len %d nr_pages %lu\n", len, nr_pages);
+
+call_func:
+	func = rds_info_funcs[optname - RDS_INFO_FIRST];
+	if (func == NULL) {
+		ret = -ENOPROTOOPT;
+		goto out;
+	}
+
+	iter.pages = pages;
+	iter.addr = NULL;
+	iter.offset = start & (PAGE_SIZE - 1);
+
+	func(sock, len, &iter, &lens);
+	BUG_ON(lens.each == 0);
+
+	total = lens.nr * lens.each;
+
+	rds_info_iter_unmap(&iter);
+
+	if (total > len) {
+		len = total;
+		ret = -ENOSPC;
+	} else {
+		len = total;
+		ret = lens.each;
+	}
+
+	if (put_user(len, optlen))
+		ret = -EFAULT;
+
+out:
+	for (i = 0; pages != NULL && i < nr_pages; i++)
+		put_page(pages[i]);
+	kfree(pages);
+
+	return ret;
+}
diff --git a/net/rds/info.h b/net/rds/info.h
new file mode 100644
index 0000000..b6c052c
--- /dev/null
+++ b/net/rds/info.h
@@ -0,0 +1,30 @@
+#ifndef _RDS_INFO_H
+#define _RDS_INFO_H
+
+struct rds_info_lengths {
+	unsigned int	nr;
+	unsigned int	each;
+};
+
+struct rds_info_iterator;
+
+/*
+ * These functions must fill in the fields of @lens to reflect the size
+ * of the available info source.  If the snapshot fits in @len then it
+ * should be copied using @iter.  The caller will deduce if it was copied
+ * or not by comparing the lengths.
+ */
+typedef void (*rds_info_func)(struct socket *sock, unsigned int len,
+			      struct rds_info_iterator *iter,
+			      struct rds_info_lengths *lens);
+
+void rds_info_register_func(int optname, rds_info_func func);
+void rds_info_deregister_func(int optname, rds_info_func func);
+int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
+			int __user *optlen);
+void rds_info_copy(struct rds_info_iterator *iter, void *data,
+		   unsigned long bytes);
+void rds_info_iter_unmap(struct rds_info_iterator *iter);
+
+
+#endif
diff --git a/net/rds/stats.c b/net/rds/stats.c
new file mode 100644
index 0000000..6371468
--- /dev/null
+++ b/net/rds/stats.c
@@ -0,0 +1,148 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+
+#include "rds.h"
+
+DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_statistics, rds_stats);
+
+/* :.,$s/unsigned long\>.*\<s_\(.*\);/"\1",/g */
+
+static char *rds_stat_names[] = {
+	"conn_reset",
+	"recv_drop_bad_checksum",
+	"recv_drop_old_seq",
+	"recv_drop_no_sock",
+	"recv_drop_dead_sock",
+	"recv_deliver_raced",
+	"recv_delivered",
+	"recv_queued",
+	"recv_immediate_retry",
+	"recv_delayed_retry",
+	"recv_ack_required",
+	"recv_rdma_bytes",
+	"recv_ping",
+	"send_queue_empty",
+	"send_queue_full",
+	"send_sem_contention",
+	"send_sem_queue_raced",
+	"send_immediate_retry",
+	"send_delayed_retry",
+	"send_drop_acked",
+	"send_ack_required",
+	"send_queued",
+	"send_rdma",
+	"send_rdma_bytes",
+	"send_pong",
+	"page_remainder_hit",
+	"page_remainder_miss",
+	"copy_to_user",
+	"copy_from_user",
+	"cong_update_queued",
+	"cong_update_received",
+	"cong_send_error",
+	"cong_send_blocked",
+};
+
+void rds_stats_info_copy(struct rds_info_iterator *iter,
+			 uint64_t *values, char **names, size_t nr)
+{
+	struct rds_info_counter ctr;
+	size_t i;
+
+	for (i = 0; i < nr; i++) {
+		BUG_ON(strlen(names[i]) >= sizeof(ctr.name));
+		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
+		ctr.value = values[i];
+
+		rds_info_copy(iter, &ctr, sizeof(ctr));
+	}
+}
+
+/*
+ * This gives global counters across all the transports.  The strings
+ * are copied in so that the tool doesn't need knowledge of the specific
+ * stats that we're exporting.  Some are pretty implementation dependent
+ * and may change over time.  That doesn't stop them from being useful.
+ *
+ * This is the only function in the chain that knows about the byte granular
+ * length in userspace.  It converts it to number of stat entries that the
+ * rest of the functions operate in.
+ */
+static void rds_stats_info(struct socket *sock, unsigned int len,
+			   struct rds_info_iterator *iter,
+			   struct rds_info_lengths *lens)
+{
+	struct rds_statistics stats = {0, };
+	uint64_t *src;
+	uint64_t *sum;
+	size_t i;
+	int cpu;
+	unsigned int avail;
+
+	avail = len / sizeof(struct rds_info_counter);
+
+	if (avail < ARRAY_SIZE(rds_stat_names)) {
+		avail = 0;
+		goto trans;
+	}
+
+	for_each_online_cpu(cpu) {
+		src = (uint64_t *)&(per_cpu(rds_stats, cpu));
+		sum = (uint64_t *)&stats;
+		for (i = 0; i < sizeof(stats) / sizeof(uint64_t); i++)
+			*(sum++) += *(src++);
+	}
+
+	rds_stats_info_copy(iter, (uint64_t *)&stats, rds_stat_names,
+			    ARRAY_SIZE(rds_stat_names));
+	avail -= ARRAY_SIZE(rds_stat_names);
+
+trans:
+	lens->each = sizeof(struct rds_info_counter);
+	lens->nr = rds_trans_stats_info_copy(iter, avail) +
+		   ARRAY_SIZE(rds_stat_names);
+}
+
+void rds_stats_exit(void)
+{
+	rds_info_deregister_func(RDS_INFO_COUNTERS, rds_stats_info);
+}
+
+int __init rds_stats_init(void)
+{
+	rds_info_register_func(RDS_INFO_COUNTERS, rds_stats_info);
+	return 0;
+}
-- 
1.5.6.3

