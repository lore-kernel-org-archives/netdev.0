From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] partial checksum and GSO support for tun/tap.
Date: Thu, 24 Jan 2008 01:10:44 +1100
Message-ID: <200801240110.45178.rusty@rustcorp.com.au>
References: <200801240107.38929.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60224 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238AbYAWOXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 09:23:38 -0500
In-Reply-To: <200801240107.38929.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Changes since last time: we how have explicit IFF_RECV_CSUM and 
IFF_RECV_GSO bits, and some renaming of virtio_net hdr)

We use the virtio_net_hdr: it is an ABI already and designed to
encapsulate such metadata as GSO and partial checksums.

IFF_VIRTIO_HDR means you will write and read a 'struct virtio_net_hdr'
at the start of each packet.  You can always write packets with
partial checksum and gso to the tap device using this header.

IFF_RECV_CSUM means you can handle reading packets with partial
checksums.  If IFF_RECV_GSO is also set, it means you can handle
reading (all types of) GSO packets.

Note that there is no easy way to detect if these flags are supported:
see next patch.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/tun.c      |  259 +++++++++++++++++++++++++++++++++++++++++++------
 include/linux/if_tun.h |    6 +
 2 files changed, 238 insertions(+), 27 deletions(-)

diff -r cb85fb035378 drivers/net/tun.c
--- a/drivers/net/tun.c	Wed Jan 23 20:06:56 2008 +1100
+++ b/drivers/net/tun.c	Wed Jan 23 20:12:51 2008 +1100
@@ -62,6 +62,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
+#include <linux/virtio_net.h>
 #include <net/net_namespace.h>
 
 #include <asm/system.h>
@@ -238,35 +239,188 @@ static unsigned int tun_chr_poll(struct 
 	return mask;
 }
 
+static struct sk_buff *copy_user_skb(size_t align, struct iovec *iv, size_t len)
+{
+	struct sk_buff *skb;
+
+	if (!(skb = alloc_skb(len + align, GFP_KERNEL)))
+		return ERR_PTR(-ENOMEM);
+
+	if (align)
+		skb_reserve(skb, align);
+
+	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
+		kfree_skb(skb);
+		return ERR_PTR(-EFAULT);
+	}
+	return skb;
+}
+
+/* This will fail if they give us a crazy iovec, but that's their own fault. */
+static int get_user_skb_frags(const struct iovec *iv, size_t count,
+			      struct skb_frag_struct *f)
+{
+	unsigned int i, j, num_pg = 0;
+	int err;
+	struct page *pages[MAX_SKB_FRAGS];
+
+	down_read(&current->mm->mmap_sem);
+	for (i = 0; i < count; i++) {
+		int n, npages;
+		unsigned long base, len;
+		base = (unsigned long)iv[i].iov_base;
+		len = (unsigned long)iv[i].iov_len;
+
+		if (len == 0)
+			continue;
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
+
+static struct sk_buff *map_user_skb(const struct virtio_net_hdr *gso,
+				    size_t align, struct iovec *iv,
+				    size_t count, size_t len)
+{
+	struct sk_buff *skb;
+	struct skb_shared_info *sinfo;
+	int err;
+
+	if (!(skb = alloc_skb(gso->hdr_len + align, GFP_KERNEL)))
+		return ERR_PTR(-ENOMEM);
+
+	if (align)
+		skb_reserve(skb, align);
+
+	sinfo = skb_shinfo(skb);
+	sinfo->gso_size = gso->gso_size;
+	sinfo->gso_type = SKB_GSO_DODGY;
+	switch (gso->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+	case VIRTIO_NET_HDR_GSO_TCPV4:
+		sinfo->gso_type |= SKB_GSO_TCPV4;
+		break;
+	case VIRTIO_NET_HDR_GSO_TCPV6:
+		sinfo->gso_type |= SKB_GSO_TCPV6;
+		break;
+	case VIRTIO_NET_HDR_GSO_UDP:
+		sinfo->gso_type |= SKB_GSO_UDP;
+		break;
+	default:
+		err = -EINVAL;
+		goto fail;
+	}
+
+	if (gso->gso_type & VIRTIO_NET_HDR_GSO_ECN)
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+
+	/* Copy in the header. */
+	if (memcpy_fromiovec(skb_put(skb, gso->hdr_len), iv, gso->hdr_len)) {
+		err = -EFAULT;
+		goto fail;
+	}
+
+	err = get_user_skb_frags(iv, count, sinfo->frags);
+	if (err < 0)
+		goto fail;
+
+	sinfo->nr_frags = err;
+	skb->len += len;
+	skb->data_len += len;
+	
+	return skb;
+
+fail:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+
+static inline size_t iov_total(const struct iovec *iv, unsigned long count)
+{
+	unsigned long i;
+	size_t len;
+
+	for (i = 0, len = 0; i < count; i++)
+		len += iv[i].iov_len;
+
+	return len;
+}
+
 /* Get packet from user space buffer */
-static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
+static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t num)
 {
 	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
+	struct virtio_net_hdr gso = { 0, VIRTIO_NET_HDR_GSO_NONE };
 	struct sk_buff *skb;
-	size_t len = count, align = 0;
+	size_t tot_len = iov_total(iv, num);
+	size_t len = tot_len, align = 0;
 
 	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) > count)
+		if ((len -= sizeof(pi)) > tot_len)
 			return -EINVAL;
 
 		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
+			return -EFAULT;
+	}
+	if (tun->flags & TUN_VIRTIO_HDR) {
+		if ((len -= sizeof(gso)) > tot_len)
+			return -EINVAL;
+
+		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
 			return -EFAULT;
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV)
 		align = NET_IP_ALIGN;
 
-	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
+	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE)
+		skb = map_user_skb(&gso, align, iv, num, len);
+	else
+		skb = copy_user_skb(align, iv, len);
+
+	if (IS_ERR(skb)) {
 		tun->dev->stats.rx_dropped++;
-		return -ENOMEM;
-	}
-
-	if (align)
-		skb_reserve(skb, align);
-	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
-		tun->dev->stats.rx_dropped++;
-		kfree_skb(skb);
-		return -EFAULT;
+		return PTR_ERR(skb);
 	}
 
 	switch (tun->flags & TUN_TYPE_MASK) {
@@ -280,7 +434,13 @@ static __inline__ ssize_t tun_get_user(s
 		break;
 	};
 
-	if (tun->flags & TUN_NOCHECKSUM)
+	if (gso.flags & (1 << VIRTIO_NET_F_CSUM)) {
+		if (!skb_partial_csum_set(skb,gso.csum_start,gso.csum_offset)) {
+			tun->dev->stats.rx_dropped++;
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+	} else if (tun->flags & TUN_NOCHECKSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx_ni(skb);
@@ -289,18 +449,7 @@ static __inline__ ssize_t tun_get_user(s
 	tun->dev->stats.rx_packets++;
 	tun->dev->stats.rx_bytes += len;
 
-	return count;
-}
-
-static inline size_t iov_total(const struct iovec *iv, unsigned long count)
-{
-	unsigned long i;
-	size_t len;
-
-	for (i = 0, len = 0; i < count; i++)
-		len += iv[i].iov_len;
-
-	return len;
+	return tot_len;
 }
 
 static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
@@ -313,7 +462,7 @@ static ssize_t tun_chr_aio_write(struct 
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	return tun_get_user(tun, (struct iovec *) iv, iov_total(iv, count));
+	return tun_get_user(tun, (struct iovec *) iv, count);
 }
 
 /* Put packet to the user space buffer */
@@ -336,6 +485,42 @@ static __inline__ ssize_t tun_put_user(s
 		if (memcpy_toiovec(iv, (void *) &pi, sizeof(pi)))
 			return -EFAULT;
 		total += sizeof(pi);
+	}
+	if (tun->flags & TUN_VIRTIO_HDR) {
+		struct virtio_net_hdr gso;
+		struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+		if (skb_is_gso(skb)) {
+			gso.hdr_len = skb_transport_header(skb) - skb->data;
+			gso.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCPV4)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		} else
+			gso.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+		
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			gso.csum_start = skb->csum_start - skb_headroom(skb);
+			gso.csum_offset = skb->csum_offset;
+		} else {
+			gso.flags = 0;
+			gso.csum_offset = gso.csum_start = 0;
+		}
+
+		if ((len -= sizeof(gso)) < 0)
+			return -EINVAL;
+
+		if (memcpy_toiovec(iv, (void *)&gso, sizeof(gso)))
+			return -EFAULT;
+		total += sizeof(gso);
 	}
 
 	len = min_t(int, skb->len, len);
@@ -523,6 +708,17 @@ static int tun_set_iff(struct file *file
 
 		tun_net_init(dev);
 
+		/* Virtio header means we can handle csum & gso. */
+		if ((ifr->ifr_flags & (IFF_VIRTIO_HDR|IFF_RECV_CSUM)) ==
+		    (IFF_VIRTIO_HDR|IFF_RECV_CSUM)) {
+			dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
+					NETIF_F_HIGHDMA | NETIF_F_FRAGLIST;
+
+			if (ifr->ifr_flags & IFF_RECV_GSO)
+				dev->features |= NETIF_F_TSO | NETIF_F_UFO |
+						 NETIF_F_TSO_ECN | NETIF_F_TSO6;
+		}
+
 		if (strchr(dev->name, '%')) {
 			err = dev_alloc_name(dev, dev->name);
 			if (err < 0)
@@ -543,6 +739,15 @@ static int tun_set_iff(struct file *file
 
 	if (ifr->ifr_flags & IFF_ONE_QUEUE)
 		tun->flags |= TUN_ONE_QUEUE;
+
+	if (ifr->ifr_flags & IFF_VIRTIO_HDR)
+		tun->flags |= TUN_VIRTIO_HDR;
+
+	if (ifr->ifr_flags & IFF_RECV_CSUM)
+		tun->flags |= TUN_RECV_CSUM;
+
+	if (ifr->ifr_flags & IFF_RECV_GSO)
+		tun->flags |= TUN_RECV_GSO;
 
 	file->private_data = tun;
 	tun->attached = 1;
diff -r cb85fb035378 include/linux/if_tun.h
--- a/include/linux/if_tun.h	Wed Jan 23 20:06:56 2008 +1100
+++ b/include/linux/if_tun.h	Wed Jan 23 20:12:51 2008 +1100
@@ -70,6 +70,9 @@ struct tun_struct {
 #define TUN_NO_PI	0x0040
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
+#define TUN_VIRTIO_HDR	0x0200
+#define TUN_RECV_CSUM	0x0400
+#define TUN_RECV_GSO	0x0400
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -85,6 +88,9 @@ struct tun_struct {
 #define IFF_TAP		0x0002
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
+#define IFF_VIRTIO_HDR	0x4000
+#define IFF_RECV_CSUM	0x8000
+#define IFF_RECV_GSO	0x0800
 
 struct tun_pi {
 	unsigned short flags;
