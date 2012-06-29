From: Andreas Gruenbacher <agruen@linbit.com>
Subject: [RFC] [TCP 2/3] tcp: Zero-copy receive from a socket into a bio
Date: Fri, 29 Jun 2012 16:55:35 +0200
Message-ID: <1340981735.25226.4.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Receive" data from a tcp socket by directly mapping sectors in the socket receive
buffers into a bio without copying.  This requires that the receive buffer
contains contiguous sectors which are well-enough aligned for the block device
associated with the bio.

Any data that cannot be mapped into the bio is left in the socket receive
buffers and can be received conventionally, by copying it out of the buffers.

Signed-off-by: Andreas Gruenbacher <agruen@linbit.com>
---
 include/net/tcp.h      |    3 +
 net/ipv4/Makefile      |    3 +-
 net/ipv4/tcp_recvbio.c |  168 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 173 insertions(+), 1 deletion(-)
 create mode 100644 net/ipv4/tcp_recvbio.c

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e79aa48..c4d924b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -538,6 +538,9 @@ typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
 extern int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 			 sk_read_actor_t recv_actor);
 
+/* tcp_recvbio.c */
+extern int tcp_recvbio(struct sock *sk, struct bio *bio, size_t size);
+
 extern void tcp_initialize_rcv_mss(struct sock *sk);
 
 extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index ff75d3b..7ee9f92 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,8 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o
+	     inet_fragment.o ping.o \
+	     tcp_recvbio.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
 obj-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/ipv4/tcp_recvbio.c b/net/ipv4/tcp_recvbio.c
new file mode 100644
index 0000000..4d6f833
--- /dev/null
+++ b/net/ipv4/tcp_recvbio.c
@@ -0,0 +1,168 @@
+#include <linux/module.h>
+#include <net/tcp.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+
+static int tcp_recvbio_add(struct bio *bio, struct sk_buff *skb,
+			   struct bio_vec *last)
+{
+	struct request_queue *q = bio->bi_bdev->bd_disk->queue;
+	unsigned short vcnt = bio->bi_vcnt;
+	int ret;
+
+	if (vcnt == queue_max_segments(q))
+		return 0;
+	if (!blk_rq_aligned(q, last->bv_offset, last->bv_len))
+		return -EOPNOTSUPP;
+	ret = bio_add_page(bio, last->bv_page, last->bv_len, last->bv_offset);
+	if (vcnt != bio->bi_vcnt)
+		get_page(last->bv_page);
+	return ret;
+}
+
+static int tcp_recvbio_data(read_descriptor_t *rd_desc, struct sk_buff *skb,
+			    unsigned int offset, size_t len)
+{
+	struct bio *bio = rd_desc->arg.data;
+	int start = skb_headlen(skb), consumed = 0, frag_len, i;
+	struct sk_buff *frag_iter;
+	struct bio_vec last = { };
+	int ret = 0;
+
+	if (offset > (int)skb->len - len)
+		return -EFAULT;
+
+	/* Do not consume more data than we need.  */
+	if (len > rd_desc->count)
+		len = rd_desc->count;
+
+	/* Head of the skb */
+	frag_len = start - offset;
+	if (frag_len > 0) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + skb_frag_size(frag);
+		frag_len = end - offset;
+		if (frag_len > 0) {
+			if (frag_len > len)
+				frag_len = len;
+
+			last.bv_page = skb_frag_page(frag);
+			last.bv_offset = frag->page_offset + offset - start;
+			last.bv_len = frag_len;
+			ret = tcp_recvbio_add(bio, skb, &last);
+			if (ret <= 0)
+				goto out;
+			consumed += frag_len;
+			len -= frag_len;
+			if (!len)
+				break;
+			offset += frag_len;
+		}
+		start = end;
+	}
+
+	skb_walk_frags(skb, frag_iter) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + frag_iter->len;
+		frag_len = end - offset;
+		if (frag_len > 0) {
+			if (frag_len > len)
+				frag_len = len;
+
+			ret = tcp_recvbio_data(rd_desc, frag_iter, offset -
+					       start, frag_len);
+			if (ret <= 0)
+				goto out;
+			consumed += frag_len;
+			len -= frag_len;
+			if (!len)
+				break;
+			offset += frag_len;
+		}
+		start = end;
+	}
+
+out:
+	rd_desc->written += consumed;
+	rd_desc->count -= consumed;
+	return consumed ? consumed : ret;
+}
+
+/**
+ * tcp_recvbio  -  zero-copy receive from a socket into a bio
+ * @sk: socket to receive from
+ * @bio: empty bio to receive into
+ * @size: number of bytes to receive
+ *
+ * Directly add page fragments from @sk's receive buffer to @bio.  The page
+ * fragments are held referenced with get_page().  Release those references
+ * with bio_release_pages() when done.
+ *
+ * Returns the number of bytes received into @bio.
+ */
+int tcp_recvbio(struct sock *sk, struct bio *bio, size_t size)
+{
+	long timeo = sock_rcvtimeo(sk, 0);
+	read_descriptor_t rd_desc = {
+		.count = size,
+		.arg = { .data = bio },
+	};
+	int ret = 0;
+
+	BUG_ON(bio->bi_idx != 0);
+
+	lock_sock(sk);
+	while (rd_desc.count) {
+		read_lock(&sk->sk_callback_lock);
+		ret = tcp_read_sock(sk, &rd_desc, tcp_recvbio_data);
+		read_unlock(&sk->sk_callback_lock);
+		if (ret < 0)
+			break;
+		else if (ret > 0)
+			timeo = sock_rcvtimeo(sk, 0);
+		else {
+			if (sock_flag(sk, SOCK_DONE))
+				break;
+			if (sk->sk_err) {
+				ret = sock_error(sk);
+				break;
+			}
+			if (sk->sk_shutdown & RCV_SHUTDOWN)
+				break;
+			if (sk->sk_state == TCP_CLOSE) {
+				/*
+				 * This occurs when user tries to read
+				 * from never connected socket.
+				 */
+				if (!sock_flag(sk, SOCK_DONE))
+					ret = -ENOTCONN;
+				break;
+                        }
+			if (!timeo) {
+				ret = -EAGAIN;
+				break;
+			}
+			sk_wait_data(sk, &timeo);
+			if (signal_pending(current)) {
+				ret = timeo ? sock_intr_errno(timeo) : -EAGAIN;
+				break;
+			}
+			timeo = 0;
+		}
+	}
+	release_sock(sk);
+	return rd_desc.written ? rd_desc.written : ret;
+}
+EXPORT_SYMBOL(tcp_recvbio);
-- 
1.7.10.2
