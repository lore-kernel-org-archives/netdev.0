From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V4 5/8]macvtap: macvtap TX zero-copy support
Date: Wed, 04 May 2011 01:14:53 -0700
Message-ID: <1304496893.20660.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only when buffer size is greater than GOODCOPY_LEN (256), macvtap
enables zero-copy.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/net/macvtap.c |  126 ++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 115 insertions(+), 11 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 6696e56..e8bc5ff 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -60,6 +60,7 @@ static struct proto macvtap_proto = {
  */
 static dev_t macvtap_major;
 #define MACVTAP_NUM_DEVS 65536
+#define GOODCOPY_LEN 256
 static struct class *macvtap_class;
 static struct cdev macvtap_cdev;
 
@@ -340,6 +341,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 {
 	struct net *net = current->nsproxy->net_ns;
 	struct net_device *dev = dev_get_by_index(net, iminor(inode));
+	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *q;
 	int err;
 
@@ -369,6 +371,16 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
 	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
+	/*
+	 * so far only VM uses macvtap, enable zero copy between guest
+	 * kernel and host kernel when lower device supports high memory
+	 * DMA
+	 */
+	if (vlan) {
+		if (vlan->lowerdev->features & NETIF_F_ZEROCOPY)
+			sock_set_flag(&q->sk, SOCK_ZEROCOPY);
+	}
+
 	err = macvtap_set_queue(dev, file, q);
 	if (err)
 		sock_put(&q->sk);
@@ -433,6 +445,80 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 	return skb;
 }
 
+/* set skb frags from iovec, this can move to core network code for reuse */
+static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
+				  int offset, size_t count)
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
+		skb->data_len += len;
+		skb->len += len;
+		skb->truesize += len;
+		while (len) {
+			f = &skb_shinfo(skb)->frags[i];
+			f->page = page[i];
+			f->page_offset = base & ~PAGE_MASK;
+			f->size = min_t(int, len, PAGE_SIZE - f->page_offset);
+			skb_shinfo(skb)->nr_frags++;
+			/* increase sk_wmem_alloc */
+			atomic_add(f->size, &skb->sk->sk_wmem_alloc);
+			base += f->size;
+			len -= f->size;
+			i++;
+		}
+		offset1 = 0;
+		++from;
+	}
+	return 0;
+}
+
 /*
  * macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
  * be shared with the tun/tap driver.
@@ -515,17 +601,19 @@ static int macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 
 
 /* Get packet from user space buffer */
-static ssize_t macvtap_get_user(struct macvtap_queue *q,
-				const struct iovec *iv, size_t count,
-				int noblock)
+static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
+				const struct iovec *iv, unsigned long total_len,
+				size_t count, int noblock)
 {
 	struct sk_buff *skb;
 	struct macvlan_dev *vlan;
-	size_t len = count;
+	unsigned long len = total_len;
 	int err;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int vnet_hdr_len = 0;
+	int copylen, zerocopy;
 
+	zerocopy = sock_flag(&q->sk, SOCK_ZEROCOPY) && (len > GOODCOPY_LEN);
 	if (q->flags & IFF_VNET_HDR) {
 		vnet_hdr_len = q->vnet_hdr_sz;
 
@@ -552,12 +640,28 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	if (unlikely(len < ETH_HLEN))
 		goto err;
 
-	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, len, vnet_hdr.hdr_len,
-				noblock, &err);
+	if (zerocopy)
+		/* There are 256 bytes to be copied in skb, so there is enough
+		 * room for skb expand head in case it is used.
+		 * The rest buffer is mapped from userspace.
+		 */
+		copylen = GOODCOPY_LEN;
+	else
+		copylen = len;
+
+	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
+				vnet_hdr.hdr_len, noblock, &err);
 	if (!skb)
 		goto err;
 
-	err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len, len);
+	if (zerocopy)
+		err = zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
+	else
+		err = skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
+						   len);
+	if (sock_flag(&q->sk, SOCK_ZEROCOPY))
+		memcpy(&skb_shinfo(skb)->ubuf, m->msg_control,
+			sizeof(struct skb_ubuf_info));
 	if (err)
 		goto err_kfree;
 
@@ -579,7 +683,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 		kfree_skb(skb);
 	rcu_read_unlock_bh();
 
-	return count;
+	return total_len;
 
 err_kfree:
 	kfree_skb(skb);
@@ -601,8 +705,8 @@ static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
 	ssize_t result = -ENOLINK;
 	struct macvtap_queue *q = file->private_data;
 
-	result = macvtap_get_user(q, iv, iov_length(iv, count),
-			      file->f_flags & O_NONBLOCK);
+	result = macvtap_get_user(q, NULL, iv, iov_length(iv, count), count,
+				  file->f_flags & O_NONBLOCK);
 	return result;
 }
 
@@ -815,7 +919,7 @@ static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
 			   struct msghdr *m, size_t total_len)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
-	return macvtap_get_user(q, m->msg_iov, total_len,
+	return macvtap_get_user(q, m, m->msg_iov, total_len, m->msg_iovlen,
 			    m->msg_flags & MSG_DONTWAIT);
 }
 
