From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH RFC 4/5] tun: vringfd xmit support.
Date: Sat, 5 Apr 2008 22:06:33 +1000
Message-ID: <200804052206.33922.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au> <200804052205.43824.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49043 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbYDEMG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 08:06:59 -0400
In-Reply-To: <200804052205.43824.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies tun to allow a vringfd to specify the send
buffer.  The user does a write to push out packets from the buffer.

Again, more thought needs to be put into the possible races with ring
registration.

Again we use the 'struct virtio_net_hdr' to allow userspace to send
GSO packets.  In this case, it can hint how much to copy, and the
other pages will be made into skb fragments.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 8270b5fdf03f drivers/net/tun.c
--- a/drivers/net/tun.c	Sat Apr 05 22:49:10 2008 +1100
+++ b/drivers/net/tun.c	Sat Apr 05 22:51:10 2008 +1100
@@ -101,7 +101,7 @@ struct tun_struct {
 	u32 chr_filter[2];
 	u32 net_filter[2];
 
-	struct vring_info	*inring;
+	struct vring_info	*inring, *outring;
 
 #ifdef TUN_DEBUG	
 	int debug;
@@ -258,6 +258,162 @@ static void tun_net_init(struct net_devi
 	}
 }
 
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
+/* Get packet from user space buffer.  copylen is a hint as to how
+ * much to copy (rest is pinned).  */
+static struct sk_buff *get_user_skb(struct tun_struct *tun, struct iovec *iv,
+				    size_t copylen, size_t len, int extra)
+{
+	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
+	struct sk_buff *skb;
+	size_t align = 0;
+	int err;
+
+	/* You can't have user fragments without room for destruction info. */
+	BUG_ON(!extra && copylen != len);
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
+	/* We don't need a destructor if we don't have fragments. */
+	if (extra && copylen == len)
+		extra = 0;
+
+	if (!(skb = __alloc_skb(copylen + align, GFP_KERNEL, 0, extra, -1))) {
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	if (align)
+		skb_reserve(skb, align);
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
+}
+
 #ifdef CONFIG_VRINGFD
 static void unset_recv(void *_tun)
 {
@@ -362,8 +518,118 @@ static int set_recv_vring(struct tun_str
 	tun->inring = vi;
 	return 0;
 }
+
+static void unset_xmit(void *_tun)
+{
+	struct tun_struct *tun = _tun;
+
+	tun->outring = NULL;
+}
+
+struct skb_shinfo_tun {
+	struct tun_struct *tun;
+
+	unsigned int id;
+	unsigned int len;
+};
+
+/* We are done with this skb: put it in the used pile. */
+static void skb_finished(struct skb_shared_info *sinfo)
+{
+	struct skb_shinfo_tun *sht = (void *)(sinfo + 1);
+
+	/* FIXME: Race prevention */
+	vring_used_buffer_atomic(sht->tun->outring, sht->id, sht->len);
+	vring_wake(sht->tun->outring);
+
+	/* Release device. */
+	dev_put(sht->tun->dev);
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
+		struct skb_shinfo_tun *sht;
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
+		skb = get_user_skb(tun, iov, h.hdr_len, len, sizeof(*sht));
+		if (IS_ERR(skb))
+			return PTR_ERR(skb);
+
+		if ((h.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+		    !skb_partial_csum_set(skb, h.csum_start, h.csum_offset)) {
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+
+		shinfo = skb_shinfo(skb);
+		/* If it has fragments, set up destructor for later. */
+		if (shinfo->nr_frags) {
+			sht = (void *)(shinfo + 1);
+			shinfo->destructor = skb_finished;
+			sht->id = id;
+			sht->len = sizeof(h) + skb->len;
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
+	.destroy = unset_xmit,
+	.push = xmit_packets,
+};
+
+static int set_xmit_vring(struct tun_struct *tun, int fd)
+{
+	struct vring_info *vi;
+
+	/* FIXME: Racy. */
+	vi = vring_attach(fd, &xmitops, tun, false);
+	if (IS_ERR(vi))
+		return PTR_ERR(vi);
+	tun->outring = vi;
+	return 0;
+}
 #else /* ... !CONFIG_VRINGFD */
 static int set_recv_vring(struct tun_struct *tun, int fd)
+{
+	return -ENOTTY;
+}
+
+static int set_xmit_vring(struct tun_struct *tun, int fd)
 {
 	return -ENOTTY;
 }
@@ -390,74 +656,26 @@ static unsigned int tun_chr_poll(struct 
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
+	skb = get_user_skb(tun, (struct iovec *)iv, len, len, 0);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	netif_rx_ni(skb);
+	return len;
 }
 
 /* Put packet to the user space buffer */
@@ -795,7 +1013,10 @@ static int tun_chr_ioctl(struct inode *i
 #endif
 
 	case TUNSETRECVVRING:
-		return set_recv_vring(tun, arg);		
+		return set_recv_vring(tun, arg);
+
+	case TUNSETXMITVRING:
+		return set_xmit_vring(tun, arg);
 
 	case SIOCGIFFLAGS:
 		ifr.ifr_flags = tun->if_flags;
diff -r 8270b5fdf03f include/linux/if_tun.h
--- a/include/linux/if_tun.h	Sat Apr 05 22:49:10 2008 +1100
+++ b/include/linux/if_tun.h	Sat Apr 05 22:51:10 2008 +1100
@@ -43,6 +43,7 @@
 #define TUNSETLINK    _IOW('T', 205, int)
 #define TUNSETGROUP   _IOW('T', 206, int)
 #define TUNSETRECVVRING _IOW('T', 207, int)
+#define TUNSETXMITVRING _IOW('T', 208, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
