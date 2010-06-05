From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 17/19] Export proto_ops to vhost-net driver.
Date: Sat,  5 Jun 2010 18:14:56 +0800
Message-ID: <1275732899-5423-17-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-10-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-12-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-13-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-14-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-15-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-16-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65455 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932945Ab0FEKHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 06:07:19 -0400
In-Reply-To: <1275732899-5423-16-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Currently, vhost-net is only user to the mp device.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 drivers/vhost/mpassthru.c |  295 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 290 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/mpassthru.c b/drivers/vhost/mpassthru.c
index 8c48898..23755ba 100644
--- a/drivers/vhost/mpassthru.c
+++ b/drivers/vhost/mpassthru.c
@@ -414,6 +414,11 @@ static void mp_put(struct mp_file *mfile)
 		mp_detach(mfile->mp);
 }
 
+static void iocb_tag(struct kiocb *iocb)
+{
+	iocb->ki_flags = 1;
+}
+
 /* The callback to destruct the external buffers or skb */
 static void page_dtor(struct skb_external_page *ext_page)
 {
@@ -449,7 +454,7 @@ static void page_dtor(struct skb_external_page *ext_page)
 	 * Queue the notifier to wake up the backend driver
 	 */
 
-	create_iocb(info, info->total);
+	iocb_tag(info->iocb);
 
 	sk = ctor->port.sock->sk;
 	sk->sk_write_space(sk);
@@ -569,8 +574,288 @@ failed:
 	return NULL;
 }
 
+static void mp_sock_destruct(struct sock *sk)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	kfree(mp);
+}
+
+static void mp_sock_state_change(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN);
+}
+
+static void mp_sock_write_space(struct sock *sk)
+{
+	if (sk_has_sleeper(sk))
+		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT);
+}
+
+static void mp_sock_data_ready(struct sock *sk, int coming)
+{
+	struct mp_struct *mp = container_of(sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor = NULL;
+	struct sk_buff *skb = NULL;
+	struct page_info *info = NULL;
+	struct ethhdr *eth;
+	struct kiocb *iocb = NULL;
+	int len, i;
+
+	struct virtio_net_hdr hdr = {
+		.flags = 0,
+		.gso_type = VIRTIO_NET_HDR_GSO_NONE
+	};
+
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return;
+
+	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
+		if (skb_shinfo(skb)->destructor_arg) {
+			info = container_of(skb_shinfo(skb)->destructor_arg,
+					struct page_info, ext_page);
+			info->skb = skb;
+			if (skb->len > info->len) {
+				mp->dev->stats.rx_dropped++;
+				DBG(KERN_INFO "Discarded truncated rx packet: "
+				    " len %d > %zd\n", skb->len, info->len);
+				info->total = skb->len;
+				goto clean;
+			} else {
+				eth = eth_hdr(skb);
+				skb_push(skb, ETH_HLEN);
+				info->total = skb->len;
+			}
+		} else {
+			/* The skb composed with kernel buffers
+			 * in case external buffers are not sufficent.
+			 * The case should be rare.
+			 */
+			unsigned long flags;
+			int i;
+			info = NULL;
+
+			spin_lock_irqsave(&ctor->read_lock, flags);
+			if (!list_empty(&ctor->readq)) {
+				info = list_first_entry(&ctor->readq,
+						struct page_info, list);
+				list_del(&info->list);
+			}
+			spin_unlock_irqrestore(&ctor->read_lock, flags);
+			if (!info) {
+				DBG(KERN_INFO
+				    "No external buffer avaliable %p\n",
+				    skb);
+				skb_queue_head(&sk->sk_receive_queue,
+						skb);
+				break;
+			}
+			info->skb = skb;
+			eth = eth_hdr(skb);
+			skb_push(skb, ETH_HLEN);
+			info->total = skb->len;
+			skb_copy_datagram_iovec(skb, 0, info->iov, skb->len);
+		}
+
+		len = memcpy_toiovec(info->hdr, (unsigned char *)&hdr,
+				sizeof hdr);
+		if (len) {
+			DBG(KERN_INFO
+				"Unable to write vnet_hdr at addr %p: %d\n",
+				info->hdr->iov_base, len);
+			goto clean;
+		}
+
+		iocb = create_iocb(info, skb->len + sizeof(hdr));
+		continue;
+
+clean:
+		kfree_skb(skb);
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ext_page_info_cache, info);
+	}
+	return;
+}
+
+static int mp_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct iovec *iov = m->msg_iov;
+	struct page_info *info = NULL;
+	struct frag frags[MAX_SKB_FRAGS];
+	struct sk_buff *skb;
+	int count = m->msg_iovlen;
+	int total = 0, header, n, i, len, rc;
+	unsigned long base;
+
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return -ENODEV;
+
+	total = iov_length(iov, count);
+
+	if (total < ETH_HLEN)
+		return -EINVAL;
+
+	if (total <= COPY_THRESHOLD)
+		goto copy;
+
+	n = 0;
+	for (i = 0; i < count; i++) {
+		base = (unsigned long)iov[i].iov_base;
+		len = iov[i].iov_len;
+		if (!len)
+			continue;
+		n += ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
+		if (n > MAX_SKB_FRAGS)
+			return -EINVAL;
+	}
+
+copy:
+	header = total > COPY_THRESHOLD ? COPY_HDR_LEN : total;
+
+	skb = alloc_skb(header + NET_IP_ALIGN, GFP_ATOMIC);
+	if (!skb)
+		goto drop;
+
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	skb_set_network_header(skb, ETH_HLEN);
+
+	memcpy_fromiovec(skb->data, iov, header);
+	skb_put(skb, header);
+	skb->protocol = *((__be16 *)(skb->data) + ETH_ALEN);
+
+	if (header == total) {
+		rc = total;
+		info = alloc_small_page_info(ctor, iocb, total);
+	} else {
+		info = alloc_page_info(ctor, iocb, iov, count, frags, 0, total);
+		if (info)
+			for (i = 0; info->pages[i]; i++) {
+				skb_add_rx_frag(skb, i, info->pages[i],
+						frags[i].offset, frags[i].size);
+				info->pages[i] = NULL;
+			}
+	}
+	if (info != NULL) {
+		info->desc_pos = iocb->ki_pos;
+		info->total = total;
+		info->skb = skb;
+		skb_shinfo(skb)->destructor_arg = &info->ext_page;
+		skb->dev = mp->dev;
+		ctor->wq_len++;
+		create_iocb(info, info->total);
+		dev_queue_xmit(skb);
+		return 0;
+	}
+drop:
+	kfree_skb(skb);
+	if (info) {
+		for (i = 0; info->pages[i]; i++)
+			put_page(info->pages[i]);
+		kmem_cache_free(ext_page_info_cache, info);
+	}
+	mp->dev->stats.tx_dropped++;
+	return -ENOMEM;
+}
+
+static int mp_recvmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *m, size_t total_len,
+		int flags)
+{
+	struct mp_struct *mp = container_of(sock->sk, struct mp_sock, sk)->mp;
+	struct page_ctor *ctor;
+	struct iovec *iov = m->msg_iov;
+	int count = m->msg_iovlen;
+	int npages, payload;
+	struct page_info *info;
+	struct frag frags[MAX_SKB_FRAGS];
+	unsigned long base;
+	int i, len;
+	unsigned long flag;
+
+	if (!(flags & MSG_DONTWAIT))
+		return -EINVAL;
+
+	ctor = rcu_dereference(mp->ctor);
+	if (!ctor)
+		return -EINVAL;
+
+	/* Error detections in case invalid external buffer */
+	if (count > 2 && iov[1].iov_len < ctor->port.hdr_len &&
+			mp->dev->features & NETIF_F_SG) {
+		return -EINVAL;
+	}
+
+	npages = ctor->port.npages;
+	payload = ctor->port.data_len;
+
+	/* If KVM guest virtio-net FE driver use SG feature */
+	if (count > 2) {
+		for (i = 2; i < count; i++) {
+			base = (unsigned long)iov[i].iov_base & ~PAGE_MASK;
+			len = iov[i].iov_len;
+			if (npages == 1)
+				len = min_t(int, len, PAGE_SIZE - base);
+			else if (base)
+				break;
+			payload -= len;
+			if (payload <= 0)
+				goto proceed;
+			if (npages == 1 || (len & ~PAGE_MASK))
+				break;
+		}
+	}
+
+	if ((((unsigned long)iov[1].iov_base & ~PAGE_MASK)
+				- NET_SKB_PAD - NET_IP_ALIGN) >= 0)
+		goto proceed;
+
+	return -EINVAL;
+
+proceed:
+	/* skip the virtnet head */
+	iov++;
+	count--;
+
+	if (!ctor->lock_pages || !ctor->rq_len)
+		set_memlock_rlimit(ctor, RLIMIT_MEMLOCK,
+				iocb->ki_user_data * 4096 * 2,
+				iocb->ki_user_data * 4096 * 2);
+
+	/* Translate address to kernel */
+	info = alloc_page_info(ctor, iocb, iov, count, frags, npages, 0);
+	if (!info)
+		return -ENOMEM;
+	info->len = total_len;
+	info->hdr[0].iov_base = iocb->ki_iovec[0].iov_base;
+	info->hdr[0].iov_len = iocb->ki_iovec[0].iov_len;
+	info->offset = frags[0].offset;
+	info->desc_pos = iocb->ki_pos;
+
+	iov--;
+	count++;
+
+	memcpy(info->iov, iov, sizeof(struct iovec) * count);
+
+	spin_lock_irqsave(&ctor->read_lock, flag);
+	list_add_tail(&info->list, &ctor->readq);
+	spin_unlock_irqrestore(&ctor->read_lock, flag);
+
+	ctor->rq_len++;
+
+	return 0;
+}
+
 /* Ops structure to mimic raw sockets with mp device */
 static const struct proto_ops mp_socket_ops = {
+	.sendmsg = mp_sendmsg,
+	.recvmsg = mp_recvmsg,
 };
 
 static struct proto mp_proto = {
@@ -693,10 +978,10 @@ static long mp_chr_ioctl(struct file *file, unsigned int cmd,
 		sk->sk_sndbuf = INT_MAX;
 		container_of(sk, struct mp_sock, sk)->mp = mp;
 
-		sk->sk_destruct = NULL;
-		sk->sk_data_ready = NULL;
-		sk->sk_write_space = NULL;
-		sk->sk_state_change = NULL;
+		sk->sk_destruct = mp_sock_destruct;
+		sk->sk_data_ready = mp_sock_data_ready;
+		sk->sk_write_space = mp_sock_write_space;
+		sk->sk_state_change = mp_sock_state_change;
 		ret = mp_attach(mp, file);
 		if (ret < 0)
 			goto err_free_sk;
-- 
1.5.4.4

