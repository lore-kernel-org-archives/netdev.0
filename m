From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] tun: experimental zero copy tx support
Date: Sun, 13 May 2012 18:52:06 +0300
Message-ID: <20120513155206.GA26847@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab2EMPwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2012 11:52:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let vhost-net utilize zero copy tx when the experimental
zero copy mode is enabled and when used with tun.  This works on
top of the patchset 'copy aside frags with destructors' that I posted
previously. This is not using tcp so doesn't have the
issue with early skb cloning noticed by Ian.

For those that wish to test this with kvm, I intend to post a patchset +
git tree with just the necessary bits from the destructor patch
a bit later.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c |  125 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 120 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index fe5cd2f3..eb10ee7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -100,6 +100,8 @@ do {								\
 } while (0)
 #endif
 
+#define GOODCOPY_LEN 128
+
 #define FLT_EXACT_COUNT 8
 struct tap_filter {
 	unsigned int    count;    /* Number of addrs. Zero means disabled */
@@ -602,8 +604,80 @@ static struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
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
+
+	/* Skip over from offset */
+	while (count && (offset >= from->iov_len)) {
+		offset -= from->iov_len;
+		++from;
+		--count;
+	}
+
+	/* copy up to skb headlen */
+	while (count && (copy > 0)) {
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
+		atomic_add(len, &skb->sk->sk_wmem_alloc);
+		while (len) {
+			int off = base & ~PAGE_MASK;
+			int size = min_t(int, len, PAGE_SIZE - off);
+			__skb_fill_page_desc(skb, i, page[i], off, size);
+			skb_shinfo(skb)->nr_frags++;
+			/* increase sk_wmem_alloc */
+			base += size;
+			len -= size;
+			i++;
+		}
+		offset1 = 0;
+		++from;
+	}
+	return 0;
+}
+
 /* Get packet from user space buffer */
-static ssize_t tun_get_user(struct tun_struct *tun,
+static ssize_t tun_get_user(struct tun_struct *tun, void *msg_control,
 			    const struct iovec *iv, size_t count,
 			    int noblock)
 {
@@ -612,6 +686,9 @@ static ssize_t tun_get_user(struct tun_struct *tun,
 	size_t len = count, align = NET_SKB_PAD;
 	struct virtio_net_hdr gso = { 0 };
 	int offset = 0;
+	int copylen;
+	bool zerocopy = false;
+	int err;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) > count)
@@ -645,14 +722,47 @@ static ssize_t tun_get_user(struct tun_struct *tun,
 			return -EINVAL;
 	}
 
-	skb = tun_alloc_skb(tun, align, len, gso.hdr_len, noblock);
+	if (msg_control)
+		zerocopy = true;
+
+	if (zerocopy) {
+		/* Userspace may produce vectors with count greater than
+		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
+		 * to let the rest of data to be fit in the frags.
+		 */
+		if (count > MAX_SKB_FRAGS) {
+			copylen = iov_length(iv, count - MAX_SKB_FRAGS);
+			if (copylen < offset)
+				copylen = 0;
+			else
+				copylen -= offset;
+		} else
+				copylen = 0;
+		/* There are 256 bytes to be copied in skb, so there is enough
+		 * room for skb expand head in case it is used.
+		 * The rest of the buffer is mapped from userspace.
+		 */
+		if (copylen < gso.hdr_len)
+			copylen = gso.hdr_len;
+		if (!copylen)
+			copylen = GOODCOPY_LEN;
+	} else
+		copylen = len;
+
+	skb = tun_alloc_skb(tun, align, copylen, gso.hdr_len, noblock);
 	if (IS_ERR(skb)) {
 		if (PTR_ERR(skb) != -EAGAIN)
 			tun->dev->stats.rx_dropped++;
 		return PTR_ERR(skb);
 	}
 
-	if (skb_copy_datagram_from_iovec(skb, 0, iv, offset, len)) {
+	if (zerocopy) {
+		err = zerocopy_sg_from_iovec(skb, iv, offset, count);
+		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+	} else
+		err = skb_copy_datagram_from_iovec(skb, 0, iv, offset, len);
+
+	if (err) {
 		tun->dev->stats.rx_dropped++;
 		kfree_skb(skb);
 		return -EFAULT;
@@ -726,6 +836,10 @@ static ssize_t tun_get_user(struct tun_struct *tun,
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
+	/* copy skb_ubuf_info for callback when skb has no error */
+	if (zerocopy)
+		skb_shinfo(skb)->destructor_arg = msg_control;
+
 	netif_rx_ni(skb);
 
 	tun->dev->stats.rx_packets++;
@@ -746,7 +860,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 	tun_debug(KERN_INFO, tun, "tun_chr_write %ld\n", count);
 
-	result = tun_get_user(tun, iv, iov_length(iv, count),
+	result = tun_get_user(tun, NULL, iv, iov_length(iv, count),
 			      file->f_flags & O_NONBLOCK);
 
 	tun_put(tun);
@@ -960,7 +1074,7 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
 	struct tun_struct *tun = container_of(sock, struct tun_struct, socket);
-	return tun_get_user(tun, m->msg_iov, total_len,
+	return tun_get_user(tun, m->msg_control, m->msg_iov, total_len,
 			    m->msg_flags & MSG_DONTWAIT);
 }
 
@@ -1130,6 +1244,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space = tun_sock_write_space;
 		sk->sk_sndbuf = INT_MAX;
+		sock_set_flag(sk, SOCK_ZEROCOPY);
 
 		tun_sk(sk)->tun = tun;
 
-- 
MST
