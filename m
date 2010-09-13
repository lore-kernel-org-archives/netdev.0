From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host kernel
Date: Mon, 13 Sep 2010 13:48:03 -0700
Message-ID: <1284410883.13351.14.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1284410580.13351.10.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add zero copy feature between userspace and kernel in macvtap when lower device supports
high memory DMA.


Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/net/macvtap.c |  136 +++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 126 insertions(+), 10 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3b1c54a..186cde1 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -274,6 +274,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	struct net *net = current->nsproxy->net_ns;
 	struct net_device *dev = dev_get_by_index(net, iminor(inode));
 	struct macvtap_queue *q;
+	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err;
 
 	err = -ENODEV;
@@ -302,6 +303,17 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
 	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
+	/*
+	 * so far only VM uses macvtap, enable zero copy between guest
+	 * kernel and host kernel when lower device supports high memory
+	 * DMA
+	 */
+	if (vlan) {
+		if ((vlan->lowerdev->features & NETIF_F_HIGHDMA) &&
+		    (vlan->lowerdev->features & NETIF_F_SG))
+			sock_set_flag(&q->sk, SOCK_ZEROCOPY);
+	}
+
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
 		sock_put(&q->sk);
@@ -343,6 +355,24 @@ out:
 	return mask;
 }
 
+#define GOODCOPY_LEN  (L1_CACHE_BYTES < 64 ? 64 : L1_CACHE_BYTES)
+
+static inline struct sk_buff *macvtap_alloc_skb_goodcopy(struct sock *sk,
+						 size_t prepad, size_t copy,
+						 int noblock, int *err)
+{
+	struct sk_buff *skb;
+
+	skb = sock_alloc_send_pskb(sk, prepad + copy, 0, noblock, err);
+	if (!skb)
+		return NULL;
+	skb_reserve(skb, prepad);
+	skb_put(skb, copy);
+
+	return skb;
+
+}
+
 static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 						size_t len, size_t linear,
 						int noblock, int *err)
@@ -447,15 +477,91 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 	return 0;
 }
 
+/* set skb frags from iovec, this can move to core network code for reuse */
+static int set_sg_from_iovec_zerocopy(struct sk_buff *skb,
+				      const struct iovec *from, int offset,
+				      size_t count)
+{
+	int len = iov_length(from, count) - offset;
+	int copy = skb_headlen(skb);
+	int size, offset1 = 0;
+	int i = 0;
+	skb_frag_t *f;
+
+	/* Skip over from offset */
+	while (offset >= from->iov_len) {
+		offset -= from->iov_len;
+		++from;
+		--count;
+	}
+
+	/* copy up to skb headlen */
+	while (copy > 0) {
+		size = min_t(unsigned int, copy, from->iov_len - offset);
+		if (copy_from_user(skb->data + offset1, from->iov_base + offset,
+				   size))
+			return -EFAULT;
+		if (copy > size) {
+			++from;
+			--count;
+		}
+		copy -= size;
+		offset1 += size;
+		offset = 0;
+	}
+
+	if (len == offset1)
+		return 0;
+
+	while (count--) {
+		struct page *page[MAX_SKB_FRAGS];
+		int num_pages;
+		unsigned long base;
+
+		len = from->iov_len - offset1;
+		if (!len) {
+			offset1 = 0;
+			++from;
+			continue;
+		}
+		base = (unsigned long)from->iov_base + offset1;
+		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
+		if ((num_pages != size) ||
+		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
+			/* put_page is in skb free */
+			return -EFAULT;
+		while (len) {
+			f = &skb_shinfo(skb)->frags[i];
+			f->page = page[i];
+			f->page_offset = base & ~PAGE_MASK;
+			f->size = min_t(int, len, PAGE_SIZE - f->page_offset);
+			skb->data_len += f->size;
+			skb->len += f->size;
+			skb->truesize += f->size;
+			skb_shinfo(skb)->nr_frags++;
+			/* increase sk_wmem_alloc */
+			if (skb->sk && skb->destructor == sock_wfree)
+				atomic_add(f->size, &skb->sk->sk_wmem_alloc);
+			base += f->size;
+			len -= f->size;
+			i++;
+		}
+		offset1 = 0;
+		++from;
+	}
+	return 0;
+}
 
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q,
-				const struct iovec *iv, size_t count,
-				int noblock)
+				const struct iovec *iv,
+				unsigned long total_len,
+				unsigned long count, int noblock)
 {
 	struct sk_buff *skb;
 	struct macvlan_dev *vlan;
-	size_t len = count;
+	unsigned len = total_len;
 	int err;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int vnet_hdr_len = 0;
@@ -485,12 +591,22 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	if (unlikely(len < ETH_HLEN))
 		goto err;
 
-	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, len, vnet_hdr.hdr_len,
-				noblock, &err);
+	if (sock_flag(&q->sk, SOCK_ZEROCOPY)) {
+		int copy = len > 2 * GOODCOPY_LEN ? GOODCOPY_LEN : len;
+		skb = macvtap_alloc_skb_goodcopy(&q->sk, NET_IP_ALIGN, copy,
+						 noblock, &err);
+	} else
+		skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, len,
+					vnet_hdr.hdr_len, noblock, &err);
 	if (!skb)
 		goto err;
 
-	err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len, len);
+	if (sock_flag(&q->sk, SOCK_ZEROCOPY))
+		err = set_sg_from_iovec_zerocopy(skb, iv, vnet_hdr_len, count);
+	else
+		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
+						   len);
+
 	if (err)
 		goto err_kfree;
 
@@ -512,7 +628,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 		kfree_skb(skb);
 	rcu_read_unlock_bh();
 
-	return count;
+	return total_len;
 
 err_kfree:
 	kfree_skb(skb);
@@ -534,8 +650,8 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 	ssize_t result = -ENOLINK;
 	struct macvtap_queue *q = file->private_data;
 
-	result = macvtap_get_user(q, iv, iov_length(iv, count),
-			      file->f_flags & O_NONBLOCK);
+	result = macvtap_get_user(q, iv, iov_length(iv, count), count,
+				  file->f_flags & O_NONBLOCK);
 	return result;
 }
 
@@ -748,7 +864,7 @@ static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
 			   struct msghdr *m, size_t total_len)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
-	return macvtap_get_user(q, m->msg_iov, total_len,
+	return macvtap_get_user(q, m->msg_iov, total_len, m->msg_iovlen,
 			    m->msg_flags & MSG_DONTWAIT);
 }
 


