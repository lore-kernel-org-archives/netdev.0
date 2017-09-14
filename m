From: Ilya Lesokhin <ilyal@mellanox.com>
Subject: [PATCH net-next 5/5] tls: Add generic NIC offload infrastructure.
Date: Thu, 14 Sep 2017 13:46:28 +0300
Message-ID: <1505385988-94522-6-git-send-email-ilyal@mellanox.com>
References: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Cc: davejwatson@fb.com, tom@herbertland.com,
        hannes@stressinduktion.org, borisp@mellanox.com,
        ilyal@mellanox.com, aviadye@mellanox.com, liranl@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37234 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751829AbdINKqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:46:35 -0400
In-Reply-To: <1505385988-94522-1-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a generic infrastructure to offload TLS crypto to a
network devices. It enables the kernel TLS socket to skip encryption and
authentication operations on the transmit side of the data path. Leaving
those computationally expensive operations to the NIC.

The NIC offload infrastructure builds TLS records and pushes them to the
TCP layer just like the SW KTLS implementation and using the same API.
TCP segmentation is mostly unaffected. Currently the only exception is
that we prevent mixed SKBs where only part of the payload requires
offload. In the future we are likely to add a similar restriction
following a change cipher spec record.

The notable differences between SW KTLS and NIC offloaded TLS
implementations are as follows:
1. The offloaded implementation builds "plaintext TLS record", those
records contain plaintext instead of ciphertext and place holder bytes
instead of authentication tags.
2. The offloaded implementation maintains a mapping from TCP sequence
number to TLS records. Thus given a TCP SKB sent from a NIC offloaded
 TLS socket, we can use the tls NIC offload infrastructure to obtain
enough context to encrypt the payload of the SKB.
A TLS record is released when the last byte of the record is ack'ed,
this is done through the new icsk_clean_acked callback.

The infrastructure should be extendable to support various NIC offload
implementations.  However it is currently written with the
implementation below in mind:
The NIC assumes that packets from each offloaded stream are sent as
plaintext and in-order. It keeps track of the TLS records in the TCP
stream. When a packet marked for offload is transmitted, the NIC
encrypts the payload in-place and puts authentication tags in the
relevant place holders.

The responsibility for handling out-of-order packets (i.e. TCP
retransmission, qdisc drops) falls on the netdev driver.

The netdev driver keeps track of the expected TCP SN from the NIC's
perspective.  If the next packet to transmit matches the expected TCP
SN, the driver advances the expected TCP SN, and transmits the packet
with TLS offload indication.

If the next packet to transmit does not match the expected TCP SN. The
driver calls the TLS layer to obtain the TLS record that includes the
TCP of the packet for transmission. Using this TLS record, the driver
posts a work entry on the transmit queue to reconstruct the NIC TLS
state required for the offload of the out-of-order packet. It updates
the expected TCP SN accordingly and transmit the now in-order packet.
The same queue is used for packet transmission and TLS context
reconstruction to avoid the need for flushing the transmit queue before
issuing the context reconstruction request.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 include/net/tls.h    |  41 +++-
 net/tls/Kconfig      |   9 +
 net/tls/Makefile     |   3 +
 net/tls/tls_device.c | 673 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tls/tls_main.c   |  63 +++--
 5 files changed, 771 insertions(+), 18 deletions(-)
 create mode 100644 net/tls/tls_device.c

diff --git a/include/net/tls.h b/include/net/tls.h
index b89d397..1f83c8e 100644
--- a/include/net/tls.h
+++ b/include/net/tls.h
@@ -71,6 +71,24 @@ struct tls_sw_context {
 	struct scatterlist sg_aead_out[2];
 };
 
+struct tls_record_info {
+	struct list_head list;
+	u32 end_seq;
+	int len;
+	int num_frags;
+	skb_frag_t frags[MAX_SKB_FRAGS];
+};
+
+struct tls_offload_context {
+	struct list_head records_list;
+	struct scatterlist sg_tx_data[MAX_SKB_FRAGS];
+	void (*sk_destruct)(struct sock *sk);
+	struct tls_record_info *open_record;
+	struct tls_record_info *retransmit_hint;
+	u32 expected_seq;
+	spinlock_t lock;	/* protects records list */
+};
+
 enum {
 	TLS_PENDING_CLOSED_RECORD
 };
@@ -81,6 +99,9 @@ struct tls_context {
 		struct tls12_crypto_info_aes_gcm_128 crypto_send_aes_gcm_128;
 	};
 
+	struct list_head gclist;
+	struct sock *sk;
+	struct net_device *netdev;
 	void *priv_ctx;
 
 	u16 prepend_size;
@@ -123,9 +144,18 @@ int tls_sw_sendpage(struct sock *sk, struct page *page,
 		    int offset, size_t size, int flags);
 void tls_sw_close(struct sock *sk, long timeout);
 
-void tls_sk_destruct(struct sock *sk, struct tls_context *ctx);
-void tls_icsk_clean_acked(struct sock *sk);
+void tls_clear_device_offload(struct sock *sk, struct tls_context *ctx);
+int tls_set_device_offload(struct sock *sk, struct tls_context *ctx);
+int tls_device_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
+int tls_device_sendpage(struct sock *sk, struct page *page,
+			int offset, size_t size, int flags);
+void tls_device_sk_destruct(struct sock *sk);
+void tls_device_cleanup(void);
 
+struct tls_record_info *tls_get_record(struct tls_offload_context *context,
+				       u32 seq);
+
+void tls_sk_destruct(struct sock *sk, struct tls_context *ctx);
 int tls_push_sg(struct sock *sk, struct tls_context *ctx,
 		struct scatterlist *sg, u16 first_offset,
 		int flags);
@@ -162,6 +192,13 @@ static inline bool tls_is_pending_open_record(struct tls_context *tls_ctx)
 	return tls_ctx->pending_open_record_frags;
 }
 
+static inline bool tls_is_sk_tx_device_offloaded(struct sock *sk)
+{
+	/* matches smp_store_release in tls_set_device_offload */
+	return	smp_load_acquire(&sk->sk_destruct) ==
+			&tls_device_sk_destruct;
+}
+
 static inline void tls_err_abort(struct sock *sk)
 {
 	sk->sk_err = -EBADMSG;
diff --git a/net/tls/Kconfig b/net/tls/Kconfig
index eb58303..1a4ea55c 100644
--- a/net/tls/Kconfig
+++ b/net/tls/Kconfig
@@ -13,3 +13,12 @@ config TLS
 	encryption handling of the TLS protocol to be done in-kernel.
 
 	If unsure, say N.
+
+config TLS_DEVICE
+	bool "Transport Layer Security HW offload"
+	depends on TLS
+	default n
+	---help---
+	Enable kernel support for HW offload of the TLS protocol.
+
+	If unsure, say N.
diff --git a/net/tls/Makefile b/net/tls/Makefile
index a930fd1..9de5055 100644
--- a/net/tls/Makefile
+++ b/net/tls/Makefile
@@ -5,3 +5,6 @@
 obj-$(CONFIG_TLS) += tls.o
 
 tls-y := tls_main.o tls_sw.o
+
+tls-$(CONFIG_TLS_DEVICE) += tls_device.o
+
diff --git a/net/tls/tls_device.c b/net/tls/tls_device.c
new file mode 100644
index 0000000..94a25c2
--- /dev/null
+++ b/net/tls/tls_device.c
@@ -0,0 +1,673 @@
+/* Copyright (c) 2016-2017, Mellanox Technologies All rights reserved.
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ *      - Neither the name of the Mellanox Technologies nor the
+ *        names of its contributors may be used to endorse or promote
+ *        products derived from this software without specific prior written
+ *        permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
+ * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+ * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
+ * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
+ * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE
+ */
+
+#include <linux/module.h>
+#include <net/tcp.h>
+#include <net/inet_common.h>
+#include <linux/highmem.h>
+#include <linux/netdevice.h>
+
+#include <net/tls.h>
+
+static void tls_device_gc_task(struct work_struct *work);
+
+static DECLARE_WORK(tls_device_gc_work, tls_device_gc_task);
+static LIST_HEAD(tls_device_gc_list);
+static DEFINE_SPINLOCK(tls_device_gc_lock);
+
+static void tls_device_gc_task(struct work_struct *work)
+{
+	struct tls_context *ctx, *tmp;
+	struct list_head gc_list;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tls_device_gc_lock, flags);
+	INIT_LIST_HEAD(&gc_list);
+	list_splice_init(&tls_device_gc_list, &gc_list);
+	spin_unlock_irqrestore(&tls_device_gc_lock, flags);
+
+	list_for_each_entry_safe(ctx, tmp, &gc_list, gclist) {
+		struct tls_offload_context *offlad_ctx = tls_offload_ctx(ctx);
+		void (*sk_destruct)(struct sock *sk) = offlad_ctx->sk_destruct;
+		struct net_device *netdev = ctx->netdev;
+		struct sock *sk = ctx->sk;
+
+		netdev->tlsdev_ops->tls_dev_del(netdev, sk,
+						TLS_OFFLOAD_CTX_DIR_TX);
+
+		list_del(&ctx->gclist);
+		kfree(offlad_ctx);
+		kfree(ctx);
+		sk_destruct(sk);
+	}
+}
+
+static void tls_device_queue_ctx_destruction(struct tls_context *ctx)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&tls_device_gc_lock, flags);
+	list_add_tail(&ctx->gclist, &tls_device_gc_list);
+	spin_unlock_irqrestore(&tls_device_gc_lock, flags);
+
+	schedule_work(&tls_device_gc_work);
+}
+
+/* We assume that the socket is already connected */
+static struct net_device *get_netdev_for_sock(struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct net_device *netdev = NULL;
+
+	netdev = dev_get_by_index(sock_net(sk), inet->cork.fl.flowi_oif);
+
+	return netdev;
+}
+
+static void detach_sock_from_netdev(struct sock *sk, struct tls_context *ctx)
+{
+	struct net_device *netdev;
+
+	netdev = get_netdev_for_sock(sk);
+	if (!netdev) {
+		pr_err("got offloaded socket with no netdev\n");
+		return;
+	}
+
+	if (!netdev->tlsdev_ops) {
+		pr_err("attach_sock_to_netdev: netdev %s with no TLS offload\n",
+		       netdev->name);
+		return;
+	}
+
+	netdev->tlsdev_ops->tls_dev_del(netdev, sk, TLS_OFFLOAD_CTX_DIR_TX);
+	dev_put(netdev);
+}
+
+static int attach_sock_to_netdev(struct sock *sk, struct net_device *netdev,
+				 struct tls_context *ctx)
+{
+	int rc;
+
+	rc = netdev->tlsdev_ops->tls_dev_add(
+			netdev,
+			sk,
+			TLS_OFFLOAD_CTX_DIR_TX,
+			&ctx->crypto_send);
+	if (rc) {
+		pr_err("The netdev has refused to offload this socket\n");
+		goto out;
+	}
+
+	sk->sk_bound_dev_if = netdev->ifindex;
+	sk_dst_reset(sk);
+
+	rc = 0;
+out:
+	return rc;
+}
+
+static void destroy_record(struct tls_record_info *record)
+{
+	skb_frag_t *frag;
+	int nr_frags = record->num_frags;
+
+	while (nr_frags > 0) {
+		frag = &record->frags[nr_frags - 1];
+		__skb_frag_unref(frag);
+		--nr_frags;
+	}
+	kfree(record);
+}
+
+static void delete_all_records(struct tls_offload_context *offload_ctx)
+{
+	struct tls_record_info *info, *temp;
+
+	list_for_each_entry_safe(info, temp, &offload_ctx->records_list, list) {
+		list_del(&info->list);
+		destroy_record(info);
+	}
+
+	offload_ctx->retransmit_hint = NULL;
+}
+
+static void tls_icsk_clean_acked(struct sock *sk)
+{
+	struct tls_context *tls_ctx = tls_get_ctx(sk);
+	struct tls_offload_context *ctx;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tls_record_info *info, *temp;
+	unsigned long flags;
+
+	if (!tls_ctx)
+		return;
+
+	ctx = tls_offload_ctx(tls_ctx);
+
+	spin_lock_irqsave(&ctx->lock, flags);
+	info = ctx->retransmit_hint;
+	if (info && !before(tp->snd_una, info->end_seq)) {
+		ctx->retransmit_hint = NULL;
+		list_del(&info->list);
+		destroy_record(info);
+	}
+
+	list_for_each_entry_safe(info, temp, &ctx->records_list, list) {
+		if (before(tp->snd_una, info->end_seq))
+			break;
+		list_del(&info->list);
+
+		destroy_record(info);
+	}
+
+	spin_unlock_irqrestore(&ctx->lock, flags);
+}
+
+static void tls_device_free_resources(struct sock *sk)
+{
+	struct tls_context *tls_ctx = tls_get_ctx(sk);
+	struct tls_offload_context *ctx = tls_offload_ctx(tls_ctx);
+
+	if (ctx->open_record)
+		destroy_record(ctx->open_record);
+}
+
+/* At this point, there should be no references on this
+ * socket and no in-flight SKBs associated with this
+ * socket, so it is safe to free all the resources.
+ */
+void tls_device_sk_destruct(struct sock *sk)
+{
+	struct tls_context *tls_ctx = tls_get_ctx(sk);
+	struct tls_offload_context *ctx = tls_offload_ctx(tls_ctx);
+
+	delete_all_records(ctx);
+
+	tls_device_queue_ctx_destruction(tls_ctx);
+}
+EXPORT_SYMBOL(tls_device_sk_destruct);
+
+static inline void tls_append_frag(struct tls_record_info *record,
+				   struct page_frag *pfrag,
+				   int size)
+{
+	skb_frag_t *frag;
+
+	frag = &record->frags[record->num_frags - 1];
+	if (frag->page.p == pfrag->page &&
+	    frag->page_offset + frag->size == pfrag->offset) {
+		frag->size += size;
+	} else {
+		++frag;
+		frag->page.p = pfrag->page;
+		frag->page_offset = pfrag->offset;
+		frag->size = size;
+		++record->num_frags;
+		get_page(pfrag->page);
+	}
+
+	pfrag->offset += size;
+	record->len += size;
+}
+
+static inline int tls_push_record(struct sock *sk,
+				  struct tls_context *ctx,
+				  struct tls_offload_context *offload_ctx,
+				  struct tls_record_info *record,
+				  struct page_frag *pfrag,
+				  int flags,
+				  unsigned char record_type)
+{
+	skb_frag_t *frag;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct page_frag fallback_frag;
+	struct page_frag  *tag_pfrag = pfrag;
+	int i;
+
+	/* fill prepand */
+	frag = &record->frags[0];
+	tls_fill_prepend(ctx,
+			 skb_frag_address(frag),
+			 record->len - ctx->prepend_size,
+			 record_type);
+
+	if (unlikely(!skb_page_frag_refill(
+				ctx->tag_size,
+				pfrag, GFP_KERNEL))) {
+		/* HW doesn't care about the data in the tag
+		 * so in case pfrag has no room
+		 * for a tag and we can't allocate a new pfrag
+		 * just use the page in the first frag
+		 * rather then write a complicated fall back code.
+		 */
+		tag_pfrag = &fallback_frag;
+		tag_pfrag->page = skb_frag_page(frag);
+		tag_pfrag->offset = 0;
+	}
+
+	tls_append_frag(record, tag_pfrag, ctx->tag_size);
+	record->end_seq = tp->write_seq + record->len;
+	spin_lock_irq(&offload_ctx->lock);
+	list_add_tail(&record->list, &offload_ctx->records_list);
+	spin_unlock_irq(&offload_ctx->lock);
+	offload_ctx->open_record = NULL;
+	set_bit(TLS_PENDING_CLOSED_RECORD, &ctx->flags);
+	tls_advance_record_sn(sk, ctx);
+
+	for (i = 0; i < record->num_frags; i++) {
+		frag = &record->frags[i];
+		sg_unmark_end(&offload_ctx->sg_tx_data[i]);
+		sg_set_page(&offload_ctx->sg_tx_data[i], skb_frag_page(frag),
+			    frag->size, frag->page_offset);
+		sk_mem_charge(sk, frag->size);
+		get_page(skb_frag_page(frag));
+	}
+	sg_mark_end(&offload_ctx->sg_tx_data[record->num_frags - 1]);
+
+	/* all ready, send */
+	return tls_push_sg(sk, ctx, offload_ctx->sg_tx_data, 0, flags);
+}
+
+static inline int tls_create_new_record(
+		struct tls_offload_context *offload_ctx,
+		struct page_frag *pfrag,
+		size_t prepend_size)
+{
+	skb_frag_t *frag;
+	struct tls_record_info *record;
+
+	record = kmalloc(sizeof(*record), GFP_KERNEL);
+	if (!record)
+		return -ENOMEM;
+
+	frag = &record->frags[0];
+	__skb_frag_set_page(frag, pfrag->page);
+	frag->page_offset = pfrag->offset;
+	skb_frag_size_set(frag, prepend_size);
+
+	get_page(pfrag->page);
+	pfrag->offset += prepend_size;
+
+	record->num_frags = 1;
+	record->len = prepend_size;
+	offload_ctx->open_record = record;
+	return 0;
+}
+
+static inline int tls_do_allocation(
+		struct sock *sk,
+		struct tls_offload_context *offload_ctx,
+		struct page_frag *pfrag,
+		size_t prepend_size)
+{
+	int ret;
+
+	if (!offload_ctx->open_record) {
+		if (unlikely(!skb_page_frag_refill(prepend_size, pfrag,
+						   sk->sk_allocation))) {
+			sk->sk_prot->enter_memory_pressure(sk);
+			sk_stream_moderate_sndbuf(sk);
+			return -ENOMEM;
+		}
+
+		ret = tls_create_new_record(offload_ctx, pfrag, prepend_size);
+		if (ret)
+			return ret;
+
+		if (pfrag->size > pfrag->offset)
+			return 0;
+	}
+
+	if (!sk_page_frag_refill(sk, pfrag))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int tls_push_data(struct sock *sk,
+			 struct iov_iter *msg_iter,
+			 size_t size, int flags,
+			 unsigned char record_type)
+{
+	struct tls_context *tls_ctx = tls_get_ctx(sk);
+	struct tls_offload_context *ctx = tls_offload_ctx(tls_ctx);
+	struct tls_record_info *record = ctx->open_record;
+	struct page_frag *pfrag;
+	int copy, rc = 0;
+	size_t orig_size = size;
+	u32 max_open_record_len;
+	long timeo;
+	int more = flags & (MSG_SENDPAGE_NOTLAST | MSG_MORE);
+	int tls_push_record_flags = flags | MSG_SENDPAGE_NOTLAST;
+	bool done = false;
+
+	if (sk->sk_err)
+		return -sk->sk_err;
+
+	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	rc = tls_complete_pending_work(sk, tls_ctx, flags, &timeo);
+	if (rc < 0)
+		return rc;
+
+	pfrag = sk_page_frag(sk);
+
+	/* KTLS_TLS_HEADER_SIZE is not counted as part of the TLS record, and
+	 * we need to leave room for an authentication tag.
+	 */
+	max_open_record_len = TLS_MAX_PAYLOAD_SIZE +
+			      tls_ctx->prepend_size;
+	do {
+		if (tls_do_allocation(sk, ctx, pfrag,
+				      tls_ctx->prepend_size)) {
+			rc = sk_stream_wait_memory(sk, &timeo);
+			if (!rc)
+				continue;
+
+			record = ctx->open_record;
+			if (!record)
+				break;
+handle_error:
+			if (record_type != TLS_RECORD_TYPE_DATA) {
+				/* avoid sending partial
+				 * record with type !=
+				 * application_data
+				 */
+				size = orig_size;
+				destroy_record(record);
+				ctx->open_record = NULL;
+			} else if (record->len > tls_ctx->prepend_size) {
+				goto last_record;
+			}
+
+			break;
+		}
+
+		record = ctx->open_record;
+		copy = min_t(size_t, size, (pfrag->size - pfrag->offset));
+		copy = min_t(size_t, copy, (max_open_record_len - record->len));
+
+		if (copy_from_iter_nocache(
+				page_address(pfrag->page) + pfrag->offset,
+				copy, msg_iter) != copy) {
+			rc = -EFAULT;
+			goto handle_error;
+		}
+		tls_append_frag(record, pfrag, copy);
+
+		size -= copy;
+		if (!size) {
+last_record:
+			tls_push_record_flags = flags;
+			if (more) {
+				tls_ctx->pending_open_record_frags =
+						record->num_frags;
+				break;
+			}
+
+			done = true;
+		}
+
+		if ((done) ||
+		    (record->len >= max_open_record_len) ||
+		    (record->num_frags >= MAX_SKB_FRAGS - 1)) {
+			rc = tls_push_record(sk,
+					     tls_ctx,
+					     ctx,
+					     record,
+					     pfrag,
+					     tls_push_record_flags,
+					     record_type);
+			if (rc < 0)
+				break;
+		}
+	} while (!done);
+
+	if (orig_size - size > 0)
+		rc = orig_size - size;
+
+	return rc;
+}
+
+int tls_device_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
+{
+	unsigned char record_type = TLS_RECORD_TYPE_DATA;
+	int rc = 0;
+
+	lock_sock(sk);
+
+	if (unlikely(msg->msg_controllen)) {
+		rc = tls_proccess_cmsg(sk, msg, &record_type);
+		if (rc)
+			goto out;
+	}
+
+	rc = tls_push_data(sk, &msg->msg_iter, size,
+			   msg->msg_flags, record_type);
+
+out:
+	release_sock(sk);
+	return rc;
+}
+
+int tls_device_sendpage(struct sock *sk, struct page *page,
+			int offset, size_t size, int flags)
+{
+	struct iov_iter	msg_iter;
+	struct kvec iov;
+	char *kaddr = kmap(page);
+	int rc = 0;
+
+	if (flags & MSG_SENDPAGE_NOTLAST)
+		flags |= MSG_MORE;
+
+	lock_sock(sk);
+
+	if (flags & MSG_OOB) {
+		rc = -ENOTSUPP;
+		goto out;
+	}
+
+	iov.iov_base = kaddr + offset;
+	iov.iov_len = size;
+	iov_iter_kvec(&msg_iter, WRITE | ITER_KVEC, &iov, 1, size);
+	rc = tls_push_data(sk, &msg_iter, size,
+			   flags, TLS_RECORD_TYPE_DATA);
+	kunmap(page);
+
+out:
+	release_sock(sk);
+	return rc;
+}
+
+struct tls_record_info *tls_get_record(struct tls_offload_context *context,
+				       u32 seq)
+{
+	struct tls_record_info *info;
+
+	info = context->retransmit_hint;
+	if (!info ||
+	    before(seq, info->end_seq - info->len))
+		info = list_first_entry(&context->records_list,
+					struct tls_record_info, list);
+
+	list_for_each_entry_from(info, &context->records_list, list) {
+		if (before(seq, info->end_seq)) {
+			if (!context->retransmit_hint ||
+			    after(info->end_seq,
+				  context->retransmit_hint->end_seq))
+				context->retransmit_hint = info;
+			return info;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(tls_get_record);
+
+static int tls_device_push_pending_record(struct sock *sk, int flags)
+{
+	struct iov_iter	msg_iter;
+
+	iov_iter_kvec(&msg_iter, WRITE | ITER_KVEC, NULL, 0, 0);
+	return tls_push_data(sk, &msg_iter, 0, flags, TLS_RECORD_TYPE_DATA);
+}
+
+int tls_set_device_offload(struct sock *sk, struct tls_context *ctx)
+{
+	struct tls_crypto_info *crypto_info;
+	struct tls_offload_context *offload_ctx;
+	struct tls_record_info *start_marker_record;
+	u16 nonece_size, tag_size, iv_size, rec_seq_size;
+	char *iv, *rec_seq;
+	int rc;
+	struct net_device *netdev;
+	struct sk_buff *skb;
+
+	if (!ctx) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (ctx->priv_ctx) {
+		rc = -EEXIST;
+		goto out;
+	}
+
+	netdev = get_netdev_for_sock(sk);
+	if (!netdev) {
+		pr_err("%s: netdev not found\n", __func__);
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (!(netdev->features & NETIF_F_HW_TLS_TX)) {
+		rc = -ENOTSUPP;
+		goto release_netdev;
+	}
+
+	crypto_info = &ctx->crypto_send;
+	switch (crypto_info->cipher_type) {
+	case TLS_CIPHER_AES_GCM_128: {
+		nonece_size = TLS_CIPHER_AES_GCM_128_IV_SIZE;
+		tag_size = TLS_CIPHER_AES_GCM_128_TAG_SIZE;
+		iv_size = TLS_CIPHER_AES_GCM_128_IV_SIZE;
+		iv = ((struct tls12_crypto_info_aes_gcm_128 *)crypto_info)->iv;
+		rec_seq_size = TLS_CIPHER_AES_GCM_128_REC_SEQ_SIZE;
+		rec_seq =
+		 ((struct tls12_crypto_info_aes_gcm_128 *)crypto_info)->rec_seq;
+		break;
+	}
+	default:
+		rc = -EINVAL;
+		goto release_netdev;
+	}
+
+	start_marker_record = kmalloc(sizeof(*start_marker_record), GFP_KERNEL);
+	if (!start_marker_record) {
+		rc = -ENOMEM;
+		goto release_netdev;
+	}
+
+	rc = attach_sock_to_netdev(sk, netdev, ctx);
+	if (rc)
+		goto free_marker_record;
+
+	ctx->netdev = netdev;
+	ctx->sk = sk;
+
+	ctx->prepend_size = TLS_HEADER_SIZE + nonece_size;
+	ctx->tag_size = tag_size;
+	ctx->iv_size = iv_size;
+	ctx->iv = kmalloc(iv_size + TLS_CIPHER_AES_GCM_128_SALT_SIZE,
+			  GFP_KERNEL);
+	if (!ctx->iv) {
+		rc = -ENOMEM;
+		goto detach_sock;
+	}
+	memcpy(ctx->iv + TLS_CIPHER_AES_GCM_128_SALT_SIZE, iv, iv_size);
+	ctx->rec_seq_size = rec_seq_size;
+	ctx->rec_seq = kmalloc(rec_seq_size, GFP_KERNEL);
+	if (!ctx->rec_seq) {
+		rc = -ENOMEM;
+		goto err_iv;
+	}
+	memcpy(ctx->rec_seq, rec_seq, rec_seq_size);
+
+	offload_ctx = ctx->priv_ctx;
+	start_marker_record->end_seq = tcp_sk(sk)->write_seq;
+	start_marker_record->len = 0;
+	start_marker_record->num_frags = 0;
+
+	INIT_LIST_HEAD(&offload_ctx->records_list);
+	list_add_tail(&start_marker_record->list, &offload_ctx->records_list);
+	spin_lock_init(&offload_ctx->lock);
+
+	inet_csk(sk)->icsk_clean_acked = &tls_icsk_clean_acked;
+	ctx->push_pending_record = tls_device_push_pending_record;
+	ctx->free_resources = tls_device_free_resources;
+	offload_ctx->sk_destruct = sk->sk_destruct;
+
+	/* TLS offload is greatly simplified if we don't send
+	 * SKBs where only part of the payload needs to be encrypted.
+	 * So mark the last skb in the write queue as end of record.
+	 */
+	skb = tcp_write_queue_tail(sk);
+	if (skb)
+		TCP_SKB_CB(skb)->eor = 1;
+
+	/* After the next line tls_is_sk_tx_device_offloaded
+	 * will return true and ndo_start_xmit might access the
+	 * offload context
+	 */
+	smp_store_release(&sk->sk_destruct,
+			  &tls_device_sk_destruct);
+	goto release_netdev;
+
+err_iv:
+	kfree(ctx->iv);
+detach_sock:
+	detach_sock_from_netdev(sk, ctx);
+free_marker_record:
+	kfree(start_marker_record);
+release_netdev:
+	dev_put(netdev);
+out:
+	return rc;
+}
+
+void __exit tls_device_cleanup(void)
+{
+	flush_work(&tls_device_gc_work);
+}
diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index ae20ee3..a93a712 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -45,8 +45,16 @@
 MODULE_DESCRIPTION("Transport Layer Security Support");
 MODULE_LICENSE("Dual BSD/GPL");
 
-static struct proto tls_base_prot;
-static struct proto tls_sw_prot;
+enum {
+	TLS_BASE_TX,
+	TLS_SW_TX,
+#ifdef CONFIG_TLS_DEVICE
+	TLS_HW_TX,
+#endif
+	TLS_NUM_CONFIG,
+};
+
+static struct proto tls_prots[TLS_NUM_CONFIG];
 
 int wait_on_pending_writer(struct sock *sk, long *timeo)
 {
@@ -393,11 +401,19 @@ static int do_tls_setsockopt_tx(struct sock *sk, char __user *optval,
 
 	ctx->sk_proto_close = sk->sk_prot->close;
 
-	/* currently SW is default, we will have ethtool in future */
-	rc = tls_set_sw_offload(sk, ctx);
-	prot = &tls_sw_prot;
-	if (rc)
-		goto err_crypto_info;
+#ifdef CONFIG_TLS_DEVICE
+	rc = tls_set_device_offload(sk, ctx);
+	prot = &tls_prots[TLS_HW_TX];
+	if (rc) {
+#else
+	{
+#endif
+		/* if HW offload fails fallback to SW */
+		rc = tls_set_sw_offload(sk, ctx);
+		prot = &tls_prots[TLS_SW_TX];
+		if (rc)
+			goto err_crypto_info;
+	}
 
 	sk->sk_prot = prot;
 	goto out;
@@ -452,7 +468,8 @@ static int tls_init(struct sock *sk)
 	icsk->icsk_ulp_data = ctx;
 	ctx->setsockopt = sk->sk_prot->setsockopt;
 	ctx->getsockopt = sk->sk_prot->getsockopt;
-	sk->sk_prot = &tls_base_prot;
+
+	sk->sk_prot = &tls_prots[TLS_BASE_TX];
 out:
 	return rc;
 }
@@ -463,16 +480,27 @@ static int tls_init(struct sock *sk)
 	.init			= tls_init,
 };
 
-static int __init tls_register(void)
+static void build_protos(struct proto *prot, struct proto *base)
 {
-	tls_base_prot			= tcp_prot;
-	tls_base_prot.setsockopt	= tls_setsockopt;
-	tls_base_prot.getsockopt	= tls_getsockopt;
+	prot[TLS_BASE_TX] = *base;
+	prot[TLS_BASE_TX].setsockopt = tls_setsockopt;
+	prot[TLS_BASE_TX].getsockopt = tls_getsockopt;
+
+	prot[TLS_SW_TX] = prot[TLS_BASE_TX];
+	prot[TLS_SW_TX].close		= tls_sk_proto_close;
+	prot[TLS_SW_TX].sendmsg		= tls_sw_sendmsg;
+	prot[TLS_SW_TX].sendpage	= tls_sw_sendpage;
+
+#ifdef CONFIG_TLS_DEVICE
+	prot[TLS_HW_TX] = prot[TLS_SW_TX];
+	prot[TLS_HW_TX].sendmsg		= tls_device_sendmsg;
+	prot[TLS_HW_TX].sendpage	= tls_device_sendpage;
+#endif
+}
 
-	tls_sw_prot			= tls_base_prot;
-	tls_sw_prot.sendmsg		= tls_sw_sendmsg;
-	tls_sw_prot.sendpage            = tls_sw_sendpage;
-	tls_sw_prot.close               = tls_sk_proto_close;
+static int __init tls_register(void)
+{
+	build_protos(tls_prots, &tcp_prot);
 
 	tcp_register_ulp(&tcp_tls_ulp_ops);
 
@@ -482,6 +510,9 @@ static int __init tls_register(void)
 static void __exit tls_unregister(void)
 {
 	tcp_unregister_ulp(&tcp_tls_ulp_ops);
+#ifdef CONFIG_TLS_DEVICE
+	tls_device_cleanup();
+#endif
 }
 
 module_init(tls_register);
-- 
1.8.3.1
