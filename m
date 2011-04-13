From: Andreas Gruenbacher <agruen@linbit.com>
Subject: [RFC][PATCH] Zero-copy receive from socket into bio
Date: Wed, 13 Apr 2011 23:39:23 +0200
Message-ID: <201104132339.24183.agruen@linbit.com>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm currently looking into supporting zero-copy receive in drbd.

The basic idea is this: drbd transmits bios via sockets.  An ideal sender
sends the packet header and data in separate packets, and the network driver
supports RX_COPYBREAK and receives them into separate socket buffers.  The
socket buffers end up aligned properly, and we add them to bios and submit
them, no copying required.

This scenario doesn't seem to be supported by the existing infrastructure, so
does this patch make sense?

Thanks,
Andreas

---

[PATCH] Add a generic zero-copy-receive primitive

This requires a network driver which supports header-data split, i.e.,
receiving small header packets and big data packets into different
buffers so that the data will end up aligned well enough for consumption
by the block layer (search for RX_COPYBREAK in the drivers).

diff --git a/tcp_recvbio.c b/tcp_recvbio.c
new file mode 100644
index 0000000..38342e9
--- /dev/null
+++ b/tcp_recvbio.c
@@ -0,0 +1,185 @@
+#include <linux/kernel.h>
+#include <net/tcp.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/fs.h>
+#include "tcp_recvbio.h"
+
+static int tcp_recvbio_add(struct sk_buff *skb, struct bio *bio,
+			   struct bio_vec *last)
+{
+	struct request_queue *q = bio->bi_bdev->bd_disk->queue;
+	struct sk_buff **frag_list = &skb_shinfo(skb)->frag_list;
+	int ret;
+
+	/*
+	 * Reject fragmented skbs: there should be no need to support them.  We
+	 * use frag_list to keep track of the skbs attached to a bio instead.
+	 */
+	if (*frag_list && skb != (struct sk_buff *)bio->bi_private)
+		return false;
+
+	if (!blk_rq_aligned(q, last->bv_offset, last->bv_len))
+		return false;
+	ret = bio_add_page(bio, last->bv_page, last->bv_len, last->bv_offset);
+
+	if (ret && !*frag_list) {
+		/* Tell the network layer to leave @skb alone.  */
+		skb_get(skb);
+
+		/* Put this skb on the list.  */
+		*frag_list = (struct sk_buff *)bio->bi_private;
+		bio->bi_private = skb;
+	}
+	return ret;
+}
+
+static int tcp_recvbio_data(read_descriptor_t *rd_desc, struct sk_buff *skb,
+			    unsigned int offset, size_t len)
+{
+	struct bio *bio = rd_desc->arg.data;
+	struct request_queue *q = bio->bi_bdev->bd_disk->queue;
+	int start = skb_headlen(skb), consumed = 0, i;
+	struct bio_vec last = { };
+
+	/* Cannot zero-copy from the header.  */
+	if (offset < start)
+		goto give_up;
+
+	/* Give up if the payload is unaligned.  */
+	if (!blk_rq_aligned(q, offset - start, 0))
+		goto give_up;
+
+	/* Do not consume more data than we need.  */
+	if (len > rd_desc->count - rd_desc->written)
+		len = rd_desc->count - rd_desc->written;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		int end, frag_len;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag->size;
+		frag_len = end - offset;
+		if (frag_len > 0) {
+			bool merged = false;
+			unsigned int page_offset;
+
+			if (frag_len > len)
+				frag_len = len;
+
+			page_offset = frag->page_offset + offset - start;
+			if (last.bv_page == frag->page &&
+			    last.bv_offset + last.bv_len == page_offset) {
+				/* Merge with the previous fragment.  */
+				last.bv_len += frag_len;
+				merged = true;
+			}
+			len -= frag_len;
+			offset += frag_len;
+			if (!len || !merged) {
+				if (last.bv_page) {
+					if (!tcp_recvbio_add(skb, bio, &last))
+						goto give_up;
+					consumed += last.bv_len;
+				}
+				if (!len)
+					goto out;
+				last.bv_page = frag->page;
+				last.bv_offset = page_offset;
+				last.bv_len = frag_len;
+			}
+		}
+		start = end;
+	}
+
+	/*
+	 * We don't care if there are additional blocks in the skb's frag_list
+	 * that are zero-copyable: at worst, we end up copying too many blocks.
+	 * (See skb_copy_bits() for an example of walking the frag_list.)
+	 */
+
+out:
+	rd_desc->written += consumed;
+	return consumed;
+
+give_up:
+	rd_desc->count = 0;
+	goto out;
+}
+
+/**
+ * tcp_recvbio  -  zero-copy receive a bio from a socket
+ * @sk: socket to receive from
+ * @bio: bio to add socket data to
+ * @size: bytes to receive
+ * @list: single linked list of skbs added to @bio
+ *
+ * Zero-copy receive data from @sk into @bio by directly using the socket
+ * buffer pages, bypassing the page cache.  To keep the network layer from
+ * modifying the socket buffers while in use by @bio, we skb_get() them and
+ * return a list of skbs that @bio now references.  The caller is
+ * responsible for releasing @list with consume_skbs() once done.
+ *
+ * Returns the number of bytes received into @bio.
+ */
+int tcp_recvbio(struct sock *sk, struct bio *bio, size_t size,
+		struct sk_buff **list)
+{
+	read_descriptor_t rd_desc = {
+		.count = size,
+		.arg = { .data = bio },
+	};
+	void *old_bi_private;
+	int err = 0;
+
+	/* Temporarily build referenced skb list in bi_private.  */
+	old_bi_private = bio->bi_private;
+	bio->bi_private = NULL;
+
+	lock_sock(sk);
+	while (rd_desc.written < rd_desc.count) {
+		long timeo = sock_rcvtimeo(sk, 0);
+
+		sk_wait_data(sk, &timeo);
+		if (signal_pending(current)) {
+			err = sock_intr_errno(timeo);
+			break;
+		}
+		if (!timeo) {
+			if (!rd_desc.written)
+				err = -EAGAIN;
+			break;
+		}
+		read_lock(&sk->sk_callback_lock);
+		err = tcp_read_sock(sk, &rd_desc, tcp_recvbio_data);
+		read_unlock(&sk->sk_callback_lock);
+		if (err < 0)
+			break;
+	}
+	release_sock(sk);
+
+	*list = (struct sk_buff *)bio->bi_private;
+	bio->bi_private = old_bi_private;
+
+	if (err)
+		return err;
+	return rd_desc.written;
+}
+
+/**
+ * consume_skbs  -  consume a list of skbs
+ *
+ * This assumes that the skbs are linked on frag_list, as the @list returned
+ * from tcp_recvbio().
+ */
+void consume_skbs(struct sk_buff **skb)
+{
+	while (*skb) {
+		struct sk_buff *tmp = *skb;
+		*skb = skb_shinfo(tmp)->frag_list;
+		skb_shinfo(tmp)->frag_list = NULL;
+		consume_skb(tmp);
+	}
+}
diff --git a/tcp_recvbio.h b/tcp_recvbio.h
new file mode 100644
index 0000000..0ba30ee
--- /dev/null
+++ b/tcp_recvbio.h
@@ -0,0 +1,9 @@
+#ifndef __TCP_RECVBIO_H
+#define __TCP_RECVBIO_H
+
+
+extern int tcp_recvbio(struct sock *, struct bio *, size_t, struct sk_buff **);
+extern void consume_skbs(struct sk_buff **);
+
+
+#endif  /* __TCP_RECVBIO_H */
-- 
1.7.4.1.415.g5e839
