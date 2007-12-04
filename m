From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchannels. The 22'th century release.
Date: Tue, 4 Dec 2007 17:45:20 +0300
Message-ID: <20071204144520.GA20797@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42749 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbXLDOpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 09:45:23 -0500
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.14.1/8.14.1) with ESMTP id lB4EjKmw025461
	for <netdev@vger.kernel.org>; Tue, 4 Dec 2007 17:45:20 +0300
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.14.1/8.12.1/Submit) id lB4EjKnT025425
	for netdev@vger.kernel.org; Tue, 4 Dec 2007 17:45:20 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is the 22'th release of the netchannels, a peer-to-peer protocol
agnostic communication channel between hardware and users. It uses
unified cache to store channels, allows to allocate buffers for data
from userspace mapped area or from other preallocated set of pages
(like VFS cache). All protocol processing happens in process context.

Users of the system can be for example userspace - it allows to receive
and send traffic from the wire without any kernel interference, to
implement own protocols and offload its processing to the hardware.

This idea was originally proposed and implemented by Van Jacobson.
This patchset (with userspace netowrk stack) is a logical continuation
of the idea with move to the full peer-to-peer processing.

One of its users is userspace network stack [2].

Short changelog:
 * update cached route in the netchannel when it expires.

Thanks to Salvatore Del Popolo <delpopolo@dit.unitn.it> for testing.

1. Netchannels homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

2. Userspace network stack.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/arch/i386/kernel/syscall_table.S b/arch/i386/kernel/syscall_table.S
index 2697e92..3231b22 100644
--- a/arch/i386/kernel/syscall_table.S
+++ b/arch/i386/kernel/syscall_table.S
@@ -319,3 +319,4 @@ ENTRY(sys_call_table)
 	.long sys_move_pages
 	.long sys_getcpu
 	.long sys_epoll_pwait
+	.long sys_netchannel_control
diff --git a/arch/x86_64/ia32/ia32entry.S b/arch/x86_64/ia32/ia32entry.S
index b4aa875..d35d4d8 100644
--- a/arch/x86_64/ia32/ia32entry.S
+++ b/arch/x86_64/ia32/ia32entry.S
@@ -718,4 +718,5 @@ ia32_sys_call_table:
 	.quad compat_sys_vmsplice
 	.quad compat_sys_move_pages
 	.quad sys_getcpu
+	.quad sys_netchannel_control
 ia32_syscall_end:		
diff --git a/include/asm-i386/unistd.h b/include/asm-i386/unistd.h
index beeeaf6..33242f8 100644
--- a/include/asm-i386/unistd.h
+++ b/include/asm-i386/unistd.h
@@ -325,10 +325,11 @@
 #define __NR_move_pages		317
 #define __NR_getcpu		318
 #define __NR_epoll_pwait	319
+#define __NR_netchannel_control	320
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 320
+#define NR_syscalls 321
 #include <linux/err.h>
 
 /*
diff --git a/include/asm-x86_64/unistd.h b/include/asm-x86_64/unistd.h
index 777288e..16f1aac 100644
--- a/include/asm-x86_64/unistd.h
+++ b/include/asm-x86_64/unistd.h
@@ -619,8 +619,10 @@ __SYSCALL(__NR_sync_file_range, sys_sync_file_range)
 __SYSCALL(__NR_vmsplice, sys_vmsplice)
 #define __NR_move_pages		279
 __SYSCALL(__NR_move_pages, sys_move_pages)
+#define __NR_netchannel_control	280
+__SYSCALL(__NR_netchannel_control, sys_netchannel_control)
 
-#define __NR_syscall_max __NR_move_pages
+#define __NR_syscall_max __NR_netchannel_control
 
 #ifdef __KERNEL__
 #include <linux/err.h>
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 4c02119..bdf6432 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -36,9 +36,11 @@
 #define CN_VAL_CIFS                     0x1
 #define CN_W1_IDX			0x3	/* w1 communication */
 #define CN_W1_VAL			0x1
+#define CN_NETCHANNELS_IDX		0x04	/* Netchannels connection control */
+#define CN_NETCHANNELS_VAL		0x01
 
 
-#define CN_NETLINK_USERS		4
+#define CN_NETLINK_USERS		5
 
 /*
  * Maximum connector's message size.
diff --git a/include/linux/netchannel.h b/include/linux/netchannel.h
new file mode 100644
index 0000000..c56afc5
--- /dev/null
+++ b/include/linux/netchannel.h
@@ -0,0 +1,175 @@
+/*
+ * 	netchannel.h
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef __NETCHANNEL_H
+#define __NETCHANNEL_H
+
+#include <linux/types.h>
+
+enum netchannel_commands {
+	NETCHANNEL_CREATE = 0,
+};
+
+enum netchannel_type {
+	NETCHANNEL_EMPTY = 0,
+	NETCHANNEL_COPY_USER,
+	NETCHANNEL_NAT,
+	NETCHANNEL_MAX
+};
+
+/*
+ * Destination and source addresses/ports are from receiving point ov view, 
+ * i.e. when packet is being received, destination is local address.
+ */
+
+struct unetdata
+{
+	__u32			saddr, daddr;
+	__u16			sport, dport;
+	__u8			proto;			/* IP protocol number */
+	__u8			reserved[3];
+};
+
+struct unetchannel
+{
+	struct unetdata		data, mask;
+	__u32			prio;			/* Netchanenl's priority. */
+	__u32			type;			/* Netchannel type: copy_to_user, NAT or something */
+	__u8			memory_limit_order;	/* Memor limit order */
+	__u8			reserved[3];
+};
+
+struct unetchannel_control
+{
+	struct unetchannel	unc;
+	__u32			cmd;
+	__u16			len, header_len;
+	__u32			flags;
+	__u32			timeout;
+	int			fd;
+};
+
+#define NETCHANNEL_NAT_CREATE	0x0
+#define NETCHANNEL_NAT_REMOVE	0x1
+
+struct netchannel_nat
+{
+	__u32			cmd;
+	struct unetchannel	flow;
+	struct unetdata		target;
+};
+
+#ifdef __KERNEL__
+
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+
+#define NC_NUM_DIMENSIONS	5
+
+struct trie
+{
+	struct rcu_head	rcu_head;
+	unsigned long	parent;
+	struct trie	*left, *right;
+	int		refcnt, wrefcnt;
+	unsigned int	prio;
+	union {
+		struct trie	*next;
+		void		*ptr;
+	};
+};
+
+struct interval
+{
+	u32		val, mask;
+};
+
+int trie_init(void);
+struct trie *trie_search(struct interval *in, int num);
+int trie_add(struct interval *in, int num, int prio, void *priv);
+void trie_del(struct interval *in, int num);
+
+struct netchannel;
+
+struct netchannel
+{
+	struct unetchannel	unc;
+	struct list_head	thread_entry;
+	int			thread_id, need_exit;
+	struct rcu_head		rcu_head;
+	spinlock_t		lock;
+	unsigned long		hit;
+
+	int			(*nc_init)(struct netchannel *);
+	int			(*nc_cleanup)(struct netchannel *);
+	int			(*nc_process)(struct netchannel *, struct sk_buff *);
+	int 			(*nc_enqueue)(struct netchannel *, struct sk_buff *, int cpu);
+
+	struct sk_buff_head 	recv_queue;
+
+	void			*priv;
+};
+
+struct netchannel_callbacks
+{
+	int			(*nc_init)(struct netchannel *);
+	int			(*nc_cleanup)(struct netchannel *);
+	int			(*nc_process)(struct netchannel *, struct sk_buff *);
+	int 			(*nc_enqueue)(struct netchannel *, struct sk_buff *, int cpu);
+};
+
+int netchannel_add_callbacks(struct netchannel_callbacks *cbs, int type);
+
+struct netchannel_copy_user
+{
+	wait_queue_head_t	wait;
+	atomic_t		qlen;
+	struct file		*file;
+	struct dst_entry	*dst;
+};
+
+#define NETCHANNEL_MAX_ORDER	31
+#define NETCHANNEL_MIN_ORDER	PAGE_SHIFT
+
+int netchannel_skb_enqueue_thread(struct netchannel *nc, struct sk_buff *skb, int cpu);
+struct netchannel *netchannel_search_interval(struct interval *in, int num);
+void netchannel_remove(struct netchannel *nc);
+struct netchannel *netchannel_create(struct unetchannel *unc, void *priv, int *error);
+
+static inline void netchanel_unetchannel2interval(struct unetchannel *unc, struct interval *u)
+{
+	u[0].val = ntohl(unc->data.daddr);
+	u[0].mask = ntohl(unc->mask.daddr);
+	u[1].val = ntohl(unc->data.saddr);
+	u[1].mask = ntohl(unc->mask.saddr);
+	u[2].val = ntohs(unc->data.dport);
+	u[2].mask = ntohs(unc->mask.dport);
+	u[3].val = ntohs(unc->data.sport);
+	u[3].mask = ntohs(unc->mask.sport);
+	u[4].val = unc->data.proto;
+	u[4].mask = unc->mask.proto;
+}
+
+struct dst_entry *route_get(struct dst_entry *dst);
+struct dst_entry *route_get_raw(u32 saddr, u32 daddr, u16 sport, u16 dport, u8 proto);
+
+#endif /* __KERNEL__ */
+#endif /* __NETCHANNEL_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9264139..a3bc419 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -707,6 +707,15 @@ extern int		dev_hard_start_xmit(struct sk_buff *skb,
 
 extern void		dev_init(void);
 
+#ifdef CONFIG_NETCHANNEL
+extern int netchannel_recv(struct sk_buff *skb);
+#else
+static inline int netchannel_recv(struct sk_buff *skb) 
+{
+	return -1;
+}
+#endif
+
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85577a4..ff2bdf9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -338,6 +338,18 @@ static inline struct sk_buff *alloc_skb(unsigned int size,
 	return __alloc_skb(size, priority, 0);
 }
 
+#ifdef CONFIG_NETCHANNEL
+struct unetchannel;
+extern struct sk_buff *netchannel_alloc(struct unetchannel *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask);
+#else
+static struct sk_buff *netchannel_alloc(void *unc, unsigned int header_size, 
+		unsigned int total_size, gfp_t gfp_mask)
+{
+	return NULL;
+}
+#endif
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 1912c6c..a42e608 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -605,4 +605,6 @@ asmlinkage long sys_getcpu(unsigned __user *cpu, unsigned __user *node, struct g
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
+asmlinkage long sys_netchannel_control(void __user *arg);
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 0e53314..275e3e8 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -134,9 +134,12 @@ cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
+
 cond_syscall(compat_sys_move_pages);
 
 /* block-layer dependent */
 cond_syscall(sys_bdflush);
 cond_syscall(sys_ioprio_set);
 cond_syscall(sys_ioprio_get);
+
+cond_syscall(sys_netchannel_control);
diff --git a/net/Kconfig b/net/Kconfig
index a81aca4..da6edfe 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -66,6 +66,8 @@ source "net/ipv6/Kconfig"
 
 endif # if INET
 
+source "net/core/netchannel/Kconfig"
+
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index 1195680..98c165e 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -16,5 +16,6 @@ obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_WIRELESS_EXT) += wireless.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
+obj-$(CONFIG_NETCHANNEL) += netchannel/
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 81c426a..33ba1ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1808,6 +1808,10 @@ int netif_receive_skb(struct sk_buff *skb)
 		}
 	}
 
+	ret = netchannel_recv(skb);
+	if (!ret)
+		goto out;
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (pt_prev) {
 		ret = deliver_skb(skb, pt_prev, orig_dev);
diff --git a/net/core/netchannel/Kconfig b/net/core/netchannel/Kconfig
new file mode 100644
index 0000000..760d1d5
--- /dev/null
+++ b/net/core/netchannel/Kconfig
@@ -0,0 +1,16 @@
+config NETCHANNEL
+	bool "Network channels"
+	---help---
+	  Network channels are peer-to-peer abstraction, which allows to create
+	  high performance communications. 
+	  Main advantages are unified address cache, protocol processing moved
+	  to userspace, receiving zero-copy support and other interesting features.
+
+config NETCHANNEL_USERSPACE
+	bool "Userspace netchannels"
+	depends on NETCHANNEL
+	---help---
+	  Userspace interface (file descriptor) for netchannels, which allows to implement 
+	  network stack in userspace, packet-socket-like interface - when userspace can select 
+	  set of IP addressed to work with without main kernel stack - like BGP/OSPF daemons, 
+	  TUN/TAP interface, VPN proxies and much more.
diff --git a/net/core/netchannel/Makefile b/net/core/netchannel/Makefile
new file mode 100644
index 0000000..337ed35
--- /dev/null
+++ b/net/core/netchannel/Makefile
@@ -0,0 +1,2 @@
+obj-y += netchannel.o trie.o
+obj-$(CONFIG_NETCHANNEL_USERSPACE) += user.o
diff --git a/net/core/netchannel/netchannel.c b/net/core/netchannel/netchannel.c
new file mode 100644
index 0000000..7bfdd50
--- /dev/null
+++ b/net/core/netchannel/netchannel.c
@@ -0,0 +1,607 @@
+/*
+ * 	netchannel.c
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/skbuff.h>
+#include <linux/highmem.h>
+#include <linux/netchannel.h>
+#include <linux/percpu.h>
+#include <linux/rcupdate.h>
+#include <linux/kthread.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+
+#include <net/route.h>
+
+static kmem_cache_t *netchannel_cache __read_mostly;
+
+struct netchannel_thread
+{
+	struct list_head	netchannel_list;
+	spinlock_t		lock;
+	struct task_struct	*task;
+	wait_queue_head_t	wait;
+};
+
+static DEFINE_PER_CPU(struct netchannel_thread, netchannel_thread_pool);
+#define NETCHANNEL_WAIT_TIMEOUT	HZ
+
+static struct netchannel_callbacks *netchannel_callbacks[NETCHANNEL_MAX];
+
+static int netchannel_empty_init(struct netchannel *nc)
+{
+	return 0;
+}
+
+static int netchannel_empty_cleanup(struct netchannel *nc)
+{
+	return 0;
+}
+
+static int netchannel_empty_enqueue(struct netchannel *nc, struct sk_buff *skb, int cpu)
+{
+	return 0;
+}
+
+static int netchannel_empty_process(struct netchannel *nc, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct netchannel_callbacks netchannel_callbacks_empty = {
+	.nc_init = &netchannel_empty_init,
+	.nc_cleanup = &netchannel_empty_cleanup,
+	.nc_process = &netchannel_empty_process,
+	.nc_enqueue = &netchannel_empty_enqueue,
+};
+
+static void netchannel_free(struct netchannel *nc)
+{
+	kmem_cache_free(netchannel_cache, nc);
+}
+
+/* Must be called under netchannel's lock with interrupts turned off */
+static void __netchannel_queue(struct netchannel *nc, int cpu)
+{
+	struct netchannel_thread *th;
+
+	if (cpu != -1)
+		nc->thread_id = cpu;
+	else if (nc->thread_id == -1)
+		nc->thread_id = smp_processor_id();
+	th = &per_cpu(netchannel_thread_pool, nc->thread_id);
+
+	spin_lock(&th->lock);
+	list_add_tail(&nc->thread_entry, &th->netchannel_list);
+	spin_unlock(&th->lock);
+	wake_up(&th->wait);
+}
+
+static int netchannel_queue(struct netchannel *nc, int cpu)
+{
+	unsigned long flags;
+	int ret = 0;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	if (list_empty(&nc->thread_entry)) {
+		__netchannel_queue(nc, cpu);
+		ret = 1;
+	}
+	spin_unlock_irqrestore(&nc->lock, flags);
+
+	return ret;
+}
+
+static void netchannel_free_rcu(struct rcu_head *rcu_head)
+{
+	struct netchannel *nc = container_of(rcu_head, struct netchannel, rcu_head);
+	unsigned long flags;
+
+	spin_lock_irqsave(&nc->lock, flags);
+	nc->need_exit = 1;
+	__netchannel_queue(nc, -1);
+	spin_unlock_irqrestore(&nc->lock, flags);
+}
+
+static inline void netchannel_schedule_free(struct netchannel *nc)
+{
+	call_rcu(&nc->rcu_head, netchannel_free_rcu);
+}
+
+int netchannel_skb_enqueue_thread(struct netchannel *nc, struct sk_buff *skb, int cpu)
+{
+	skb_queue_tail(&nc->recv_queue, skb);
+	return netchannel_queue(nc, cpu);
+}
+EXPORT_SYMBOL_GPL(netchannel_skb_enqueue_thread);
+
+static int netchannel_thread_process(void *data)
+{
+	struct netchannel_thread *th = data;
+	struct netchannel *nc = NULL;
+	unsigned long flags;
+	struct sk_buff *skb;
+	int err, free = 0;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible_timeout(th->wait, 
+				kthread_should_stop() || !list_empty(&th->netchannel_list),
+				NETCHANNEL_WAIT_TIMEOUT);
+
+		spin_lock_irqsave(&th->lock, flags);
+		if (!list_empty(&th->netchannel_list)) {
+			nc = list_entry(th->netchannel_list.next, struct netchannel, thread_entry);
+		} else
+			nc = NULL;
+		spin_unlock_irqrestore(&th->lock, flags);
+		if (!nc)
+			continue;
+
+		while ((skb = skb_dequeue(&nc->recv_queue))) {
+			err = nc->nc_process(nc, skb);
+
+			if (err)
+				kfree_skb(skb);
+		}
+
+		spin_lock_irqsave(&nc->lock, flags);
+		spin_lock(&th->lock);
+		list_del_init(&nc->thread_entry);
+		spin_unlock(&th->lock);
+		if (nc->need_exit)
+			free = 1;
+		spin_unlock_irqrestore(&nc->lock, flags);
+
+		/*
+		 * Freeing can only be scheduled through 
+		 * netchannel_schedule_free(), which will 
+		 * setup RCU callback netchannel_free_rcu(),
+		 * which will run after netchannel is removed
+		 * from trie and thus unaccessible from 
+		 * core processing.
+		 */
+		if (free)
+			netchannel_free(nc);
+	}
+
+	return 0;
+}
+
+static int netchannel_start_threads(void)
+{
+	int cpu, err;
+
+	for_each_possible_cpu(cpu) {
+		struct netchannel_thread *th = &per_cpu(netchannel_thread_pool, cpu);
+
+		init_waitqueue_head(&th->wait);
+		spin_lock_init(&th->lock);
+		INIT_LIST_HEAD(&th->netchannel_list);
+
+		th->task = kthread_run(netchannel_thread_process, th, "netchannel/%d", cpu);
+		if (IS_ERR(th->task)) {
+			err = PTR_ERR(th->task);
+			goto err_out_exit;
+		}
+	}
+
+	return 0;
+
+err_out_exit:
+	for_each_possible_cpu(cpu) {
+		struct netchannel_thread *th = &per_cpu(netchannel_thread_pool, cpu);
+
+		if (th->task) {
+			kthread_stop(th->task);
+			th->task = NULL;
+		}
+	}
+
+	return err;
+}
+
+static void netchannel_stop_threads(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct netchannel_thread *th = &per_cpu(netchannel_thread_pool, cpu);
+
+		if (th->task) {
+			kthread_stop(th->task);
+			th->task = NULL;
+		}
+	}
+}
+
+static int netchannel_convert_skb_ipv6(struct sk_buff *skb, struct unetdata *udata)
+{
+	/*
+	 * Hash IP addresses into src/dst. Setup TCP/UDP ports.
+	 * Not supported yet.
+	 */
+	return -1;
+}
+
+static int netchannel_convert_skb_ipv4(struct sk_buff *skb, struct unetdata *udata)
+{
+	struct iphdr *iph;
+	u32 len;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto inhdr_error;
+
+	iph = skb->nh.iph;
+
+	if (iph->ihl < 5 || iph->version != 4)
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, iph->ihl*4))
+		goto inhdr_error;
+
+	iph = skb->nh.iph;
+
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		goto inhdr_error;
+
+	len = ntohs(iph->tot_len);
+	if (skb->len < len || len < (iph->ihl*4))
+		goto inhdr_error;
+
+	if (pskb_trim_rcsum(skb, len))
+		goto inhdr_error;
+
+	udata->saddr = iph->saddr;
+	udata->daddr = iph->daddr;
+	udata->proto = iph->protocol;
+
+	len = skb->len;
+
+	skb->h.raw = skb->nh.raw + iph->ihl*4;
+
+	switch (iph->protocol) {
+		case IPPROTO_TCP:
+		case IPPROTO_UDP:
+			udata->sport = ((u16 *)skb->h.raw)[0];
+			udata->dport = ((u16 *)skb->h.raw)[1];
+			break;
+		default:
+			goto inhdr_error;
+	}
+
+	return 0;
+
+inhdr_error:
+	return -1;
+}
+
+static int netchannel_convert_skb(struct sk_buff *skb, struct unetdata *udata)
+{
+	if (skb->pkt_type == PACKET_OTHERHOST)
+		return -1;
+
+	switch (ntohs(skb->protocol)) {
+		case ETH_P_IP:
+			return netchannel_convert_skb_ipv4(skb, udata);
+		case ETH_P_IPV6:
+			return netchannel_convert_skb_ipv6(skb, udata);
+		default:
+			return -1;
+	}
+}
+
+struct netchannel *netchannel_search_interval(struct interval *in, int num)
+{
+	struct trie *tr;
+	struct netchannel *nc = NULL;
+
+	tr = trie_search(in, num);
+	if (!tr)
+		return nc;
+
+	nc = tr->ptr;
+	return nc;
+}
+
+EXPORT_SYMBOL_GPL(netchannel_search_interval);
+
+static struct netchannel *netchannel_search_udata(struct unetdata *udata)
+{
+	struct interval u[NC_NUM_DIMENSIONS];
+
+	u[0].val = ntohl(udata->daddr);
+	u[1].val = ntohl(udata->saddr);
+	u[2].val = ntohs(udata->dport);
+	u[3].val = ntohs(udata->sport);
+	u[4].val = udata->proto;
+	u[0].mask = u[1].mask = u[2].mask = u[3].mask = u[4].mask = 0xffffffff;
+
+	return netchannel_search_interval(u, NC_NUM_DIMENSIONS);
+}
+
+int netchannel_recv(struct sk_buff *skb)
+{
+	struct netchannel *nc;
+	struct unetdata udata;
+	int err;
+
+	err = netchannel_convert_skb(skb, &udata);
+	if (err)
+		return err;
+
+	rcu_read_lock();
+	nc = netchannel_search_udata(&udata);
+	if (!nc) {
+		err = -ENODEV;
+		goto err_out_unlock;
+	}
+
+	nc->hit++;
+#if 0
+	printk("netchannel: daddr: %u.%u.%u.%u/%u.%u.%u.%u %u/%u, saddr: %u.%u.%u.%u/%u.%u.%u.%u %u/%u, proto: %u/%u, enc: %p.\n",
+			NIPQUAD(nc->unc.data.daddr), NIPQUAD(nc->unc.mask.daddr), 
+			ntohs(nc->unc.data.dport), ntohs(nc->unc.mask.dport),
+			NIPQUAD(nc->unc.data.saddr), NIPQUAD(nc->unc.mask.saddr), 
+			ntohs(nc->unc.data.sport), ntohs(nc->unc.mask.sport),
+			nc->unc.data.proto, nc->unc.mask.proto, nc->nc_enqueue);
+#endif
+	err = nc->nc_enqueue(nc, skb, smp_processor_id());
+	if (err < 0)
+		goto err_out_unlock;
+
+	rcu_read_unlock();
+	
+	return 0;
+
+err_out_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
+static int netchannel_add(struct netchannel *nc)
+{
+	int err;
+	struct interval u[NC_NUM_DIMENSIONS];
+
+	netchanel_unetchannel2interval(&nc->unc, u);
+
+	err = trie_add(u, NC_NUM_DIMENSIONS, nc->unc.prio, nc);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+void netchannel_remove(struct netchannel *nc)
+{
+	struct interval u[NC_NUM_DIMENSIONS];
+
+	netchanel_unetchannel2interval(&nc->unc, u);
+
+	trie_del(u, NC_NUM_DIMENSIONS);
+
+	nc->nc_cleanup(nc);
+	netchannel_schedule_free(nc);
+}
+EXPORT_SYMBOL_GPL(netchannel_remove);
+
+static int netchannel_ip_route_output_flow(struct rtable **rp, struct flowi *flp, int flags)
+{
+	int err;
+
+	err = __ip_route_output_key(rp, flp);
+	if (err)
+		return err;
+
+	if (flp->proto) {
+		if (!flp->fl4_src)
+			flp->fl4_src = (*rp)->rt_src;
+		if (!flp->fl4_dst)
+			flp->fl4_dst = (*rp)->rt_dst;
+	}
+
+	return 0;
+}
+
+struct dst_entry *route_get_raw(u32 saddr, u32 daddr, u16 sport, u16 dport, u8 proto)
+{
+	struct rtable *rt;
+	struct flowi fl = { .oif = 0,
+			    .nl_u = { .ip4_u =
+				      { .saddr = saddr,
+					.daddr = daddr,
+					.tos = 0 } },
+			    .proto = proto,
+			    .uli_u = { .ports =
+				       { .sport = sport,
+					 .dport = dport } } };
+
+	if (netchannel_ip_route_output_flow(&rt, &fl, 0))
+		goto no_route;
+	return dst_clone(&rt->u.dst);
+
+no_route:
+	return NULL;
+}
+
+struct dst_entry *route_get(struct dst_entry *dst)
+{
+	if (dst && dst->obsolete && dst->ops->check(dst, 0) == NULL) {
+		dst_release(dst);
+		return NULL;
+	}
+	return dst_clone(dst);
+}
+
+/*
+ * Addresses and ports must be in network byte order.
+ */
+struct netchannel *netchannel_create(struct unetchannel *unc, void *priv, int *error)
+{
+	struct netchannel *nc;
+	int err;
+
+	if (unc->type >= NETCHANNEL_MAX) {
+		err = -ENOSYS;
+		goto err_out_exit;
+	}
+
+	if (!netchannel_callbacks[unc->type]) {
+		err = -ENOSYS;
+		goto err_out_exit;
+	}
+
+	nc = kmem_cache_alloc(netchannel_cache, GFP_KERNEL);
+	if (!nc) {
+		err = -ENOMEM;
+		goto err_out_exit;
+	}
+
+	memset(nc, 0, sizeof(struct netchannel));
+
+	nc->hit = 0;
+	memcpy(&nc->unc, unc, sizeof(struct unetchannel));
+	nc->nc_init = netchannel_callbacks[unc->type]->nc_init;
+	nc->nc_cleanup = netchannel_callbacks[unc->type]->nc_cleanup;
+	nc->nc_enqueue = netchannel_callbacks[unc->type]->nc_enqueue;
+	nc->nc_process = netchannel_callbacks[unc->type]->nc_process;
+	nc->priv = priv;
+	INIT_LIST_HEAD(&nc->thread_entry);
+	INIT_RCU_HEAD(&nc->rcu_head);
+	spin_lock_init(&nc->lock);
+	skb_queue_head_init(&nc->recv_queue);
+	nc->thread_id = -1;
+
+	if (unlikely(nc->unc.memory_limit_order > NETCHANNEL_MAX_ORDER))
+		nc->unc.memory_limit_order = NETCHANNEL_MAX_ORDER;
+
+	if (unlikely(nc->unc.memory_limit_order < NETCHANNEL_MIN_ORDER))
+		nc->unc.memory_limit_order = NETCHANNEL_MIN_ORDER;
+#if 0
+	printk("netchannel: daddr: %u.%u.%u.%u/%u.%u.%u.%u %u/%u, saddr: %u.%u.%u.%u/%u.%u.%u.%u %u/%u, proto: %u/%u.\n",
+			NIPQUAD(nc->unc.data.daddr), NIPQUAD(nc->unc.mask.daddr), 
+			ntohs(nc->unc.data.dport), ntohs(nc->unc.mask.dport),
+			NIPQUAD(nc->unc.data.saddr), NIPQUAD(nc->unc.mask.saddr), 
+			ntohs(nc->unc.data.sport), ntohs(nc->unc.mask.sport),
+			nc->unc.data.proto, nc->unc.mask.proto);
+#endif
+	err = nc->nc_init(nc);
+
+	if (err < 0)
+		goto err_out_free;
+
+	*error = err;
+
+	err = netchannel_add(nc);
+	if (err)
+		goto err_out_cleanup;
+
+	return nc;
+
+err_out_cleanup:
+	nc->nc_cleanup(nc);
+err_out_free:
+	kmem_cache_free(netchannel_cache, nc);
+err_out_exit:
+	*error = err;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(netchannel_create);
+
+asmlinkage long sys_netchannel_control(void __user *arg)
+{
+	struct unetchannel_control ctl;
+	int ret;
+
+	if (copy_from_user(&ctl, arg, sizeof(struct unetchannel_control)))
+		return -EFAULT;
+
+	switch (ctl.cmd) {
+		case NETCHANNEL_CREATE:
+			ret = -EINVAL;
+			netchannel_create(&ctl.unc, NULL, &ret);
+			break;
+		default:
+			ret = -EINVAL;
+			break;
+	}
+	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
+		return -EFAULT;
+
+	return ret;
+}
+
+int netchannel_add_callbacks(struct netchannel_callbacks *cbs, int type)
+{
+	if (type >= NETCHANNEL_MAX)
+		return -EINVAL;
+
+	if (!cbs->nc_init || !cbs->nc_cleanup || !cbs->nc_process || !cbs->nc_enqueue)
+		return -EINVAL;
+
+	if (netchannel_callbacks[type])
+		return -EACCES;
+
+	netchannel_callbacks[type] = cbs;
+	return 0;
+}
+
+static int __init netchannel_init(void)
+{
+	int err = -ENOMEM;
+
+	netchannel_cache = kmem_cache_create("netchannel", sizeof(struct netchannel), 0, 0,
+			NULL, NULL);
+	if (!netchannel_cache)
+		goto err_out_exit;
+	
+	err = netchannel_start_threads();
+	if (err)
+		goto err_out_remove_netchannel_cache;
+
+	err = netchannel_add_callbacks(&netchannel_callbacks_empty, NETCHANNEL_EMPTY);
+	if (err)
+		goto err_out_remove_netchannel_cache;
+
+	err = trie_init();
+	if (err)
+		goto err_out_stop_threads;
+
+	return 0;
+
+err_out_stop_threads:
+	netchannel_stop_threads();
+err_out_remove_netchannel_cache:
+	kmem_cache_destroy(netchannel_cache);
+err_out_exit:
+	printk(KERN_NOTICE "netchannel: failed to initialize subsystem.\n");
+	return err;
+}
+
+module_init(netchannel_init);
diff --git a/net/core/netchannel/trie.c b/net/core/netchannel/trie.c
new file mode 100644
index 0000000..8d6244c
--- /dev/null
+++ b/net/core/netchannel/trie.c
@@ -0,0 +1,417 @@
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/netchannel.h>
+
+//#define TRIE_DEBUG
+
+#ifdef TRIE_DEBUG
+#define ulog(f, a...) printk(f, ##a)
+#else
+#define ulog(f, a...) do {} while(0)
+#endif
+
+#define NODE_WILDCARD		2
+#define NODE_NEWROOT		1
+
+#define NODE_MASK		(~3UL)
+
+#define node_wildcard(tr)	((tr)->parent & NODE_WILDCARD)
+#define node_parent(tr)		(rcu_dereference((struct trie *)((tr)->parent & NODE_MASK)))
+#define node_left(tr)		(rcu_dereference(tr->left))
+#define node_right(tr)		(rcu_dereference(tr->right))
+#define node_new_root(tr)	((tr)->parent & NODE_NEWROOT)
+#define node_set_next(tr, n)	(rcu_assign_pointer((tr)->next, (n)))
+#define node_set_parent(tr, p)	do { (tr)->parent = (unsigned long)(p); } while(0)
+#define node_set_new_root(tr)	((tr)->parent |= NODE_NEWROOT)
+
+static kmem_cache_t *trie_cache __read_mostly;
+static DEFINE_MUTEX(trie_mutex);
+static struct trie *__trie_root __read_mostly;
+
+static inline void node_set_wildcard(struct trie *tr)
+{
+	if (++tr->wrefcnt == 1)
+		tr->parent |= NODE_WILDCARD;
+}
+
+static inline void node_clear_wildcard(struct trie *tr)
+{
+	if (--tr->wrefcnt == 0)
+		tr->parent &= ~NODE_WILDCARD;
+}
+
+static struct trie *node_alloc(struct trie *parent, struct trie *left, struct trie *right, 
+		int bit, int wildcard, int prio, struct trie *next)
+{
+	struct trie *tr;
+
+	tr = kmem_cache_alloc(trie_cache, GFP_KERNEL);
+	if (!tr)
+		return NULL;
+
+	memset(tr, 0, sizeof(struct trie));
+
+	INIT_RCU_HEAD(&tr->rcu_head);
+	tr->refcnt = 1;
+	tr->wrefcnt = 0;
+	tr->prio = prio;
+	tr->next = next;
+	if (wildcard)
+		node_set_wildcard(tr);
+	tr->parent = (unsigned long)parent;
+	tr->left = left;
+	tr->right = right;
+	smp_wmb();
+
+	return tr;
+}
+
+static inline void node_get(struct trie *tr)
+{
+	tr->refcnt++;
+}
+
+static void node_free(struct trie *tr);
+static inline void node_put(struct trie *tr)
+{
+	ulog("trie: put %p, will %s be freed, refcnt: %d.\n", tr, (tr->refcnt == 1)?"":"not", tr->refcnt-1);
+	if (--tr->refcnt == 0)
+		node_free(tr);
+}
+
+static void node_free_rcu(struct rcu_head *rcu_head)
+{
+	struct trie *tr = container_of(rcu_head, struct trie, rcu_head);
+	kmem_cache_free(trie_cache, tr);
+}
+
+static void node_free(struct trie *tr)
+{
+	struct trie *parent = node_parent(tr);
+
+	if (node_new_root(tr) && tr->next)
+		node_put(tr->next);
+
+	if (parent) {
+		if (tr == rcu_dereference(parent->left))
+			rcu_assign_pointer(parent->left, NULL);
+		else
+			rcu_assign_pointer(parent->right, NULL);
+	}
+	ulog("trie: free: tr: %p, next: %p, left: %p, right: %p, parent: %p.\n",
+			tr, tr->next, tr->left, tr->right, parent);
+	call_rcu(&tr->rcu_head, node_free_rcu);
+}
+
+static struct trie *node_alloc_set(unsigned int prio, int depth)
+{
+	int i;
+	struct trie *tr = NULL, *next = NULL;
+
+	for (i=depth-1; i>=0; --i) {
+		tr = node_alloc(NULL, NULL, NULL, 0, 0, prio, next);
+		if (!tr)
+			goto err_out_exit;
+		node_set_new_root(tr);
+		if (next)
+			node_set_parent(next, tr);
+		next = tr;
+	}
+
+	ulog("trie: set prio: %u, depth: %d, ", prio, depth);
+	for (i=0; i<depth; ++i) {
+		ulog("%p [0x%lx] -> ", next, next->parent);
+		next = next->next;
+	}
+	ulog("\n");
+
+	return tr;
+
+err_out_exit:
+	while (next) {
+		tr = next->next;
+		node_put(next);
+		next = tr;
+	}
+
+	return NULL;
+}
+
+static struct trie *node_add_u32(struct trie *tr, u32 val, u32 mask, unsigned int prio, int depth, void *priv)
+{
+	struct trie *next, *trie_next = tr->next;
+	int pos = 0, bit, size, wpos;
+	u32 m;
+
+	size = sizeof(val)*8 - 1;
+	wpos = ffs(mask);
+	if (wpos == 1)
+		wpos = 0;
+	m = val & mask;
+
+	if (!m)
+		return NULL;
+
+	if (!trie_next || depth == 1)
+		trie_next = priv;
+
+	node_get(tr);
+
+	do {
+		if (wpos && (size - pos + 1 == wpos)) {
+			if (tr->prio < prio)
+				tr->prio = prio;
+			node_set_wildcard(tr);
+			trie_next = tr->next;
+			break;
+		}
+
+		bit = (m >> (size-pos)) & 1;
+		next = (bit)?node_right(tr):node_left(tr);
+
+		if (!next) {
+			if ((bit && node_left(tr)) || (!bit && node_right(tr))) {
+				next = node_alloc_set(prio, depth);
+				if (!next) {
+					tr = NULL;
+					break;
+				}
+				node_set_parent(next, tr);
+				trie_next = next->next;
+			} else {
+				if (!tr->next || depth == 1)
+					node_set_next(tr, priv);
+				trie_next = tr->next;
+				next = node_alloc(tr, NULL, NULL, bit, 0, prio, trie_next);
+				if (!next) {
+					tr = NULL;
+					break;
+				}
+			}
+			if (bit)
+				rcu_assign_pointer(tr->right, next);
+			else
+				rcu_assign_pointer(tr->left, next);
+		} else {
+			node_get(next);
+		}
+		tr = next;
+		trie_next = tr->next;
+	} while (++pos <= size);
+
+	if (!trie_next || depth == 1)
+		node_set_next(tr, priv);
+	if (!tr)
+		return NULL;
+	
+	ulog("%s: added: %08x/%08x tr: %p, prio: %d, trie_next: %p, priv: %p, depth: %d, prio: %d.\n", 
+			__func__, val, mask, tr, (tr)?tr->prio:-1, trie_next, priv, depth, prio);
+
+	return trie_next;
+}
+
+static struct trie *node_del_u32(struct trie *tr, u32 val, u32 mask)
+{
+	struct trie *next, *ret = NULL;
+	int pos = 0, bit, err = 0, size, wpos;
+	u32 m;
+
+	if (!tr)
+		return NULL;
+
+	size = sizeof(val)*8 - 1;
+	wpos = ffs(mask);
+	if (wpos == 1)
+		wpos = 0;
+	m = val & mask;
+
+	ulog("trie: del: tr: %p, %08x/%08x -> %08x, wpos: %d.\n", tr, val, mask, m, wpos);
+
+	do {
+		bit = (m >> (size-pos)) & 1;
+
+		ulog("trie: del: tr: %p, left: %p, right: %p, next: %p, pos: %d.\n",
+				tr, (tr)?tr->left:NULL, (tr)?tr->right:NULL, (tr)?tr->next:NULL, pos);
+		next = (bit)?node_right(tr):node_left(tr);
+
+		if (wpos && (size - pos + 1 == wpos)) {
+			node_clear_wildcard(tr);
+			ulog("wildcard tr: %p [%p], refcnt: %d.\n", tr, tr->next, tr->refcnt);
+			node_put(tr);
+			break;
+		}
+
+		ret = tr->next;
+#if 1
+		ulog("tr: %p [%p], refcnt: %d, pos: %d, size: %d.\n", 
+				tr, tr->next, tr->refcnt, pos, size);
+#endif
+		node_put(tr);
+
+		if ((pos < size) && !next) {
+			err = -ENODEV;
+			tr = ret = NULL;
+			break;
+		}
+		tr = next;
+	} while ((++pos <= size) && tr);
+
+	{
+		if (pos > size && tr) {
+			ulog("trie: del: putting %p [%d].\n", tr, tr->refcnt);
+			node_put(tr);
+		}
+	}
+
+	ulog(" removed val: %08x, mask: %08x, m: %08x, wpos: %d, err: %d, tr: %p [%p], ret: %p.\n", 
+			val, mask, m, wpos, err, tr, (tr)?tr->next:NULL, ret);
+
+	return ret;
+}
+
+int trie_add(struct interval *in, int num, int prio, void *priv)
+{
+	struct trie *tr;
+	struct trie *root = __trie_root;
+	int i;
+	
+	for (i=0; i<num; ++i) {
+		if ((in[i].val & in[i].mask) == 0) {
+			printk("trie: check %d/%d: %08x/%08x -> %08x.\n", 
+					i, num, in[i].val, in[i].mask, in[i].val & in[i].mask);
+			return -EINVAL;
+		}
+	}
+
+	mutex_lock(&trie_mutex);
+	for (i=0; i<num; ++i) {
+		tr = node_add_u32(root, in[i].val, in[i].mask, prio, num-i, priv);
+		if (i == num - 1)
+			break;
+		if (!tr)
+			goto err_out_clean;
+		root = tr;
+	}
+	mutex_unlock(&trie_mutex);
+
+	return 0;
+
+err_out_clean:
+	while (--i >= 0)
+		node_del_u32(root, in[i].val, in[i].mask);
+	mutex_unlock(&trie_mutex);
+	return -ENOMEM;
+}
+
+void trie_del(struct interval *in, int num)
+{
+	int i;
+	struct trie *root = __trie_root;
+	
+	for (i=0; i<num; ++i) {
+		if ((in[i].val & in[i].mask) == 0) {
+			ulog("trie: del %d/%d bogus: %08x/%08x -> %08x.\n", 
+				i, num, in[i].val, in[i].mask, in[i].val & in[i].mask);
+			return;
+		}
+	}
+
+	mutex_lock(&trie_mutex);
+	rcu_read_lock();
+	i = 0;
+	for (i=0; i<num; ++i) {
+		ulog("trie: root: %p, del %08x/%08x -> %08x.\n", root, in[i].val, in[i].mask, in[i].val & in[i].mask);
+		root = node_del_u32(root, in[i].val, in[i].mask);
+		if (!root)
+			break;
+	}
+	rcu_read_unlock();
+	mutex_unlock(&trie_mutex);
+}
+
+static struct trie *__trie_search(struct trie *root, struct interval *in, int num)
+{
+	struct trie *ret = NULL, *tr = root;
+	int pos = 0, size, bit;
+	u32 m;
+
+	if (!num || !tr)
+		return NULL;
+
+	ulog("trie: search root: %p, val: %08x, mask: %08x, num: %d.\n", root, in[0].val, in[0].mask, num);
+
+	size = sizeof(in[0].val)*8 - 1;
+	m = in[0].val & in[0].mask;
+
+	do {
+		bit = (m >> (size-pos)) & 1;
+		ulog("%c", (bit)?'+':'-');
+
+		ulog("trie: search: tr: %p [%p], refcnt: %d [0x%x], left: %p, right: %p.\n", tr, tr->next, tr->refcnt, tr->refcnt, tr->left, tr->right);
+
+		if (node_wildcard(tr)) {
+			struct trie *tmp;
+
+			ulog(" trie: found wildcard tr: %p, prio: %d, num: %d.\n", tr, tr->prio, num);
+			tmp = __trie_search(tr->next, &in[1], num-1);
+			if (tmp && (!ret || (ret->prio < tmp->prio)))
+				ret = tmp;
+			if ((num == 1) && (!ret || (ret->prio < tr->prio))) {
+				ret = tr;
+			}
+		}
+		tr = (bit)?node_right(tr):node_left(tr);
+		if (!tr) {
+			ulog(" end: pos: %d, size: %d, ret: %p [prio: %d].\n", pos, size, ret, (ret)?ret->prio:-1);
+		}
+	} while (++pos <= size && tr);
+
+	if (tr && (!ret || (ret->prio < tr->prio))) {
+		ulog("trie: on exit tr: %p, prio: %d, num: %d.\n", tr, (tr)?tr->prio:-1, num);
+		if (num > 1)
+			ret = __trie_search(tr->next, &in[1], num-1);
+		else
+			ret = tr;
+		ulog("trie: ret on exit tr: %p, prio: %d, num: %d.\n", ret, (tr)?tr->prio:-1, num);
+	}
+
+	if (!ret) {
+		ulog(" failed: %08x %u.%u.%u.%u, num: %d.\n", in[0].val, HIPQUAD(in[0].val), num);
+	} else {
+		ulog(" found: %08x %u.%u.%u.%u, prio: %d, tr: %p, num: %d, ptr: %p.\n", 
+				in[0].val, HIPQUAD(in[0].val), ret->prio, ret, num, ret->ptr);
+	}
+
+	return ret;
+}
+
+struct trie *trie_search(struct interval *in, int num)
+{
+	struct trie *tr;
+
+	tr = __trie_search(__trie_root, in, num);
+	
+	ulog("local: %u.%u.%u.%u:%u, foreign: %u.%u.%u.%u:%u, proto: %u, tr: %p, ptr: %p.\n",
+			HIPQUAD(in[0].val), in[2].val, HIPQUAD(in[1].val), in[3].val, in[4].val, tr, (tr)?tr->ptr:NULL);
+	return tr;
+}
+
+int trie_init(void)
+{
+	trie_cache = kmem_cache_create("trie", sizeof(struct trie), 0, 0,
+			NULL, NULL);
+	if (!trie_cache)
+		return -ENOMEM;
+
+	__trie_root = node_alloc_set(0, NC_NUM_DIMENSIONS);
+	if (!__trie_root)
+		goto err_out_destroy_cache;
+
+	return 0;
+
+err_out_destroy_cache:
+	kmem_cache_destroy(trie_cache);
+
+	return -ENOMEM;
+}
diff --git a/net/core/netchannel/user.c b/net/core/netchannel/user.c
new file mode 100644
index 0000000..1175796
--- /dev/null
+++ b/net/core/netchannel/user.c
@@ -0,0 +1,403 @@
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/file.h>
+#include <linux/netchannel.h>
+#include <linux/mount.h>
+#include <linux/netfilter.h>
+
+#include <net/ip.h>
+
+static char netchannel_name[] = "netchannel";
+
+static int netchannel_get_sb(struct file_system_type *fs_type, 
+		int flags, const char *dev_name, void *data, struct vfsmount *mnt)
+{
+	/* So original magic... */
+	return get_sb_pseudo(fs_type, netchannel_name, NULL, 0xabcdef, mnt);
+}
+
+static struct file_system_type netchannel_fs = {
+	.name		= netchannel_name,
+	.get_sb		= netchannel_get_sb,
+	.kill_sb	= kill_anon_super,
+};
+
+static struct vfsmount *netchannel_mnt;
+
+static int netchannel_wait_for_packet(struct netchannel *nc, long *timeo_p)
+{
+	struct netchannel_copy_user *p = nc->priv;
+	int error = 0;
+	DEFINE_WAIT(wait);
+
+	prepare_to_wait_exclusive(&p->wait, &wait, TASK_INTERRUPTIBLE);
+
+	if (skb_queue_empty(&nc->recv_queue)) {
+		if (signal_pending(current))
+			goto interrupted;
+
+		*timeo_p = schedule_timeout(*timeo_p);
+	}
+out:
+	finish_wait(&p->wait, &wait);
+	return error;
+interrupted:
+	error = (*timeo_p == MAX_SCHEDULE_TIMEOUT) ? -ERESTARTSYS : -EINTR;
+	goto out;
+}
+
+static struct sk_buff *netchannel_get_skb(struct netchannel *nc, unsigned int *timeout, int *error)
+{
+	struct netchannel_copy_user *p = nc->priv;
+	struct sk_buff *skb = NULL;
+	long tm = *timeout;
+
+	*error = 0;
+
+	while (1) {
+		skb = skb_dequeue(&nc->recv_queue);
+		if (skb)
+			break;
+
+		if (*timeout) {
+			*error = netchannel_wait_for_packet(nc, &tm);
+			if (*error) {
+				*timeout = tm;
+				break;
+			}
+			tm = *timeout;
+		} else {
+			*error = -EAGAIN;
+			break;
+		}
+	}
+
+	if (!skb)
+		skb = skb_dequeue(&nc->recv_queue);
+
+	if (skb)
+		atomic_sub(skb->len, &p->qlen);
+
+	return skb;
+}
+
+static int netchannel_copy_from_user(struct netchannel *nc, unsigned int *timeout, u16 len, u16 header_len, void __user *arg)
+{
+	struct sk_buff *skb;
+	struct netchannel_copy_user *p = nc->priv;
+	int err = -EINVAL;
+	struct dst_entry *dst;
+	struct net_device *dev;
+
+	if (header_len > len)
+		goto err_out_exit;
+
+	dst = route_get(p->dst);
+	if (!dst) {
+		p->dst = route_get_raw(nc->unc.data.daddr, nc->unc.data.saddr,
+					nc->unc.data.dport, nc->unc.data.sport,
+					nc->unc.data.proto);
+		if (p->dst)
+			dst = route_get(p->dst);
+
+		if (!p->dst || !dst) {
+			err = -EHOSTUNREACH;
+			goto err_out_exit;
+		}
+	}
+
+	dev = dst->dev;
+
+	skb = alloc_skb(len+LL_RESERVED_SPACE(dev), GFP_KERNEL);
+	if (!skb) {
+		err = -ENOMEM;
+		goto err_out_route_put;
+	}
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	err = skb_add_data(skb, arg, len);
+	if (err)
+		goto err_out_free;
+	
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (!header_len) {
+		struct iphdr *iph = (struct iphdr *)skb->data;
+		header_len = iph->ihl<<2;
+	}
+
+	skb->nh.raw = skb->data;
+	skb->h.raw = skb->data + header_len;
+	skb->protocol = htons(ETH_P_IP);
+	skb->dst = dst;
+	skb->dev = dst->dev;
+
+	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+
+err_out_free:
+	kfree_skb(skb);
+	dst = NULL;
+err_out_route_put:
+	dst_release(dst);
+err_out_exit:
+	return err;
+}
+
+static int netchannel_copy_to_user(struct netchannel *nc, unsigned int *timeout, u16 *len, void __user *arg)
+{
+	unsigned int copied;
+	struct sk_buff *skb;
+	struct iovec to;
+	int err;
+
+	skb = netchannel_get_skb(nc, timeout, &err);
+	if (!skb)
+		return err;
+
+	to.iov_base = arg;
+	to.iov_len = *len;
+
+	copied = skb->len;
+	if (copied > *len)
+		copied = *len;
+
+	err = skb_copy_datagram_iovec(skb, 0, &to, copied);
+
+	*len = (err == 0)?copied:0;
+
+	kfree_skb(skb);
+
+	return err;
+}
+
+static ssize_t netchannel_read(struct file *file, char __user *buf, size_t size, loff_t *off)
+{
+	struct netchannel *nc = file->private_data;
+	unsigned int timeout = 0;
+	int ret;
+
+	ret = netchannel_copy_to_user(nc, &timeout, (u16 *)&size, buf);
+	if (ret < 0)
+		return ret;
+	return size;
+}
+
+static ssize_t netchannel_write(struct file *file, const char __user *buf, size_t size, loff_t *off)
+{
+	struct netchannel *nc = file->private_data;
+	unsigned int timeout = 0;
+	u16 header_len = 0;
+	int ret;
+
+	ret = netchannel_copy_from_user(nc, &timeout, size, header_len, (void __user *)buf);
+	if (ret < 0)
+		return ret;
+	return size;
+}
+
+static unsigned int netchannel_poll(struct file *file, struct poll_table_struct *wait)
+{
+	struct netchannel *nc = file->private_data;
+	struct netchannel_copy_user *p = nc->priv;
+	unsigned int mask = 0;
+
+	poll_wait(file, &p->wait, wait);
+	if (!skb_queue_empty(&nc->recv_queue))
+		mask |= POLLIN;
+
+	return mask;
+}
+
+static int netchannel_release(struct inode *inode, struct file *file)
+{
+	struct netchannel *nc = file->private_data;
+
+	if (nc)
+		netchannel_remove(nc);
+
+	return 0;
+}
+
+static struct file_operations netchannel_fops = {
+	.release	= netchannel_release,
+	.read		= netchannel_read,
+	.poll		= netchannel_poll,
+	.write		= netchannel_write,
+	.owner		= THIS_MODULE,
+};
+
+static int netchannel_bind_fd(struct netchannel *nc)
+{
+	struct file *file;
+	struct netchannel_copy_user *p = nc->priv;
+	int fd, ret;
+
+	fd = get_unused_fd();
+	if (fd < 0)
+		return fd;
+
+	file = get_empty_filp();
+	if (!file) {
+		ret = -ENFILE;
+		goto out_put_fd;
+	}
+
+	file->f_op = &netchannel_fops;
+	file->f_vfsmnt = mntget(netchannel_mnt);
+	file->f_dentry = dget(netchannel_mnt->mnt_root);
+	file->f_mapping = file->f_dentry->d_inode->i_mapping;
+	file->f_mode = FMODE_READ|FMODE_WRITE;
+	file->f_flags = O_RDWR;
+	file->private_data = nc;
+
+	p->file = file;
+	
+	fd_install(fd, file);
+
+	return fd;
+
+out_put_fd:
+	put_unused_fd(fd);
+	return ret;
+}
+
+static int netchannel_copy_user_init(struct netchannel *nc)
+{
+	int fd, err;
+	struct netchannel_copy_user *p;
+
+	nc->priv = kzalloc(sizeof(struct netchannel_copy_user), GFP_KERNEL);
+	if (!nc->priv)
+		return -ENOMEM;
+	p = nc->priv;
+
+	skb_queue_head_init(&nc->recv_queue);
+	init_waitqueue_head(&p->wait);
+	atomic_set(&p->qlen, 0);
+	p->dst = route_get_raw(nc->unc.data.daddr, nc->unc.data.saddr,
+			nc->unc.data.dport, nc->unc.data.sport, nc->unc.data.proto);
+
+	printk("%s: %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u, reverse route: %p.\n", 
+			__func__, 
+			NIPQUAD(nc->unc.data.saddr), ntohs(nc->unc.data.sport),
+			NIPQUAD(nc->unc.data.daddr), ntohs(nc->unc.data.dport),
+			p->dst);
+
+	if (!p->dst) {
+		err = -EHOSTUNREACH;
+		goto err_out_free;
+	}
+
+	fd = netchannel_bind_fd(nc);
+	if (fd < 0) {
+		err = fd;
+		goto err_out_route_put;
+	}
+
+	return fd;
+
+err_out_route_put:
+	dst_release(p->dst);
+	p->dst = NULL;
+err_out_free:
+	kfree(nc->priv);
+	nc->priv = NULL;
+
+	return err;
+}
+
+static int netchannel_copy_user_cleanup(struct netchannel *nc)
+{
+	struct netchannel_copy_user *p = nc->priv;
+
+	skb_queue_purge(&nc->recv_queue);
+	
+	/*
+	 * ->release() can only be accessed through fput() path,
+	 *  which can be only called after file descriptor is created
+	 *  and returned to userspace.
+	 * netchannel_copy_user_cleanup() in turn can be called through
+	 * netchannel_remove() (called from ->release()) path and 
+	 * when initialization fails, in the latter case file descriptor 
+	 * will not be returned, but fput() will be called eventually, so 
+	 * to prevent use after free ->private_area will be set to NULL
+	 * so in case when ->nc_cleanup() is called through 
+	 * failed initialization error path, we would not call it again
+	 * from ->release() path.
+	 *
+	 *  It can be done without any locks, since this function by design
+	 *  this function can only be called either when initialization
+	 *  failed (and thus no descriptor returned and close() can not be
+	 *  called on it) or when close() is called (or program exits),
+	 *  but only one time after initialization is completed.
+	 */
+
+	p->file->private_data = NULL;
+
+	dst_free(p->dst);
+	kfree(p);
+
+	return 0;
+}
+
+static int netchannel_copy_user_enqueue(struct netchannel *nc, struct sk_buff *skb, int cpu)
+{
+	struct netchannel_copy_user *p = nc->priv;
+
+	if (atomic_read(&p->qlen) + skb->len > (1 << nc->unc.memory_limit_order)) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	atomic_add( skb->len, &p->qlen);
+	skb_queue_tail(&nc->recv_queue, skb);
+	wake_up(&p->wait);
+	return 0;
+}
+
+static int netchannel_copy_user_process(struct netchannel *nc, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct netchannel_callbacks netchannel_copy_user_callbacks = {
+	.nc_init = netchannel_copy_user_init,
+	.nc_cleanup = netchannel_copy_user_cleanup,
+	.nc_enqueue = netchannel_copy_user_enqueue,
+	.nc_process = netchannel_copy_user_process,
+};
+
+static int netchanel_userspace_init(void)
+{
+	int err;
+
+	err = register_filesystem(&netchannel_fs);
+	if (err) {
+		printk(KERN_ERR "Failed to register netchannel fs, err: %d.\n", err);
+		return err;
+	}
+
+	netchannel_mnt = kern_mount(&netchannel_fs);
+	if (IS_ERR(netchannel_mnt)) {
+		printk(KERN_ERR "Failed to mount netchannel fs, err: %ld.\n", PTR_ERR(netchannel_mnt));
+		err = PTR_ERR(netchannel_mnt);
+		goto err_out_unregister;
+	}
+
+	err = netchannel_add_callbacks(&netchannel_copy_user_callbacks, NETCHANNEL_COPY_USER);
+	if (err)
+		goto err_out_umount;
+
+	return 0;
+
+err_out_umount:
+	mntput(netchannel_mnt);
+err_out_unregister:
+	unregister_filesystem(&netchannel_fs);
+	return err;
+}
+
+module_init(netchanel_userspace_init);


-- 
	Evgeniy Polyakov
