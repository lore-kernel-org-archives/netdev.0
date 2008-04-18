From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 5/5] tun: vringfd xmit support.
Date: Fri, 18 Apr 2008 14:43:24 +1000
Message-ID: <200804181443.24812.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au> <200804181441.10499.rusty@rustcorp.com.au> <200804181442.17251.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45416 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbYDREo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 00:44:26 -0400
In-Reply-To: <200804181442.17251.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies tun to allow a vringfd to specify the send
buffer.  The user does a write to push out packets from the buffer.

Again we use the 'struct virtio_net_hdr' to allow userspace to send
GSO packets.  In this case, it can hint how much to copy, and the
other pages will be made into skb fragments.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |  410 +++++++++++++++++++++++++++++++++++++++++--------
 include/linux/if_tun.h |    1 
 2 files changed, 351 insertions(+), 60 deletions(-)

diff -r f797ec115d1b drivers/net/tun.c
--- a/drivers/net/tun.c	Fri Apr 18 05:58:40 2008 +1000
+++ b/drivers/net/tun.c	Fri Apr 18 06:07:21 2008 +1000
@@ -65,6 +65,8 @@
 #include <linux/vring.h>
 #include <linux/virtio_net.h>
 #include <linux/file.h>
+#include <linux/spinlock.h>
+#include <linux/kthread.h>
 #include <net/net_namespace.h>
 
 #include <asm/system.h>
@@ -102,8 +104,8 @@ struct tun_struct {
 	u32 chr_filter[2];
 	u32 net_filter[2];
 
-	struct vring_info	*inring;
-	struct file		*infile;
+	struct vring_info	*inring, *outring;
+	struct file		*infile, *outfile;
 
 #ifdef TUN_DEBUG
 	int debug;
@@ -258,6 +261,169 @@ static void tun_net_init(struct net_devi
 		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
 		break;
 	}
+}
+
+/* We don't consolidate consecutive iovecs, so huge iovecs can break here.
+ * Users will learn not to do that. */
+static int get_user_skb_frags(const struct iovec *iv, size_t len,
+			      struct skb_frag_struct *f)
+{
+	unsigned int i, j, num_pg = 0;
+	int err;
+	struct page *pages[MAX_SKB_FRAGS];
+
+	down_read(&current->mm->mmap_sem);
+	while (len) {
+		int n, npages;
+		unsigned long base, len;
+		base = (unsigned long)iv->iov_base;
+		len = (unsigned long)iv->iov_len;
+
+		if (len == 0) {
+			iv++;
+			continue;
+		}
+
+		/* How many pages will this take? */
+		npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;
+		if (unlikely(num_pg + npages > MAX_SKB_FRAGS)) {
+			err = -ENOSPC;
+			goto fail;
+		}
+		n = get_user_pages(current, current->mm, base, npages,
+				   0, 0, pages, NULL);
+		if (unlikely(n < 0)) {
+			err = n;
+			goto fail;
+		}
+
+		/* Transfer pages to the frag array */
+		for (j = 0; j < n; j++) {
+			f[num_pg].page = pages[j];
+			if (j == 0) {
+				f[num_pg].page_offset = offset_in_page(base);
+				f[num_pg].size = min(len, PAGE_SIZE -
+						     f[num_pg].page_offset);
+			} else {
+				f[num_pg].page_offset = 0;
+				f[num_pg].size = min(len, PAGE_SIZE);
+			}
+			len -= f[num_pg].size;
+			base += f[num_pg].size;
+			num_pg++;
+		}
+
+		if (unlikely(n != npages)) {
+			err = -EFAULT;
+			goto fail;
+		}
+	}
+	up_read(&current->mm->mmap_sem);
+	return num_pg;
+
+fail:
+	for (i = 0; i < num_pg; i++)
+		put_page(f[i].page);
+	up_read(&current->mm->mmap_sem);
+	return err;
+}
+
+/* We actually store this at the head of the skb. */
+struct skb_tun_hdr {
+	struct list_head list;
+	struct tun_struct *tun;
+	unsigned int id;
+	unsigned int len;
+};
+
+/* Get packet from user space buffer.  copylen is a hint as to how
+ * much to copy (rest is pinned).  */
+static struct sk_buff *get_user_skb(struct tun_struct *tun, struct iovec *iv,
+				    size_t copylen, size_t len)
+{
+	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
+	struct sk_buff *skb;
+	size_t align = 0, extra = 0;
+	int err;
+
+	if (!(tun->flags & TUN_NO_PI)) {
+		if (len < sizeof(pi)) {
+			err = -EINVAL;
+			goto fail;
+		}
+		len -= sizeof(pi);
+
+		if (memcpy_fromiovec((void *)&pi, iv, sizeof(pi))) {
+			err = -EFAULT;
+			goto fail;
+		}
+		if (copylen > len)
+			copylen = len;
+	}
+
+	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
+		align = NET_IP_ALIGN;
+		if (unlikely(copylen < ETH_HLEN)) {
+			if (len < ETH_HLEN) {
+				err = -EINVAL;
+				goto fail;
+			}
+			copylen = ETH_HLEN;
+		}
+	}
+
+	/* Allocate extra header if we need  */
+	if (copylen != len)
+		extra = sizeof(struct skb_tun_hdr);
+
+	skb = alloc_skb(extra + copylen + align, GFP_KERNEL);
+	if (!skb) {
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	if (extra + align)
+		skb_reserve(skb, extra + align);
+
+	if (memcpy_fromiovec(skb_put(skb, copylen), iv, copylen)) {
+		err = -EFAULT;
+		goto free_skb;
+	}
+
+	switch (tun->flags & TUN_TYPE_MASK) {
+	case TUN_TUN_DEV:
+		skb_reset_mac_header(skb);
+		skb->protocol = pi.proto;
+		skb->dev = tun->dev;
+		break;
+	case TUN_TAP_DEV:
+		skb->protocol = eth_type_trans(skb, tun->dev);
+		break;
+	};
+
+	if (tun->flags & TUN_NOCHECKSUM)
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	/* Anything left gets put into frags. */
+	if (extra) {
+		struct skb_shared_info *sinfo = skb_shinfo(skb);
+		int err = get_user_skb_frags(iv, len - copylen, sinfo->frags);
+		if (err < 0)
+			goto free_skb;
+		sinfo->nr_frags = err;
+	}
+	tun->dev->last_rx = jiffies;
+
+	tun->dev->stats.rx_packets++;
+	tun->dev->stats.rx_bytes += len;
+
+	return skb;
+
+free_skb:
+	kfree_skb(skb);
+fail:
+	tun->dev->stats.rx_dropped++;
+	return ERR_PTR(err);
 }
 
 #if defined(CONFIG_VRING) || defined(CONFIG_VRING_MODULE)
@@ -355,6 +521,132 @@ static struct vring_ops recvops = {
 	.pull = pull_recv_skbs,
 };
 
+static DEFINE_SPINLOCK(finished_lock);
+static LIST_HEAD(shinfo_finished_list);
+static struct task_struct *shinfo_finisher;
+
+static void used_buffer(struct skb_tun_hdr *tunh)
+{
+	/* Woot, something happened. */
+	vring_wake(tunh->tun->outring);
+
+	/* Release device.  Keeping this reference blocks file close. */
+	dev_put(tunh->tun->dev);
+
+	/* tunh == skb->head. */
+	kfree(tunh);
+}
+
+static int do_shinfo_finisher(void *unused)
+{
+	LIST_HEAD(list);
+	struct skb_tun_hdr *i;
+
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+
+		spin_lock_irq(&finished_lock);
+		list_splice_init(&list, &shinfo_finished_list);
+		spin_unlock_irq(&finished_lock);
+
+		if (list_empty(&list)) {
+			schedule();
+			continue;
+		}
+
+		list_for_each_entry(i, &list, list) {
+			vring_used_buffer(i->tun->outring, i->id, i->len);
+			used_buffer(i);
+		}
+	}
+	return 0;
+}
+
+/* We are done with this skb data: put it in the used pile. */
+static void shinfo_finished(struct skb_shared_info *sinfo)
+{
+	struct skb_tun_hdr *tunh = (void *)skb_shinfo_to_head(sinfo);
+	unsigned long flags;
+
+	spin_lock_irqsave(&finished_lock, flags);
+	list_add(&tunh->list, &shinfo_finished_list);
+	spin_unlock_irqrestore(&finished_lock, flags);
+
+	wake_up_process(shinfo_finisher);
+}
+
+static int xmit_packets(void *_tun)
+{
+	struct tun_struct *tun = _tun;
+	struct iovec iov[1+MAX_SKB_FRAGS];
+	unsigned int iovnum = ARRAY_SIZE(iov);
+	int id, err, wake = 0;
+	unsigned long len;
+
+	while ((id = vring_get_buffer(tun->outring, NULL, NULL, NULL,
+				      iov, &iovnum, &len)) > 0) {
+		struct virtio_net_hdr h;
+		struct sk_buff *skb;
+		struct skb_shared_info *shinfo;
+
+		if (unlikely(len < sizeof(h)))
+			return -EINVAL;
+
+		err = memcpy_fromiovec((void *)&h, iov, sizeof(h));
+		if (unlikely(err))
+			return -EFAULT;
+
+		len -= sizeof(h);
+		if (h.hdr_len > len)
+			return -EINVAL;
+
+		/* Without GSO, we copy entire packet. */
+		if (h.gso_type == VIRTIO_NET_HDR_GSO_NONE)
+			h.hdr_len = len;
+
+		skb = get_user_skb(tun, iov, h.hdr_len, len);
+		if (IS_ERR(skb))
+			return PTR_ERR(skb);
+
+		if ((h.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+		    !skb_partial_csum_set(skb, h.csum_start, h.csum_offset)) {
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+
+		/* If it has fragments, set up destructor for later. */
+		shinfo = skb_shinfo(skb);
+		if (skb_shinfo(skb)->nr_frags) {
+			struct skb_tun_hdr *tunh = (void *)skb->head;
+			shinfo->destructor = shinfo_finished;
+			tunh->id = id;
+			tunh->len = sizeof(h) + skb->len;
+		} else {
+			vring_used_buffer(tun->outring, id, sizeof(h)+skb->len);
+			wake = 1;
+		}
+		netif_rx_ni(skb);
+	}
+
+	if (wake)
+		vring_wake(tun->outring);
+
+	/* 0 or error. */
+	return id;
+}
+
+static struct vring_ops xmitops = {
+	.push = xmit_packets,
+};
+
+static int init_vring(void)
+{
+	shinfo_finisher = kthread_run(do_shinfo_finisher, NULL, "tun");
+	if (IS_ERR(shinfo_finisher))
+		return PTR_ERR(shinfo_finisher);
+	return 0;
+}
+
 static int set_recv_vring(struct tun_struct *tun, int fd)
 {
 	int err;
@@ -391,9 +685,47 @@ static void unset_vrings(struct tun_stru
 		vring_unset_ops(tun->inring);
 		fput(tun->infile);
 	}
+	if (tun->outring) {
+		vring_unset_ops(tun->outring);
+		fput(tun->outfile);
+	}
+}
+
+static int set_xmit_vring(struct tun_struct *tun, int fd)
+{
+	int err;
+
+	if (tun->outring)
+		return -EBUSY;
+
+	tun->outfile = fget(fd);
+	if (!tun->outfile)
+		return -EBADF;
+
+	tun->outring = vring_get(tun->outfile);
+	if (!tun->outring) {
+		err = -EBADF;
+		goto put;
+	}
+
+	err = vring_set_ops(tun->outring, &xmitops, tun);
+	if (err) {
+		tun->outring = NULL;
+		goto put;
+	}
+	return 0;
+
+put:
+	fput(tun->outfile);
+	tun->outfile = NULL;
+	return err;
 }
 #else /* ... !CONFIG_VRING */
 static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	return -ENOTTY;
+}
+static int set_xmit_vring(struct tun_struct *tun, int fd)
 {
 	return -ENOTTY;
 }
@@ -424,74 +756,26 @@ static unsigned int tun_chr_poll(struct 
 	return mask;
 }
 
-/* Get packet from user space buffer */
-static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
-{
-	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
-	struct sk_buff *skb;
-	size_t len = count, align = 0;
-
-	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) > count)
-			return -EINVAL;
-
-		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
-			return -EFAULT;
-	}
-
-	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
-		align = NET_IP_ALIGN;
-		if (unlikely(len < ETH_HLEN))
-			return -EINVAL;
-	}
-
-	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
-		tun->dev->stats.rx_dropped++;
-		return -ENOMEM;
-	}
-
-	if (align)
-		skb_reserve(skb, align);
-	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
-		tun->dev->stats.rx_dropped++;
-		kfree_skb(skb);
-		return -EFAULT;
-	}
-
-	switch (tun->flags & TUN_TYPE_MASK) {
-	case TUN_TUN_DEV:
-		skb_reset_mac_header(skb);
-		skb->protocol = pi.proto;
-		skb->dev = tun->dev;
-		break;
-	case TUN_TAP_DEV:
-		skb->protocol = eth_type_trans(skb, tun->dev);
-		break;
-	};
-
-	if (tun->flags & TUN_NOCHECKSUM)
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-	netif_rx_ni(skb);
-	tun->dev->last_rx = jiffies;
-
-	tun->dev->stats.rx_packets++;
-	tun->dev->stats.rx_bytes += len;
-
-	return count;
-}
-
 static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 			      unsigned long count, loff_t pos)
 {
 	struct tun_struct *tun = iocb->ki_filp->private_data;
+	size_t len;
+	struct sk_buff *skb;
 
 	if (!tun)
 		return -EBADFD;
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	return tun_get_user(tun, (struct iovec *) iv, iov_length(iv, count));
+	len = iov_length(iv, count);
+
+	skb = get_user_skb(tun, (struct iovec *)iv, len, len);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	netif_rx_ni(skb);
+	return len;
 }
 
 /* Put packet to the user space buffer */
@@ -831,6 +1115,9 @@ static int tun_chr_ioctl(struct inode *i
 	case TUNSETRECVVRING:
 		return set_recv_vring(tun, arg);
 
+	case TUNSETXMITVRING:
+		return set_xmit_vring(tun, arg);
+
 	case SIOCGIFFLAGS:
 		ifr.ifr_flags = tun->if_flags;
 		if (copy_to_user( argp, &ifr, sizeof ifr))
@@ -1078,6 +1365,12 @@ static int __init tun_init(void)
 	ret = misc_register(&tun_miscdev);
 	if (ret)
 		printk(KERN_ERR "tun: Can't register misc device %d\n", TUN_MINOR);
+	else {
+		ret = init_vring();
+		if (ret)
+			misc_deregister(&tun_miscdev);
+	}
+
 	return ret;
 }
 
diff -r f797ec115d1b include/linux/if_tun.h
--- a/include/linux/if_tun.h	Fri Apr 18 05:58:40 2008 +1000
+++ b/include/linux/if_tun.h	Fri Apr 18 06:07:21 2008 +1000
@@ -43,6 +43,7 @@
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
 #define TUNSETRECVVRING _IOW('T', 207, int)
+#define TUNSETXMITVRING _IOW('T', 208, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
