From: Richard Weinberger <rw@linutronix.de>
Subject: [PATCH 4/5] netfilter: Implement xt_RLOG
Date: Wed, 18 Jan 2012 23:43:29 +0100
Message-ID: <1326926610-17830-5-git-send-email-rw@linutronix.de>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rostedt@goodmis.org, Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:47847 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637Ab2ARXbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 18:31:43 -0500
In-Reply-To: <1326926610-17830-1-git-send-email-rw@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard@nod.at>

xt_RLOG is a new logging target, it produces log messages like LOG
but it does not write them into the kernel syslog.
All messages are written into ring buffers.
The user can create arbitrary many ring buffer of any size.
Each ring buffer is represented as file in /proc/net/netfilter/xt_RLOG/

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/netfilter/Kconfig   |   17 ++
 net/netfilter/Makefile  |    1 +
 net/netfilter/xt_RLOG.c |  622 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 640 insertions(+), 0 deletions(-)
 create mode 100644 net/netfilter/xt_RLOG.c

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f8ac4ef..5810ed3 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -578,6 +578,23 @@ config NETFILTER_XT_TARGET_RATEEST
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_TARGET_RLOG
+	tristate '"RLOG" target support (EXPERIMENTAL)'
+	depends on EXPERIMENTAL
+	depends on NETFILTER_ADVANCED
+	depends on RING_BUFFER
+	select IP_NF_TARGET_LOG
+	select IP6_NF_TARGET_LOG if IP6_NF_IPTABLES
+	help
+	  This target records packet headers into one or more ring buffers.
+	  Each ring buffer is represented as a file in
+	  /proc/net/netfilter/xt_RLOG/.
+	  It produces the same output as LOG.
+	  Select this target if you like LOG but don't want your kernel syslog
+	  flooded.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_TEE
 	tristate '"TEE" - packet cloning to alternate destination'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 40f4c3d..447b58d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -62,6 +62,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_RLOG) += xt_RLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) += xt_TPROXY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) += xt_TCPMSS.o
diff --git a/net/netfilter/xt_RLOG.c b/net/netfilter/xt_RLOG.c
new file mode 100644
index 0000000..b2b53d9
--- /dev/null
+++ b/net/netfilter/xt_RLOG.c
@@ -0,0 +1,622 @@
+/*
+ * Copyright (c) 2012 Richard Weinberger <richard@nod.at>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/ring_buffer.h>
+#include <linux/cpu.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/proc_fs.h>
+#include <linux/wait.h>
+#include <linux/time.h>
+#include <linux/sched.h>
+#include <linux/list.h>
+#include <linux/atomic.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+
+#include <net/netfilter/xt_log.h>
+#include <net/netfilter/nf_log.h>
+
+#define TARGETNAME_LEN		32
+#define DEFAULT_RING_SIZE	1024 /* in KiB */
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#	define WITH_IPV6 1
+#endif
+
+struct rlog_target {
+	char name[TARGETNAME_LEN];
+	struct ring_buffer *buffer;
+	atomic_t pipe_in_use;
+	atomic_t refcnt;
+
+	struct list_head list;
+};
+
+struct rlog_entry {
+	size_t count;
+	char msg[0];
+};
+
+struct rlog_iter {
+	struct ring_buffer *buffer;
+	const char *buffer_name;
+	struct rlog_entry *ent;
+
+	char print_buf[PAGE_SIZE];
+	size_t print_buf_len;
+	size_t print_buf_pos;
+
+	unsigned long lost_events;
+	int cpu;
+
+	struct mutex lock;
+};
+
+struct rlog_tg_info {
+	char name[TARGETNAME_LEN];
+	unsigned int size;
+	unsigned char logflags;
+	bool add_timestamp;
+	struct rlog_target *log_target;
+};
+
+static DEFINE_SPINLOCK(target_list_lock);
+static LIST_HEAD(target_list);
+static DECLARE_WAIT_QUEUE_HEAD(rlog_wait);
+static struct proc_dir_entry *prlog;
+
+static struct nf_loginfo default_loginfo = {
+	.type   = NF_LOG_TYPE_LOG,
+	.u = {
+		.log = {
+			.logflags = NF_LOG_MASK,
+		},
+	},
+};
+
+static void wakeup_work_handler(struct work_struct *work)
+{
+	wake_up(&rlog_wait);
+}
+
+static DECLARE_WORK(wakeup_work, wakeup_work_handler);
+
+static void rlog_wake_up(void)
+{
+	schedule_work(&wakeup_work);
+}
+
+static int add_record(struct ring_buffer *buffer, struct sbuff *m)
+{
+	struct rlog_entry *entry;
+	struct ring_buffer_event *event;
+
+	event = ring_buffer_lock_reserve(buffer, sizeof(*entry) + m->count);
+	if (!event)
+		return 1;
+
+	entry = ring_buffer_event_data(event);
+	memcpy(entry->msg, m->buf, m->count);
+	entry->count = m->count;
+
+	ring_buffer_unlock_commit(buffer, event);
+	rlog_wake_up();
+
+	return 0;
+}
+
+static struct rlog_entry *peek_next_entry(struct rlog_iter *iter, int cpu,
+					  unsigned long long *ts)
+{
+	struct ring_buffer_event *event;
+
+	event = ring_buffer_peek(iter->buffer, cpu, ts, &iter->lost_events);
+
+	if (event)
+		return ring_buffer_event_data(event);
+
+	return NULL;
+}
+
+static struct rlog_entry *find_next_entry(struct rlog_iter *iter)
+{
+	struct rlog_entry *ent, *next = NULL;
+	unsigned long long next_ts = 0, ts;
+	int cpu, next_cpu = -1;
+
+	for_each_buffer_cpu (iter->buffer, cpu) {
+		if (ring_buffer_empty_cpu(iter->buffer, cpu))
+			continue;
+
+		ent = peek_next_entry(iter, cpu, &ts);
+
+		if (ent && (!next || ts < next_ts)) {
+			next = ent;
+			next_cpu = cpu;
+			next_ts = ts;
+		}
+	}
+
+	iter->cpu = next_cpu;
+
+	return next;
+}
+
+static struct rlog_iter *find_next_entry_inc(struct rlog_iter *iter)
+{
+	iter->ent = find_next_entry(iter);
+
+	if (iter->ent)
+		return iter;
+
+	return NULL;
+}
+
+static int buffer_empty(struct rlog_iter *iter)
+{
+	int cpu;
+
+	for_each_buffer_cpu (iter->buffer, cpu) {
+		if (!ring_buffer_empty_cpu(iter->buffer, cpu))
+			return 0;
+	}
+
+	return 1;
+}
+
+static ssize_t rlog_to_user(struct rlog_iter *iter, char __user *ubuf,
+			    size_t cnt)
+{
+	int ret;
+	int len;
+
+	if (!cnt)
+		goto out;
+
+	len = iter->print_buf_len - iter->print_buf_pos;
+	if (len < 1)
+		return -EBUSY;
+
+	if (cnt > len)
+		cnt = len;
+
+	ret = copy_to_user(ubuf, iter->print_buf + iter->print_buf_pos, cnt);
+	if (ret == cnt)
+		return -EFAULT;
+
+	cnt -= ret;
+	iter->print_buf_pos += cnt;
+
+out:
+	return cnt;
+}
+
+static int rlog_open_pipe(struct inode *inode, struct file *file)
+{
+	struct rlog_iter *iter;
+	struct rlog_target *tgt = PDE(inode)->data;
+	int ret = 0;
+
+	/* only one consuming reader is allowed */
+	if (atomic_cmpxchg(&tgt->pipe_in_use, 0, 1)) {
+		ret = -EBUSY;
+		goto out;
+	}
+
+	iter = kzalloc(sizeof(*iter), GFP_KERNEL);
+	if (!iter) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	mutex_init(&iter->lock);
+	iter->buffer = tgt->buffer;
+	iter->buffer_name = tgt->name;
+
+	file->private_data = iter;
+out:
+	return ret;
+}
+
+static unsigned int rlog_poll_pipe(struct file *file, poll_table *poll_table)
+{
+	struct rlog_iter *iter = file->private_data;
+
+	if (!buffer_empty(iter))
+		return POLLIN | POLLRDNORM;
+
+	poll_wait(file, &rlog_wait, poll_table);
+
+	if (!buffer_empty(iter))
+		return POLLIN | POLLRDNORM;
+
+	return 0;
+}
+
+static int rlog_release_pipe(struct inode *inode, struct file *file)
+{
+	struct rlog_iter *iter = file->private_data;
+	struct rlog_target *tgt = PDE(inode)->data;
+
+	mutex_destroy(&iter->lock);
+	kfree(iter);
+	atomic_set(&tgt->pipe_in_use, 0);
+
+	return 0;
+}
+
+static void wait_pipe(struct rlog_iter *iter)
+{
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait(&rlog_wait, &wait, TASK_INTERRUPTIBLE);
+
+	if (buffer_empty(iter))
+		schedule();
+
+	finish_wait(&rlog_wait, &wait);
+}
+
+static int rlog_wait_pipe(struct file *file)
+{
+	struct rlog_iter *iter = file->private_data;
+
+	while (buffer_empty(iter)) {
+		if (file->f_flags & O_NONBLOCK)
+			return -EAGAIN;
+
+		mutex_unlock(&iter->lock);
+
+		wait_pipe(iter);
+
+		mutex_lock(&iter->lock);
+
+		if (signal_pending(current))
+			return -EINTR;
+	}
+
+	return 1;
+}
+
+static ssize_t rlog_read_pipe(struct file *file, char __user *ubuf,
+			      size_t cnt, loff_t *ppos)
+{
+	struct rlog_iter *iter = file->private_data;
+	ssize_t ret;
+
+	ret = rlog_to_user(iter, ubuf, cnt);
+	if (ret != -EBUSY)
+		goto out;
+
+	iter->print_buf_pos = 0;
+	iter->print_buf_len = 0;
+
+	if (cnt >= PAGE_SIZE)
+		cnt = PAGE_SIZE - 1;
+
+	mutex_lock(&iter->lock);
+again:
+	ret = rlog_wait_pipe(file);
+	if (ret <= 0)
+		goto out_unlock;
+
+	while (find_next_entry_inc(iter) != NULL) {
+		struct rlog_entry *ent;
+		ent = iter->ent;
+
+		if (ent->count >= PAGE_SIZE - iter->print_buf_len)
+			break;
+
+		memcpy(iter->print_buf + iter->print_buf_len, ent->msg,
+			ent->count);
+		iter->print_buf_len += ent->count;
+
+		ring_buffer_consume(iter->buffer, iter->cpu, NULL,
+			&iter->lost_events);
+		if (iter->lost_events)
+			printk(KERN_WARNING KBUILD_MODNAME ": Ring %s "
+				"lost %lu events\n", iter->buffer_name,
+				iter->lost_events);
+
+		if (iter->print_buf_len >= cnt)
+			break;
+	}
+
+	ret = rlog_to_user(iter, ubuf, cnt);
+
+	if (iter->print_buf_pos >= iter->print_buf_len) {
+		iter->print_buf_pos = 0;
+		iter->print_buf_len = 0;
+	}
+
+	if (ret == -EBUSY)
+		goto again;
+out_unlock:
+	mutex_unlock(&iter->lock);
+out:
+	return ret;
+}
+
+static const struct file_operations rlog_pipe_fops = {
+	.open		= rlog_open_pipe,
+	.poll		= rlog_poll_pipe,
+	.read		= rlog_read_pipe,
+	.release	= rlog_release_pipe,
+	.llseek		= no_llseek,
+};
+
+static struct rlog_target *new_rlog_target(const char *name, size_t rb_size)
+{
+	struct rlog_target *new;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
+		new = ERR_PTR(-ENOMEM);
+
+		goto out;
+	}
+
+	new->buffer = ring_buffer_alloc(rb_size, RB_FL_OVERWRITE);
+	if (!new->buffer) {
+		kfree(new);
+		new = ERR_PTR(-ENOMEM);
+
+		goto out;
+	}
+
+	strlcpy(new->name, name, TARGETNAME_LEN);
+
+	if (!proc_create_data(name, 0400, prlog, &rlog_pipe_fops, new)) {
+		ring_buffer_free(new->buffer);
+		kfree(new);
+		new = ERR_PTR(-ENOMEM);
+
+		goto out;
+	}
+
+	atomic_set(&new->pipe_in_use, 0);
+	atomic_set(&new->refcnt, 0);
+
+	spin_lock(&target_list_lock);
+	list_add(&new->list, &target_list);
+	spin_unlock(&target_list_lock);
+out:
+	return new;
+}
+
+static void free_rlog_target(struct rlog_target *target)
+{
+	remove_proc_entry(target->name, prlog);
+	ring_buffer_free(target->buffer);
+	list_del(&target->list);
+	kfree(target);
+}
+
+static struct rlog_target *find_taget(const char *name)
+{
+	struct list_head *e;
+	struct rlog_target *tmp, *victim = NULL;
+
+	spin_lock(&target_list_lock);
+
+	list_for_each(e, &target_list) {
+		tmp = list_entry(e, struct rlog_target, list);
+		if (strcmp(tmp->name, name) == 0) {
+			victim = tmp;
+
+			goto out;
+		}
+	}
+
+out:
+	spin_unlock(&target_list_lock);
+
+	return victim;
+}
+
+static void rlog_log_common(struct sbuff *m,
+			    u_int8_t pf,
+			    unsigned int hooknum,
+			    const struct sk_buff *skb,
+			    const struct net_device *in,
+			    const struct net_device *out,
+			    bool add_timestamp)
+{
+	if (add_timestamp) {
+		static struct timespec ts;
+		getnstimeofday(&ts);
+		sb_add(m, "[%li.%li] ", ts.tv_sec, ts.tv_nsec);
+	}
+
+	sb_add(m, "IN=%s OUT=%s ", in ? in->name : "", out ? out->name : "");
+
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge) {
+		const struct net_device *physindev;
+		const struct net_device *physoutdev;
+
+		physindev = skb->nf_bridge->physindev;
+		if (physindev && in != physindev)
+			sb_add(m, "PHYSIN=%s ", physindev->name);
+		physoutdev = skb->nf_bridge->physoutdev;
+		if (physoutdev && out != physoutdev)
+			sb_add(m, "PHYSOUT=%s ", physoutdev->name);
+	}
+#endif
+}
+
+static struct sbuff *rlog_log_ip_packet(u_int8_t pf,
+			    unsigned int hooknum,
+			    const struct sk_buff *skb,
+			    const struct net_device *in,
+			    const struct net_device *out,
+			    const struct rlog_tg_info *info)
+{
+	struct nf_loginfo loginfo = default_loginfo;
+	struct sbuff *m = sb_open();
+
+	loginfo.u.log.logflags = info->logflags;
+	rlog_log_common(m, pf, hooknum, skb, in, out, info->add_timestamp);
+
+	if (in != NULL)
+		ipt_dump_mac_header(m, &loginfo, skb);
+
+	ipt_dump_packet(m, &loginfo, skb, 0);
+
+	return m;
+}
+
+#ifdef WITH_IPV6
+static struct sbuff *rlog_log_ip6_packet(u_int8_t pf,
+			    unsigned int hooknum,
+			    const struct sk_buff *skb,
+			    const struct net_device *in,
+			    const struct net_device *out,
+			    const struct rlog_tg_info *info)
+{
+	struct nf_loginfo loginfo = default_loginfo;
+	struct sbuff *m = sb_open();
+
+	loginfo.u.log.logflags = info->logflags;
+	rlog_log_common(m, pf, hooknum, skb, in, out, info->add_timestamp);
+
+	if (in != NULL)
+		ip6t_dump_mac_header(m, &default_loginfo, skb);
+
+	ip6t_dump_packet(m, &default_loginfo, skb, skb_network_offset(skb), 1);
+
+	return m;
+}
+#endif
+
+static unsigned int
+rlog_tg(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct rlog_tg_info *info = par->targinfo;
+	struct rlog_target *t = info->log_target;
+
+	struct sbuff *m;
+
+	if (par->family == NFPROTO_IPV4)
+		m = rlog_log_ip_packet(NFPROTO_IPV4, par->hooknum, skb,
+			par->in, par->out, info);
+#ifdef WITH_IPV6
+	else if (par->family == NFPROTO_IPV6)
+		m = rlog_log_ip6_packet(NFPROTO_IPV6, par->hooknum, skb,
+			par->in, par->out, info);
+#endif
+	else
+		BUG();
+
+	sb_add(m, "\n");
+	add_record(t->buffer, m);
+
+	__sb_close(m, 0);
+
+	return XT_CONTINUE;
+}
+
+static int rlog_tg_check(const struct xt_tgchk_param *par)
+{
+	struct rlog_tg_info *info = par->targinfo;
+	struct rlog_target *t;
+	int ret = 0;
+
+	if (info->name[sizeof(info->name) - 1] != '\0') {
+		ret = -EINVAL;
+
+		goto out;
+	}
+
+	t = find_taget(info->name);
+	if (!t) {
+		if (!info->size)
+			info->size = DEFAULT_RING_SIZE;
+
+		t = new_rlog_target(info->name, info->size << 10);
+		if (IS_ERR(t)) {
+			ret = PTR_ERR(t);
+
+			goto out;
+		}
+	}
+
+	atomic_inc(&t->refcnt);
+	info->log_target = t;
+out:
+	return ret;
+}
+
+static void rlog_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	struct rlog_tg_info *info = par->targinfo;
+	struct rlog_target *t = info->log_target;
+
+	if (atomic_dec_and_test(&t->refcnt))
+		free_rlog_target(t);
+}
+
+static struct xt_target rlog_tg_regs[] __read_mostly = {
+	{
+		.name		= "RLOG",
+		.family		= NFPROTO_IPV4,
+		.target		= rlog_tg,
+		.targetsize	= sizeof(struct rlog_tg_info),
+		.checkentry	= rlog_tg_check,
+		.destroy	= rlog_tg_destroy,
+		.me		= THIS_MODULE,
+	},
+#ifdef WITH_IPV6
+	{
+		.name		= "RLOG",
+		.family		= NFPROTO_IPV6,
+		.target		= rlog_tg,
+		.targetsize	= sizeof(struct rlog_tg_info),
+		.checkentry	= rlog_tg_check,
+		.destroy	= rlog_tg_destroy,
+		.me		= THIS_MODULE,
+	}
+#endif
+};
+
+static void __exit rlog_exit(void)
+{
+	BUG_ON(!list_empty(&target_list));
+
+	xt_unregister_targets(rlog_tg_regs, ARRAY_SIZE(rlog_tg_regs));
+	remove_proc_entry(KBUILD_MODNAME, proc_net_netfilter);
+}
+module_exit(rlog_exit);
+
+static int __init rlog_init(void)
+{
+	prlog = proc_mkdir(KBUILD_MODNAME, proc_net_netfilter);
+	if (!prlog)
+		return -ENOMEM;
+
+	if (xt_register_targets(rlog_tg_regs, ARRAY_SIZE(rlog_tg_regs)) < 0) {
+		remove_proc_entry(KBUILD_MODNAME, proc_net_netfilter);
+
+		return -EINVAL;
+	}
+
+	return 0;
+}
+module_init(rlog_init);
+
+MODULE_AUTHOR("Richard Weinberger");
+MODULE_LICENSE("GPL");
-- 
1.7.7
