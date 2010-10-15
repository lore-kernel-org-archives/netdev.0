From: xiaohui.xin@intel.com
Subject: [PATCH v13 11/16] Add header file for mp device.
Date: Fri, 15 Oct 2010 17:12:12 +0800
Message-ID: <e6a3012c63893f071316026bca90280ef972d8f2.1287132437.git.xiaohui.xin@intel.com>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/mpassthru.h |  133 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 133 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/mpassthru.h

diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
new file mode 100644
index 0000000..1115f55
--- /dev/null
+++ b/include/linux/mpassthru.h
@@ -0,0 +1,133 @@
+#ifndef __MPASSTHRU_H
+#define __MPASSTHRU_H
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+#include <linux/ioctl.h>
+
+/* ioctl defines */
+#define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
+#define MPASSTHRU_UNBINDDEV    _IO('M', 214)
+#define MPASSTHRU_SET_MEM_LOCKED       _IOW('M', 215, unsigned long)
+#define MPASSTHRU_GET_MEM_LOCKED_NEED  _IOR('M', 216, unsigned long)
+
+#define COPY_THRESHOLD (L1_CACHE_BYTES * 4)
+#define COPY_HDR_LEN   (L1_CACHE_BYTES < 64 ? 64 : L1_CACHE_BYTES)
+
+#define DEFAULT_NEED   ((8192*2*2)*4096)
+
+struct frag {
+	u16     offset;
+	u16     size;
+};
+
+#define HASH_BUCKETS    (8192*2)
+struct page_info {
+	struct list_head        list;
+	struct page_info        *next;
+	struct page_info        *prev;
+	struct page             *pages[MAX_SKB_FRAGS];
+	struct sk_buff          *skb;
+	struct page_pool        *pool;
+
+	/* The pointer relayed to skb, to indicate
+	 * it's a external allocated skb or kernel
+	 */
+	struct skb_ext_page    ext_page;
+	/* flag to indicate read or write */
+#define INFO_READ                      0
+#define INFO_WRITE                     1
+	unsigned                flags;
+	/* exact number of locked pages */
+	unsigned                pnum;
+
+	/* The fields after that is for backend
+	 * driver, now for vhost-net.
+	 */
+	/* the kiocb structure related to */
+	struct kiocb            *iocb;
+	/* the ring descriptor index */
+	unsigned int            desc_pos;
+	/* the iovec coming from backend, we only
+	 * need few of them */
+	struct iovec            hdr[2];
+	struct iovec            iov[2];
+};
+
+struct page_pool {
+	/* the queue for rx side */
+	struct list_head        readq;
+	/* the lock to protect readq */
+	spinlock_t              read_lock;
+	/* record the orignal rlimit */
+	struct rlimit           o_rlim;
+	/* userspace wants to locked */
+	int                     locked_pages;
+	/* currently locked pages */
+	int                     cur_pages;
+	/* the memory locked before */
+	unsigned long		orig_locked_vm;
+	/* the device according to */
+	struct net_device       *dev;
+	/* the mp_port according to dev */
+	struct mp_port          port;
+	/* the hash_table list to find each locked page */
+	struct page_info        **hash_table;
+};
+
+static struct kmem_cache *ext_page_info_cache;
+
+#ifdef __KERNEL__
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+struct socket *mp_get_socket(struct file *);
+struct page_pool *page_pool_create(struct net_device *dev,
+				   struct socket *sock);
+int async_recvmsg(struct kiocb *iocb, struct page_pool *pool,
+		  struct iovec *iov, int count, int flags);
+int async_sendmsg(struct sock *sk, struct kiocb *iocb,
+		  struct page_pool *pool, struct iovec *iov,
+		  int count);
+void async_data_ready(struct sock *sk, struct page_pool *pool);
+void dev_change_state(struct net_device *dev);
+void page_pool_destroy(struct mm_struct *mm, struct page_pool *pool);
+#else
+#include <linux/err.h>
+#include <linux/errno.h>
+struct file;
+struct socket;
+static inline struct socket *mp_get_socket(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
+static inline struct page_pool *page_pool_create(struct net_device *dev,
+		struct socket *sock)
+{
+	return ERR_PTR(-EINVAL);
+}
+static inline int async_recvmsg(struct kiocb *iocb, struct page_pool *pool,
+		struct iovec *iov, int count, int flags)
+{
+	return -EINVAL;
+}
+static inline int async_sendmsg(struct sock *sk, struct kiocb *iocb,
+		struct page_pool *pool, struct iovec *iov,
+		int count)
+{
+	return -EINVAL;
+}
+static inline void async_data_ready(struct sock *sk, struct page_pool *pool)
+{
+	return;
+}
+static inline void dev_change_state(struct net_device *dev)
+{
+	return;
+}
+static inline void page_pool_destroy(struct mm_struct *mm,
+				     struct page_pool *pool)
+{
+	return;
+}
+#endif /* CONFIG_MEDIATE_PASSTHRU */
+#endif /* __KERNEL__ */
+#endif /* __MPASSTHRU_H */
-- 
1.7.3
