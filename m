From: Li Yu <raise.sail@gmail.com>
Subject: [RFC][PATCH 1/4] skbtrace: core feature
Date: Wed, 11 Jul 2012 10:17:37 +0800
Message-ID: <4FFCE241.6010305@gmail.com>
References: <4FFBC6B6.2000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40614 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033Ab2GKCRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 22:17:49 -0400
Received: by pbbrp8 with SMTP id rp8so1204818pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 19:17:49 -0700 (PDT)
In-Reply-To: <4FFBC6B6.2000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This implements core feature of skbtrace, which contains glue code of
tracepoints subsystem and relay file system, and provide skbtrace API
for particular networking traces.

Thanks

Sign-off-by: Li Yu <bingtian.ly@taobao.com>
---
 include/linux/skbtrace.h        |  151 ++++++++
 include/linux/skbtrace_api.h    |   70 ++++
 include/trace/events/skbtrace.h |   29 ++
 net/core/skbtrace-core.c        |  758
+++++++++++++++++++++++++++++++++++++++
 4 files changed, 1008 insertions(+)
 create mode 100644 include/linux/skbtrace.h
 create mode 100644 include/linux/skbtrace_api.h
 create mode 100644 include/trace/events/skbtrace.h
 create mode 100644 net/core/skbtrace-core.c

diff --git a/include/linux/skbtrace.h b/include/linux/skbtrace.h
new file mode 100644
index 0000000..34b9144
--- /dev/null
+++ b/include/linux/skbtrace.h
@@ -0,0 +1,151 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	API for kernel
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#ifndef _LINUX_SKBTRACE_H
+#define _LINUX_SKBTRACE_H
+
+#include <linux/static_key.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/net.h>
+#include <linux/skbtrace_api.h>
+
+#include <net/sock.h>
+
+#if defined(CONFIG_SKBTRACE) || defined(CONFIG_SKBTRACE_MODULE)
+#define HAVE_SKBTRACE 1
+#else
+#define HAVE_SKBTRACE 0
+#endif
+
+#if HAVE_SKBTRACE
+
+struct skbtrace_tracepoint {
+	const char *name;
+	void *probe;
+	int (*setup_options)(struct skbtrace_tracepoint *tp,
+						char *name, char *options);
+	char* (*desc)(struct skbtrace_tracepoint *tp);
+	unsigned int enabled:1;
+	void *private;
+};
+
+extern atomic64_t skbtrace_event_seq;
+
+#define INIT_SKBTRACE_BLOCK(blk, p, act, fl, blk_size) \
+	do {\
+		(blk)->len = (blk_size);\
+		(blk)->action = (act);\
+		(blk)->flags = (fl);\
+		(blk)->seq = atomic64_add_return(1, &skbtrace_event_seq);\
+		(blk)->ts = current_kernel_time();\
+		(blk)->ptr = (p);\
+	} while (0)
+
+#define EMPTY_SKBTRACE_TP	{.name = NULL, }
+
+struct skbtrace_context {
+	union {
+		struct skbtrace_block blk;
+	};
+};
+
+extern int skbtrace_register_tracepoints(int af,
+				struct skbtrace_tracepoint *tp_list);
+extern void skbtrace_unregister_tracepoints(int af);
+extern void __skbtrace_probe(struct skbtrace_block *blk);
+extern int skbtrace_events_common_init(void);
+
+extern struct static_key skbtrace_filters_enabled;
+extern struct sk_filter *def_sk_filter;
+
+static inline void skbtrace_probe(struct skbtrace_block *blk)
+{
+	if (skbtrace_action_invalid == blk->action)
+		return;
+	__skbtrace_probe(blk);
+}
+
+static inline struct skbtrace_context *skbtrace_context_get(struct sock
*sk)
+{
+	if (likely(sk->sk_skbtrace))
+		return sk->sk_skbtrace;
+	sk->sk_skbtrace = kzalloc(sizeof(struct skbtrace_context), GFP_ATOMIC);
+	return sk->sk_skbtrace;
+}
+
+static inline void skbtrace_context_destroy(struct sock *sk)
+{
+	kfree(sk->sk_skbtrace);
+	sk->sk_skbtrace = NULL;
+}
+
+static inline void skbtrace_context_reset(struct sock *sk)
+{
+	sk->sk_skbtrace = NULL;
+}
+
+static inline int skbtrace_bypass_skb(struct sk_buff *skb)
+{
+	if (static_key_false(&skbtrace_filters_enabled)) {
+		if (skb->skbtrace_filtered)
+			return skb->hit_skbtrace;
+		else if (def_sk_filter) {
+			unsigned int pkt_len;
+
+			pkt_len = SK_RUN_FILTER(def_sk_filter, skb);
+			skb->hit_skbtrace = !pkt_len;
+			skb->skbtrace_filtered = 1;
+			return skb->hit_skbtrace;
+		}
+	}
+	return 0;
+}
+
+#define SKBTRACE_SKB_EVENT_BEGIN \
+{\
+	if (skbtrace_bypass_skb(skb)) {\
+		return;	\
+	} else {
+
+#define SKBTRACE_SKB_EVENT_END \
+	} \
+}
+
+#define SKBTRACE_SOCK_EVENT_BEGIN {
+
+#define SKBTRACE_SOCK_EVENT_END }
+
+#else /* HAVE_SKBTRACE */
+
+static inline void remove_skbtrace_context(struct sock *sk)
+{
+}
+
+static inline void skbtrace_context_reset(struct sock *sk)
+{
+}
+
+#endif /* HAVE_SKBTRACE */
+
+#endif /* _LINUX_SKBTRACE_H */
diff --git a/include/linux/skbtrace_api.h b/include/linux/skbtrace_api.h
new file mode 100644
index 0000000..58db922
--- /dev/null
+++ b/include/linux/skbtrace_api.h
@@ -0,0 +1,70 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	User/Kernel Interface
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+#ifndef _LINUX_SKBTRACE_API_H
+#define _LINUX_SKBTRACE_API_H
+
+#include <linux/types.h>
+
+#ifdef __KERNEL__
+#include <linux/time.h>
+#else
+#include <time.h>
+#define __packed	__attribute__ ((__packed__))
+#endif
+
+#define TRACE_SPEC_MAX_LEN	256
+
+#define SKBTRACE_DEF_SUBBUF_SIZE	(1<<7)
+#define SKBTRACE_DEF_SUBBUF_NR		(1<<11)
+
+#define SKBTRACE_MIN_SUBBUF_SIZE	SKBTRACE_DEF_SUBBUF_SIZE
+#define SKBTRACE_MIN_SUBBUF_NR		SKBTRACE_DEF_SUBBUF_NR
+
+#define SKBTRACE_MAX_SUBBUF_SIZE	(1<<12)
+#define SKBTRACE_MAX_SUBBUF_NR		(1<<20)
+
+#define SC	0	/* for tracepoints in process context */
+#define SI	1	/* for tracepoints in softirq context */
+#define HW	2	/* for tracepoints in hardirq context */
+#define NR_CHANNELS	3
+
+/* struct skbtrace_block - be used in kernel/user interaction	*/
+/* @len:	whole data structure size in bytes		*/
+/* @action:	action of this skbtrace_block			*/
+/* @flags:	the flags depend on above action field		*/
+/* @ts:		the timestamp of this event.			*/
+/* @ptr:	the major source kernel data structure		*/
+/*		of this event, for gerneral, a sk_buff or sock	*/
+/* PLEASE:							*/
+/*	Keep 32 bits alignment on 32 bits platform		*/
+/*	And, keep 64 bits alignment on 64 bits platform		*/
+struct skbtrace_block {
+	__u16 len;
+	__u16 action;
+	__u32 flags;
+	struct timespec ts;
+	__u64 seq;
+	void *ptr;
+} __packed;
+
+#endif
diff --git a/include/trace/events/skbtrace.h
b/include/trace/events/skbtrace.h
new file mode 100644
index 0000000..b580814
--- /dev/null
+++ b/include/trace/events/skbtrace.h
@@ -0,0 +1,29 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ *	Events
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#if !defined(_TRACE_EVENTS_SKBTRACE_H)
+#define _TRACE_EVENTS_SKBTRACE_H
+
+#include <linux/tracepoint.h>
+
+#endif
diff --git a/net/core/skbtrace-core.c b/net/core/skbtrace-core.c
new file mode 100644
index 0000000..6146bca
--- /dev/null
+++ b/net/core/skbtrace-core.c
@@ -0,0 +1,758 @@
+/*
+ *  skbtrace - sk_buff trace utilty
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
+ *
+ * 2012 Li Yu <bingtian.ly@taobao.com>
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/relay.h>
+#include <linux/debugfs.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/jhash.h>
+
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include <linux/skbtrace.h>
+#include <net/sock.h>
+
+#define SKBTRACE_VERSION	"1"
+#define SKBTRACE_DIR		"skbtrace"
+
+static unsigned long skbtrace_dropped[NR_CHANNELS][NR_CPUS];
+/* +1 for quick indexing trick in __skbtrace_probe() */
+static struct rchan *skbtrace_channels[NR_CHANNELS + 1];
+
+static struct sock_fprog def_sk_fprog;
+struct sk_filter *def_sk_filter;
+EXPORT_SYMBOL_GPL(def_sk_filter);
+
+static struct dentry	*skbtrace_dentry;
+static struct dentry	*enabled_control;
+static struct dentry	*dropped_control;
+static struct dentry	*version_control;
+static struct dentry	*subbuf_nr_control;
+static struct dentry	*subbuf_size_control;
+static struct dentry	*filters_control;
+
+static const struct file_operations	enabled_fops;
+static const struct file_operations	dropped_fops;
+static const struct file_operations	version_fops;
+static const struct file_operations	subbuf_nr_fops;
+static const struct file_operations	subbuf_size_fops;
+static const struct file_operations	filters_fops;
+
+static int nr_skbtrace_enabled_tp;
+static int subbuf_nr = SKBTRACE_DEF_SUBBUF_NR;
+static int subbuf_size = SKBTRACE_DEF_SUBBUF_SIZE;
+
+struct static_key skbtrace_filters_enabled = STATIC_KEY_INIT_FALSE;
+EXPORT_SYMBOL_GPL(skbtrace_filters_enabled);
+
+atomic64_t skbtrace_event_seq = ATOMIC64_INIT(0);
+EXPORT_SYMBOL_GPL(skbtrace_event_seq);
+
+/* protect agaist af_tp_list and skbtrace_channels */
+static struct mutex skbtrace_lock;
+static struct skbtrace_tracepoint *af_tp_list[AF_MAX];
+
+static int create_controls(void);
+static void remove_controls(void);
+static int  create_channels(void);
+static void flush_channels(void);
+static void destroy_channels(void);
+static ssize_t sk_filter_read(struct sock_fprog *fprog, char __user
*buffer,
+							    size_t count);
+static ssize_t sk_filter_write(struct sock_fprog *sk_fprog,
+				struct sk_filter **sk_filter,
+				const char __user *buffer, size_t count);
+
+static void skbtrace_proto_load(void)
+{
+	int af;
+
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		/* load proto-specific events */
+		if (!af_tp_list[af])
+			request_module("skbtrace-af-%d", af);
+	}
+}
+
+void __skbtrace_probe(struct skbtrace_block *blk)
+{
+	unsigned int chan_id;
+	struct rchan *rchan;
+
+	chan_id = (!!in_irq()) << 1;
+	chan_id |= !!in_softirq();	/* make sparse happy */
+	rchan = skbtrace_channels[chan_id];
+
+	if (unlikely(chan_id >= HW))
+		relay_write(rchan, blk, blk->len);
+	else {
+		local_bh_disable();
+		__relay_write(rchan, blk, blk->len);
+		local_bh_enable();
+	}
+	blk->action = skbtrace_action_invalid;
+}
+EXPORT_SYMBOL_GPL(__skbtrace_probe);
+
+int skbtrace_register_tracepoints(int af,
+				struct skbtrace_tracepoint *tp_list)
+{
+	int ret = 0;
+
+	if (af < 0 || af >= AF_MAX || !tp_list)
+		return -EINVAL;
+
+	mutex_lock(&skbtrace_lock);
+	if (af_tp_list[af])
+		ret = -EEXIST;
+	else if (tp_list[0].name)
+		af_tp_list[af] = tp_list;
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(skbtrace_register_tracepoints);
+
+void skbtrace_unregister_tracepoints(int af)
+{
+	struct skbtrace_tracepoint *tp;
+
+	if (af < 0 || af >= AF_MAX)
+		return;
+
+	mutex_lock(&skbtrace_lock);
+	tp = af_tp_list[af];
+	while (tp && tp->name) {
+		if (tp->enabled) {
+			tp->enabled = 0;
+			--nr_skbtrace_enabled_tp;
+			tracepoint_probe_unregister(tp->name, tp->probe, tp);
+		}
+		tp++;
+	}
+	af_tp_list[af] = NULL;
+	mutex_unlock(&skbtrace_lock);
+	flush_channels();
+}
+EXPORT_SYMBOL_GPL(skbtrace_unregister_tracepoints);
+
+static int subbuf_start_handler(struct rchan_buf *buf,
+				void *subbuf,
+				void *prev_subbuf,
+				size_t prev_padding)
+{
+	if (relay_buf_full(buf)) {
+		long trace, cpu;
+
+		trace = (long)buf->chan->private_data;
+		cpu = buf->cpu;
+		skbtrace_dropped[trace][cpu]++;
+		return 0;
+	}
+	return 1;
+}
+
+static struct dentry *create_buf_file_handler(const char *filename,
+					      struct dentry *parent,
+					      umode_t mode,
+					      struct rchan_buf *buf,
+					      int *is_global)
+{
+	return debugfs_create_file(filename, mode, parent, buf,
+				       &relay_file_operations);
+}
+
+static int remove_buf_file_handler(struct dentry *dentry)
+{
+	debugfs_remove(dentry);
+	return 0;
+}
+
+static struct rchan_callbacks relayfs_callbacks = {
+	.subbuf_start = subbuf_start_handler,
+	.create_buf_file = create_buf_file_handler,
+	.remove_buf_file = remove_buf_file_handler,
+};
+
+/* caller must hold skbtrace_lock */
+static int create_channels(void)
+{
+	unsigned long i, created;
+	const char *skbtrace_names[NR_CHANNELS] = {    "trace.syscall.cpu",
+							"trace.softirq.cpu",
+							"trace.hardirq.cpu" };
+	created = 0;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i])
+			continue;
+		skbtrace_channels[i] = relay_open(skbtrace_names[i],
+			skbtrace_dentry, subbuf_size, subbuf_nr,
+				&relayfs_callbacks, (void *)i);
+		if (!skbtrace_channels[i]) {
+			destroy_channels();
+			return -ENOMEM;
+		}
+		created = 1;
+	}
+	skbtrace_channels[HW + 1] = skbtrace_channels[HW];
+
+	if (created)
+		__module_get(THIS_MODULE);
+	return 0;
+}
+
+static void flush_channels(void)
+{
+	int i;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i])
+			relay_flush(skbtrace_channels[i]);
+	}
+}
+
+/* caller must hold skbtrace_lock */
+static void destroy_channels(void)
+{
+	int i, removed;
+
+	removed = 0;
+	for (i = 0; i < NR_CHANNELS; i++) {
+		if (skbtrace_channels[i]) {
+			relay_flush(skbtrace_channels[i]);
+			relay_close(skbtrace_channels[i]);
+			skbtrace_channels[i] = NULL;
+			removed = 1;
+		}
+	}
+	skbtrace_channels[HW + 1] = NULL;
+
+	if (removed)
+		module_put(THIS_MODULE);
+}
+
+static void remove_controls(void)
+{
+#define REMOVE_DEBUGFS_FILE(name) \
+	do {\
+		if (name##_control) \
+			debugfs_remove(name##_control); \
+	} while(0);
+
+	REMOVE_DEBUGFS_FILE(enabled)
+	REMOVE_DEBUGFS_FILE(dropped)
+	REMOVE_DEBUGFS_FILE(version)
+	REMOVE_DEBUGFS_FILE(subbuf_nr)
+	REMOVE_DEBUGFS_FILE(subbuf_size)
+	REMOVE_DEBUGFS_FILE(filters)
+}
+
+static int create_controls(void)
+{
+#define CREATE_DEBUGFS_FILE(name)\
+	do {\
+		name##_control = debugfs_create_file(#name, 0,\
+				skbtrace_dentry, NULL, &name##_fops);\
+		if (name##_control)\
+			break;\
+		pr_err("skbtrace: couldn't create relayfs file '" #name "'\n");\
+		goto fail;\
+	} while (0);
+
+	CREATE_DEBUGFS_FILE(enabled)
+	CREATE_DEBUGFS_FILE(dropped)
+	CREATE_DEBUGFS_FILE(version)
+	CREATE_DEBUGFS_FILE(subbuf_nr)
+	CREATE_DEBUGFS_FILE(subbuf_size)
+	CREATE_DEBUGFS_FILE(filters)
+
+#undef CREATE_DEBUGFS_FILE
+	return 0;
+fail:
+	remove_controls();
+	return -1;
+}
+
+static char *skbtrace_tracepoint_default_desc(struct
skbtrace_tracepoint *t)
+{
+	char *desc;
+	int n;
+
+	n = strlen(t->name) + 64;
+	desc = kmalloc(n, GFP_KERNEL);
+	if (!desc)
+		return NULL;
+
+	snprintf(desc, n, "%s enabled:%d\n", t->name, !!t->enabled);
+	return desc;
+}
+
+static char *skbtrace_tracepoint_desc(struct skbtrace_tracepoint *tp)
+{
+	if (tp->desc)
+		return tp->desc(tp);
+	return skbtrace_tracepoint_default_desc(tp);
+}
+
+static ssize_t enabled_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	size_t ret, offset, len;
+	struct skbtrace_tracepoint *tp;
+	int af;
+	char *desc = NULL;
+
+	skbtrace_proto_load();
+
+	ret = offset = 0;
+	mutex_lock(&skbtrace_lock);
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->name) {
+			kfree(desc);
+			desc = skbtrace_tracepoint_desc(tp);
+			if (!desc)
+				return -ENOMEM;
+			len = strlen(desc);
+			offset += len;
+			if (offset <= *ppos) {
+				++tp;
+				continue;
+			}
+			if (count < len) {
+				ret = -EINVAL;
+				goto unlock;
+			}
+			if (copy_to_user(buffer, desc, len)) {
+				ret = -EFAULT;
+				goto unlock;
+			}
+			*ppos += len;
+			ret = len;
+			goto unlock;
+		}
+	}
+unlock:
+	kfree(desc);
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+
+static int skbtrace_enable_tp(char *event_spec)
+{
+	char *name, *options;
+	int ret, af;
+	struct skbtrace_tracepoint *tp;
+
+	name = event_spec;
+	options = strchr(event_spec, ',');
+	if (options) {
+		*options = '\x0';
+		++options;
+		if ('\x0' == *options)
+			options = NULL;
+	}
+
+	ret = -EEXIST;
+	mutex_lock(&skbtrace_lock);
+
+	if (!nr_skbtrace_enabled_tp) {
+		ret = create_channels();
+		if (ret)
+			goto unlock;
+	}
+
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->name) {
+			if (!strcmp(name, tp->name)) {
+				if (tp->setup_options) {
+					ret = tp->setup_options(tp,
+							name, options);
+					if (ret)
+						goto unlock;
+				}
+				ret = tracepoint_probe_register(tp->name,
+							tp->probe, tp);
+				goto reg;
+			}
+			++tp;
+		}
+	}
+
+reg:
+	if (ret && !nr_skbtrace_enabled_tp)
+		destroy_channels();
+	else if (!ret) {
+		tp->enabled = 1;
+		++nr_skbtrace_enabled_tp;
+	}
+unlock:
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+
+static int skbtrace_disable_tp(char *name)
+{
+	int ret, af;
+	struct skbtrace_tracepoint *tp;
+
+	/*
+	 * '-*' has two meanings:
+	 *
+	 *   (0) first time, it disables all tracepoints, and flush channels.
+	 *   (1) second time, it removes all channels.
+	 */
+
+	if (!nr_skbtrace_enabled_tp && '*' == *name) {
+		destroy_channels();
+		return 0;
+	}
+
+	ret = -EINVAL;
+	mutex_lock(&skbtrace_lock);
+	for (af = AF_UNSPEC; af < AF_MAX; af++) {
+		tp = af_tp_list[af];
+		while (tp && tp->name) {
+			if ('*' == *name || !strcmp(name, tp->name)) {
+				ret = tracepoint_probe_unregister(tp->name,
+							tp->probe, tp);
+				if (!ret) {
+					tp->enabled = 0;
+					--nr_skbtrace_enabled_tp;
+				}
+				if ('*' != *name)
+					goto unreg;
+			}
+			++tp;
+		}
+	}
+
+unreg:
+	flush_channels();
+
+	mutex_unlock(&skbtrace_lock);
+
+	return ret;
+}
+
+/* The user given buffer should contains such like string:
+ *	(0) To enable a skbtrace event:		"TRACE_NAME"
+ *	(1) To disable a skbtrace event:	"-TRACE_NAME"
+ *	(2) To disable all skbtrace events:	"-*"
+ */
+static ssize_t enabled_write(struct file *filp, const char __user *buffer,
+			     size_t count, loff_t *ppos)
+{
+	char kbuf[TRACE_SPEC_MAX_LEN+1];
+	int ret;
+
+	skbtrace_proto_load();
+
+	if (count >= TRACE_SPEC_MAX_LEN)
+		return -EINVAL;
+	if (copy_from_user(kbuf, buffer, count))
+		return -EFAULT;
+	kbuf[count] = '\x0';
+
+	if ('-' != kbuf[0])
+		ret = skbtrace_enable_tp(&kbuf[0]);
+	else
+		ret = skbtrace_disable_tp(&kbuf[1]);
+
+	return ret ?: count;
+}
+
+static int kmod_open(struct inode *inodep, struct file *filp)
+{
+	__module_get(THIS_MODULE);
+	return 0;
+}
+
+static int kmod_release(struct inode *inodep, struct file *filp)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static const struct file_operations enabled_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		enabled_read,
+	.write =	enabled_write,
+};
+
+static ssize_t dropped_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+
+	char buf[256];
+	unsigned long skbtrace_total_dropped[NR_CHANNELS] = {0, 0, 0};
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		skbtrace_total_dropped[HW] += skbtrace_dropped[HW][cpu];
+		skbtrace_total_dropped[SI] += skbtrace_dropped[SI][cpu];
+		skbtrace_total_dropped[SC] += skbtrace_dropped[SC][cpu];
+	}
+
+	snprintf(buf, sizeof(buf), "%lu %lu %lu\n",
+		skbtrace_total_dropped[HW],
+		skbtrace_total_dropped[SI],
+		skbtrace_total_dropped[SC]
+		);
+
+	return simple_read_from_buffer(buffer, count, ppos,
+				       buf, strlen(buf));
+}
+
+static ssize_t dropped_write(struct file *filp, const char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	memset(skbtrace_dropped, 0, sizeof(skbtrace_dropped));
+	return count;
+}
+
+static const struct file_operations dropped_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		dropped_read,
+	.write =	dropped_write,
+};
+
+static ssize_t version_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return simple_read_from_buffer(buffer, count, ppos,
+				       SKBTRACE_VERSION "\n",
+					strlen(SKBTRACE_VERSION "\n"));
+}
+
+static const struct file_operations version_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		version_read,
+};
+
+static ssize_t subbuf_x_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos, int which)
+{
+	char buf[24];
+
+	sprintf(buf, "%d\n", which);
+	return simple_read_from_buffer(buffer, count, ppos,
+				       buf, strlen(buf));
+}
+
+static ssize_t subbuf_x_write(struct file *filp, const char __user *buffer,
+			    size_t count, loff_t *ppos,
+			    int *which, int min_val, int max_val)
+{
+	char buf[24];
+	int v;
+
+	if (nr_skbtrace_enabled_tp)
+		return -EBUSY;
+
+	if (!buffer || count > sizeof(buf) - 1)
+		return -EINVAL;
+	memset(buf, 0, sizeof(buf));
+	if (copy_from_user(buf, buffer, count))
+		return -EFAULT;
+	if (sscanf(buf, "%d", &v) != 1)
+		return -EINVAL;
+	if (v < min_val || v > max_val)
+		return -EINVAL;
+
+	*which = v;
+	return count;
+}
+
+static ssize_t subbuf_nr_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_read(filp, buffer, count, ppos, subbuf_nr);
+}
+
+static ssize_t subbuf_nr_write(struct file *filp, const char __user
*buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_write(filp, buffer, count, ppos, &subbuf_nr,
+			SKBTRACE_MIN_SUBBUF_NR, SKBTRACE_MAX_SUBBUF_NR);
+}
+
+static const struct file_operations subbuf_nr_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		subbuf_nr_read,
+	.write =	subbuf_nr_write,
+};
+
+static ssize_t subbuf_size_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_read(filp, buffer, count, ppos, subbuf_size);
+}
+
+static ssize_t subbuf_size_write(struct file *filp, const char __user
*buffer,
+			    size_t count, loff_t *ppos)
+{
+	return subbuf_x_write(filp, buffer, count, ppos, &subbuf_size,
+			SKBTRACE_MIN_SUBBUF_SIZE, SKBTRACE_MAX_SUBBUF_SIZE);
+}
+
+static const struct file_operations subbuf_size_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		subbuf_size_read,
+	.write =	subbuf_size_write,
+};
+
+static ssize_t sk_filter_read(struct sock_fprog *fprog, char __user
*buffer,
+							    size_t count)
+{
+	int sz_filter;
+	struct sock_fprog user_fprog;
+
+	if (!fprog || !fprog->filter)
+		return -EINVAL;
+	sz_filter = fprog->len * sizeof(struct sock_filter);
+	if (count < sizeof(struct sock_fprog) + sz_filter)
+		return -EINVAL;
+	user_fprog.len = fprog->len;
+	user_fprog.filter = (struct sock_filter *)
+					(buffer + sizeof(struct sock_fprog));
+	if (copy_to_user(buffer, &user_fprog, sizeof(struct sock_fprog)))
+		return -EFAULT;
+	if (copy_to_user(user_fprog.filter, fprog->filter, sz_filter))
+		return -EFAULT;
+
+	return sizeof(struct sock_fprog) + sz_filter;
+}
+
+static ssize_t sk_filter_write(struct sock_fprog *sk_fprog,
+				struct sk_filter **sk_filter,
+				const char __user *buffer, size_t count)
+{
+	int sz_filter, ret;
+	struct sock_filter __user *user_filter;
+
+	if (count < sizeof(struct sock_fprog) || sk_fprog->filter)
+		return -EINVAL;
+	if (copy_from_user(sk_fprog, buffer, sizeof(struct sock_fprog)))
+		return -EFAULT;
+	sz_filter = sk_fprog->len * sizeof(struct sock_filter);
+	user_filter = sk_fprog->filter;
+
+	sk_fprog->filter = kzalloc(sz_filter, GFP_KERNEL);
+	if (!sk_fprog->filter)
+		ret = -ENOMEM;
+
+	ret = -EFAULT;
+	if (!copy_from_user(sk_fprog->filter, user_filter, sz_filter))
+		ret = sk_unattached_filter_create(sk_filter, sk_fprog);
+	if (!ret) {
+		static_key_slow_inc(&skbtrace_filters_enabled);
+		return sizeof(struct sock_fprog) + sz_filter;
+	}
+	kfree(sk_fprog->filter);
+	sk_fprog->filter = NULL;
+	return ret;
+}
+
+static ssize_t filters_read(struct file *filp, char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	return sk_filter_read(&def_sk_fprog, buffer, count);
+}
+
+static ssize_t filters_write(struct file *filp, const char __user *buffer,
+			    size_t count, loff_t *ppos)
+{
+	skbtrace_proto_load();
+
+	if (nr_skbtrace_enabled_tp)
+		return -EBUSY;
+
+	if (def_sk_fprog.filter) {
+		kfree(def_sk_fprog.filter);
+		def_sk_fprog.filter = NULL;
+	}
+	if (def_sk_filter) {
+		static_key_slow_dec(&skbtrace_filters_enabled);
+		sk_unattached_filter_destroy(def_sk_filter);
+		def_sk_filter = NULL;
+	}
+	return sk_filter_write(&def_sk_fprog, &def_sk_filter, buffer, count);
+}
+
+static const struct file_operations filters_fops = {
+	.owner =	THIS_MODULE,
+	.open =		kmod_open,
+	.release =	kmod_release,
+	.read =		filters_read,
+	.write =	filters_write,
+};
+
+static int skbtrace_init(void)
+{
+	mutex_init(&skbtrace_lock);
+
+	memset(&def_sk_fprog, 0, sizeof(struct sock_fprog));
+	def_sk_filter = NULL;
+
+	if (skbtrace_events_common_init())
+		return -ENODEV;
+
+	skbtrace_dentry = debugfs_create_dir(SKBTRACE_DIR, NULL);
+	if (!skbtrace_dentry)
+		return -ENOMEM;
+
+	if (create_controls()) {
+		debugfs_remove(skbtrace_dentry);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void skbtrace_exit(void)
+{
+	skbtrace_disable_tp("*"); /* disable all enabled tracepoints */
+	skbtrace_disable_tp("*"); /* remove channels in debugfs at 2nd time */
+	if (unlikely(nr_skbtrace_enabled_tp))
+		pr_err("skbtrace: failed to clean tracepoints.\n");
+	remove_controls();
+	debugfs_remove(skbtrace_dentry);
+}
+
+module_init(skbtrace_init);
+module_exit(skbtrace_exit);
+MODULE_LICENSE("GPL");
-- 
1.7.9.5
