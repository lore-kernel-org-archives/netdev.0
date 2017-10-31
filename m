From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 02/14] packet: implement PACKET_MEMREG setsockopt
Date: Tue, 31 Oct 2017 13:41:33 +0100
Message-ID: <20171031124145.9667-3-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44449 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751746AbdJaMmT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:19 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

Here, the PACKET_MEMREG setsockopt is implemented for the AF_PACKET
protocol family. PACKET_MEMREG allows the user to register memory
regions that can be used by AF_PACKET V4 as packet data buffers.

Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 include/linux/tpacket4.h | 101 +++++++++++++++++++++++++++++
 net/packet/af_packet.c   | 163 +++++++++++++++++++++++++++++++++++++++++++++++
 net/packet/internal.h    |   4 ++
 3 files changed, 268 insertions(+)
 create mode 100644 include/linux/tpacket4.h

diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
new file mode 100644
index 000000000000..fcf4c333c78d
--- /dev/null
+++ b/include/linux/tpacket4.h
@@ -0,0 +1,101 @@
+/*
+ *  tpacket v4
+ *  Copyright(c) 2017 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef _LINUX_TPACKET4_H
+#define _LINUX_TPACKET4_H
+
+#define TP4_UMEM_MIN_FRAME_SIZE 2048
+#define TP4_KERNEL_HEADROOM 256 /* Headrom for XDP */
+
+struct tp4_umem {
+	struct pid *pid;
+	struct page **pgs;
+	unsigned int npgs;
+	size_t size;
+	unsigned long address;
+	unsigned int frame_size;
+	unsigned int frame_size_log2;
+	unsigned int nframes;
+	unsigned int nfpplog2; /* num frames per page in log2 */
+	unsigned int data_headroom;
+};
+
+/*************** V4 QUEUE OPERATIONS *******************************/
+
+/**
+ * tp4q_umem_new - Creates a new umem (packet buffer)
+ *
+ * @addr: The address to the umem
+ * @size: The size of the umem
+ * @frame_size: The size of each frame, between 2K and PAGE_SIZE
+ * @data_headroom: The desired data headroom before start of the packet
+ *
+ * Returns a pointer to the new umem or NULL for failure
+ **/
+static inline struct tp4_umem *tp4q_umem_new(unsigned long addr, size_t size,
+					     unsigned int frame_size,
+					     unsigned int data_headroom)
+{
+	struct tp4_umem *umem;
+	unsigned int nframes;
+
+	if (frame_size < TP4_UMEM_MIN_FRAME_SIZE || frame_size > PAGE_SIZE) {
+		/* Strictly speaking we could support this, if:
+		 * - huge pages, or*
+		 * - using an IOMMU, or
+		 * - making sure the memory area is consecutive
+		 * but for now, we simply say "computer says no".
+		 */
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (!is_power_of_2(frame_size))
+		return ERR_PTR(-EINVAL);
+
+	if (!PAGE_ALIGNED(addr)) {
+		/* Memory area has to be page size aligned. For
+		 * simplicity, this might change.
+		 */
+		return ERR_PTR(-EINVAL);
+	}
+
+	if ((addr + size) < addr)
+		return ERR_PTR(-EINVAL);
+
+	nframes = size / frame_size;
+	if (nframes == 0)
+		return ERR_PTR(-EINVAL);
+
+	data_headroom =	ALIGN(data_headroom, 64);
+
+	if (frame_size - data_headroom - TP4_KERNEL_HEADROOM < 0)
+		return ERR_PTR(-EINVAL);
+
+	umem = kzalloc(sizeof(*umem), GFP_KERNEL);
+	if (!umem)
+		return ERR_PTR(-ENOMEM);
+
+	umem->pid = get_task_pid(current, PIDTYPE_PID);
+	umem->size = size;
+	umem->address = addr;
+	umem->frame_size = frame_size;
+	umem->frame_size_log2 = ilog2(frame_size);
+	umem->nframes = nframes;
+	umem->nfpplog2 = ilog2(PAGE_SIZE / frame_size);
+	umem->data_headroom = data_headroom;
+
+	return umem;
+}
+
+#endif /* _LINUX_TPACKET4_H */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9603f6ff17a4..b39be424ec0e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -89,11 +89,15 @@
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
 #include <linux/percpu.h>
+#include <linux/log2.h>
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
 #endif
 #include <linux/bpf.h>
 #include <net/compat.h>
+#include <linux/sched/mm.h>
+#include <linux/sched/task.h>
+#include <linux/sched/signal.h>
 
 #include "internal.h"
 
@@ -2975,6 +2979,132 @@ static int packet_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 		return packet_snd(sock, msg, len);
 }
 
+static void
+packet_umem_unpin_pages(struct tp4_umem *umem)
+{
+	unsigned int i;
+
+	for (i = 0; i < umem->npgs; i++) {
+		struct page *page = umem->pgs[i];
+
+		set_page_dirty_lock(page);
+		put_page(page);
+	}
+	kfree(umem->pgs);
+	umem->pgs = NULL;
+}
+
+static void
+packet_umem_free(struct tp4_umem *umem)
+{
+	struct mm_struct *mm;
+	struct task_struct *task;
+	unsigned long diff;
+
+	packet_umem_unpin_pages(umem);
+
+	task = get_pid_task(umem->pid, PIDTYPE_PID);
+	put_pid(umem->pid);
+	if (!task)
+		goto out;
+	mm = get_task_mm(task);
+	put_task_struct(task);
+	if (!mm)
+		goto out;
+
+	diff = umem->size >> PAGE_SHIFT;
+
+	down_write(&mm->mmap_sem);
+	mm->pinned_vm -= diff;
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+out:
+	kfree(umem);
+}
+
+static struct tp4_umem *
+packet_umem_new(unsigned long addr, size_t size, unsigned int frame_size,
+		unsigned int data_headroom)
+{
+	unsigned long lock_limit, locked, npages;
+	unsigned int gup_flags = FOLL_WRITE;
+	int need_release = 0, j = 0, i, ret;
+	struct page **page_list;
+	struct tp4_umem *umem;
+
+	if (!can_do_mlock())
+		return ERR_PTR(-EPERM);
+
+	umem = tp4q_umem_new(addr, size, frame_size, data_headroom);
+	if (IS_ERR(umem))
+		return umem;
+
+	page_list = (struct page **)__get_free_page(GFP_KERNEL);
+	if (!page_list) {
+		put_pid(umem->pid);
+		kfree(umem);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	npages = PAGE_ALIGN(umem->nframes * umem->frame_size) >> PAGE_SHIFT;
+
+	down_write(&current->mm->mmap_sem);
+
+	locked = npages + current->mm->pinned_vm;
+	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+
+	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if (npages == 0 || npages > UINT_MAX) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	umem->pgs = kcalloc(npages, sizeof(*umem->pgs), GFP_KERNEL);
+	if (!umem->pgs) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	need_release = 1;
+	while (npages) {
+		ret = get_user_pages(addr,
+				     min_t(unsigned long, npages,
+					   PAGE_SIZE / sizeof(struct page *)),
+				     gup_flags, page_list, NULL);
+
+		if (ret < 0)
+			goto out;
+
+		umem->npgs += ret;
+		addr += ret * PAGE_SIZE;
+		npages -= ret;
+
+		for (i = 0; i < ret; i++)
+			umem->pgs[j++] = page_list[i];
+	}
+
+	ret = 0;
+
+out:
+	if (ret < 0) {
+		if (need_release)
+			packet_umem_unpin_pages(umem);
+		put_pid(umem->pid);
+		kfree(umem);
+	} else {
+		current->mm->pinned_vm = locked;
+	}
+
+	up_write(&current->mm->mmap_sem);
+	free_page((unsigned long)page_list);
+
+	return ret < 0 ? ERR_PTR(ret) : umem;
+}
+
 /*
  *	Close a PACKET socket. This is fairly simple. We immediately go
  *	to 'closed' state and remove our protocol entry in the device list.
@@ -3024,6 +3154,11 @@ static int packet_release(struct socket *sock)
 		packet_set_ring(sk, &req_u, 1, 1);
 	}
 
+	if (po->umem) {
+		packet_umem_free(po->umem);
+		po->umem = NULL;
+	}
+
 	f = fanout_release(sk);
 
 	synchronize_net();
@@ -3828,6 +3963,31 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
 		return 0;
 	}
+	case PACKET_MEMREG:
+	{
+		struct tpacket_memreg_req req;
+		struct tp4_umem *umem;
+
+		if (optlen < sizeof(req))
+			return -EINVAL;
+		if (copy_from_user(&req, optval, sizeof(req)))
+			return -EFAULT;
+
+		umem = packet_umem_new(req.addr, req.len, req.frame_size,
+				       req.data_headroom);
+		if (IS_ERR(umem))
+			return PTR_ERR(umem);
+
+		lock_sock(sk);
+		if (po->umem) {
+			release_sock(sk);
+			packet_umem_free(umem);
+			return -EBUSY;
+		}
+		po->umem = umem;
+		release_sock(sk);
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -4245,6 +4405,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		case TPACKET_V3:
 			po->tp_hdrlen = TPACKET3_HDRLEN;
 			break;
+		default:
+			err = -EINVAL;
+			goto out;
 		}
 
 		err = -EINVAL;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 94d1d405a116..9c07cfe1b8a3 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -2,6 +2,7 @@
 #define __PACKET_INTERNAL_H__
 
 #include <linux/refcount.h>
+#include <linux/tpacket4.h>
 
 struct packet_mclist {
 	struct packet_mclist	*next;
@@ -109,6 +110,9 @@ struct packet_sock {
 	union  tpacket_stats_u	stats;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
+
+	struct tp4_umem			*umem;
+
 	int			copy_thresh;
 	spinlock_t		bind_lock;
 	struct mutex		pg_vec_lock;
-- 
2.11.0
