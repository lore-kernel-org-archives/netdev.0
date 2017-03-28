From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 06/15] tls: tls offload support
Date: Tue, 28 Mar 2017 16:26:23 +0300
Message-ID: <1490707592-1430-7-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47689 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932538AbdC1N1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:27:06 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces TX HW offload.

tls_main: contains generic logic that will be shared by both
SW and HW implementations.
tls_device: contains generic HW logic that is shared by all
HW offload implementations.

Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 MAINTAINERS               |  13 +
 include/net/tls.h         | 184 ++++++++++++++
 include/uapi/linux/Kbuild |   1 +
 include/uapi/linux/tls.h  |  84 +++++++
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/tls/Kconfig           |  12 +
 net/tls/Makefile          |   7 +
 net/tls/tls_device.c      | 594 ++++++++++++++++++++++++++++++++++++++++++++++
 net/tls/tls_main.c        | 348 +++++++++++++++++++++++++++
 10 files changed, 1245 insertions(+)
 create mode 100644 include/net/tls.h
 create mode 100644 include/uapi/linux/tls.h
 create mode 100644 net/tls/Kconfig
 create mode 100644 net/tls/Makefile
 create mode 100644 net/tls/tls_device.c
 create mode 100644 net/tls/tls_main.c

diff --git a/MAINTAINERS b/MAINTAINERS
index b340ef6..e3b70c3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8486,6 +8486,19 @@ F:	net/ipv6/
 F:	include/net/ip*
 F:	arch/x86/net/*
 
+NETWORKING [TLS]
+M:	Ilya Lesokhin <ilyal@mellanox.com>
+M:	Aviad Yehezkel <aviadye@mellanox.com>
+M:	Boris Pismenny <borisp@mellanox.com>
+M:	Haggai Eran <haggaie@mellanox.com>
+L:	netdev@vger.kernel.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
+S:	Maintained
+F:	net/tls/*
+F:	include/uapi/linux/tls.h
+F:	include/net/tls.h
+
 NETWORKING [IPSEC]
 M:	Steffen Klassert <steffen.klassert@secunet.com>
 M:	Herbert Xu <herbert@gondor.apana.org.au>
diff --git a/include/net/tls.h b/include/net/tls.h
new file mode 100644
index 0000000..f7f0cde
--- /dev/null
+++ b/include/net/tls.h
@@ -0,0 +1,184 @@
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
+#ifndef _TLS_OFFLOAD_H
+#define _TLS_OFFLOAD_H
+
+#include <linux/types.h>
+
+#include <uapi/linux/tls.h>
+
+
+/* Maximum data size carried in a TLS record */
+#define TLS_MAX_PAYLOAD_SIZE		((size_t)1 << 14)
+
+#define TLS_HEADER_SIZE			5
+#define TLS_NONCE_OFFSET		TLS_HEADER_SIZE
+
+#define TLS_CRYPTO_INFO_READY(info)	((info)->cipher_type)
+#define TLS_IS_STATE_HW(info)		((info)->state == TLS_STATE_HW)
+
+#define TLS_RECORD_TYPE_DATA		0x17
+
+
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
+	struct tls_record_info *open_record;
+	struct tls_record_info *retransmit_hint;
+	u32 expectedSN;
+	spinlock_t lock;	/* protects records list */
+};
+
+struct tls_context {
+	union {
+		struct tls_crypto_info crypto_send;
+		struct tls_crypto_info_aes_gcm_128 crypto_send_aes_gcm_128;
+	};
+
+	void *priv_ctx;
+
+	u16 prepand_size;
+	u16 tag_size;
+	u16 iv_size;
+	char *iv;
+
+	/* TODO: change sw code to use below fields and push_frags function */
+	skb_frag_t *pending_frags;
+	u16 num_pending_frags;
+	u16 pending_offset;
+
+	void (*sk_write_space)(struct sock *sk);
+	void (*sk_destruct)(struct sock *sk);
+};
+
+
+int tls_sk_query(struct sock *sk, int optname, char __user *optval,
+		int __user *optlen);
+int tls_sk_attach(struct sock *sk, int optname, char __user *optval,
+		  unsigned int optlen);
+
+void tls_clear_device_offload(struct sock *sk, struct tls_context *ctx);
+int tls_set_device_offload(struct sock *sk, struct tls_context *ctx);
+int tls_device_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
+int tls_device_sendpage(struct sock *sk, struct page *page,
+			int offset, size_t size, int flags);
+
+struct tls_record_info *tls_get_record(struct tls_offload_context *context,
+				       u32 seq);
+
+void tls_sk_destruct(struct sock *sk, struct tls_context *ctx);
+void tls_icsk_clean_acked(struct sock *sk);
+
+void tls_device_sk_destruct(struct sock *sk);
+
+
+int tls_push_frags(struct sock *sk, struct tls_context *ctx,
+		   skb_frag_t *frag, u16 num_frags, u16 first_offset,
+		   int flags);
+int tls_push_paritial_record(struct sock *sk, struct tls_context *ctx,
+			     int flags);
+
+static inline bool tls_is_pending_open_record(struct tls_context *ctx)
+{
+	return !!ctx->num_pending_frags;
+}
+
+static inline bool tls_is_sk_tx_device_offloaded(struct sock *sk)
+{
+	return	smp_load_acquire(&sk->sk_destruct) ==
+			&tls_device_sk_destruct;
+}
+
+static inline void tls_err_abort(struct sock *sk)
+{
+	xchg(&sk->sk_err, -EBADMSG);
+	sk->sk_error_report(sk);
+}
+
+static inline void tls_increment_seqno(unsigned char *seq, struct sock *sk)
+{
+	int i;
+
+	for (i = 7; i >= 0; i--) {
+		++seq[i];
+		if (seq[i] != 0)
+			break;
+	}
+
+	if (i == -1)
+		tls_err_abort(sk);
+}
+
+static inline void tls_fill_prepend(struct tls_context *ctx,
+			     char *buf,
+			     size_t plaintext_len,
+			     unsigned char record_type)
+{
+	size_t pkt_len, iv_size = ctx->iv_size;
+
+	pkt_len = plaintext_len + iv_size + ctx->tag_size;
+
+	/* we cover nonce explicit here as well, so buf should be of
+	 * size KTLS_DTLS_HEADER_SIZE + KTLS_DTLS_NONCE_EXPLICIT_SIZE
+	 */
+	buf[0] = record_type;
+	buf[1] = TLS_VERSION_MINOR(ctx->crypto_send.version);
+	buf[2] = TLS_VERSION_MAJOR(ctx->crypto_send.version);
+	/* we can use IV for nonce explicit according to spec */
+	buf[3] = pkt_len >> 8;
+	buf[4] = pkt_len & 0xFF;
+	memcpy(buf + TLS_NONCE_OFFSET, ctx->iv, iv_size);
+}
+
+static inline struct tls_context *tls_get_ctx(const struct sock *sk)
+{
+	return sk->sk_user_data;
+}
+
+static inline struct tls_offload_context *tls_offload_ctx(
+		const struct tls_context *tls_ctx)
+{
+	return (struct tls_offload_context *)tls_ctx->priv_ctx;
+}
+
+
+#endif /* _TLS_OFFLOAD_H */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index cd2be1c..96ae5ca 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -406,6 +406,7 @@ header-y += sysinfo.h
 header-y += target_core_user.h
 header-y += taskstats.h
 header-y += tcp.h
+header-y += tls.h
 header-y += tcp_metrics.h
 header-y += telephony.h
 header-y += termios.h
diff --git a/include/uapi/linux/tls.h b/include/uapi/linux/tls.h
new file mode 100644
index 0000000..464621b
--- /dev/null
+++ b/include/uapi/linux/tls.h
@@ -0,0 +1,84 @@
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
+#ifndef _UAPI_LINUX_TLS_H
+#define _UAPI_LINUX_TLS_H
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/socket.h>
+#include <linux/tcp.h>
+
+/* Supported versions */
+#define TLS_VERSION_MINOR(ver)	((ver) & 0xFF)
+#define TLS_VERSION_MAJOR(ver)	(((ver) >> 8) & 0xFF)
+
+#define TLS_VERSION_NUMBER(id)	((((id##_VERSION_MAJOR) & 0xFF) << 8) |	\
+				 ((id##_VERSION_MINOR) & 0xFF))
+
+#define TLS_1_2_VERSION_MAJOR	0x3
+#define TLS_1_2_VERSION_MINOR	0x3
+#define TLS_1_2_VERSION		TLS_VERSION_NUMBER(TLS_1_2)
+
+/* Supported ciphers */
+#define TLS_CIPHER_AES_GCM_128			51
+#define TLS_CIPHER_AES_GCM_128_IV_SIZE		((size_t)8)
+#define TLS_CIPHER_AES_GCM_128_KEY_SIZE		((size_t)16)
+#define TLS_CIPHER_AES_GCM_128_SALT_SIZE	((size_t)4)
+#define TLS_CIPHER_AES_GCM_128_TAG_SIZE		((size_t)16)
+
+struct tls_ctrlmsg {
+	unsigned char type;
+	unsigned char data[0];
+} __attribute__((packed));
+
+enum tls_state {
+	TLS_STATE_SW = 0x0,
+	TLS_STATE_HW = 0x1,
+};
+
+struct tls_crypto_info {
+	__u16 version;
+	__u16 cipher_type;
+	__u32 state;
+};
+
+struct tls_crypto_info_aes_gcm_128 {
+	struct tls_crypto_info info;
+	unsigned char iv[TLS_CIPHER_AES_GCM_128_IV_SIZE];
+	unsigned char key[TLS_CIPHER_AES_GCM_128_KEY_SIZE];
+	unsigned char salt[TLS_CIPHER_AES_GCM_128_SALT_SIZE];
+};
+
+#endif /* _UAPI_LINUX_TLS_H */
diff --git a/net/Kconfig b/net/Kconfig
index a100500..b50e899 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -55,6 +55,7 @@ menu "Networking options"
 
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
+source "net/tls/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
 
diff --git a/net/Makefile b/net/Makefile
index 4cafaa2..23da6df 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_LLC)		+= llc/
 obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/
 obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
+obj-$(CONFIG_TLS)		+= tls/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
 obj-$(CONFIG_NET)		+= ipv6/
diff --git a/net/tls/Kconfig b/net/tls/Kconfig
new file mode 100644
index 0000000..75bfb43
--- /dev/null
+++ b/net/tls/Kconfig
@@ -0,0 +1,12 @@
+#
+# TLS configuration
+#
+config TLS
+	tristate "Transport Layer Security support"
+	depends on NET
+	default m
+	---help---
+	Enable kernel support for TLS protocol. This allows processing
+	of protocol in kernel as well as oflloading it to HW.
+
+	If unsure, say N.
diff --git a/net/tls/Makefile b/net/tls/Makefile
new file mode 100644
index 0000000..65e5677
--- /dev/null
+++ b/net/tls/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the TLS subsystem.
+#
+
+obj-$(CONFIG_TLS) += tls.o
+
+tls-y := tls_main.o tls_device.o
diff --git a/net/tls/tls_device.c b/net/tls/tls_device.c
new file mode 100644
index 0000000..77a4a59
--- /dev/null
+++ b/net/tls/tls_device.c
@@ -0,0 +1,594 @@
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
+/* We assume that the socket is already connected */
+static struct net_device *get_netdev_for_sock(struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	struct net_device *netdev = NULL;
+
+	pr_info("Using output interface 0x%x\n", inet->cork.fl.flowi_oif);
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
+static int attach_sock_to_netdev(struct sock *sk, struct tls_context *ctx)
+{
+	struct net_device *netdev = get_netdev_for_sock(sk);
+	int rc = -EINVAL;
+
+	if (!netdev) {
+		pr_err("attach_sock_to_netdev: netdev not found\n");
+		goto out;
+	}
+
+	if (!netdev->tlsdev_ops) {
+		pr_err("attach_sock_to_netdev: netdev %s with no TLS offload\n",
+		       netdev->name);
+		goto out;
+	}
+
+	rc = netdev->tlsdev_ops->tls_dev_add(
+			netdev,
+			sk,
+			TLS_OFFLOAD_CTX_DIR_TX,
+			&ctx->crypto_send,
+			(struct tls_offload_context **)(&ctx->priv_ctx));
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
+	dev_put(netdev);
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
+}
+
+void tls_clear_device_offload(struct sock *sk, struct tls_context *tls_ctx)
+{
+	struct tls_offload_context *ctx = tls_offload_ctx(tls_ctx);
+
+	if (!ctx)
+		return;
+
+	if (ctx->open_record)
+		destroy_record(ctx->open_record);
+
+	delete_all_records(ctx);
+	detach_sock_from_netdev(sk, tls_ctx);
+}
+
+void tls_icsk_clean_acked(struct sock *sk)
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
+EXPORT_SYMBOL(tls_icsk_clean_acked);
+
+void tls_device_sk_destruct(struct sock *sk)
+{
+	struct tls_context *ctx = tls_get_ctx(sk);
+
+	tls_clear_device_offload(sk, ctx);
+	tls_sk_destruct(sk, ctx);
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
+
+	/* fill prepand */
+	frag = &record->frags[0];
+	tls_fill_prepend(ctx,
+			 skb_frag_address(frag),
+			 record->len - ctx->prepand_size,
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
+
+	offload_ctx->open_record = NULL;
+	tls_increment_seqno(ctx->iv, sk);
+
+	/* all ready, send */
+	return tls_push_frags(sk, ctx, record->frags,
+			      record->num_frags, 0, flags);
+
+}
+
+static inline int tls_get_new_record(
+		struct tls_offload_context *offload_ctx,
+		struct page_frag *pfrag,
+		size_t prepand_size)
+{
+	skb_frag_t *frag;
+	struct tls_record_info *record;
+
+	/* TODO: do we want to use pfrag
+	 * to store the record metadata?
+	 * the lifetime of the data and
+	 * metadata is the same and
+	 * we can avoid kmalloc overhead.
+	 */
+	record = kmalloc(sizeof(*record), GFP_KERNEL);
+	if (!record)
+		return -ENOMEM;
+
+	frag = &record->frags[0];
+	__skb_frag_set_page(frag, pfrag->page);
+	frag->page_offset = pfrag->offset;
+	skb_frag_size_set(frag, prepand_size);
+
+	get_page(pfrag->page);
+	pfrag->offset += prepand_size;
+
+	record->num_frags = 1;
+	record->len = prepand_size;
+	offload_ctx->open_record = record;
+	return 0;
+}
+
+static inline int tls_do_allocation(
+		struct sock *sk,
+		struct tls_offload_context *offload_ctx,
+		struct page_frag *pfrag,
+		size_t prepand_size)
+{
+	struct tls_record_info *record;
+
+	if (!sk_page_frag_refill(sk, pfrag))
+		return -ENOMEM;
+
+	record = offload_ctx->open_record;
+	if (!record) {
+		tls_get_new_record(offload_ctx, pfrag, prepand_size);
+		record = offload_ctx->open_record;
+		if (!record)
+			return -ENOMEM;
+	}
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
+	bool last = false;
+
+	if (sk->sk_err)
+		return sk->sk_err;
+
+	/* Only one writer at a time is allowed */
+	if (sk->sk_write_pending)
+		return -EBUSY;
+	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
+	pfrag = sk_page_frag(sk);
+
+	/* KTLS_TLS_HEADER_SIZE is not counted as part of the TLS record, and
+	 * we need to leave room for an authentication tag.
+	 */
+	max_open_record_len = TLS_MAX_PAYLOAD_SIZE
+			+ TLS_HEADER_SIZE - tls_ctx->tag_size;
+
+	if (tls_is_pending_open_record(tls_ctx)) {
+		rc = tls_push_paritial_record(sk, tls_ctx, flags);
+		if (rc < 0)
+			return rc;
+	}
+
+	do {
+		if (tls_do_allocation(sk, ctx, pfrag,
+				      tls_ctx->prepand_size)) {
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
+			} else if (record->len > tls_ctx->prepand_size) {
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
+			last = true;
+		}
+
+		if ((last && !more) ||
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
+	} while (!last);
+
+	if (orig_size - size > 0) {
+		rc = orig_size - size;
+		if (record_type != TLS_RECORD_TYPE_DATA)
+			rc++;
+	}
+
+	return rc;
+}
+
+static inline bool record_is_open(struct sock *sk)
+{
+	struct tls_context *tls_ctx = tls_get_ctx(sk);
+	struct tls_offload_context *ctx = tls_offload_ctx(tls_ctx);
+	struct tls_record_info *record = ctx->open_record;
+
+	return record;
+}
+
+int tls_device_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
+{
+	unsigned char record_type = TLS_RECORD_TYPE_DATA;
+	int rc = 0;
+
+	lock_sock(sk);
+
+	if (unlikely(msg->msg_flags & MSG_OOB)) {
+		if ((msg->msg_flags & MSG_MORE) || record_is_open(sk)) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		if (copy_from_iter(&record_type, 1, &msg->msg_iter) != 1) {
+			rc = -EFAULT;
+			goto out;
+		}
+
+		--size;
+		msg->msg_flags &= ~MSG_OOB;
+	}
+
+	rc = tls_push_data(sk, &msg->msg_iter, size,
+			   msg->msg_flags,
+			   record_type);
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
+			   flags,
+			   TLS_RECORD_TYPE_DATA);
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
+int tls_set_device_offload(struct sock *sk, struct tls_context *ctx)
+{
+	struct tls_crypto_info *crypto_info;
+	struct tls_offload_context *offload_ctx;
+	struct tls_record_info *dummy_record;
+	u16 nonece_size, tag_size, iv_size;
+	char *iv;
+	int rc;
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
+	crypto_info = &ctx->crypto_send;
+	switch (crypto_info->cipher_type) {
+	case TLS_CIPHER_AES_GCM_128: {
+		nonece_size = TLS_CIPHER_AES_GCM_128_IV_SIZE;
+		tag_size = TLS_CIPHER_AES_GCM_128_TAG_SIZE;
+		iv_size = TLS_CIPHER_AES_GCM_128_IV_SIZE;
+		iv = ((struct tls_crypto_info_aes_gcm_128 *)crypto_info)->iv;
+		break;
+	}
+	default:
+		rc = -EINVAL;
+		goto out;
+	}
+
+	dummy_record = kmalloc(sizeof(*dummy_record), GFP_KERNEL);
+	if (!dummy_record) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	rc = attach_sock_to_netdev(sk, ctx);
+	if (rc)
+		goto err_dummy_record;
+
+	ctx->prepand_size = TLS_HEADER_SIZE + nonece_size;
+	ctx->tag_size = tag_size;
+	ctx->iv_size = iv_size;
+	ctx->iv = kmalloc(iv_size, GFP_KERNEL);
+	if (!ctx->iv) {
+		rc = ENOMEM;
+		goto detach_sock;
+	}
+	memcpy(ctx->iv, iv, iv_size);
+
+	offload_ctx = ctx->priv_ctx;
+	dummy_record->end_seq = offload_ctx->expectedSN;
+	dummy_record->len = 0;
+	dummy_record->num_frags = 0;
+
+	INIT_LIST_HEAD(&offload_ctx->records_list);
+	list_add_tail(&dummy_record->list, &offload_ctx->records_list);
+	spin_lock_init(&offload_ctx->lock);
+
+	inet_csk(sk)->icsk_clean_acked = &tls_icsk_clean_acked;
+
+	/* After this line the tx_handler might access the offload context */
+	smp_store_release(&sk->sk_destruct,
+			  &tls_device_sk_destruct);
+	goto out;
+
+detach_sock:
+	detach_sock_from_netdev(sk, ctx);
+err_dummy_record:
+	kfree(dummy_record);
+out:
+	return rc;
+}
diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
new file mode 100644
index 0000000..6a3df25
--- /dev/null
+++ b/net/tls/tls_main.c
@@ -0,0 +1,348 @@
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
+
+#include <net/tcp.h>
+#include <net/inet_common.h>
+#include <linux/highmem.h>
+#include <linux/netdevice.h>
+
+#include <net/tls.h>
+
+MODULE_AUTHOR("Mellanox Technologies");
+MODULE_DESCRIPTION("Transport Layer Security Support");
+MODULE_LICENSE("Dual BSD/GPL");
+
+static struct proto tls_device_prot;
+
+int tls_push_frags(struct sock *sk,
+		   struct tls_context *ctx,
+		   skb_frag_t *frag,
+		   u16 num_frags,
+		   u16 first_offset,
+		   int flags)
+{
+	int sendpage_flags = flags | MSG_SENDPAGE_NOTLAST;
+	int ret = 0;
+	size_t size;
+	int offset = first_offset;
+
+	size = skb_frag_size(frag) - offset;
+	offset += frag->page_offset;
+
+	while (1) {
+		if (!--num_frags)
+			sendpage_flags = flags;
+
+		 /* is sending application-limited? */
+		tcp_rate_check_app_limited(sk);
+retry:
+		ret = do_tcp_sendpages(sk,
+				       skb_frag_page(frag),
+				       offset,
+				       size,
+				       sendpage_flags);
+
+		if (ret != size) {
+			if (ret > 0) {
+				offset += ret;
+				size -= ret;
+				goto retry;
+			}
+
+			offset -= frag->page_offset;
+			ctx->pending_offset = offset;
+			ctx->pending_frags = frag;
+			ctx->num_pending_frags = num_frags + 1;
+			return ret;
+		}
+
+		if (!num_frags)
+			break;
+
+		frag++;
+		offset = frag->page_offset;
+		size = skb_frag_size(frag);
+	}
+
+	return 0;
+}
+
+int tls_push_paritial_record(struct sock *sk, struct tls_context *ctx,
+			     int flags) {
+	skb_frag_t *frag = ctx->pending_frags;
+	u16 offset = ctx->pending_offset;
+	u16 num_frags = ctx->num_pending_frags;
+
+	ctx->num_pending_frags = 0;
+
+	return tls_push_frags(sk, ctx, frag,
+			      num_frags, offset, flags);
+}
+
+static void tls_write_space(struct sock *sk)
+{
+	struct tls_context *ctx = tls_get_ctx(sk);
+
+	if (tls_is_pending_open_record(ctx)) {
+		gfp_t sk_allocation = sk->sk_allocation;
+		int rc;
+
+		sk->sk_allocation = GFP_ATOMIC;
+		rc = tls_push_paritial_record(sk, ctx,
+					      MSG_DONTWAIT | MSG_NOSIGNAL);
+		sk->sk_allocation = sk_allocation;
+
+		if (rc < 0)
+			return;
+	}
+
+	ctx->sk_write_space(sk);
+}
+
+int tls_sk_query(struct sock *sk, int optname, char __user *optval,
+		 int __user *optlen)
+{
+	int rc = 0;
+	struct tls_context *ctx = tls_get_ctx(sk);
+	struct tls_crypto_info *crypto_info;
+	int len;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
+	if (!optval || (len < sizeof(*crypto_info))) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (!ctx) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	/* get user crypto info */
+	switch (optname) {
+	case TCP_TLS_TX: {
+		crypto_info = &ctx->crypto_send;
+		break;
+	}
+	case TCP_TLS_RX:
+		/* fallthru since for now we don't support */
+	default: {
+		rc = -ENOPROTOOPT;
+		goto out;
+	}
+	}
+
+	if (!TLS_CRYPTO_INFO_READY(crypto_info)) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	if (len == sizeof(crypto_info)) {
+		rc = copy_to_user(optval, crypto_info, sizeof(*crypto_info));
+		goto out;
+	}
+
+	switch (crypto_info->cipher_type) {
+	case TLS_CIPHER_AES_GCM_128: {
+		struct tls_crypto_info_aes_gcm_128 *crypto_info_aes_gcm_128 =
+				container_of(crypto_info,
+					     struct tls_crypto_info_aes_gcm_128,
+					     info);
+
+		if (len != sizeof(*crypto_info_aes_gcm_128)) {
+			rc = -EINVAL;
+			goto out;
+		}
+		if (TLS_IS_STATE_HW(crypto_info)) {
+			lock_sock(sk);
+			memcpy(crypto_info_aes_gcm_128->iv,
+			       ctx->iv,
+			       TLS_CIPHER_AES_GCM_128_IV_SIZE);
+			release_sock(sk);
+		}
+		rc = copy_to_user(optval,
+				  crypto_info_aes_gcm_128,
+				  sizeof(*crypto_info_aes_gcm_128));
+		break;
+	}
+	default:
+		rc = -EINVAL;
+	}
+
+out:
+	return rc;
+}
+EXPORT_SYMBOL(tls_sk_query);
+
+void tls_sk_destruct(struct sock *sk, struct tls_context *ctx)
+{
+	ctx->sk_destruct(sk);
+	kfree(ctx->iv);
+	kfree(ctx);
+	module_put(THIS_MODULE);
+}
+
+int tls_sk_attach(struct sock *sk, int optname, char __user *optval,
+		  unsigned int optlen)
+{
+	int rc = 0;
+	struct tls_context *ctx = tls_get_ctx(sk);
+	struct tls_crypto_info *crypto_info;
+	bool allocated_tls_ctx = false;
+
+	if (!optval || (optlen < sizeof(*crypto_info))) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	/* allocate tls context */
+	if (!ctx) {
+		ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+		if (!ctx) {
+			rc = -ENOMEM;
+			goto out;
+		}
+		sk->sk_user_data = ctx;
+		allocated_tls_ctx = true;
+	}
+
+	/* get user crypto info */
+	switch (optname) {
+	case TCP_TLS_TX: {
+		crypto_info = &ctx->crypto_send;
+		break;
+	}
+	case TCP_TLS_RX:
+		/* fallthru since for now we don't support */
+	default: {
+		rc = -ENOPROTOOPT;
+		goto err_sk_user_data;
+	}
+	}
+
+	/* Currently we don't support set crypto info more than one time */
+	if (TLS_CRYPTO_INFO_READY(crypto_info)) {
+		rc = -EEXIST;
+		goto err_sk_user_data;
+	}
+
+	rc = copy_from_user(crypto_info, optval, sizeof(*crypto_info));
+	if (rc) {
+		rc = -EFAULT;
+		goto err_sk_user_data;
+	}
+
+	/* currently we support only HW offload */
+	if (!TLS_IS_STATE_HW(crypto_info)) {
+		rc = -ENOPROTOOPT;
+		goto err_crypto_info;
+	}
+
+	/* check version */
+	if (crypto_info->version != TLS_1_2_VERSION) {
+		rc = -ENOTSUPP;
+		goto err_crypto_info;
+	}
+
+	switch (crypto_info->cipher_type) {
+	case TLS_CIPHER_AES_GCM_128: {
+		if (optlen != sizeof(struct tls_crypto_info_aes_gcm_128)) {
+			rc = -EINVAL;
+			goto err_crypto_info;
+		}
+		rc = copy_from_user(crypto_info,
+				    optval,
+				    sizeof(struct tls_crypto_info_aes_gcm_128));
+		break;
+	}
+	default:
+		rc = -EINVAL;
+		goto err_crypto_info;
+	}
+
+	if (rc) {
+		rc = -EFAULT;
+		goto err_crypto_info;
+	}
+
+	ctx->sk_write_space = sk->sk_write_space;
+	ctx->sk_destruct = sk->sk_destruct;
+	sk->sk_write_space = tls_write_space;
+
+	if (TLS_IS_STATE_HW(crypto_info)) {
+		rc = tls_set_device_offload(sk, ctx);
+		if (rc)
+			goto err_crypto_info;
+	}
+
+	if (!try_module_get(THIS_MODULE)) {
+		rc = -EINVAL;
+		goto err_set_device_offload;
+	}
+
+	/* TODO: add protection */
+	sk->sk_prot = &tls_device_prot;
+	goto out;
+
+err_set_device_offload:
+	tls_clear_device_offload(sk, ctx);
+err_crypto_info:
+	memset(crypto_info, 0, sizeof(*crypto_info));
+err_sk_user_data:
+	if (allocated_tls_ctx)
+		kfree(ctx);
+out:
+	return rc;
+}
+EXPORT_SYMBOL(tls_sk_attach);
+
+static int __init tls_init(void)
+{
+	tls_device_prot			= tcp_prot;
+	tls_device_prot.sendmsg		= tls_device_sendmsg;
+	tls_device_prot.sendpage	= tls_device_sendpage;
+
+	return 0;
+}
+
+static void __exit tls_exit(void)
+{
+}
+
+module_init(tls_init);
+module_exit(tls_exit);
-- 
2.7.4
