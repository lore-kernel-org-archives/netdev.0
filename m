From: Peter Moody <pmoody@google.com>
Subject: [PATCH 2/2] security: Hone LSM
Date: Thu, 31 Jul 2014 18:21:40 -0700
Message-ID: <1406856100-21674-3-git-send-email-pmoody@google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
Cc: brandon.carpenter@pnnl.gov, casey@schaufler-ca.com,
	netdev@vger.kernel.org, Peter Moody <pmoody@google.com>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1406856100-21674-1-git-send-email-pmoody@google.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the Hone (Host/Network) process <-> packet correlation
module to the linux security subsystem. Hone aims to provide network
administrators with the ability to correlate network activity seen on
the network to the process which sent/received it.

Signed-off-by: Peter Moody <pmoody@google.com>
---
 include/linux/hone.h               |  50 +++
 security/Kconfig                   |   1 +
 security/Makefile                  |   2 +
 security/hone/Kconfig              |   8 +
 security/hone/Makefile             |   3 +
 security/hone/hone.h               | 164 ++++++++++
 security/hone/hone_event.c         | 625 +++++++++++++++++++++++++++++++++++++
 security/hone/hone_lsm.c           | 183 +++++++++++
 security/hone/hone_mmutil.c        | 106 +++++++
 security/hone/hone_mmutil.h        |  20 ++
 security/hone/hone_notify.c        | 450 ++++++++++++++++++++++++++
 security/hone/hone_pcapng.c        | 596 +++++++++++++++++++++++++++++++++++
 security/hone/hone_pcapng.h        |  30 ++
 security/hone/hone_ringbuf.c       |  51 +++
 security/hone/hone_ringbuf.h       |  34 ++
 security/hone/hone_socket_lookup.c | 264 ++++++++++++++++
 16 files changed, 2587 insertions(+)
 create mode 100644 include/linux/hone.h
 create mode 100644 security/hone/Kconfig
 create mode 100644 security/hone/Makefile
 create mode 100644 security/hone/hone.h
 create mode 100644 security/hone/hone_event.c
 create mode 100644 security/hone/hone_lsm.c
 create mode 100644 security/hone/hone_mmutil.c
 create mode 100644 security/hone/hone_mmutil.h
 create mode 100644 security/hone/hone_notify.c
 create mode 100644 security/hone/hone_pcapng.c
 create mode 100644 security/hone/hone_pcapng.h
 create mode 100644 security/hone/hone_ringbuf.c
 create mode 100644 security/hone/hone_ringbuf.h
 create mode 100644 security/hone/hone_socket_lookup.c

diff --git a/include/linux/hone.h b/include/linux/hone.h
new file mode 100644
index 0000000..7ad7ad8
--- /dev/null
+++ b/include/linux/hone.h
@@ -0,0 +1,50 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ */
+
+#include <linux/skbuff.h>
+
+#ifndef _INCLUDE_LINUX_HONE_H
+#define _INCLUDE_LINUX_HONE_H
+
+#define PKTNOT_PACKET_IN 1
+#define PKTNOT_PACKET_OUT 2
+
+/* hone block types for pcapng blocks */
+#define HONE_IF_DESC_BLOCK	0x00000001
+#define HONE_IF_STATS_BLOCK	0x00000005
+#define HONE_PACKET_BLOCK	0x00000006
+#define HONE_PROCESS_BLOCK	0x00000101
+#define HONE_CONNECTION_BLOCK	0x00000102
+#define HONE_SECTION_HDR_BLOCK	0x0A0D0D0A
+
+/* ioctls for controlling hone. */
+#define HEIO_RESTART _IO(0xE0, 0x01)
+#define HEIO_GET_AT_HEAD _IO(0xE0, 0x03)
+#define HEIO_GET_SNAPLEN _IOR(0xE0, 0x04, int)
+#define HEIO_SET_SNAPLEN _IOW(0xE0, 0x05, int)
+#define HEIO_SET_FILTER_SOCK _IOW(0xE0, 0x06, int)
+
+#define HONE_PROCESS 1
+#define HONE_SOCKET 2
+#define HONE_PACKET 3
+#define HONE_USER 0x8000
+
+#define PROC_FORK 1
+#define PROC_EXEC 2
+#define PROC_EXIT 3
+#define PROC_KTHD 4
+
+void hone_exec_handler(int);
+void hone_exit_handler(void);
+void hone_fork_handler(struct task_struct *);
+void hone_raw_rcv_handler(struct sock *, struct sk_buff *);
+void hone_inet_create_handler(int, struct sock *);
+
+#endif
diff --git a/security/Kconfig b/security/Kconfig
index beb86b5..84d2b45 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -122,6 +122,7 @@ source security/smack/Kconfig
 source security/tomoyo/Kconfig
 source security/apparmor/Kconfig
 source security/yama/Kconfig
+source security/hone/Kconfig
 
 source security/integrity/Kconfig
 
diff --git a/security/Makefile b/security/Makefile
index 05f1c93..ff20918 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -8,6 +8,7 @@ subdir-$(CONFIG_SECURITY_SMACK)		+= smack
 subdir-$(CONFIG_SECURITY_TOMOYO)        += tomoyo
 subdir-$(CONFIG_SECURITY_APPARMOR)	+= apparmor
 subdir-$(CONFIG_SECURITY_YAMA)		+= yama
+subdir-$(CONFIG_SECURITY_HONE)		+= hone
 
 # always enable default capabilities
 obj-y					+= commoncap.o
@@ -22,6 +23,7 @@ obj-$(CONFIG_AUDIT)			+= lsm_audit.o
 obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/
 obj-$(CONFIG_SECURITY_APPARMOR)		+= apparmor/
 obj-$(CONFIG_SECURITY_YAMA)		+= yama/
+obj-$(CONFIG_SECURITY_HONE) 		+= hone/
 obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
 
 # Object integrity file lists
diff --git a/security/hone/Kconfig b/security/hone/Kconfig
new file mode 100644
index 0000000..bdaad6b
--- /dev/null
+++ b/security/hone/Kconfig
@@ -0,0 +1,8 @@
+config SECURITY_HONE
+       bool "HOst NEt corrleation engine support"
+       default n
+       help
+         This selects hone, a tool for correlating packets to
+         processes.
+
+         If you are unsure how to answer this question, answer N.
diff --git a/security/hone/Makefile b/security/hone/Makefile
new file mode 100644
index 0000000..b87c0a8
--- /dev/null
+++ b/security/hone/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_SECURITY_HONE)	:= hone.o
+hone-y := hone_lsm.o hone_notify.o hone_ringbuf.o hone_event.o \
+					hone_mmutil.o hone_pcapng.o hone_ringbuf.o hone_socket_lookup.o
diff --git a/security/hone/hone.h b/security/hone/hone.h
new file mode 100644
index 0000000..1533cf7
--- /dev/null
+++ b/security/hone/hone.h
@@ -0,0 +1,164 @@
+#ifndef _SECURITY_HONE_HONE_H
+#define _SECURITY_HONE_HONE_H
+
+#include <linux/hone.h>
+#include <linux/tcp.h>
+
+#define HONE_USER_HEAD (HONE_USER | 1)
+#define HONE_USER_TAIL (HONE_USER | 2)
+
+#define READER_HEAD 0x00000001
+#define READER_INIT 0x00000002
+#define READER_TAIL 0x00000004
+#define READER_FINISH 0x00000008
+#define READER_RESTART 0x0000000F
+#define READER_FILTER_PID 0x00000100
+
+struct guid_struct {
+	uint32_t data1;
+	uint16_t data2;
+	uint16_t data3;
+	uint8_t  data4[8];
+};
+
+struct device_info {
+	struct guid_struct host_guid;
+	bool host_guid_is_set;
+	const char *host_id;
+	const char *comment;
+	struct dentry *dir;
+	struct dentry *pcapng;
+	struct dentry *text;
+};
+
+struct statistics {
+	atomic64_t process;
+	atomic64_t socket;
+	atomic64_t packet;
+};
+
+struct reader_info {
+	unsigned int snaplen;
+	struct timespec boot_time;
+	struct timespec start_time;
+	struct statistics delivered;
+	struct statistics dropped;
+	atomic64_t filtered;
+};
+
+struct process_event {
+	union {
+		struct mm_struct *mm;
+		char *comm;
+	};
+	int event;
+	pid_t pid;
+	pid_t ppid;
+	pid_t tgid;
+	uid_t uid;
+	uid_t euid;
+	uid_t loginuid;
+	gid_t gid;
+	int retval;
+};
+
+struct socket_event {
+	unsigned long sock;
+	int event;
+	pid_t pid;
+	pid_t ppid;
+	pid_t tgid;
+	uid_t uid;
+	gid_t gid;
+};
+
+struct packet_event {
+	unsigned long sock;
+	int dir;
+	int len;
+	pid_t pid;
+	struct sock *sk;
+	struct sk_buff *skb;
+};
+
+struct user_event {
+	void *data;
+};
+
+struct hone_event {
+	int type;
+	union {
+		atomic_t users;
+		struct hone_event *next;
+	};
+	struct timespec ts;
+	union {
+		struct process_event process;
+		struct socket_event socket;
+		struct packet_event packet;
+		struct user_event user;
+	};
+};
+
+struct packet_args {
+	struct sock *sk;
+	struct sk_buff *skb;
+};
+
+#define STATISTICS_INIT {ATOMIC64_INIT(0), ATOMIC64_INIT(0), ATOMIC64_INIT(0)}
+#define DEFINE_STATISTICS(name) struct statistics name = STATISTICS_INIT
+
+static inline void init_statistics(struct statistics *stats)
+{
+	atomic64_set(&stats->process, 0);
+	atomic64_set(&stats->socket, 0);
+	atomic64_set(&stats->packet, 0);
+}
+
+extern void get_hone_statistics(struct statistics *received,
+				struct statistics *dropped,
+				struct timespec *ts);
+
+void free_hone_event(struct hone_event *event);
+
+int hone_notify_init(void);
+int hone_fs_init(void);
+
+int process_notifier_notify(unsigned long event, struct task_struct *task);
+int sock_notifier_notify(unsigned long event, struct sock *sk);
+int packet_notifier_notify(unsigned long event, struct packet_args *pargs);
+int hone_notifier_register(struct notifier_block *nb);
+int hone_notifier_unregister(struct notifier_block *nb);
+
+struct hone_event *__alloc_socket_event(unsigned long v, int val,
+					struct task_struct *task, gfp_t flags);
+struct hone_event *__alloc_process_event(struct task_struct *task, int type,
+                                         gfp_t flags);
+
+static inline void get_hone_event(struct hone_event *event)
+{
+	BUG_ON(unlikely(!atomic_read(&event->users)));
+	atomic_inc(&event->users);
+}
+
+static inline void put_hone_event(struct hone_event *event)
+{
+	BUG_ON(unlikely(!atomic_read(&event->users)));
+	if (atomic_dec_and_test(&event->users))
+		free_hone_event(event);
+}
+
+static inline void put_sock(struct sock *sk)
+{
+	if (sk->sk_state == TCP_TIME_WAIT)
+		inet_twsk_put(inet_twsk(sk));
+	else
+		sock_put(sk);
+}
+
+struct sock *lookup_v4_sock(const struct sk_buff *skb,
+			const struct net_device *indev);
+struct sock *lookup_v6_sock(const struct sk_buff *skb,
+			const struct net_device *indev);
+
+#endif
diff --git a/security/hone/hone_event.c b/security/hone/hone_event.c
new file mode 100644
index 0000000..b2339bc
--- /dev/null
+++ b/security/hone/hone_event.c
@@ -0,0 +1,625 @@
+#include <linux/kernel.h>
+#include <linux/security.h>
+#include <linux/fdtable.h>
+#include <linux/fs.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <linux/ipv6.h>
+#include <linux/ip.h>
+
+#include <linux/hone.h>
+
+#include "hone.h"
+#include "hone_mmutil.h"
+#include "hone_pcapng.h"
+#include "hone_ringbuf.h"
+
+static struct device_info devinfo = {
+	.comment = NULL,
+	.host_id = NULL,
+	.host_guid_is_set = false
+};
+
+#ifndef CONFIG_HONE_DEFAULT_PAGEORDER
+	#ifdef CONFIG_64BIT
+		#define CONFIG_HONE_DEFAULT_PAGEORDER 3
+	#else
+		#define CONFIG_HONE_DEFAULT_PAGEORDER 2
+	#endif
+#endif
+
+static unsigned int pageorder = CONFIG_HONE_DEFAULT_PAGEORDER;
+#define size_of_pages(order) (PAGE_SIZE << (order))
+#define READ_BUFFER_PAGE_ORDER 5
+#define READ_BUFFER_SIZE size_of_pages(READ_BUFFER_PAGE_ORDER)
+
+struct hone_reader {
+	struct semaphore sem;
+	struct ring_buf ringbuf;
+	struct notifier_block nb;
+	struct reader_info info;
+	atomic_t flags;
+	char *buf;
+	struct sock *filter_sk;
+	struct hone_event *event;
+	size_t length, offset;
+	wait_queue_head_t event_wait_queue;
+
+	unsigned int (*format)(const struct device_info*,
+			const struct reader_info*,
+			struct hone_event *,
+			char *, unsigned int);
+};
+
+static struct hone_event head_event = {HONE_USER_HEAD, {ATOMIC_INIT(1)} };
+static struct hone_event tail_event = {HONE_USER_TAIL, {ATOMIC_INIT(1)} };
+
+#define reader_will_block(rdr)					\
+	(ring_is_empty(&(rdr)->ringbuf) && !(rdr)->event &&	\
+	 !(atomic_read(&(rdr)->flags) & READER_RESTART))
+
+static unsigned int format_as_text(const struct device_info *devinfo,
+				const struct reader_info *info,
+				struct hone_event *event, char *buf,
+				unsigned int buflen)
+{
+	static const char * const event_names[] = {
+		"????", "FORK", "EXEC", "EXIT", "KTHD"};
+	unsigned int n = 0;
+
+#define printbuf(fmt, ...)						\
+	({								\
+		n += snprintf(buf + n, buflen - n, fmt, ##__VA_ARGS__); \
+		if (n >= buflen)					\
+			goto out_long;					\
+		n;							\
+	})
+
+	switch (event->type) {
+	case HONE_PROCESS:
+	{
+		struct process_event *pev = &event->process;
+
+		printbuf("%lu.%09lu %s %d %d %d %d\n",
+			event->ts.tv_sec, event->ts.tv_nsec,
+			event_names[pev->event], pev->pid, pev->ppid, pev->euid,
+			pev->gid);
+
+		if (pev->mm) {
+			n--;
+			if (pev->event == PROC_KTHD)
+				printbuf(" [%s]", pev->comm);
+			else {
+				char *path, *argv;
+
+				printbuf(" \"");
+				path = mm_path(pev->mm, buf + n,
+					buflen - n - 3);
+
+				if (path) {
+					int pathlen = strlen(path);
+
+					memmove(buf + n, path, pathlen);
+					n += pathlen;
+				}
+
+				printbuf("\" ");
+				argv = buf + n;
+				n += mm_argv(pev->mm, buf + n, buflen - n - 1);
+				for ( ; argv < buf + n; argv++) {
+					if (*argv == '\0')
+						*argv = ' ';
+				}
+			}
+			printbuf("\n");
+		}
+		break;
+	}
+	case HONE_SOCKET:
+	{
+		struct socket_event *sockev = &event->socket;
+
+		printbuf("%lu.%09lu SOCK %c %d %d %d %d %08lx\n",
+			event->ts.tv_sec, event->ts.tv_nsec,
+			sockev->event ? 'C' : 'O', sockev->pid, sockev->ppid,
+			sockev->uid, sockev->gid, sockev->sock & 0xFFFFFFFF);
+	}
+		break;
+	case HONE_PACKET:
+	{
+		int offset;
+		struct iphdr _iph, *iph;
+
+		offset = skb_network_offset(event->packet.skb);
+		iph = skb_header_pointer(event->packet.skb, offset,
+					sizeof(_iph), &_iph);
+
+		printbuf("%lu.%09lu PAKT %c %08lx %u", event->ts.tv_sec,
+			event->ts.tv_nsec, event->packet.dir ? 'I' : 'O',
+			event->packet.sock & 0xFFFFFFFF, event->packet.pid);
+		if (!iph)
+			printbuf(" ? ? -> ?");
+		else if (iph->version == 4) {
+			if (iph->protocol == IPPROTO_TCP ||
+				iph->protocol == IPPROTO_UDP) {
+				struct udphdr _uh, *uh;
+
+				uh = skb_header_pointer(
+					event->packet.skb,
+					offset + (iph->ihl << 2),
+					sizeof(_uh), &_uh);
+				if (uh) {
+					printbuf(" %sv4 %pI4:%d -> %pI4:%d",
+						iph->protocol == IPPROTO_TCP
+						? "TCP" : "UDP",
+						&iph->saddr, ntohs(uh->source),
+						&iph->daddr, ntohs(uh->dest));
+				} else {
+					printbuf(" %sv4 ? -> ?",
+						iph->protocol == IPPROTO_TCP ?
+						"TCP" : "UDP");
+				}
+			} else {
+				printbuf(" %u %pI4 -> %pI4", iph->protocol,
+					&iph->saddr, &iph->daddr);
+			}
+		} else if (iph->version == 6) {
+			struct ipv6hdr _iph6, *iph6;
+
+			iph6 = skb_header_pointer(event->packet.skb, offset,
+						sizeof(_iph6), &_iph6);
+			if (iph6->nexthdr == IPPROTO_TCP ||
+				iph6->nexthdr == IPPROTO_UDP) {
+				struct udphdr _uh, *uh;
+
+				uh = skb_header_pointer(
+					event->packet.skb,
+					offset + sizeof(struct ipv6hdr),
+					sizeof(_uh), &_uh);
+				if (uh) {
+					printbuf(" %sv6 %pI6:%d -> %pI6:%d",
+						iph6->nexthdr == IPPROTO_TCP ?
+						"TCP" : "UDP",
+						&iph6->saddr, ntohs(uh->source),
+						&iph6->daddr, ntohs(uh->dest));
+				} else {
+					printbuf(" %sv6 ? -> ?",
+						iph6->nexthdr == IPPROTO_TCP ?
+						"TCP" : "UDP");
+				}
+			} else {
+				printbuf(" %u %pI6 -> %pI6", iph6->nexthdr,
+					&iph6->saddr, &iph6->daddr);
+			}
+		} else {
+			printbuf(" ?.%d ? -> ?", iph->version);
+		}
+		printbuf(" %u\n", event->packet.skb->len);
+	}
+	break;
+	case HONE_USER_HEAD:
+		if (devinfo->host_guid_is_set)
+			printbuf("%lu.%09lu HEAD %lu.%09lu {" GUID_FMT "}\n",
+				info->start_time.tv_sec,
+				info->start_time.tv_nsec,
+				info->boot_time.tv_sec, info->boot_time.tv_nsec,
+				GUID_TUPLE(&devinfo->host_guid));
+		else
+			printbuf("%lu.%09lu HEAD %lu.%09lu\n",
+				info->start_time.tv_sec,
+				info->start_time.tv_nsec,
+				info->boot_time.tv_sec,
+				info->boot_time.tv_nsec);
+		break;
+	case HONE_USER_TAIL:
+		printbuf("%lu.%09lu TAIL\n",
+			info->start_time.tv_sec, info->start_time.tv_nsec);
+		break;
+	default:
+		printbuf("%lu.%09lu ???? %d\n",
+			 event->ts.tv_sec, event->ts.tv_nsec, event->type);
+		break;
+
+	}
+
+#undef printbuf
+	return n;
+out_long:
+	snprintf(buf + buflen - 5, 5, "...\n");
+	return buflen;
+}
+
+static void free_hone_reader(struct hone_reader *reader)
+{
+	if (reader) {
+		if (reader->ringbuf.data) {
+			free_pages((unsigned long) (reader->ringbuf.data),
+				   reader->ringbuf.pageorder);
+			reader->ringbuf.data = NULL;
+		}
+		if (reader->buf) {
+			free_pages((unsigned long) (reader->buf),
+				   READ_BUFFER_PAGE_ORDER);
+			reader->buf = NULL;
+		}
+		kfree(reader);
+	}
+}
+
+static struct hone_reader *alloc_hone_reader(void)
+{
+	struct hone_reader *reader;
+	struct ring_buf *ring;
+
+	reader = kzalloc(sizeof(*reader), GFP_KERNEL);
+	if (!reader)
+		goto alloc_failed;
+
+	reader->buf = (typeof(reader->buf)) __get_free_pages(
+		GFP_KERNEL | __GFP_ZERO, READ_BUFFER_PAGE_ORDER);
+	if (!reader->buf)
+		goto alloc_failed;
+
+	ring = &reader->ringbuf;
+	ring->pageorder = pageorder;
+
+	ring->data = (typeof(ring->data)) __get_free_pages(
+		GFP_KERNEL | __GFP_ZERO, ring->pageorder);
+	if (!ring->data)
+		goto alloc_failed;
+	ring->length = size_of_pages(ring->pageorder) / sizeof(*(ring->data));
+
+	reader->format = format_as_pcapng;
+
+	atomic_set(&reader->flags, READER_HEAD | READER_INIT);
+	sema_init(&reader->sem, 1);
+	init_waitqueue_head(&reader->event_wait_queue);
+	return reader;
+
+alloc_failed:
+	free_hone_reader(reader);
+	return NULL;
+}
+
+static void inc_stats_counter(struct statistics *stats, int type)
+{
+	atomic64_t *counter;
+
+	switch(type) {
+	case HONE_PROCESS:
+		counter = &stats->process;
+		break;
+	case HONE_SOCKET:
+		counter = &stats->socket;
+		break;
+	case HONE_PACKET:
+		counter = &stats->packet;
+		break;
+	default:
+		return;
+	}
+	atomic64_inc(counter);
+}
+
+static inline int enqueue_event(struct hone_reader *reader,
+				struct hone_event *event)
+{
+	/* Ignore threads for now */
+	if (event->type == HONE_PROCESS &&
+		event->process.pid != event->process.tgid)
+		return 0;
+	/* Filter out packets for local socket, if set */
+	if (event->type == HONE_PACKET && reader->filter_sk &&
+	    event->packet.sock == (unsigned long) reader->filter_sk) {
+		atomic64_inc(&reader->info.filtered);
+		return 0;
+	}
+
+	get_hone_event(event);
+	if (ring_append(&reader->ringbuf, event)) {
+		inc_stats_counter(&reader->info.dropped, event->type);
+		put_hone_event(event);
+		return 0;
+	}
+	return 1;
+}
+
+static int hone_event_handler(struct notifier_block *nb, unsigned long val,
+			      void *v)
+{
+	struct hone_reader *reader =
+		container_of(nb, struct hone_reader, nb);
+
+	if (enqueue_event(reader, v))
+		wake_up_interruptible_all(&reader->event_wait_queue);
+	return 0;
+}
+
+static struct hone_event *__add_files(struct hone_reader *reader,
+				      struct hone_event *event,
+				      struct task_struct *task)
+{
+	struct files_struct *files;
+	struct file *file;
+	struct fdtable *fdt;
+	struct hone_event *sk_event;
+	struct socket *sock;
+	struct sock *sk;
+	unsigned long flags, set;
+	int i, fd, err;
+
+	files = get_files_struct(task);
+	if (!files)
+		return event;
+
+	spin_lock_irqsave(&files->file_lock, flags);
+
+	fdt = files_fdtable(files);
+	if (!fdt)
+		goto out;
+
+	for (i = 0; (fd = i * BITS_PER_LONG) < fdt->max_fds; i++) {
+		for (set = fdt->open_fds[i]; set; set >>= 1, fd++) {
+			if (!(set & 1))
+				continue;
+			file = fdt->fd[fd];
+			if (!file)
+				continue;
+
+			sock = sock_from_file(file, &err);
+			if (!sock)
+				continue;
+			sk = sock->sk;
+			if (!sk || (sk->sk_family != PF_INET &&
+				    sk->sk_family != PF_INET6))
+				continue;
+
+			sk_event = __alloc_socket_event((unsigned long) sk,
+							0, task, GFP_ATOMIC);
+			if (sk_event) {
+				sk_event->next = event;
+				event = sk_event;
+				event->ts = task->start_time;
+			} else {
+				atomic64_inc(&reader->info.dropped.socket);
+			}
+		}
+	}
+out:
+	spin_unlock_irqrestore(&files->file_lock, flags);
+	put_files_struct(files);
+	return event;
+}
+
+#define prev_task(p) \
+	list_entry_rcu((p)->tasks.prev, struct task_struct, tasks)
+
+static struct hone_event *add_current_tasks(struct hone_reader *reader,
+					    struct hone_event *event)
+{
+	struct hone_event *proc_event;
+	struct task_struct *task;
+
+	rcu_read_lock();
+	for (task = &init_task; (task = prev_task(task)) != &init_task; ) {
+		if (task->flags & PF_EXITING)
+			continue;
+		event = __add_files(reader, event, task);
+		proc_event =  __alloc_process_event(
+			task, task->flags & PF_FORKNOEXEC ?
+			PROC_FORK : PROC_EXEC,
+			GFP_ATOMIC);
+		if (proc_event) {
+			proc_event->next = event;
+			event = proc_event;
+			event->ts = task->start_time;
+		} else {
+			atomic64_inc(&reader->info.dropped.process);
+		}
+	}
+	rcu_read_unlock();
+	return event;
+}
+
+static void free_initial_events(struct hone_reader *reader)
+{
+	struct hone_event *event, *next;
+
+	for (event = reader->event; event; event = next) {
+		next = event->next;
+		free_hone_event(event);
+	}
+	reader->event = NULL;
+}
+
+static void add_initial_events(struct hone_reader *reader)
+{
+	free_initial_events(reader);
+	reader->event = add_current_tasks(reader, NULL);
+}
+
+static int hone_open(struct inode *inode, struct file *file)
+{
+	struct hone_reader *reader;
+	int err = -ENOMEM;
+
+	if ((file->f_flags & O_ACCMODE) != O_RDONLY) {
+		pr_err("no readonly failed\n");
+		return -EINVAL;
+	}
+
+	reader = alloc_hone_reader();
+	if (!reader) {
+		pr_err("reader alloc failed\n");
+		goto reader_failed;
+	}
+
+	if (file->f_dentry == devinfo.text)
+		reader->format = format_as_text;
+	file->private_data = reader;
+
+	getboottime(&reader->info.boot_time);
+	ktime_get_ts(&reader->info.start_time);
+	init_statistics(&reader->info.delivered);
+	init_statistics(&reader->info.dropped);
+	reader->nb.notifier_call = hone_event_handler;
+	err = hone_notifier_register(&reader->nb);
+	if (err) {
+		pr_err("hone_notifier_register() failed with error %d\n", err);
+		goto register_failed;
+	}
+	return 0;
+
+register_failed:
+	free_hone_reader(reader);
+reader_failed:
+	return err;
+}
+
+static int hone_release(struct inode *inode, struct file *file)
+{
+	struct hone_reader *reader = file->private_data;
+	struct hone_event *event;
+
+	hone_notifier_unregister(&reader->nb);
+	file->private_data = NULL;
+	while ((event = ring_pop(&reader->ringbuf)))
+		put_hone_event(event);
+	if (reader->filter_sk) {
+		sock_put(reader->filter_sk);
+		reader->filter_sk = NULL;
+	}
+	free_initial_events(reader);
+	free_hone_reader(reader);
+	return 0;
+}
+
+static ssize_t hone_read(struct file *file, char __user *buffer,
+			size_t length, loff_t *offset)
+{
+	struct hone_reader *reader = file->private_data;
+	size_t n, copied = 0;
+
+	if (!length)
+		return 0;
+
+	do {
+		while (!reader->offset && reader_will_block(reader)) {
+			if (file->f_flags & O_NONBLOCK)
+				return -EAGAIN;
+			if (wait_event_interruptible(
+					reader->event_wait_queue,
+					!reader_will_block(reader)))
+				return -EINTR;
+		}
+
+		if (file->f_flags & O_NONBLOCK) {
+			if (down_trylock(&reader->sem))
+				return -EAGAIN;
+		} else if (down_interruptible(&reader->sem)) {
+			return -EINTR;
+		}
+
+		while (copied < length) {
+			if (!reader->offset) {
+				int flags;
+				struct hone_event *event;
+
+				void (*free_event)(struct hone_event *);
+
+				flags = atomic_read(&reader->flags);
+				if (flags & READER_TAIL) {
+					atomic_clear_mask(READER_TAIL,
+							   &reader->flags);
+					 event = &tail_event;
+					 free_event = NULL;
+				} else if (flags & READER_FINISH) {
+					if (!copied)
+						atomic_clear_mask(READER_FINISH,
+								&reader->flags);
+					up(&reader->sem);
+					return copied;
+				} else if (flags & READER_HEAD) {
+					atomic_clear_mask(READER_HEAD,
+							  &reader->flags);
+					event = &head_event;
+					free_event = NULL;
+				} else if (flags & READER_INIT) {
+					atomic_clear_mask(READER_INIT,
+							  &reader->flags);
+					add_initial_events(reader);
+					continue;
+				} else if (reader->event) {
+					event = reader->event;
+					reader->event = event->next;
+					free_event = free_hone_event;
+				} else {
+					event = ring_pop(&reader->ringbuf);
+					free_event = put_hone_event;
+				}
+
+				if (!event)
+					break;
+				reader->length = reader->format(
+					&devinfo, &reader->info,
+					event, reader->buf, READ_BUFFER_SIZE);
+				inc_stats_counter(&reader->info.delivered,
+						event->type);
+				if (free_event)
+					free_event(event);
+			}
+			n = min(reader->length - reader->offset,
+				length - copied);
+			if (copy_to_user(buffer + copied,
+					 reader->buf + reader->offset, n)) {
+				up(&reader->sem);
+				return -EFAULT;
+			}
+			copied += n;
+			reader->offset += n;
+			if (reader->offset >= reader->length)
+				reader->offset = 0;
+		}
+		up(&reader->sem);
+	} while (!copied);
+	return copied;
+}
+
+static unsigned int hone_poll(struct file *file,
+			struct poll_table_struct *wait)
+{
+	struct hone_reader *reader = file->private_data;
+
+	poll_wait(file, &reader->event_wait_queue, wait);
+	if (!reader_will_block(reader))
+		return POLLIN | POLLRDNORM;
+	return 0;
+}
+
+static const struct file_operations hone_ops = {
+	.open = hone_open,
+	.read = hone_read,
+	.release = hone_release,
+	.poll = hone_poll,
+};
+
+int __init hone_fs_init(void)
+{
+	devinfo.dir = securityfs_create_dir("hone", NULL);
+	if (IS_ERR(devinfo.dir))
+		return -1;
+	devinfo.pcapng = securityfs_create_file("pcapng", 0600,
+					devinfo.dir, NULL, &hone_ops);
+	if (!devinfo.pcapng) {
+		pr_err("could not create hone output file\n");
+		return -1;
+	}
+
+	devinfo.text = securityfs_create_file("text", 0600,
+					devinfo.dir, NULL, &hone_ops);
+	if (!devinfo.text) {
+		pr_err("could not create hone output file\n");
+		return -1;
+	}
+	return 0;
+}
diff --git a/security/hone/hone_lsm.c b/security/hone/hone_lsm.c
new file mode 100644
index 0000000..4f7e785
--- /dev/null
+++ b/security/hone/hone_lsm.c
@@ -0,0 +1,183 @@
+#include <linux/security.h>
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/socket.h>
+#include <linux/sched.h>
+#include <linux/binfmts.h>
+#include <linux/netfilter.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#include "hone.h"
+
+void hone_task_post_create(struct task_struct *task)
+{
+	process_notifier_notify(PROC_FORK, task);
+}
+
+void hone_task_free(struct task_struct *task)
+{
+	process_notifier_notify(PROC_EXIT, task);
+}
+
+void hone_bprm_committing_creds(struct linux_binprm *bprm)
+{
+	process_notifier_notify(PROC_EXEC, current);
+}
+
+int hone_socket_post_create(struct socket *sock, int family,
+			int type, int protocol, int kern)
+{
+	if (likely(sock->sk)) {
+		sock->sk->sk_protinfo = (void *)(unsigned long)
+			(current->pid == current->tgid ?
+				current->pid : current->tgid);
+		sock_notifier_notify(0, sock->sk);
+	}
+	return 0;
+}
+
+int hone_socket_shutdown(struct socket *sock, int how)
+{
+	sock_notifier_notify(0xFFFFFFFF, sock->sk);
+	return 0;
+}
+
+int hone_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct packet_args pargs = {sk, skb};
+
+	switch (sk->sk_family) {
+	case PF_INET:
+	case PF_INET6:
+		packet_notifier_notify(PKTNOT_PACKET_IN, &pargs);
+	}
+	return 0;
+}
+
+static struct security_operations hone_ops = {
+	.name = "hone",
+
+	/* Process events. */
+	.task_post_create	= hone_task_post_create,
+	.task_free		= hone_task_free,
+	.bprm_committing_creds	= hone_bprm_committing_creds,
+
+	/* Socket events. */
+	.socket_post_create	= hone_socket_post_create,
+	.socket_shutdown	= hone_socket_shutdown,
+};
+
+static unsigned int nf_hook_v4_in(
+	const struct nf_hook_ops *hook, struct sk_buff *skb,
+	const struct net_device *indev, const struct net_device *outdev,
+	int (*okfn)(struct sk_buff *))
+{
+	struct sock *sk = lookup_v4_sock(skb, indev);
+	struct packet_args pargs = {sk, skb};
+
+	packet_notifier_notify(PKTNOT_PACKET_IN, &pargs);
+	if (sk)
+		put_sock(sk);
+	return NF_ACCEPT;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static unsigned int nf_hook_v6_in(
+	const struct nf_hook_ops *hook, struct sk_buff *skb,
+	const struct net_device *indev, const struct net_device *outdev,
+	int (*okfn)(struct sk_buff *))
+{
+	struct sock *sk = lookup_v6_sock(skb, indev);
+	struct packet_args pargs = {sk, skb};
+
+	packet_notifier_notify(PKTNOT_PACKET_IN, &pargs);
+	if (sk)
+		put_sock(sk);
+	return NF_ACCEPT;
+}
+#endif
+
+static unsigned int nf_hook_out(
+	const struct nf_hook_ops *hook, struct sk_buff *skb,
+	const struct net_device *indev, const struct net_device *outdev,
+	int (*okfn)(struct sk_buff *))
+{
+	struct packet_args pargs = {skb->sk, skb};
+
+	packet_notifier_notify(PKTNOT_PACKET_OUT, &pargs);
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops nf_inet_hooks[] = {
+	{
+		.list = {NULL, NULL},
+		.hook = nf_hook_v4_in,
+		.owner = THIS_MODULE,
+		.pf = PF_INET,
+		.hooknum = NF_INET_LOCAL_IN,
+		.priority = INT_MAX,
+	},
+	{
+		.list = {NULL, NULL},
+		.hook = nf_hook_out,
+		.owner = THIS_MODULE,
+		.pf = PF_INET,
+		.hooknum = NF_INET_LOCAL_OUT,
+		.priority = INT_MAX,
+	},
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	{
+		.list = {NULL, NULL},
+		.hook = nf_hook_v6_in,
+		.owner = THIS_MODULE,
+		.pf = PF_INET6,
+		.hooknum = NF_INET_LOCAL_IN,
+		.priority = INT_MAX,
+	},
+	{
+		.list = {NULL, NULL},
+		.hook = nf_hook_out,
+		.owner = THIS_MODULE,
+		.pf = PF_INET6,
+		.hooknum = NF_INET_LOCAL_OUT,
+		.priority = INT_MAX,
+	},
+#endif /* CONFIG_IPV6 */
+};
+
+void hone_raw_rcv_handler(struct sock *sk, struct sk_buff *skb)
+{
+	struct packet_args pargs = {sk, skb};
+
+	packet_notifier_notify(PKTNOT_PACKET_IN, &pargs);
+}
+
+static __init int hone_net_init(void)
+{
+	int err = nf_register_hooks(nf_inet_hooks, ARRAY_SIZE(
+					nf_inet_hooks));
+	if (err) {
+		pr_err("netfilter hook registration failed (%d)\n", err);
+		return -1;
+	}
+	return 0;
+}
+
+static __init int hone_init(void)
+{
+	int ret;
+
+	if (!security_module_enable(&hone_ops))
+		return 0;
+
+	if (register_security(&hone_ops))
+		panic("hone: kernel registration failed\n");
+
+	ret = hone_notify_init() || hone_net_init() || hone_fs_init();
+	if (!ret)
+		pr_info("hone: initialized\n");
+	return ret;
+}
+
+late_initcall(hone_init);
diff --git a/security/hone/hone_mmutil.c b/security/hone/hone_mmutil.c
new file mode 100644
index 0000000..bfdb72b
--- /dev/null
+++ b/security/hone/hone_mmutil.c
@@ -0,0 +1,106 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ *
+ * Much of the code below is based on procfs code.
+ */
+
+#include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+
+static int __mm_argv(struct mm_struct *mm, char *buf, int buflen)
+{
+	char *pos;
+	unsigned long addr, size;
+
+	if (!buflen)
+		return 0;
+
+	pos = buf;
+	addr = mm->arg_start;
+	size = mm->arg_end - mm->arg_start;
+	if (size > buflen)
+		size = buflen;
+	while (size) {
+		struct page *page;
+		int bytes, offset;
+		void *maddr;
+
+		if (get_user_pages(NULL, mm, addr, 1, 0, 0, &page, NULL) <= 0)
+			break;
+
+		bytes = size;
+		offset = addr & (PAGE_SIZE - 1);
+		if (bytes > (PAGE_SIZE - offset))
+			bytes = PAGE_SIZE - offset;
+
+		maddr = kmap(page);
+		memcpy(pos, maddr + offset, bytes);
+		kunmap(page);
+		put_page(page);
+
+		size -= bytes;
+		pos += bytes;
+		addr += bytes;
+	}
+
+	if (pos == buf) {
+		*pos = '\0';
+		pos++;
+	} else if (*(pos - 1))
+		*(pos - 1) = '\0';
+	return pos - buf;
+}
+
+int mm_argv(struct mm_struct *mm, char *buf, int buflen)
+{
+	int argvlen;
+
+	down_read(&mm->mmap_sem);
+	argvlen = __mm_argv(mm, buf, buflen - 1);
+	up_read(&mm->mmap_sem);
+	buf[argvlen] = '\0';
+	return argvlen;
+}
+
+static char *__exe_path(struct mm_struct *mm, char *buf, int buflen)
+{
+	char *path = NULL;
+
+	if (mm->exe_file) {
+		struct vfsmount *mnt;
+		struct dentry *dentry;
+
+		mnt = mntget(mm->exe_file->f_path.mnt);
+		dentry = dget(mm->exe_file->f_path.dentry);
+
+		if (mnt && dentry) {
+			struct path _p = {mnt, dentry};
+
+			path = d_path(&_p, buf, buflen);
+			dput(dentry);
+			mntput(mnt);
+		}
+	}
+	return path;
+}
+
+char *mm_path(struct mm_struct *mm, char *buf, int buflen)
+{
+	char *path;
+
+	down_read(&mm->mmap_sem);
+	path = __exe_path(mm, buf, buflen);
+	up_read(&mm->mmap_sem);
+	return path;
+}
diff --git a/security/hone/hone_mmutil.h b/security/hone/hone_mmutil.h
new file mode 100644
index 0000000..321e7e6
--- /dev/null
+++ b/security/hone/hone_mmutil.h
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ */
+
+#ifndef _MMUTIL_H
+#define _MMUTIL_H
+
+#include <linux/mm_types.h>
+
+char *mm_path(struct mm_struct *mm, char *buf, int buflen);
+char *mm_path_old(struct mm_struct *mm, char *buf, int buflen);
+int mm_argv(struct mm_struct *mm, char *buf, int buflen);
+
+#endif /* _MMUTIL_H */
diff --git a/security/hone/hone_notify.c b/security/hone/hone_notify.c
new file mode 100644
index 0000000..08c2f8f
--- /dev/null
+++ b/security/hone/hone_notify.c
@@ -0,0 +1,450 @@
+#include <linux/kernel.h>
+#include <linux/notifier.h>
+#include <linux/skbuff.h>
+#include <linux/cred.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/workqueue.h>
+#include <linux/uidgid.h>
+#include <net/sock.h>
+#include <linux/hone.h>
+
+#include "hone.h"
+
+/* Output */
+static RAW_NOTIFIER_HEAD(hone_notify_notifier_list);
+static DEFINE_RWLOCK(hone_notify_notifier_lock);
+
+/* Process list/Process lock. */
+static RAW_NOTIFIER_HEAD(hone_process_notifier_list);
+static DEFINE_RWLOCK(hone_process_notifier_lock);
+
+/* Socket list/Socket lock. */
+static RAW_NOTIFIER_HEAD(hone_socket_notifier_list);
+static DEFINE_RWLOCK(hone_socket_notifier_lock);
+
+/* Packet list/Packet lock. */
+static RAW_NOTIFIER_HEAD(hone_packet_notifier_list);
+static DEFINE_RWLOCK(hone_packet_notifier_lock);
+
+static struct kmem_cache *hone_cache;
+static struct kmem_cache *mmput_cache;
+static struct workqueue_struct *mmput_wq;
+struct delayed_mmput_struct {
+	struct work_struct ws;
+	struct mm_struct *mm;
+};
+
+static struct timespec start_time;
+static DEFINE_STATISTICS(hone_received);
+static DEFINE_STATISTICS(hone_dropped);
+
+#define copy_atomic64(dst, src) atomic64_set(&(dst), atomic64_read(&(src)))
+
+static void copy_statistics(const struct statistics *src,
+			struct statistics *dst)
+{
+	copy_atomic64(dst->process, src->process);
+	copy_atomic64(dst->socket, src->socket);
+	copy_atomic64(dst->packet, src->packet);
+}
+
+void get_hone_statistics(struct statistics *received,
+			struct statistics *dropped, struct timespec *ts)
+{
+	if (received)
+		copy_statistics(&hone_received, received);
+	if (dropped)
+		copy_statistics(&hone_dropped, dropped);
+	if (ts)
+		*ts = start_time;
+}
+
+#define notifier_call_chain_empty() \
+	(rcu_dereference(hone_notify_notifier_list.head) == NULL)
+
+static inline int hone_notifier_notify(struct hone_event *event)
+{
+	int result;
+	unsigned long flags;
+
+	read_lock_irqsave(&hone_notify_notifier_lock, flags);
+	result = raw_notifier_call_chain(&hone_notify_notifier_list, 0, event);
+	read_unlock_irqrestore(&hone_notify_notifier_lock, flags);
+	return result;
+}
+
+static void delayed_mmput(struct work_struct *work)
+{
+	struct delayed_mmput_struct *w = (struct delayed_mmput_struct *)work;
+
+	mmput(w->mm);
+	kmem_cache_free(mmput_cache, w);
+}
+
+static bool queue_mmput(struct mm_struct *mm)
+{
+	struct delayed_mmput_struct *delayed_mm =
+		kmem_cache_zalloc(mmput_cache, GFP_ATOMIC);
+
+	if (!delayed_mm)
+		return false;
+
+	delayed_mm->mm = mm;
+	INIT_WORK((struct work_struct *)delayed_mm,
+		delayed_mmput);
+
+	return queue_work(mmput_wq, (struct work_struct *)delayed_mm);
+}
+
+void free_hone_event(struct hone_event *event)
+{
+	if (event->type == HONE_PROCESS) {
+		if (event->process.mm) {
+			if (event->process.event == PROC_KTHD) {
+				kfree(event->process.comm);
+			} else {
+				if (unlikely(!queue_mmput(event->process.mm)))
+					BUG();
+			}
+			event->process.mm = NULL;
+		}
+	}
+	kmem_cache_free(hone_cache, event);
+}
+
+struct hone_event *alloc_hone_event(unsigned int type, gfp_t flags)
+{
+	struct hone_event *event;
+
+	event = kmem_cache_zalloc(hone_cache, flags);
+	if (!event)
+		return NULL;
+	event->type = type;
+	ktime_get_ts(&event->ts);
+	atomic_set(&event->users, 1);
+	return event;
+}
+
+struct hone_event *__alloc_process_event(
+	struct task_struct *task, int type, gfp_t flags)
+{
+	struct hone_event *event;
+
+	event = alloc_hone_event(HONE_PROCESS, flags);
+	if (event) {
+		struct process_event *pev = &event->process;
+		const struct cred *cred;
+
+		pev->event = (type != PROC_EXIT && task->flags & PF_KTHREAD) ?
+			PROC_KTHD : type;
+		if (unlikely(type == PROC_EXIT))
+			pev->retval = task->exit_code;
+		pev->pid = task->pid;
+		pev->ppid = task->real_parent->pid;
+		pev->tgid = task->tgid;
+		if (pev->event == PROC_KTHD) {
+			pev->comm = kstrndup(task->comm,
+					sizeof(task->comm), flags);
+			BUG_ON(unlikely(!pev->comm));
+		} else if (type == PROC_EXEC ||
+			(type == PROC_FORK && pev->ppid == 1)) {
+			pev->mm = get_task_mm(task);
+			BUG_ON(unlikely(!pev->mm));
+		}
+		pev->loginuid = __kuid_val(task->loginuid);
+		rcu_read_lock();
+		cred = __task_cred(task);
+		if (unlikely(!cred)) {
+			pev->uid = -1;
+			pev->euid = -1;
+		} else {
+			pev->uid = __kuid_val(cred->uid);
+			pev->euid = __kuid_val(cred->euid);
+		}
+		pev->gid = __kgid_val(cred->egid);
+		rcu_read_unlock();
+	}
+	return event;
+}
+
+int process_notifier_notify(unsigned long event, struct task_struct *task)
+{
+	int result;
+	unsigned long flags;
+
+	read_lock_irqsave(&hone_process_notifier_lock, flags);
+	result = raw_notifier_call_chain(&hone_process_notifier_list, event,
+					task);
+	read_unlock_irqrestore(&hone_process_notifier_lock, flags);
+	return result;
+}
+
+static int process_event_handler(struct notifier_block *nb,
+				 unsigned long val, void *v)
+{
+	struct hone_event *event;
+
+	if (notifier_call_chain_empty())
+		return 0;
+
+	event = __alloc_process_event(v, val, GFP_ATOMIC);
+	if (event) {
+		atomic64_inc(&hone_received.process);
+		hone_notifier_notify(event);
+		put_hone_event(event);
+	} else {
+		atomic64_inc(&hone_dropped.process);
+	}
+	return 0;
+}
+
+static struct notifier_block process_nb = {
+	.notifier_call = process_event_handler,
+};
+
+/* Process sockets below here. */
+struct hone_event *__alloc_socket_event(unsigned long sock, int type,
+					struct task_struct *task, gfp_t flags)
+{
+	struct hone_event *event;
+
+	event = alloc_hone_event(HONE_SOCKET, flags);
+	if (event) {
+		struct socket_event *sockev = &event->socket;
+		const struct cred *cred;
+
+		/* Store pid with the socket */
+		((struct sock *)sock)->sk_protinfo =
+			(void *)(unsigned long)task->pid;
+		sockev->sock = sock;
+		sockev->event = type;
+		sockev->pid = task->pid;
+		sockev->ppid = task->real_parent->pid;
+		sockev->tgid = task->tgid;
+		rcu_read_lock();
+		cred = __task_cred(task);
+		if (unlikely(!cred)) {
+			sockev->uid = -1;
+			sockev->gid = -1;
+		} else {
+			sockev->uid = __kuid_val(cred->euid);
+			sockev->gid = __kgid_val(cred->egid);
+		}
+		rcu_read_unlock();
+	}
+	return event;
+}
+
+static int socket_event_handler(struct notifier_block *nb,
+				unsigned long val, void *v)
+{
+	struct hone_event *event;
+
+	if (notifier_call_chain_empty())
+		return 0;
+	event = __alloc_socket_event((unsigned long) v, val, current,
+				GFP_ATOMIC);
+	if (event) {
+		atomic64_inc(&hone_received.socket);
+		hone_notifier_notify(event);
+		put_hone_event(event);
+	} else {
+		atomic64_inc(&hone_dropped.socket);
+	}
+	return 0;
+}
+
+static struct notifier_block socket_nb = {
+	.notifier_call = socket_event_handler,
+};
+
+int sock_notifier_register(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_socket_notifier_lock, flags);
+	result = raw_notifier_chain_register(&hone_socket_notifier_list, nb);
+	write_unlock_irqrestore(&hone_socket_notifier_lock, flags);
+	return result;
+}
+
+int sock_notifier_unregister(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_socket_notifier_lock, flags);
+	result = raw_notifier_chain_unregister(&hone_socket_notifier_list, nb);
+	write_unlock_irqrestore(&hone_socket_notifier_lock, flags);
+	return result;
+}
+
+inline int sock_notifier_notify(unsigned long event, struct sock *sk)
+{
+	int result;
+	unsigned long flags;
+
+	read_lock_irqsave(&hone_socket_notifier_lock, flags);
+	result = raw_notifier_call_chain(&hone_socket_notifier_list, event, sk);
+	read_unlock_irqrestore(&hone_socket_notifier_lock, flags);
+	return result;
+}
+
+static int packet_event_handler(struct notifier_block *nb,
+				unsigned long val, void *v)
+{
+	struct hone_event *event;
+
+	if (notifier_call_chain_empty())
+		return 0;
+
+	event = alloc_hone_event(HONE_PACKET, GFP_ATOMIC);
+	if (event) {
+		struct packet_args *args = (typeof(args)) v;
+
+		event->packet.sock = (unsigned long) args->sk;
+		event->packet.sk = args->sk;
+		event->packet.pid =
+			(unsigned long)(args->sk ? args->sk->sk_protinfo : 0);
+		event->packet.skb = skb_clone(args->skb, GFP_ATOMIC);
+		event->packet.dir = (val == PKTNOT_PACKET_IN);
+		atomic64_inc(&hone_received.packet);
+		hone_notifier_notify(event);
+		put_hone_event(event);
+	} else {
+		atomic64_inc(&hone_dropped.packet);
+	}
+	return 0;
+}
+
+static struct notifier_block packet_nb = {
+	.notifier_call = packet_event_handler,
+};
+
+int packet_notifier_register(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_packet_notifier_lock, flags);
+	result = raw_notifier_chain_register(&hone_packet_notifier_list, nb);
+	write_unlock_irqrestore(&hone_packet_notifier_lock, flags);
+	return result;
+}
+
+int packet_notifier_unregister(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_packet_notifier_lock, flags);
+	result = raw_notifier_chain_unregister(&hone_packet_notifier_list, nb);
+	write_unlock_irqrestore(&hone_packet_notifier_lock, flags);
+	return result;
+}
+
+int packet_notifier_notify(
+	unsigned long event, struct packet_args *pargs)
+{
+	int result;
+	unsigned long flags;
+
+	read_lock_irqsave(&hone_packet_notifier_lock, flags);
+	result = raw_notifier_call_chain(&hone_packet_notifier_list,
+					event, pargs);
+	read_unlock_irqrestore(&hone_packet_notifier_lock, flags);
+	return result;
+}
+
+void register_notifiers(void)
+{
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_process_notifier_lock, flags);
+	/* TODO(pmoody): check return values. */
+	raw_notifier_chain_register(&hone_process_notifier_list,
+				&process_nb);
+	raw_notifier_chain_register(&hone_socket_notifier_list,
+				&socket_nb);
+	raw_notifier_chain_register(&hone_packet_notifier_list,
+				&packet_nb);
+	write_unlock_irqrestore(&hone_process_notifier_lock, flags);
+}
+
+void unregister_notifiers(void)
+{
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_process_notifier_lock, flags);
+	/* TODO(pmoody): check return values. */
+	raw_notifier_chain_unregister(&hone_process_notifier_list,
+				&process_nb);
+	raw_notifier_chain_unregister(&hone_socket_notifier_list,
+				&socket_nb);
+	raw_notifier_chain_unregister(&hone_packet_notifier_list,
+				&packet_nb);
+	write_unlock_irqrestore(&hone_process_notifier_lock, flags);
+}
+
+int hone_notifier_register(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_notify_notifier_lock, flags);
+	if (notifier_call_chain_empty())
+		register_notifiers();
+	result = raw_notifier_chain_register(&hone_notify_notifier_list, nb);
+	write_unlock_irqrestore(&hone_notify_notifier_lock, flags);
+	return result;
+}
+
+int hone_notifier_unregister(struct notifier_block *nb)
+{
+	int result;
+	unsigned long flags;
+
+	write_lock_irqsave(&hone_notify_notifier_lock, flags);
+	result = raw_notifier_chain_unregister(&hone_notify_notifier_list, nb);
+	if (notifier_call_chain_empty())
+		unregister_notifiers();
+	write_unlock_irqrestore(&hone_notify_notifier_lock, flags);
+	return result;
+}
+
+int __init hone_notify_init(void)
+{
+	int err = -ENOMEM;
+
+	hone_cache = kmem_cache_create(
+		"hone_event", sizeof(struct hone_event), 0, 0, NULL);
+	if (!hone_cache) {
+		pr_err("kmem_cache_create() failed\n");
+		goto out_hone_cache;
+	}
+
+	mmput_cache = kmem_cache_create(
+		"hone_delayed_mmput", sizeof(struct delayed_mmput_struct),
+		0, 0, NULL);
+	if (!mmput_cache) {
+		pr_err("kmem_cache_create() failed on delayed_mm_cache\n");
+		goto out_mmput_cache;
+	}
+
+	mmput_wq = create_workqueue("hone_mmput");
+	if (!mmput_wq) {
+		err = -1;
+		goto out_workqueue;
+	}
+
+	return 0;
+
+out_workqueue:
+	kmem_cache_destroy(mmput_cache);
+out_mmput_cache:
+	kmem_cache_destroy(hone_cache);
+out_hone_cache:
+	return err;
+}
diff --git a/security/hone/hone_pcapng.c b/security/hone/hone_pcapng.c
new file mode 100644
index 0000000..0c5347c
--- /dev/null
+++ b/security/hone/hone_pcapng.c
@@ -0,0 +1,596 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ */
+
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/ktime.h>
+#include <linux/time.h>
+#include <linux/types.h>
+#include <linux/rwsem.h>
+#include <linux/utsname.h>
+#include <linux/skbuff.h>
+#include <linux/hone.h>
+
+#include "hone.h"
+#include "hone_mmutil.h"
+
+#define PADLEN(x) (((x) & 0x3) ? 4 - ((x) & 3) : 0)
+#define OPT_SIZE(x) (((x) & 0x3) ? ((((x) >> 2) + 1) << 2) : x)
+#define block_set(BUF, TYPE, VAL) \
+	({ *((TYPE*) (BUF)) = (VAL); sizeof(TYPE); })
+
+static unsigned int block_opt_ptr(char *buf,
+		uint16_t code, const void *ptr, unsigned int length)
+{
+	char *pos = buf;
+	unsigned int padlen = PADLEN(length);
+
+	pos += block_set(pos, uint16_t, code);
+	pos += block_set(pos, uint16_t, length);
+	if (ptr)
+		memcpy(pos, ptr, length);
+	pos += length;
+	memset(pos, 0, padlen);
+	pos += padlen;
+	return (unsigned int) (pos - buf);
+}
+
+#define block_opt_t(BUF, CODE, TYPE, VAL) ({				\
+			TYPE _value = (VAL);				\
+			unsigned int _length =				\
+				block_opt_ptr(BUF, CODE, &_value,	\
+					sizeof(_value));		\
+			_length; })
+
+#define block_opt(BUF, CODE, VAL) block_opt_t(BUF, CODE, typeof(VAL), VAL)
+#define block_end_opt(BUF) block_opt_ptr(BUF, 0, NULL, 0)
+
+struct timestamp {
+	uint32_t ts_high;
+	uint32_t ts_low;
+};
+
+static void timespec_to_tstamp(struct timestamp *tstamp, struct timespec *ts)
+{
+	uint64_t val = (((uint64_t) ts->tv_sec) * 1000000LL) +
+		ts->tv_nsec / 1000;
+	tstamp->ts_high = val >> 32;
+	tstamp->ts_low = val & 0xFFFFFFFF;
+}
+
+/* Section Header Block {{{
+  0                   1                   2                   3
+   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                   Block Type = 0x0A0D0D0A                     |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |                      Byte-Order Magic                         |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |          Major Version        |         Minor Version         |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 |                                                               |
+   |                          Section Length                       |
+   |                                                               |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+24 /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static unsigned int format_sechdr_block(const struct device_info *devinfo,
+		char *buf, unsigned int buflen)
+{
+	static const char *user_app = "Hone ";
+	char *pos = buf;
+	unsigned int *length_top, *length_end;
+	int n;
+
+	/* Be sure to update this value if fields are added below. */
+#define SECHDR_BLOCK_MIN_LEN 56
+	if (buflen < SECHDR_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_SECTION_HDR_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t, 0x1A2B3C4D);
+	pos += block_set(pos, uint16_t, 1);
+	pos += block_set(pos, uint16_t, 0);
+	pos += block_set(pos, uint64_t, -1);
+
+	n = buflen - (pos - buf) - 16;
+	if (devinfo->host_id && n > 0) {
+		snprintf(pos + 4, n, "%c%s", 0, devinfo->host_id);
+		pos += block_opt_ptr(pos, 257, NULL, strlen(pos + 5) + 1);
+	} else if (devinfo->host_guid_is_set) {
+		memcpy(pos + 4, "\x01\x00\x00\x00", 4);
+		memcpy(pos + 8, &devinfo->host_guid,
+			sizeof(devinfo->host_guid));
+		pos += block_opt_ptr(pos, 257, NULL, 20);
+	}
+	n = buflen - (pos - buf) - 16;
+	if (n > 0) {
+		struct new_utsname *uname;
+
+		down_read(&uts_sem);
+		uname = utsname();
+		snprintf(pos + 4, n, "%s %s %s %s %s",
+				uname->sysname, uname->nodename, uname->release,
+				uname->version, uname->machine);
+		up_read(&uts_sem);
+		pos[n] = '\0';
+		pos += block_opt_ptr(pos, 3, NULL, strlen(pos + 4));
+	}
+	n = buflen - (pos - buf) - 16;
+	if (n > 0)
+		pos += block_opt_ptr(pos, 4, user_app,
+				min(n, (typeof(n)) strlen(user_app)));
+	n = buflen - (pos - buf) - 16;
+	if (devinfo->comment && n > 0) {
+		unsigned int i, j;
+
+		for (i = 0, j = 4; devinfo->comment[i] && j < n; i++, j++) {
+			if (devinfo->comment[i] == '\\' &&
+				(!strncmp(devinfo->comment + i + 1, "040", 3) ||
+					!strncmp(devinfo->comment + i + 1, "x20", 3))) {
+				pos[j] = ' ';
+				i += 3;
+			} else
+				pos[j] = devinfo->comment[i];
+		}
+		n = j - 4;
+		if (n)
+			pos += block_opt_ptr(pos, 1, NULL, n);
+	}
+	pos += block_end_opt(pos);
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+/* Interface Description Block {{{
+    0                   1                   2                   3
+    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                    Block Type = 0x00000001                    |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |           LinkType            |           Reserved            |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |                            SnapLen                            |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static unsigned int format_ifdesc_block(const struct reader_info *info,
+		char *buf, int buflen)
+{
+	static const char *if_desc = "Hone Capture Pseudo-device";
+	char *pos = buf;
+	unsigned int *length_top, *length_end;
+
+	/* Be sure to update this value if fields are added below. */
+#define IFDESC_BLOCK_MIN_LEN 56
+	if (buflen < IFDESC_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_IF_DESC_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint16_t, 101);
+	pos += block_set(pos, uint16_t, 0);
+	pos += block_set(pos, uint32_t, info->snaplen);
+	pos += block_opt_ptr(pos, 3, if_desc,
+			strlen(if_desc));
+	pos += block_end_opt(pos);
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+/* Interface Statistics Block {{{
+    0                   1                   2                   3
+    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                   Block Type = 0x00000005                     |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |                         Interface ID                          |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |                        Timestamp (High)                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 |                        Timestamp (Low)                        |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+20 /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static unsigned int format_ifstats_block(const struct reader_info *info,
+		char *buf, int buflen)
+{
+	char *pos = buf;
+	unsigned int *length_top, *length_end;
+	struct timespec ts;
+	struct timestamp tstamp, start_time;
+	struct statistics received, dropped;
+
+	get_hone_statistics(&received, &dropped, &ts);
+	set_normalized_timespec(&ts, info->boot_time.tv_sec + ts.tv_sec,
+			info->boot_time.tv_nsec + ts.tv_nsec);
+	timespec_to_tstamp(&start_time, &ts);
+	ktime_get_ts(&ts);
+	set_normalized_timespec(&ts, info->boot_time.tv_sec + ts.tv_sec,
+			info->boot_time.tv_nsec + ts.tv_nsec);
+	timespec_to_tstamp(&tstamp, &ts);
+
+	/* Be sure to update this value if fields are added below. */
+#define IFSTATS_BLOCK_MIN_LEN 196
+	if (buflen < IFSTATS_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_IF_STATS_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, struct timestamp, tstamp);
+	pos += block_opt_t(pos, 2, struct timestamp, start_time);
+	pos += block_opt_t(pos, 4, uint64_t, atomic64_read(&received.packet));
+	pos += block_opt_t(pos, 5, uint64_t, atomic64_read(&dropped.packet));
+	pos += block_opt_t(pos, 6, uint64_t, atomic64_read(&info->filtered));
+	pos += block_opt_t(pos, 7, uint64_t, atomic64_read(&info->dropped.packet));
+	pos += block_opt_t(pos, 8, uint64_t, atomic64_read(&info->delivered.packet));
+	pos += block_opt_t(pos, 257, uint64_t, atomic64_read(&received.process));
+	pos += block_opt_t(pos, 258, uint64_t, atomic64_read(&dropped.process));
+	pos += block_opt_t(pos, 259, uint64_t, atomic64_read(&info->dropped.process));
+	pos += block_opt_t(pos, 260, uint64_t, atomic64_read(&info->delivered.process));
+	pos += block_opt_t(pos, 261, uint64_t, atomic64_read(&received.socket));
+	pos += block_opt_t(pos, 262, uint64_t, atomic64_read(&dropped.socket));
+	pos += block_opt_t(pos, 263, uint64_t, atomic64_read(&info->dropped.socket));
+	pos += block_opt_t(pos, 264, uint64_t, atomic64_read(&info->delivered.socket));
+	pos += block_end_opt(pos);
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+static inline unsigned int maxoptlen(int buflen, unsigned int length)
+{
+	unsigned int alignlen = ((buflen - 16) >> 2) << 2;
+
+	if (unlikely(buflen < 0))
+		return 0;
+	return alignlen < length ? alignlen : length;
+}
+
+/* Process Event Block {{{
+    0                   1                   2                   3
+    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                    Block Type = 0x00000101                    |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |                          Process ID                           |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |                        Timestamp (High)                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 |                        Timestamp (Low)                        |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+20 /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static size_t format_process_block(struct process_event *event,
+		struct timestamp *tstamp, char *buf, size_t buflen)
+{
+	static const uint32_t event_map[] = {0, 1, 0, -1, 2};
+	char *pos = buf;
+	unsigned int *length_top, *length_end;
+
+	/* Be sure to update this value if fields are added below. */
+#define PROCESS_BLOCK_MIN_LEN 56
+	if (buflen < PROCESS_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_PROCESS_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t, event->tgid);
+	pos += block_set(pos, struct timestamp, *tstamp);
+	if (event->event != PROC_EXEC)
+		pos += block_opt_t(pos, 2, uint32_t, event_map[event->event]);
+	pos += block_opt_t(pos, 5, uint32_t, event->ppid);
+	pos += block_opt_t(pos, 6, uint32_t, event->uid);
+	pos += block_opt_t(pos, 8, uint32_t, event->euid);
+	pos += block_opt_t(pos, 9, uint32_t, event->loginuid);
+	pos += block_opt_t(pos, 7, uint32_t, event->gid);
+	if (event->mm) {
+		char *tmp, *ptr;
+		unsigned int n, length;
+
+		ptr = pos + 4;
+		length = buflen - (pos - buf) - 16;
+		if (event->event == PROC_KTHD) {
+			n = strlen(event->comm);
+			length = maxoptlen(length, n + 2);
+			if (length) {
+				ptr[0] = '[';
+				if (length > 1)
+					memcpy(ptr + 1, event->comm,
+						length - 1);
+				if (length > n + 1)
+					ptr[length - 1] = ']';
+				pos += block_opt_ptr(pos, 3, NULL, length);
+			}
+		} else {
+			if (length > 0) {
+				tmp = mm_path(event->mm, ptr, length);
+				if (tmp) {
+					length = maxoptlen(length, strlen(tmp));
+					if (length) {
+						memmove(ptr, tmp, length);
+						pos += block_opt_ptr(pos, 3,
+								NULL, length);
+					}
+				}
+			}
+			ptr = pos + 4;
+			length = buflen - (pos - buf) - 16;
+			if (length > 0) {
+				n = mm_argv(event->mm, ptr, length);
+				if (n)
+					pos += block_opt_ptr(pos, 4, NULL,
+							maxoptlen(length, n));
+			}
+		}
+	}
+	pos += block_end_opt(pos);
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+/* Connection Event Block {{{
+    0                   1                   2                   3
+    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                    Block Type = 0x00000102                    |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |                        Connection ID                          |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |                          Process ID                           |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 |                        Timestamp (High)                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+20 |                        Timestamp (Low)                        |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+24 /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static size_t format_connection_block(struct socket_event *event,
+		struct timestamp *tstamp, char *buf, size_t buflen)
+{
+	char *pos = buf;
+	unsigned int *length_top, *length_end;
+
+	/* Be sure to update this value if fields are added below. */
+#define CONNECTION_BLOCK_MIN_LEN 40
+	if (buflen < CONNECTION_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_CONNECTION_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t,
+			event->sock & 0xFFFFFFFF);
+	pos += block_set(pos, uint32_t, event->tgid);
+	pos += block_set(pos, struct timestamp, *tstamp);
+	if (event->event) {
+		pos += block_opt_t(pos, 2, uint32_t, -1);
+		pos += block_end_opt(pos);
+	}
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+/* Enhanced Packet Block {{{
+   0                   1                   2                   3
+   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+   +---------------------------------------------------------------+
+ 0 |                    Block Type = 0x00000006                    |
+   +---------------------------------------------------------------+
+ 4 |                      Block Total Length                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ 8 |                         Interface ID                          |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+12 |                        Timestamp (High)                       |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+16 |                        Timestamp (Low)                        |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+20 |                         Captured Len                          |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+24 |                          Packet Len                           |
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+28 /                                                               /
+   /                          Packet Data                          /
+   /           ( variable length, aligned to 32 bits )             /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   /                                                               /
+   /                      Options (variable)                       /
+   /                                                               /
+   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+   |                      Block Total Length                       |
+   +---------------------------------------------------------------+
+}}} */
+static size_t format_packet_block(struct packet_event *event,
+				unsigned int snaplen,
+				struct timestamp *tstamp,
+				char *buf, size_t buflen)
+{
+	char *pos = buf;
+	int offset;
+	unsigned int *length_top, *length_end, *length_cap, offlen;
+	struct sk_buff *skb = event->skb;
+
+	/* Be sure to update this value if fields are added below. */
+#define PACKET_BLOCK_MIN_LEN 52
+	if (buflen < PACKET_BLOCK_MIN_LEN)
+		return 0;
+	pos += block_set(pos, uint32_t, HONE_PACKET_BLOCK);
+	length_top = (typeof(length_top)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, struct timestamp, *tstamp);
+	length_cap = (typeof(length_cap)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	pos += block_set(pos, uint32_t, event->len);
+
+	/* packet data */
+	offset = skb_network_header(skb) - skb->data;
+	offlen = snaplen ? min(skb->len - offset, snaplen) : skb->len - offset;
+	*length_cap = maxoptlen(buflen - (pos - buf), offlen);
+	if (*length_cap) {
+		unsigned int n = *length_cap & 3 ? 4 - (*length_cap & 3) : 0;
+
+		if (skb_copy_bits(skb, offset, pos, *length_cap))
+			BUG();
+		pos += *length_cap;
+		memset(pos, 0, n);
+		pos += n;
+	}
+
+	if (event->sock)
+		pos += block_opt_t(pos, 257, uint32_t,
+				event->sock & 0xFFFFFFFF);
+	if (event->pid)
+		pos += block_opt_t(pos, 258, uint32_t, event->pid);
+	pos += block_opt_t(pos, 2, uint32_t, event->dir ? 1 : 2);
+	pos += block_end_opt(pos);
+	length_end = (typeof(length_end)) pos;
+	pos += block_set(pos, uint32_t, 0);
+	*length_top = *length_end = (unsigned int) (pos - buf);
+	return *length_top;
+}
+
+static void normalize_ts(struct timestamp *tstamp,
+			const struct timespec *boot_time,
+			const struct timespec *event_time)
+{
+	struct timespec ts;
+
+	/* The following is used instead of timespec_add()
+	   because it doesn't exist in older kernel versions. */
+	set_normalized_timespec(&ts, boot_time->tv_sec + event_time->tv_sec,
+			boot_time->tv_nsec + event_time->tv_nsec);
+	timespec_to_tstamp(tstamp, &ts);
+}
+
+unsigned int format_as_pcapng(
+	const struct device_info *devinfo, const struct reader_info *info,
+	struct hone_event *event, char *buf, unsigned int buflen)
+{
+	unsigned int n = 0;
+	struct timestamp tstamp;
+
+	switch (event->type) {
+	case HONE_PACKET:
+		normalize_ts(&tstamp, &info->boot_time, &event->ts);
+		n = format_packet_block(
+			&event->packet, info->snaplen, &tstamp, buf, buflen);
+		break;
+	case HONE_PROCESS:
+		normalize_ts(&tstamp, &info->boot_time, &event->ts);
+		n = format_process_block(&event->process, &tstamp, buf, buflen);
+		break;
+	case HONE_SOCKET:
+		normalize_ts(&tstamp, &info->boot_time, &event->ts);
+		n = format_connection_block(&event->socket, &tstamp,
+					buf, buflen);
+		break;
+	case HONE_USER_HEAD:
+		n = format_sechdr_block(devinfo, buf, buflen);
+		n += format_ifdesc_block(info, buf + n, buflen - n);
+		break;
+	case HONE_USER_TAIL:
+		n = format_ifstats_block(info, buf + n, buflen - n);
+		break;
+	}
+
+	return n;
+}
+
+int parse_guid(struct guid_struct *guid, const char *input)
+{
+	int i, val;
+	const char *pos = input;
+	char *buf = (typeof(buf)) guid;
+
+	if (*pos == '{')
+		pos++;
+	for (i = 0; *pos && i < 32; pos++) {
+		if (*pos == '-') {
+			if (pos == input)
+				return -1;
+			continue;
+		}
+		if (*pos >= '0' && *pos <= '9')
+			val = *pos - '0';
+		else if (*pos >= 'a' && *pos <= 'f')
+			val = *pos - 'W';
+		else if (*pos >= 'A' && *pos <= 'F')
+			val = *pos - '7';
+		else
+			return -1;
+		if (i % 2) {
+			buf[i / 2] += val;
+			i++;
+		} else {
+			buf[i / 2] = val << 4;
+			i++;
+		}
+	}
+	if (i < 32)
+		return -1;
+	if (*input == '{') {
+		if (*pos != '}')
+			return -1;
+		pos++;
+	}
+	if (*pos)
+		return -1;
+	guid->data1 = ntohl(guid->data1);
+	guid->data2 = ntohs(guid->data2);
+	guid->data3 = ntohs(guid->data3);
+	return 0;
+}
diff --git a/security/hone/hone_pcapng.h b/security/hone/hone_pcapng.h
new file mode 100644
index 0000000..2987831c
--- /dev/null
+++ b/security/hone/hone_pcapng.h
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ */
+
+#ifndef _PCAPNG_H
+#define _PCAPNG_H
+
+#include <linux/atomic.h>
+#include <linux/time.h>
+
+#define HONE_USER_HEAD (HONE_USER | 1)
+#define HONE_USER_TAIL (HONE_USER | 2)
+
+#define GUID_FMT "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x"
+#define GUID_TUPLE(G) (G)->data1, (G)->data2, (G)->data3, \
+		(G)->data4[0], (G)->data4[1], (G)->data4[2], (G)->data4[3], \
+		(G)->data4[4], (G)->data4[5], (G)->data4[6], (G)->data4[7]
+
+unsigned int format_as_pcapng(
+		const struct device_info *devinfo, const struct reader_info *info,
+		struct hone_event *event, char *buf, unsigned int buflen);
+int parse_guid(struct guid_struct *guid, const char *input);
+
+#endif /* _PCAPNG_H */
diff --git a/security/hone/hone_ringbuf.c b/security/hone/hone_ringbuf.c
new file mode 100644
index 0000000..14a38f8
--- /dev/null
+++ b/security/hone/hone_ringbuf.c
@@ -0,0 +1,51 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ *
+ * Implementation of lock-free ring buffer.
+ */
+
+#include <linux/atomic.h>
+
+#include "hone_ringbuf.h"
+
+int ring_append(struct ring_buf *ring, void *elem)
+{
+	unsigned int back;
+
+	for (;;) {
+		back = ring_back(ring);
+		if (back - ring_front(ring) >= ring->length)
+			return -1;
+		if ((unsigned int)
+			atomic_cmpxchg(&ring->back, back, back + 1) == back)
+			break;
+	}
+	ring->data[back % ring->length] = elem;
+	return 0;
+}
+
+void *ring_pop(struct ring_buf *ring)
+{
+	void *elem, **slot;
+	unsigned int front;
+
+	for (;;) {
+		front = ring_front(ring);
+		if (front == ring_back(ring))
+			return NULL;
+		slot = ring->data + (front % ring->length);
+		elem = *slot;
+		if (!elem)
+			continue;
+		if (cmpxchg(slot, elem, NULL) == elem)
+			break;
+	}
+	atomic_inc(&ring->front);
+	return elem;
+}
diff --git a/security/hone/hone_ringbuf.h b/security/hone/hone_ringbuf.h
new file mode 100644
index 0000000..a12311c
--- /dev/null
+++ b/security/hone/hone_ringbuf.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ *
+ * Implementation of lock-free ring buffer.
+ */
+
+#ifndef _RINGBUF_H
+#define _RINGBUF_H
+
+#include <linux/types.h>
+
+struct ring_buf {
+	atomic_t front;
+	atomic_t back;
+	unsigned int length;
+	unsigned int pageorder;
+	void **data;
+};
+
+#define ring_front(ring) ((unsigned int) atomic_read(&(ring)->front))
+#define ring_back(ring) ((unsigned int) atomic_read(&(ring)->back))
+#define ring_used(ring) (ring_back(ring) - ring_front(ring))
+#define ring_is_empty(ring) (ring_front(ring) == ring_back(ring))
+
+int ring_append(struct ring_buf *ring, void *elem);
+void *ring_pop(struct ring_buf *ring);
+
+#endif /* _RINGBUF_H */
diff --git a/security/hone/hone_socket_lookup.c b/security/hone/hone_socket_lookup.c
new file mode 100644
index 0000000..6b0f355
--- /dev/null
+++ b/security/hone/hone_socket_lookup.c
@@ -0,0 +1,264 @@
+/*
+ * Modifications copyright (C) 2011 Battelle Memorial Institute
+ *
+ * Licensed under the GNU General Public License Version 2.
+ * See LICENSE for the full text of the license.
+ * See DISCLAIMER for additional disclaimers.
+ *
+ * Author: Brandon Carpenter
+ */
+
+/*
+ * The following code was conveniently borrowed form the xt_socket
+ * iptables module and used with minor modifications.  Thanks guys!
+ *
+ * Transparent proxy support for Linux/iptables
+ *
+ * Copyright (C) 2007-2008 BalaBit IT Ltd.
+ * Author: Krisztian Kovacs
+ */
+
+#include <linux/version.h>
+#include <linux/skbuff.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/icmp.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+
+#include "hone.h"
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <net/ipv6.h>
+#include <net/inet6_hashtables.h>
+#endif
+
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#define XT_SOCKET_HAVE_CONNTRACK 1
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
+static int extract_icmp4_fields(const struct sk_buff *skb, u8 *protocol,
+		__be32 *raddr, __be32 *laddr, __be16 *rport, __be16 *lport)
+{
+	unsigned int outside_hdrlen = ip_hdrlen(skb);
+	struct iphdr *inside_iph, _inside_iph;
+	struct icmphdr *icmph, _icmph;
+	__be16 *ports, _ports[2];
+
+	icmph = skb_header_pointer(skb, outside_hdrlen,
+				   sizeof(_icmph), &_icmph);
+	if (icmph == NULL)
+		return 1;
+
+	switch (icmph->type) {
+	case ICMP_DEST_UNREACH:
+	case ICMP_SOURCE_QUENCH:
+	case ICMP_REDIRECT:
+	case ICMP_TIME_EXCEEDED:
+	case ICMP_PARAMETERPROB:
+		break;
+	default:
+		return 1;
+	}
+
+	inside_iph = skb_header_pointer(skb, outside_hdrlen +
+					sizeof(struct icmphdr),
+					sizeof(_inside_iph), &_inside_iph);
+	if (inside_iph == NULL)
+		return 1;
+
+	if (inside_iph->protocol != IPPROTO_TCP &&
+	    inside_iph->protocol != IPPROTO_UDP)
+		return 1;
+
+	ports = skb_header_pointer(skb, outside_hdrlen +
+				   sizeof(struct icmphdr) +
+				   (inside_iph->ihl << 2),
+				   sizeof(_ports), &_ports);
+	if (ports == NULL)
+		return 1;
+
+	/* the inside IP packet is the one quoted from our side, thus
+	 * its saddr is the local address */
+	*protocol = inside_iph->protocol;
+	*laddr = inside_iph->saddr;
+	*lport = ports[0];
+	*raddr = inside_iph->daddr;
+	*rport = ports[1];
+
+	return 0;
+}
+
+struct sock *lookup_v4_sock(const struct sk_buff *skb,
+		const struct net_device *indev)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	struct sock *sk;
+	__be32 daddr = 0, saddr = 0;
+	__be16 dport = 0, sport = 0;
+	u8 protocol = 0;
+
+	if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
+		struct udphdr _hdr, *hp;
+
+		hp = skb_header_pointer(skb, ip_hdrlen(skb),
+					sizeof(_hdr), &_hdr);
+		if (!hp)
+			return NULL;
+
+		protocol = iph->protocol;
+		saddr = iph->saddr;
+		sport = hp->source;
+		daddr = iph->daddr;
+		dport = hp->dest;
+
+	} else if (iph->protocol == IPPROTO_ICMP) {
+		if (extract_icmp4_fields(skb, &protocol, &saddr, &daddr,
+					&sport, &dport))
+			return NULL;
+	} else {
+		return NULL;
+	}
+
+#ifdef XT_SOCKET_HAVE_CONNTRACK
+	/* Do the lookup with the original socket address in case this is a
+	 * reply packet of an established SNAT-ted connection. */
+	{
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn const *ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct && !nf_ct_is_untracked(ct) &&
+			((iph->protocol != IPPROTO_ICMP &&
+				ctinfo == IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
+				(iph->protocol == IPPROTO_ICMP &&
+					ctinfo == IP_CT_IS_REPLY + IP_CT_RELATED)) &&
+			(ct->status & IPS_SRC_NAT_DONE)) {
+
+			daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+			dport = (iph->protocol == IPPROTO_TCP) ?
+				ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.tcp.port :
+				ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
+		}
+	}
+#endif
+
+	if (protocol == IPPROTO_TCP)
+		sk = __inet_lookup(dev_net(skb->dev), &tcp_hashinfo,
+				saddr, sport, daddr, dport, indev->ifindex);
+	else
+		sk = udp4_lib_lookup(dev_net(skb->dev),
+				saddr, sport, daddr, dport, indev->ifindex);
+	if (!sk)
+		return NULL;
+
+	/* Ignore sockets listening on INADDR_ANY */
+	if (sk->sk_state != TCP_TIME_WAIT && inet_sk(sk)->inet_rcv_saddr == 0) {
+		put_sock(sk);
+		return NULL;
+	}
+	return sk;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int extract_icmp6_fields(const struct sk_buff *skb,
+				unsigned int outside_hdrlen, int *protocol,
+				struct in6_addr **raddr,
+				struct in6_addr **laddr, __be16 *rport,
+				__be16 *lport)
+{
+	struct ipv6hdr *inside_iph, _inside_iph;
+	struct icmp6hdr *icmph, _icmph;
+	__be16 *ports, _ports[2], _ignore;
+	u8 inside_nexthdr;
+	int inside_hdrlen;
+
+	icmph = skb_header_pointer(skb, outside_hdrlen, sizeof(_icmph),
+				&_icmph);
+	if (!icmph)
+		return 1;
+	if (icmph->icmp6_type & ICMPV6_INFOMSG_MASK)
+		return 1;
+
+	inside_iph = skb_header_pointer(
+		skb, outside_hdrlen + sizeof(_icmph), sizeof(_inside_iph),
+		&_inside_iph);
+	if (!inside_iph)
+		return 1;
+
+	inside_nexthdr = inside_iph->nexthdr;
+	inside_hdrlen = ipv6_skip_exthdr(
+		skb, outside_hdrlen + sizeof(_icmph) + sizeof(_inside_iph),
+		&inside_nexthdr, &_ignore);
+	if (inside_hdrlen < 0)
+		/* hjm: Packet has no/incomplete transport layer headers. */
+		return 1;
+	if (inside_nexthdr != IPPROTO_TCP && inside_nexthdr != IPPROTO_UDP)
+		return 1;
+
+	ports = skb_header_pointer(skb, inside_hdrlen, sizeof(_ports), &_ports);
+	if (!ports)
+		return 1;
+
+	/* the inside IP packet is the one quoted from our side, thus
+	 * its saddr is the local address */
+	*protocol = inside_nexthdr;
+	*laddr = &inside_iph->saddr;
+	*lport = ports[0];
+	*raddr = &inside_iph->daddr;
+	*rport = ports[1];
+
+	return 0;
+}
+
+struct sock *lookup_v6_sock(const struct sk_buff *skb,
+			const struct net_device *indev)
+{
+	struct sock *sk;
+	struct in6_addr *daddr, *saddr;
+	__be16 dport, sport;
+	int thoff = 0, tproto;
+
+	tproto = ipv6_find_hdr(skb, &thoff, -1, NULL, NULL);
+	if (tproto < 0)
+		/* unable to find transport header in IPv6 packet */
+		return NULL;
+
+	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {
+		struct udphdr _hdr, *hp;
+		struct ipv6hdr *iph;
+
+		hp = skb_header_pointer(skb, thoff, sizeof(_hdr), &_hdr);
+		if (!hp)
+			return NULL;
+
+		iph = ipv6_hdr(skb);
+		saddr = &iph->saddr;
+		sport = hp->source;
+		daddr = &iph->daddr;
+		dport = hp->dest;
+	} else if (tproto == IPPROTO_ICMPV6) {
+		if (extract_icmp6_fields(skb, thoff, &tproto,
+					&saddr, &daddr, &sport, &dport))
+			return NULL;
+	} else {
+		return NULL;
+	}
+
+	if (tproto == IPPROTO_TCP)
+		sk = inet6_lookup(dev_net(skb->dev), &tcp_hashinfo,
+				saddr, sport, daddr, dport, indev->ifindex);
+	else
+		sk = __udp6_lib_lookup(dev_net(skb->dev),
+				saddr, sport, daddr, dport, indev->ifindex,
+				&udp_table);
+
+	/* Ignore sockets listening on INADDR_ANY */
+	if (sk && sk->sk_state != TCP_TIME_WAIT && !inet_sk(sk)->inet_rcv_saddr) {
+		put_sock(sk);
+		return NULL;
+	}
+	/* TODO(pmoody): add pid information here. */
+	return sk;
+}
+#endif
-- 
2.0.0.526.g5318336

