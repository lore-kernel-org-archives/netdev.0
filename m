From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 5/6] Netfilter: xt_LOG: Implement ring buffer support
Date: Tue,  6 Mar 2012 00:19:47 +0100
Message-ID: <1330989588-26833-6-git-send-email-richard@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org,
	Richard Weinberger <richard@nod.at>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330989588-26833-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces NETFILTER_XT_TARGET_LOG_RING.
It allows logging into various ring buffers which are
represented as pipe-like files in /proc/net/netfilter/nf_log_ring/.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netfilter/xt_LOG.h |   10 +
 include/net/netfilter/nf_log.h   |    1 +
 net/netfilter/Kconfig            |   18 +
 net/netfilter/xt_LOG.c           |  648 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 659 insertions(+), 18 deletions(-)

diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
index cac0790..8ac25e0 100644
--- a/include/linux/netfilter/xt_LOG.h
+++ b/include/linux/netfilter/xt_LOG.h
@@ -11,9 +11,19 @@
 #define XT_LOG_MASK		0x2f
 
 struct xt_log_info {
+        unsigned char level;
+        unsigned char logflags;
+        char prefix[30];
+};
+
+struct xt_log_info_v1 {
 	unsigned char level;
 	unsigned char logflags;
 	char prefix[30];
+
+	char ring_name[30];
+	__aligned_u64 ring_size;
+	struct xt_LOG_ring_ctx *rctx __attribute__((aligned(8)));
 };
 
 #endif /* _XT_LOG_H */
diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index e991bd0..18a94f9 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -14,6 +14,7 @@
 
 #define NF_LOG_TYPE_LOG		0x01
 #define NF_LOG_TYPE_ULOG	0x02
+#define NF_LOG_TYPE_RING	0x04
 
 struct nf_loginfo {
 	u_int8_t type;
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b895d8b..337bbad 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -533,6 +533,24 @@ config NETFILTER_XT_TARGET_LOG
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+if NETFILTER_XT_TARGET_LOG
+
+config NETFILTER_XT_TARGET_LOG_RING
+	bool  'Ring buffer support'
+	default y
+	select RING_BUFFER
+	help
+	 Using this it is possible to record packets into one or more ring buffers
+	 instead of the kernel syslog.
+	 Each ring buffer is represented as file in /proc/net/netfilter/nf_log_ring/.
+
+	 To log incoming IPv4 and IPv6 SSH packets into a ring named "ssh" use:
+	   iptables -A INPUT -p tcp --dport 22 -j LOG --ring ssh
+	   ip6tables -A INPUT -p tcp --dport 22 -j LOG --ring ssh
+
+	 Then read from /proc/net/netfilter/nf_log_ring/ssh.
+endif
+
 config NETFILTER_XT_TARGET_MARK
 	tristate '"MARK" target support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index f99f8de..f75f2d7 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -16,6 +16,21 @@
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ip.h>
+#include <linux/ctype.h>
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
 #include <net/ipv6.h>
 #include <net/icmp.h>
 #include <net/udp.h>
@@ -29,6 +44,51 @@
 #include <net/netfilter/nf_log.h>
 #include <net/netfilter/xt_log.h>
 
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
+#define RING_DIR "nf_log_ring"
+
+struct xt_LOG_ring_ctx {
+	char name[32];
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
+static DEFINE_SPINLOCK(ring_list_lock);
+static LIST_HEAD(ring_list);
+static DECLARE_WAIT_QUEUE_HEAD(rlog_wait);
+static struct proc_dir_entry *prlog;
+
+static int xt_LOG_ring_add_record(const struct xt_LOG_ring_ctx *rctx,
+                           const char *buf, unsigned int len);
+static struct xt_LOG_ring_ctx *xt_LOG_ring_find_ctx(const char *name);
+static struct xt_LOG_ring_ctx *xt_LOG_ring_new_ctx(const char *name, size_t rb_size);
+static void xt_LOG_ring_get(struct xt_LOG_ring_ctx *ctx);
+static void xt_LOG_ring_put(struct xt_LOG_ring_ctx *ctx);
+#endif
+
 static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
@@ -155,7 +215,7 @@ static void dump_ipv4_packet(struct sbuff *m,
 	const struct iphdr *ih;
 	unsigned int logflags;
 
-	if (info->type == NF_LOG_TYPE_LOG)
+	if (info->type == NF_LOG_TYPE_LOG || info->type == NF_LOG_TYPE_RING)
 		logflags = info->u.log.logflags;
 	else
 		logflags = NF_LOG_MASK;
@@ -396,7 +456,7 @@ static void dump_ipv4_mac_header(struct sbuff *m,
 	struct net_device *dev = skb->dev;
 	unsigned int logflags = 0;
 
-	if (info->type == NF_LOG_TYPE_LOG)
+	if (info->type == NF_LOG_TYPE_LOG || info->type == NF_LOG_TYPE_RING)
 		logflags = info->u.log.logflags;
 
 	if (!(logflags & XT_LOG_MACDECODE))
@@ -436,9 +496,10 @@ log_packet_common(struct sbuff *m,
 		  const struct nf_loginfo *loginfo,
 		  const char *prefix)
 {
-	sb_add(m, "<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
-	       prefix,
-	       in ? in->name : "",
+	if (loginfo->type == NF_LOG_TYPE_LOG)
+		sb_add(m, "<%d>", loginfo->u.log.level);
+
+	sb_add(m, "%sIN=%s OUT=%s ", prefix, in ? in->name : "",
 	       out ? out->name : "");
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge) {
@@ -456,8 +517,7 @@ log_packet_common(struct sbuff *m,
 }
 
 
-static void
-ipt_log_packet(u_int8_t pf,
+static struct sbuff *ipt_log_packet(u_int8_t pf,
 	       unsigned int hooknum,
 	       const struct sk_buff *skb,
 	       const struct net_device *in,
@@ -477,6 +537,19 @@ ipt_log_packet(u_int8_t pf,
 
 	dump_ipv4_packet(m, loginfo, skb, 0);
 
+	return m;
+}
+
+static void ipt_log_packet_logger(u_int8_t pf,
+	       unsigned int hooknum,
+	       const struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       const struct nf_loginfo *loginfo,
+	       const char *prefix)
+{
+	struct sbuff *m = ipt_log_packet(pf, hooknum, skb, in, out, loginfo, prefix);
+
 	sb_close(m);
 }
 
@@ -495,7 +568,7 @@ static void dump_ipv6_packet(struct sbuff *m,
 	unsigned int hdrlen = 0;
 	unsigned int logflags;
 
-	if (info->type == NF_LOG_TYPE_LOG)
+	if (info->type == NF_LOG_TYPE_LOG || info->type == NF_LOG_TYPE_RING)
 		logflags = info->u.log.logflags;
 	else
 		logflags = NF_LOG_MASK;
@@ -738,7 +811,7 @@ static void dump_ipv6_mac_header(struct sbuff *m,
 	struct net_device *dev = skb->dev;
 	unsigned int logflags = 0;
 
-	if (info->type == NF_LOG_TYPE_LOG)
+	if (info->type == NF_LOG_TYPE_LOG || info->type == NF_LOG_TYPE_RING)
 		logflags = info->u.log.logflags;
 
 	if (!(logflags & XT_LOG_MACDECODE))
@@ -786,8 +859,7 @@ fallback:
 		sb_add(m, " ");
 }
 
-static void
-ip6t_log_packet(u_int8_t pf,
+static struct sbuff *ip6t_log_packet(u_int8_t pf,
 		unsigned int hooknum,
 		const struct sk_buff *skb,
 		const struct net_device *in,
@@ -807,6 +879,19 @@ ip6t_log_packet(u_int8_t pf,
 
 	dump_ipv6_packet(m, loginfo, skb, skb_network_offset(skb), 1);
 
+	return m;
+}
+
+static void ip6t_log_packet_logger(u_int8_t pf,
+	       unsigned int hooknum,
+	       const struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       const struct nf_loginfo *loginfo,
+	       const char *prefix)
+{
+	struct sbuff *m = ip6t_log_packet(pf, hooknum, skb, in, out, loginfo, prefix);
+
 	sb_close(m);
 }
 #endif
@@ -816,22 +901,28 @@ log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_log_info *loginfo = par->targinfo;
 	struct nf_loginfo li;
+	struct sbuff *m;
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = loginfo->level;
 	li.u.log.logflags = loginfo->logflags;
 
 	if (par->family == NFPROTO_IPV4)
-		ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
-			       par->out, &li, loginfo->prefix);
+		m = ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
+				   par->out, &li, loginfo->prefix);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (par->family == NFPROTO_IPV6)
-		ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
-				par->out, &li, loginfo->prefix);
+		m = ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
+				    par->out, &li, loginfo->prefix);
 #endif
-	else
+	else {
 		WARN_ON_ONCE(1);
+		goto out;
+	}
+
+	sb_close(m);
 
+out:
 	return XT_CONTINUE;
 }
 
@@ -855,37 +946,552 @@ static int log_tg_check(const struct xt_tgchk_param *par)
 	return 0;
 }
 
+static unsigned int
+log_tg_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_log_info_v1 *loginfo = par->targinfo;
+	struct nf_loginfo li;
+	struct sbuff *m;
+
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
+	if (loginfo->ring_size)
+		li.type = NF_LOG_TYPE_RING;
+	else
+#endif
+		li.type = NF_LOG_TYPE_LOG;
+
+	li.u.log.level = loginfo->level;
+	li.u.log.logflags = loginfo->logflags;
+
+	if (par->family == NFPROTO_IPV4)
+		m = ipt_log_packet(NFPROTO_IPV4, par->hooknum, skb, par->in,
+				   par->out, &li, loginfo->prefix);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (par->family == NFPROTO_IPV6)
+		m = ip6t_log_packet(NFPROTO_IPV6, par->hooknum, skb, par->in,
+				    par->out, &li, loginfo->prefix);
+#endif
+	else {
+		WARN_ON_ONCE(1);
+		goto out;
+	}
+
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
+	if (loginfo->ring_size) {
+		sb_add(m, "\n");
+		xt_LOG_ring_add_record(loginfo->rctx, m->buf, m->count);
+		__sb_close(m, 0);
+	} else
+#endif
+		sb_close(m);
+
+out:
+	return XT_CONTINUE;
+}
+
+static int log_tg_check_v1(const struct xt_tgchk_param *par)
+{
+	struct xt_log_info_v1 *loginfo = par->targinfo;
+
+	if (par->family != NFPROTO_IPV4 && par->family != NFPROTO_IPV6)
+		return -EINVAL;
+
+	if (loginfo->level >= 8) {
+		pr_debug("level %u >= 8\n", loginfo->level);
+		return -EINVAL;
+	}
+
+	if (loginfo->prefix[sizeof(loginfo->prefix)-1] != '\0') {
+		pr_debug("prefix is not null-terminated\n");
+		return -EINVAL;
+	}
+
+	/* a non-empty ring_size indicates that we're using ring_buffer */
+	if (loginfo->ring_size) {
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
+		int i;
+		struct xt_LOG_ring_ctx *rctx;
+
+		if (loginfo->ring_name[sizeof(loginfo->ring_name)-1] != '\0') {
+			pr_debug("ring_name is not null-terminated\n");
+			return -EINVAL;
+		}
+
+		if (!loginfo->ring_name[0]) {
+			pr_debug("ring_name is empty\n");
+			return -EINVAL;
+		}
+
+		for (i = 0; i < strlen(loginfo->ring_name); i++) {
+			if (!isalnum(loginfo->ring_name[i])) {
+				pr_debug("ring_name contains "
+					 "a non-alphanumeric character\n");
+				return -EINVAL;
+			}
+		}
+
+		rctx = xt_LOG_ring_find_ctx(loginfo->ring_name);
+		if (!rctx) {
+			rctx = xt_LOG_ring_new_ctx(loginfo->ring_name,
+			       loginfo->ring_size);
+			if (IS_ERR(rctx))
+				return PTR_ERR(rctx);
+		}
+
+		xt_LOG_ring_get(rctx);
+		loginfo->rctx = rctx;
+#else
+		pr_debug("Sorry, this kernel was built without CONFIG_NETFILTER_XT_TARGET_LOG_RING\n");
+		return -EINVAL;
+#endif
+	}
+
+	return 0;
+}
+
+static void log_tg_destroy_v1(const struct xt_tgdtor_param *par)
+{
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
+	const struct xt_log_info_v1 *loginfo = par->targinfo;
+	struct xt_LOG_ring_ctx *rctx = loginfo->rctx;
+
+	if (loginfo->ring_size)
+		xt_LOG_ring_put(rctx);
+#endif
+}
+
+#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
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
+static int xt_LOG_ring_add_record(const struct xt_LOG_ring_ctx *rctx,
+			   const char *buf, unsigned int len)
+{
+	struct rlog_entry *entry;
+	struct ring_buffer_event *event;
+
+	event = ring_buffer_lock_reserve(rctx->buffer, sizeof(*entry) + len);
+	if (!event)
+		return 1;
+
+	entry = ring_buffer_event_data(event);
+	memcpy(entry->msg, buf, len);
+	entry->count = len;
+
+	ring_buffer_unlock_commit(rctx->buffer, event);
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
+static struct rlog_iter *find_next_iter_entry(struct rlog_iter *iter)
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
+	struct xt_LOG_ring_ctx *tgt = PDE(inode)->data;
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
+		atomic_set(&tgt->pipe_in_use, 0);
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
+	struct xt_LOG_ring_ctx *tgt = PDE(inode)->data;
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
+	while (find_next_iter_entry(iter) != NULL) {
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
+static struct xt_LOG_ring_ctx *xt_LOG_ring_new_ctx(const char *name, size_t rb_size)
+{
+	struct xt_LOG_ring_ctx *new;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new) {
+		new = ERR_PTR(-ENOMEM);
+
+		goto out;
+	}
+
+	new->buffer = ring_buffer_alloc(rb_size << 10, RB_FL_OVERWRITE);
+	if (!new->buffer) {
+		kfree(new);
+		new = ERR_PTR(-ENOMEM);
+
+		goto out;
+	}
+
+	strlcpy(new->name, name, sizeof new->name);
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
+	spin_lock(&ring_list_lock);
+	list_add(&new->list, &ring_list);
+	spin_unlock(&ring_list_lock);
+out:
+	return new;
+}
+
+static void free_xt_LOG_ring_ctx(struct xt_LOG_ring_ctx *ctx)
+{
+	remove_proc_entry(ctx->name, prlog);
+	ring_buffer_free(ctx->buffer);
+	list_del(&ctx->list);
+	kfree(ctx);
+}
+
+static void xt_LOG_ring_get(struct xt_LOG_ring_ctx *ctx)
+{
+	atomic_inc(&ctx->refcnt);
+}
+
+static void xt_LOG_ring_put(struct xt_LOG_ring_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->refcnt))
+		free_xt_LOG_ring_ctx(ctx);
+}
+
+static struct xt_LOG_ring_ctx *xt_LOG_ring_find_ctx(const char *name)
+{
+	struct list_head *e;
+	struct xt_LOG_ring_ctx *tmp, *victim = NULL;
+
+	spin_lock(&ring_list_lock);
+
+	list_for_each(e, &ring_list) {
+		tmp = list_entry(e, struct xt_LOG_ring_ctx, list);
+		if (strcmp(tmp->name, name) == 0) {
+			victim = tmp;
+
+			goto out;
+		}
+	}
+
+out:
+	spin_unlock(&ring_list_lock);
+
+	return victim;
+}
+
+static void __exit xt_LOG_ring_exit(void)
+{
+	WARN_ON(!list_empty(&ring_list));
+	remove_proc_entry(RING_DIR, proc_net_netfilter);
+}
+
+static int __init xt_LOG_ring_init(void)
+{
+	prlog = proc_mkdir(RING_DIR, proc_net_netfilter);
+	if (!prlog)
+		return -ENOMEM;
+
+	return 0;
+}
+#else
+static void __exit xt_LOG_ring_exit(void)
+{
+}
+
+static int __init xt_LOG_ring_init(void)
+{
+	return 0;
+}
+#endif /* CONFIG_NETFILTER_XT_TARGET_LOG_RING */
+
 static struct xt_target log_tg_regs[] __read_mostly = {
 	{
 		.name		= "LOG",
 		.family		= NFPROTO_IPV4,
+		.revision	= 0,
 		.target		= log_tg,
 		.targetsize	= sizeof(struct xt_log_info),
 		.checkentry	= log_tg_check,
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "LOG",
+		.family		= NFPROTO_IPV4,
+		.revision	= 1,
+		.target		= log_tg_v1,
+		.targetsize	= sizeof(struct xt_log_info_v1),
+		.checkentry	= log_tg_check_v1,
+		.destroy	= log_tg_destroy_v1,
+		.me		= THIS_MODULE,
+	},
 #if IS_ENABLED(CONFIG_IPV6)
 	{
 		.name		= "LOG",
 		.family		= NFPROTO_IPV6,
+		.revision	= 0,
 		.target		= log_tg,
 		.targetsize	= sizeof(struct xt_log_info),
 		.checkentry	= log_tg_check,
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "LOG",
+		.family		= NFPROTO_IPV6,
+		.revision	= 1,
+		.target		= log_tg_v1,
+		.targetsize	= sizeof(struct xt_log_info_v1),
+		.checkentry	= log_tg_check_v1,
+		.destroy	= log_tg_destroy_v1,
+		.me		= THIS_MODULE,
+	},
 #endif
 };
 
 static struct nf_logger ipt_log_logger __read_mostly = {
 	.name		= "ipt_LOG",
-	.logfn		= &ipt_log_packet,
+	.logfn		= &ipt_log_packet_logger,
 	.me		= THIS_MODULE,
 };
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct nf_logger ip6t_log_logger __read_mostly = {
 	.name		= "ip6t_LOG",
-	.logfn		= &ip6t_log_packet,
+	.logfn		= &ip6t_log_packet_logger,
 	.me		= THIS_MODULE,
 };
 #endif
@@ -894,6 +1500,10 @@ static int __init log_tg_init(void)
 {
 	int ret;
 
+	ret = xt_LOG_ring_init();
+	if (ret < 0)
+		return ret;
+
 	ret = xt_register_targets(log_tg_regs, ARRAY_SIZE(log_tg_regs));
 	if (ret < 0)
 		return ret;
@@ -912,6 +1522,7 @@ static void __exit log_tg_exit(void)
 	nf_log_unregister(&ip6t_log_logger);
 #endif
 	xt_unregister_targets(log_tg_regs, ARRAY_SIZE(log_tg_regs));
+	xt_LOG_ring_exit();
 }
 
 module_init(log_tg_init);
@@ -920,6 +1531,7 @@ module_exit(log_tg_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_AUTHOR("Jan Rekorajski <baggins@pld.org.pl>");
+MODULE_AUTHOR("Richard Weinberger <richard@nod.at>");
 MODULE_DESCRIPTION("Xtables: IPv4/IPv6 packet logging");
 MODULE_ALIAS("ipt_LOG");
 MODULE_ALIAS("ip6t_LOG");
-- 
1.7.7.3
