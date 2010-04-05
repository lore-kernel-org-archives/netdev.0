From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 1/2] netdev: buffer infrastructure to log network driver's
 information
Date: Mon, 05 Apr 2010 15:52:57 +0900
Message-ID: <4BB988C9.9070709@jp.fujitsu.com>
References: <4BB98828.5030302@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:51422 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab0DEGxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 02:53:00 -0400
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o356qw4W011454
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 5 Apr 2010 15:52:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FA6445DE4F
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:52:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E4D5345DE4E
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:52:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CAAE91DB805B
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:52:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B7FC1DB8040
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:52:57 +0900 (JST)
In-Reply-To: <4BB98828.5030302@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements buffer infrastructure under driver/net.
This buffer records information from network driver.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
  drivers/net/Kconfig     |    8 +
  drivers/net/Makefile    |    1 +
  drivers/net/ndrvbuf.c   |  535 +++++++++++++++++++++++++++++++++++++++++++++++
  include/linux/ndrvbuf.h |   57 +++++
  4 files changed, 601 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7029cd5..98ac929 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -219,6 +219,14 @@ config MII
  	  or internal device.  It is safe to say Y or M here even if your
  	  ethernet card lack MII.
  
+config NDRVBUF
+	tristate "Use buffer for network device driver"
+	default m
+	help
+	  The ndrvbuf is a generally buffer for network driver. It can record
+	  some event or logging informaiton you want to preseve. ring_buffer
+	  is used as a buffer infrastructure.
+
  config MACB
  	tristate "Atmel MACB support"
  	depends on AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263 || ARCH_AT91SAM9G20 || ARCH_AT91SAM9G45 || ARCH_AT91CAP9
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4788862..84319ba 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -5,6 +5,7 @@
  obj-$(CONFIG_MII) += mii.o
  obj-$(CONFIG_MDIO) += mdio.o
  obj-$(CONFIG_PHYLIB) += phy/
+obj-$(CONFIG_NDRVBUF) += ndrvbuf.o
  
  obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
  
diff --git a/drivers/net/ndrvbuf.c b/drivers/net/ndrvbuf.c
new file mode 100644
index 0000000..7401334
--- /dev/null
+++ b/drivers/net/ndrvbuf.c
@@ -0,0 +1,535 @@
+#include <linux/ndrvbuf.h>
+
+MODULE_LICENSE("GPL");
+static struct dentry *ndrvbuf_root;
+
+/* This list links all ndrvbuf registered */
+static LIST_HEAD(ndrvbuf_list);
+static DEFINE_MUTEX(ndrvbuf_list_lock);
+static atomic_t ndrvbuf_disabled;
+/* control reading ring_buffer */
+struct ndrvbuf_reader {
+	struct ndrvbuf *ndrvbuf;
+	loff_t idx;
+	struct ring_buffer_iter **iter;
+	char *print;
+	size_t print_len;
+	loff_t print_pos;
+};
+
+/**
+ * typical_ndrvbuf_header - write a typical header
+ * @dst: buffer to write
+ * @cpu: The processor number
+ * @ts: The time stamp
+ *
+ * Write a typical header to buffer
+ **/
+size_t _typical_ndrvbuf_header(void *dst, size_t size, int cpu, u64 ts)
+{
+	int ret;
+	unsigned long usecs_rem, secs;
+
+	ts += 500;
+	do_div(ts, NSEC_PER_USEC);
+	usecs_rem = do_div(ts, USEC_PER_SEC);
+	secs = (unsigned long)ts;
+	ret = snprintf(dst, size, "[%3d] %5lu.%06lu: ", cpu, secs, usecs_rem);
+	return ret;
+}
+EXPORT_SYMBOL(_typical_ndrvbuf_header);
+
+/**
+ * ndrvbuf_default_read - print the event using hex format
+ * @ubuf: The buffer to write
+ * @bufsize: The maximum byte to write
+ * @entry: The adrress to read
+ * @len: The size of etnry
+ * @cpu: The processor nubmer
+ * @ts: The time stamp
+ *
+ * If read==NULL in register_ndrvbuf, this funcion is used when printing.
+ **/
+static size_t ndrvbuf_default_read(void *ubuf, size_t bufsize, void *entry,
+				unsigned len, int cpu, u64 ts)
+{
+	int bufpos = 0, lpos = 0;
+
+	bufpos += _typical_ndrvbuf_header(ubuf, bufsize, cpu, ts);
+	bufpos += snprintf(ubuf + bufpos, bufsize - bufpos, "\n");
+	while (lpos < len) {
+		hex_dump_to_buffer(entry + lpos, len - lpos, 16, 4,
+				ubuf + bufpos, bufsize - bufpos, 0);
+		bufpos = strlen(ubuf);
+		bufpos += snprintf(ubuf + bufpos, bufsize - bufpos, "\n");
+		lpos += 16;
+	}
+	return bufpos;
+}
+
+static int is_in_ndrvbuf_list(struct ndrvbuf *ndrvbuf)
+{
+	struct list_head *cur;
+	struct ndrvbuf *cbuf;
+
+	list_for_each(cur, &ndrvbuf_list) {
+		cbuf = list_entry(cur, struct ndrvbuf, list);
+		if (cbuf == ndrvbuf)
+			break;
+	}
+	if (cur == &ndrvbuf_list)
+		return 0;
+	else
+		return 1;
+}
+
+/**
+ * ndrvbuf_buffer_open - open ring_buffer and set itearator to read
+ * @inode: contain ndrvbuf pointer
+ * @file: The pointer to attach the ndrvbuf pointer
+ **/
+static int ndrvbuf_buffer_open(struct inode *inode, struct file *file)
+{
+	struct ndrvbuf *ndrvbuf = inode->i_private;
+	struct ndrvbuf_reader *reader;
+	int cpu;
+
+	reader = kzalloc(sizeof(struct ndrvbuf_reader), GFP_KERNEL);
+	if (!reader) {
+		pr_warning("Could not alloc reader->iter\n");
+		goto out;
+	}
+	reader->iter = kmalloc(sizeof(struct ring_buffer_iter *) * nr_cpu_ids,
+				GFP_KERNEL);
+	if (!reader->iter) {
+		pr_warning("Could not alloc reader->iter\n");
+		goto out_free_reader;
+	}
+	mutex_lock(&ndrvbuf_list_lock);
+	if (!is_in_ndrvbuf_list(ndrvbuf)) {
+		mutex_unlock(&ndrvbuf_list_lock);
+		goto out_free_iter;
+	}
+	atomic_inc(&ndrvbuf->reader_count);
+	mutex_unlock(&ndrvbuf_list_lock);
+	for_each_online_cpu(cpu)
+		reader->iter[cpu] = ring_buffer_read_start(ndrvbuf->rbuf, cpu);
+	reader->print = kmalloc(NDRVBUF_STR_LEN, GFP_KERNEL);
+	if (!reader->print) {
+		pr_warning("Could not alloc reader->print\n");
+		goto out_free_iter;
+	}
+	reader->ndrvbuf = ndrvbuf;
+	file->private_data = reader;
+	return 0;
+
+out_free_iter:
+	kfree(reader->iter);
+out_free_reader:
+	kfree(reader);
+out:
+	return -ENOMEM;
+}
+
+static int ndrvbuf_buffer_release(struct inode *inode, struct file *file)
+{
+	struct ndrvbuf_reader *reader = file->private_data;
+	struct ndrvbuf *ndrvbuf = reader->ndrvbuf;
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		ring_buffer_read_finish(reader->iter[cpu]);
+	}
+	kfree(reader->iter);
+	kfree(reader->print);
+	kfree(reader);
+	atomic_dec(&ndrvbuf->reader_count);
+	return 0;
+}
+
+static loff_t _ndrvbuf_lseek(struct ndrvbuf_reader *reader, loff_t pos)
+{
+	struct ndrvbuf *ndrvbuf = reader->ndrvbuf;
+	struct ring_buffer_iter **iter = reader->iter;
+	struct ring_buffer_event *event;
+	void *entry;
+	int cpu, next_cpu;
+	u64 ts, next_ts;
+	unsigned len;
+	int strlen;
+
+	reader->idx = 0;
+	for_each_online_cpu(cpu) {
+		ring_buffer_iter_reset(iter[cpu]);
+	}
+	while (1) {
+		next_ts = 0;
+		next_cpu = -1;
+		for_each_online_cpu(cpu) {
+			if (!iter[cpu])
+				continue;
+			event = ring_buffer_iter_peek(iter[cpu], &ts);
+			if (!event)
+				continue;
+			if (!next_ts || ts < next_ts) {
+				next_ts = ts;
+				next_cpu = cpu;
+			}
+		}
+		if (next_cpu < 0)
+			return -EINVAL;
+		event = ring_buffer_read(iter[next_cpu], &ts);
+		if (!event)
+			return -EINVAL;
+		entry = ring_buffer_event_data(event);
+		len = ring_buffer_event_length(event);
+		strlen = ndrvbuf->read(reader->print, NDRVBUF_STR_LEN,
+					entry, len, next_cpu, ts);
+		if (reader->idx + strlen > pos)
+			break;
+		reader->idx += strlen;
+	}
+	reader->print_len = strlen;
+	reader->print_pos = reader->idx + strlen - pos;
+	reader->idx = pos;
+	return pos;
+}
+
+/**
+ * ndrvbuf_buffer_read - read event and write it to user buffer
+ * @file: the file to read
+ * @buf: the file to write
+ * @nbytes: the maximum size to write
+ * @ppos: the position to read from
+ *
+ * Read an event from ring_buffer and write it user buffer.
+ * If read format function is set, use it.
+ **/
+static ssize_t ndrvbuf_buffer_read(struct file *file, char __user *buf,
+					size_t nbytes, loff_t *ppos)
+{
+	struct ndrvbuf_reader *reader = file->private_data;
+	struct ndrvbuf *ndrvbuf = reader->ndrvbuf;
+	struct ring_buffer_iter **iter = reader->iter;
+	struct ring_buffer_event *event;
+	void *entry;
+	unsigned len;
+	int cpu, next_cpu = -1;
+	u64 ts, next_ts = 0;
+	int ret;
+	size_t copy, strlen;
+	loff_t pos = *ppos;
+
+	if (pos != reader->idx)
+		_ndrvbuf_lseek(reader, pos);
+	if (reader->print_len) {
+		copy = min(reader->print_len, nbytes);
+		ret = copy_to_user(buf, reader->print + reader->print_pos,
+				copy);
+		copy -= ret;
+		reader->print_len -= copy;
+		reader->print_pos += copy;
+		reader->idx += copy;
+		*ppos += copy;
+		return copy;
+	}
+	for_each_online_cpu(cpu) {
+		if (!iter[cpu])
+			continue;
+		event = ring_buffer_iter_peek(iter[cpu], &ts);
+		if (!event)
+			continue;
+		if (!next_ts || ts < next_ts) {
+			next_ts = ts;
+			next_cpu = cpu;
+		}
+	}
+	if (next_cpu < 0)
+		return 0;
+	event = ring_buffer_read(iter[next_cpu], &ts);
+	if (!event)
+		return 0;
+	entry = ring_buffer_event_data(event);
+	len = ring_buffer_event_length(event);
+
+	strlen = ndrvbuf->read(reader->print, NDRVBUF_STR_LEN, entry,
+				len, next_cpu, ts);
+	reader->print_len = strlen;
+	copy = min(strlen, nbytes);
+	ret = copy_to_user(buf, reader->print, strlen);
+	copy -= ret;
+	reader->print_len -= copy;
+	reader->print_pos = copy;
+	*ppos = pos + copy;
+	reader->idx = *ppos;
+	return copy;
+}
+
+
+static const struct file_operations buffer_file_ops = {
+	.owner =	THIS_MODULE,
+	.open =		ndrvbuf_buffer_open,
+	.read =		ndrvbuf_buffer_read,
+	.release =	ndrvbuf_buffer_release,
+};
+
+static int ndrvbuf_buffer_size_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t ndrvbuf_buffer_size_read(struct file *file, char __user *ubuf,
+					size_t nbytes, loff_t *ppos)
+{
+	struct ndrvbuf *ndrvbuf = file->private_data;
+	int ret;
+	char buf[16];
+	ssize_t size;
+
+	mutex_lock(&ndrvbuf_list_lock);
+	if (!is_in_ndrvbuf_list(ndrvbuf)) {
+		mutex_unlock(&ndrvbuf_list_lock);
+		return -ENODEV;
+
+	}
+	ret = snprintf(buf, 16, "%lu\n", ndrvbuf->buffer_size);
+	size = simple_read_from_buffer(ubuf, nbytes, ppos, buf, ret);
+	mutex_unlock(&ndrvbuf_list_lock);
+	return size;
+}
+
+/**
+ * ndrvbuf_buffer_size_write - resize the size of ring_buffer
+ * @file: the file to read
+ * @buf: the file to write
+ * @nbytes: the maximum size to write
+ * @ppos: the position to read from
+ **/
+static ssize_t ndrvbuf_buffer_size_write(struct file *file,
+			const char __user *ubuf, size_t nbytes, loff_t *ppos)
+{
+	struct ndrvbuf *ndrvbuf = file->private_data;
+	unsigned long cur_size = ndrvbuf->buffer_size;
+	unsigned long new_size;
+	int ret;
+	char buf[64];
+
+	if (nbytes >= sizeof(buf))
+		return -EINVAL;
+	if (copy_from_user(&buf, ubuf, nbytes))
+		return -EFAULT;
+	buf[nbytes] = 0;
+	ret = strict_strtoul(buf, 10, &new_size);
+	if (ret < 0)
+		return ret;
+	if (cur_size == new_size)
+		return nbytes;
+schedule:
+	mutex_lock(&ndrvbuf_list_lock);
+	if (atomic_read(&ndrvbuf->reader_count) != 0) {
+		mutex_unlock(&ndrvbuf_list_lock);
+		schedule();
+		goto schedule;
+	}
+	atomic_inc(&ndrvbuf_disabled);
+	synchronize_sched();
+	if (!is_in_ndrvbuf_list(ndrvbuf)) {
+		atomic_dec(&ndrvbuf_disabled);
+		mutex_unlock(&ndrvbuf_list_lock);
+		return -ENODEV;
+	}
+	ret = ring_buffer_resize(ndrvbuf->rbuf, new_size);
+	if (ret < 0)
+		pr_warning("Could not change buffer size\n");
+	ndrvbuf->buffer_size = new_size;
+	if (new_size)
+		atomic_set(&ndrvbuf->disabled, 0);
+	else
+		atomic_set(&ndrvbuf->disabled, 1);
+	atomic_dec(&ndrvbuf_disabled);
+	mutex_unlock(&ndrvbuf_list_lock);
+
+	return nbytes;
+}
+
+static const struct file_operations buffer_size_file_ops = {
+	.owner =	THIS_MODULE,
+	.open =		ndrvbuf_buffer_size_open,
+	.read =		ndrvbuf_buffer_size_read,
+	.write =	ndrvbuf_buffer_size_write,
+};
+
+static struct ndrvbuf *create_ndrvbuf(const char *name, size_t size)
+{
+	struct ndrvbuf *ndrvbuf;
+	struct dentry *buf_dir;
+
+	ndrvbuf = kzalloc(sizeof(struct ndrvbuf), GFP_KERNEL);
+	if (!ndrvbuf)
+		goto out;
+	strcpy(ndrvbuf->name, name);
+	buf_dir = debugfs_create_dir(name, ndrvbuf_root);
+	if (!buf_dir) {
+		pr_warning("Could not create debugfs dir '%s'\n", name);
+		goto out_free_ndrvbuf;
+	}
+	ndrvbuf->buf_dir = buf_dir;
+	ndrvbuf->buffer_dent = debugfs_create_file("buffer",
+				S_IFREG|S_IRUGO|S_IWUSR,
+				buf_dir, ndrvbuf, &buffer_file_ops);
+	if (!ndrvbuf->buffer_dent) {
+		pr_warning("Could not create debugfs file 'buffer'\n");
+		goto out_rem_buf_dir;
+	}
+	ndrvbuf->buffer_size_dent = debugfs_create_file("buffer_size",
+				S_IFREG|S_IRUGO|S_IWUSR,
+				buf_dir, ndrvbuf, &buffer_size_file_ops);
+	if (!ndrvbuf->buffer_size_dent) {
+		pr_warning("Could not create debugfs file 'buffer_size'\n");
+		goto out_rem_buffer;
+	}
+	ndrvbuf->rbuf = ring_buffer_alloc(size, RB_FL_OVERWRITE);
+	if (!ndrvbuf->rbuf) {
+		pr_warning("Could not alloc ring_buffer for %s\n",
+							name);
+		goto out_rem_buffer_size;
+	}
+	ndrvbuf->buffer_size = size;
+	if (size)
+		atomic_set(&ndrvbuf->disabled, 0);
+	else
+		atomic_set(&ndrvbuf->disabled, 1);
+	return ndrvbuf;
+
+out_rem_buffer_size:
+	debugfs_remove(ndrvbuf->buffer_size_dent);
+out_rem_buffer:
+	debugfs_remove(ndrvbuf->buffer_dent);
+out_rem_buf_dir:
+	debugfs_remove(ndrvbuf->buf_dir);
+out_free_ndrvbuf:
+	kfree(ndrvbuf);
+out:
+	return NULL;
+}
+
+static void remove_ndrvbuf(struct ndrvbuf *ndrvbuf)
+{
+	if (!ndrvbuf)
+		return;
+	debugfs_remove(ndrvbuf->buffer_size_dent);
+	debugfs_remove(ndrvbuf->buffer_dent);
+	debugfs_remove(ndrvbuf->buf_dir);
+	ring_buffer_free(ndrvbuf->rbuf);
+	kfree(ndrvbuf);
+}
+
+/**
+ * register_ndrvbuf - create ndrvbuf struct
+ * @name: The buffer dif name. Usually, it is created under
+ *        /sys/kernel/debug/ndrvbuf
+ * @size: The size of ring_buffer per cpu
+ * @read: The read format funcion. If NULL, use ndrvbuf_default_read.
+ *
+ * This is called when network driver want to set ndrvbuf.
+ * If registering is failed, return NULL.
+ **/
+struct ndrvbuf *_register_ndrvbuf(const char *name, size_t size,
+		size_t (*read)(void *, size_t, void *, size_t, int, u64))
+{
+	struct ndrvbuf *cbuf;
+	struct list_head *cur;
+
+	mutex_lock(&ndrvbuf_list_lock);
+	atomic_inc(&ndrvbuf_disabled);
+	synchronize_sched();
+	list_for_each(cur, &ndrvbuf_list) {
+		cbuf = list_entry(cur, struct ndrvbuf, list);
+		if (!strncmp(cbuf->name, name, NDRVBUF_NAME_SIZE))
+			break;
+	}
+	if (cur != &ndrvbuf_list) {
+		pr_warning("%s already exists\n", name);
+		cbuf = NULL;
+		goto out;
+	}
+	cbuf = create_ndrvbuf(name, size);
+	if (!cbuf)
+		goto out;
+
+	if (read)
+		cbuf->read = read;
+	else
+		cbuf->read = ndrvbuf_default_read;
+	list_add(&cbuf->list, &ndrvbuf_list);
+out:
+	atomic_dec(&ndrvbuf_disabled);
+	mutex_unlock(&ndrvbuf_list_lock);
+	return cbuf;
+}
+EXPORT_SYMBOL(_register_ndrvbuf);
+
+/**
+ * unregister_ndrvbuf - free ndrbuf struct and some resources
+ * @ndrvbuf: The pointer of ndrvbuf
+ **/
+void _unregister_ndrvbuf(struct ndrvbuf *ndrvbuf)
+{
+schedule:
+	mutex_lock(&ndrvbuf_list_lock);
+	if (atomic_read(&ndrvbuf->reader_count) != 0) {
+		mutex_unlock(&ndrvbuf_list_lock);
+		schedule();
+		goto schedule;
+	}
+	atomic_inc(&ndrvbuf_disabled);
+	synchronize_sched();
+	list_del(&ndrvbuf->list);
+	atomic_dec(&ndrvbuf_disabled);
+	mutex_unlock(&ndrvbuf_list_lock);
+
+	remove_ndrvbuf(ndrvbuf);
+}
+EXPORT_SYMBOL(_unregister_ndrvbuf);
+
+/**
+ * _write_ndrvbuf - Write a trace event to buffer
+ * @ndrvbuf: buffer to write
+ * @size: The size of trace event
+ * @buf: The pointer to read from
+ **/
+void _write_ndrvbuf(struct ndrvbuf *ndrvbuf, size_t size, void *buf)
+{
+	unsigned long flags;
+
+	preempt_disable();
+	local_irq_save(flags);
+	if (!atomic_read(&ndrvbuf_disabled) && is_in_ndrvbuf_list(ndrvbuf)
+		&& !atomic_read(&ndrvbuf->disabled))
+		ring_buffer_write(ndrvbuf->rbuf, size, buf);
+	local_irq_restore(flags);
+	preempt_enable();
+}
+EXPORT_SYMBOL(_write_ndrvbuf);
+
+static int __init ndrvbuf_init(void)
+{
+	ndrvbuf_root = debugfs_create_dir("ndrvbuf", NULL);
+	if (!ndrvbuf_root) {
+		pr_warning("Could not create debugfs dir 'ndrvbuf'\n");
+		return -ENODEV;
+	}
+	atomic_set(&ndrvbuf_disabled, 0);
+	return 0;
+}
+
+module_init(ndrvbuf_init);
+
+static void __exit ndrvbuf_exit(void)
+{
+	if (ndrvbuf_root)
+		debugfs_remove(ndrvbuf_root);
+}
+
+module_exit(ndrvbuf_exit);
diff --git a/include/linux/ndrvbuf.h b/include/linux/ndrvbuf.h
new file mode 100644
index 0000000..1d56b79
--- /dev/null
+++ b/include/linux/ndrvbuf.h
@@ -0,0 +1,57 @@
+#ifndef _NDRVBUF_H_
+#define _NDRVBUF_H_
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/ring_buffer.h>
+#include <linux/debugfs.h>
+#include <linux/netdevice.h>
+
+#define NDRVBUF_STR_LEN (2*PAGE_SIZE)
+#define NDRVBUF_NAME_SIZE 32
+
+struct ndrvbuf {
+	struct list_head list;
+	char name[NDRVBUF_NAME_SIZE];
+	struct dentry *buf_dir;
+	struct dentry *enable_dent;
+	struct dentry *buffer_size_dent;
+	struct dentry *buffer_dent;
+	unsigned long buffer_size;
+	atomic_t disabled;
+	size_t (*read)(void *ubuf, size_t bufsize, void *entry,
+			size_t size, int cpu, u64 ts);
+	struct ring_buffer *rbuf;
+	atomic_t reader_count;
+};
+
+extern __attribute__((weak)) struct ndrvbuf *_register_ndrvbuf(
+		const char *name, size_t size,
+		size_t (*read)(void *, size_t, void *, size_t, int, u64));
+extern __attribute__((weak)) void _unregister_ndrvbuf(struct ndrvbuf *ndrvbuf);
+extern __attribute__((weak)) void _write_ndrvbuf(struct ndrvbuf *ndrvbuf,
+		size_t size, void *buf);
+extern __attribute__((weak)) size_t _typical_ndrvbuf_header(void *dst,
+		size_t size, int cpu, u64 ts);
+
+#define register_ndrvbuf(name, size, read) ((_register_ndrvbuf) ? \
+	_register_ndrvbuf(name, size, read) : NULL)
+
+#define unregister_ndrvbuf(ndrvbuf)					\
+	do {								\
+		if (_unregister_ndrvbuf)				\
+			_unregister_ndrvbuf(ndrvbuf);			\
+	} while (0)
+
+#define write_ndrvbuf(ndrvbuf, size, buf)				\
+	do {								\
+		if (_write_ndrvbuf)					\
+			_write_ndrvbuf(ndrvbuf, size, buf);		\
+	} while (0)
+
+#define typical_ndrvbuf_header(dst, size, cpu, ts) (			\
+	(_typical_ndrvbuf_header) ? 					\
+	_typical_ndrvbuf_header(dst, size, cpu, ts) : 0)
+
+#endif /* _NDRVBUF_H_ */

