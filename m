From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 16/17] rds: switch ->inc_copy_to_user() to passing iov_iter
Date: Sat, 22 Nov 2014 04:38:52 +0000
Message-ID: <20141122043852.GP30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

instances get considerably simpler from that...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/rds/ib.h       |    3 +--
 net/rds/ib_recv.c  |   37 +++++++++++--------------------------
 net/rds/iw.h       |    3 +--
 net/rds/iw_recv.c  |   37 +++++++++++--------------------------
 net/rds/message.c  |   35 ++++++++---------------------------
 net/rds/rds.h      |    6 ++----
 net/rds/recv.c     |    5 +++--
 net/rds/tcp.h      |    3 +--
 net/rds/tcp_recv.c |   38 +++++++++-----------------------------
 9 files changed, 47 insertions(+), 120 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 7280ab8..c36d713 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -316,8 +316,7 @@ int rds_ib_recv_alloc_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_free_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_refill(struct rds_connection *conn, int prefill);
 void rds_ib_inc_free(struct rds_incoming *inc);
-int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
-			     size_t size);
+int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context);
 void rds_ib_recv_tasklet_fn(unsigned long data);
 void rds_ib_recv_init_ring(struct rds_ib_connection *ic);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index d67de45..1b981a4 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -472,15 +472,12 @@ static struct list_head *rds_ib_recv_cache_get(struct rds_ib_refill_cache *cache
 	return head;
 }
 
-int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
-			    size_t size)
+int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to)
 {
 	struct rds_ib_incoming *ibinc;
 	struct rds_page_frag *frag;
-	struct iovec *iov = first_iov;
 	unsigned long to_copy;
 	unsigned long frag_off = 0;
-	unsigned long iov_off = 0;
 	int copied = 0;
 	int ret;
 	u32 len;
@@ -489,37 +486,25 @@ int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
 	frag = list_entry(ibinc->ii_frags.next, struct rds_page_frag, f_item);
 	len = be32_to_cpu(inc->i_hdr.h_len);
 
-	while (copied < size && copied < len) {
+	while (iov_iter_count(to) && copied < len) {
 		if (frag_off == RDS_FRAG_SIZE) {
 			frag = list_entry(frag->f_item.next,
 					  struct rds_page_frag, f_item);
 			frag_off = 0;
 		}
-		while (iov_off == iov->iov_len) {
-			iov_off = 0;
-			iov++;
-		}
-
-		to_copy = min(iov->iov_len - iov_off, RDS_FRAG_SIZE - frag_off);
-		to_copy = min_t(size_t, to_copy, size - copied);
+		to_copy = min_t(unsigned long, iov_iter_count(to),
+				RDS_FRAG_SIZE - frag_off);
 		to_copy = min_t(unsigned long, to_copy, len - copied);
 
-		rdsdebug("%lu bytes to user [%p, %zu] + %lu from frag "
-			 "[%p, %u] + %lu\n",
-			 to_copy, iov->iov_base, iov->iov_len, iov_off,
-			 sg_page(&frag->f_sg), frag->f_sg.offset, frag_off);
-
 		/* XXX needs + offset for multiple recvs per page */
-		ret = rds_page_copy_to_user(sg_page(&frag->f_sg),
-					    frag->f_sg.offset + frag_off,
-					    iov->iov_base + iov_off,
-					    to_copy);
-		if (ret) {
-			copied = ret;
-			break;
-		}
+		rds_stats_add(s_copy_to_user, to_copy);
+		ret = copy_page_to_iter(sg_page(&frag->f_sg),
+					frag->f_sg.offset + frag_off,
+					to_copy,
+					to);
+		if (ret != to_copy)
+			return -EFAULT;
 
-		iov_off += to_copy;
 		frag_off += to_copy;
 		copied += to_copy;
 	}
diff --git a/net/rds/iw.h b/net/rds/iw.h
index 04ce3b1..cbe6674 100644
--- a/net/rds/iw.h
+++ b/net/rds/iw.h
@@ -325,8 +325,7 @@ int rds_iw_recv(struct rds_connection *conn);
 int rds_iw_recv_refill(struct rds_connection *conn, gfp_t kptr_gfp,
 		       gfp_t page_gfp, int prefill);
 void rds_iw_inc_free(struct rds_incoming *inc);
-int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
-			     size_t size);
+int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 void rds_iw_recv_cq_comp_handler(struct ib_cq *cq, void *context);
 void rds_iw_recv_tasklet_fn(unsigned long data);
 void rds_iw_recv_init_ring(struct rds_iw_connection *ic);
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index aa8bf67..a66d179 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -303,15 +303,12 @@ void rds_iw_inc_free(struct rds_incoming *inc)
 	BUG_ON(atomic_read(&rds_iw_allocation) < 0);
 }
 
-int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
-			    size_t size)
+int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to)
 {
 	struct rds_iw_incoming *iwinc;
 	struct rds_page_frag *frag;
-	struct iovec *iov = first_iov;
 	unsigned long to_copy;
 	unsigned long frag_off = 0;
-	unsigned long iov_off = 0;
 	int copied = 0;
 	int ret;
 	u32 len;
@@ -320,37 +317,25 @@ int rds_iw_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
 	frag = list_entry(iwinc->ii_frags.next, struct rds_page_frag, f_item);
 	len = be32_to_cpu(inc->i_hdr.h_len);
 
-	while (copied < size && copied < len) {
+	while (iov_iter_count(to) && copied < len) {
 		if (frag_off == RDS_FRAG_SIZE) {
 			frag = list_entry(frag->f_item.next,
 					  struct rds_page_frag, f_item);
 			frag_off = 0;
 		}
-		while (iov_off == iov->iov_len) {
-			iov_off = 0;
-			iov++;
-		}
-
-		to_copy = min(iov->iov_len - iov_off, RDS_FRAG_SIZE - frag_off);
-		to_copy = min_t(size_t, to_copy, size - copied);
+		to_copy = min_t(unsigned long, iov_iter_count(to),
+				RDS_FRAG_SIZE - frag_off);
 		to_copy = min_t(unsigned long, to_copy, len - copied);
 
-		rdsdebug("%lu bytes to user [%p, %zu] + %lu from frag "
-			 "[%p, %lu] + %lu\n",
-			 to_copy, iov->iov_base, iov->iov_len, iov_off,
-			 frag->f_page, frag->f_offset, frag_off);
-
 		/* XXX needs + offset for multiple recvs per page */
-		ret = rds_page_copy_to_user(frag->f_page,
-					    frag->f_offset + frag_off,
-					    iov->iov_base + iov_off,
-					    to_copy);
-		if (ret) {
-			copied = ret;
-			break;
-		}
+		rds_stats_add(s_copy_to_user, to_copy);
+		ret = copy_page_to_iter(frag->f_page,
+					frag->f_offset + frag_off,
+					to_copy,
+					to);
+		if (ret != to_copy)
+			return -EFAULT;
 
-		iov_off += to_copy;
 		frag_off += to_copy;
 		copied += to_copy;
 	}
diff --git a/net/rds/message.c b/net/rds/message.c
index aba232f..7a546e0 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -325,14 +325,11 @@ out:
 	return ret;
 }
 
-int rds_message_inc_copy_to_user(struct rds_incoming *inc,
-				 struct iovec *first_iov, size_t size)
+int rds_message_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to)
 {
 	struct rds_message *rm;
-	struct iovec *iov;
 	struct scatterlist *sg;
 	unsigned long to_copy;
-	unsigned long iov_off;
 	unsigned long vec_off;
 	int copied;
 	int ret;
@@ -341,36 +338,20 @@ int rds_message_inc_copy_to_user(struct rds_incoming *inc,
 	rm = container_of(inc, struct rds_message, m_inc);
 	len = be32_to_cpu(rm->m_inc.i_hdr.h_len);
 
-	iov = first_iov;
-	iov_off = 0;
 	sg = rm->data.op_sg;
 	vec_off = 0;
 	copied = 0;
 
-	while (copied < size && copied < len) {
-		while (iov_off == iov->iov_len) {
-			iov_off = 0;
-			iov++;
-		}
-
-		to_copy = min(iov->iov_len - iov_off, sg->length - vec_off);
-		to_copy = min_t(size_t, to_copy, size - copied);
+	while (iov_iter_count(to) && copied < len) {
+		to_copy = min(iov_iter_count(to), sg->length - vec_off);
 		to_copy = min_t(unsigned long, to_copy, len - copied);
 
-		rdsdebug("copying %lu bytes to user iov [%p, %zu] + %lu to "
-			 "sg [%p, %u, %u] + %lu\n",
-			 to_copy, iov->iov_base, iov->iov_len, iov_off,
-			 sg_page(sg), sg->offset, sg->length, vec_off);
-
-		ret = rds_page_copy_to_user(sg_page(sg), sg->offset + vec_off,
-					    iov->iov_base + iov_off,
-					    to_copy);
-		if (ret) {
-			copied = ret;
-			break;
-		}
+		rds_stats_add(s_copy_to_user, to_copy);
+		ret = copy_page_to_iter(sg_page(sg), sg->offset + vec_off,
+					to_copy, to);
+		if (ret != to_copy)
+			return -EFAULT;
 
-		iov_off += to_copy;
 		vec_off += to_copy;
 		copied += to_copy;
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 48f8ffc..b22dad9 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -431,8 +431,7 @@ struct rds_transport {
 	int (*xmit_rdma)(struct rds_connection *conn, struct rm_rdma_op *op);
 	int (*xmit_atomic)(struct rds_connection *conn, struct rm_atomic_op *op);
 	int (*recv)(struct rds_connection *conn);
-	int (*inc_copy_to_user)(struct rds_incoming *inc, struct iovec *iov,
-				size_t size);
+	int (*inc_copy_to_user)(struct rds_incoming *inc, struct iov_iter *to);
 	void (*inc_free)(struct rds_incoming *inc);
 
 	int (*cm_handle_connect)(struct rdma_cm_id *cm_id,
@@ -667,8 +666,7 @@ int rds_message_add_extension(struct rds_header *hdr,
 int rds_message_next_extension(struct rds_header *hdr,
 			       unsigned int *pos, void *buf, unsigned int *buflen);
 int rds_message_add_rdma_dest_extension(struct rds_header *hdr, u32 r_key, u32 offset);
-int rds_message_inc_copy_to_user(struct rds_incoming *inc,
-				 struct iovec *first_iov, size_t size);
+int rds_message_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 void rds_message_inc_free(struct rds_incoming *inc);
 void rds_message_addref(struct rds_message *rm);
 void rds_message_put(struct rds_message *rm);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index bd82522..47d7b10 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -404,6 +404,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int ret = 0, nonblock = msg_flags & MSG_DONTWAIT;
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct rds_incoming *inc = NULL;
+	struct iov_iter to;
 
 	/* udp_recvmsg()->sock_recvtimeo() gets away without locking too.. */
 	timeo = sock_rcvtimeo(sk, nonblock);
@@ -449,8 +450,8 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		rdsdebug("copying inc %p from %pI4:%u to user\n", inc,
 			 &inc->i_conn->c_faddr,
 			 ntohs(inc->i_hdr.h_sport));
-		ret = inc->i_conn->c_trans->inc_copy_to_user(inc, msg->msg_iov,
-							     size);
+		iov_iter_init(&to, READ, msg->msg_iov, msg->msg_iovlen, size);
+		ret = inc->i_conn->c_trans->inc_copy_to_user(inc, &to);
 		if (ret < 0)
 			break;
 
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 6563749..0dbdd37 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -69,8 +69,7 @@ void rds_tcp_recv_exit(void);
 void rds_tcp_data_ready(struct sock *sk);
 int rds_tcp_recv(struct rds_connection *conn);
 void rds_tcp_inc_free(struct rds_incoming *inc);
-int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
-			     size_t size);
+int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 
 /* tcp_send.c */
 void rds_tcp_xmit_prepare(struct rds_connection *conn);
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 9ae6e0a..fbc5ef8 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -59,50 +59,30 @@ void rds_tcp_inc_free(struct rds_incoming *inc)
 /*
  * this is pretty lame, but, whatever.
  */
-int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
-			     size_t size)
+int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to)
 {
 	struct rds_tcp_incoming *tinc;
-	struct iovec *iov, tmp;
 	struct sk_buff *skb;
-	unsigned long to_copy, skb_off;
 	int ret = 0;
 
-	if (size == 0)
+	if (!iov_iter_count(to))
 		goto out;
 
 	tinc = container_of(inc, struct rds_tcp_incoming, ti_inc);
-	iov = first_iov;
-	tmp = *iov;
 
 	skb_queue_walk(&tinc->ti_skb_list, skb) {
-		skb_off = 0;
-		while (skb_off < skb->len) {
-			while (tmp.iov_len == 0) {
-				iov++;
-				tmp = *iov;
-			}
-
-			to_copy = min(tmp.iov_len, size);
+		unsigned long to_copy, skb_off;
+		for (skb_off = 0; skb_off < skb->len; skb_off += to_copy) {
+			to_copy = iov_iter_count(to);
 			to_copy = min(to_copy, skb->len - skb_off);
 
-			rdsdebug("ret %d size %zu skb %p skb_off %lu "
-				 "skblen %d iov_base %p iov_len %zu cpy %lu\n",
-				 ret, size, skb, skb_off, skb->len,
-				 tmp.iov_base, tmp.iov_len, to_copy);
-
-			/* modifies tmp as it copies */
-			if (skb_copy_datagram_iovec(skb, skb_off, &tmp,
-						    to_copy)) {
-				ret = -EFAULT;
-				goto out;
-			}
+			if (skb_copy_datagram_iter(skb, skb_off, to, to_copy))
+				return -EFAULT;
 
 			rds_stats_add(s_copy_to_user, to_copy);
-			size -= to_copy;
 			ret += to_copy;
-			skb_off += to_copy;
-			if (size == 0)
+
+			if (!iov_iter_count(to))
 				goto out;
 		}
 	}
-- 
1.7.10.4
