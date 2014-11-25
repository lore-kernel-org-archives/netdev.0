From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 17/17] rds: switch rds_message_copy_from_user() to iov_iter
Date: Tue, 25 Nov 2014 14:02:31 +0000
Message-ID: <1416924151-28698-17-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/rds/message.c |   42 ++++++++++++------------------------------
 net/rds/rds.h     |    3 +--
 net/rds/send.c    |    4 +++-
 3 files changed, 16 insertions(+), 33 deletions(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index 7a546e0..ff22022 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -264,64 +264,46 @@ struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned in
 	return rm;
 }
 
-int rds_message_copy_from_user(struct rds_message *rm, struct iovec *first_iov,
-					       size_t total_len)
+int rds_message_copy_from_user(struct rds_message *rm, struct iov_iter *from)
 {
 	unsigned long to_copy;
-	unsigned long iov_off;
 	unsigned long sg_off;
-	struct iovec *iov;
 	struct scatterlist *sg;
 	int ret = 0;
 
-	rm->m_inc.i_hdr.h_len = cpu_to_be32(total_len);
+	rm->m_inc.i_hdr.h_len = cpu_to_be32(iov_iter_count(from));
 
 	/*
 	 * now allocate and copy in the data payload.
 	 */
 	sg = rm->data.op_sg;
-	iov = first_iov;
-	iov_off = 0;
 	sg_off = 0; /* Dear gcc, sg->page will be null from kzalloc. */
 
-	while (total_len) {
+	while (iov_iter_count(from)) {
 		if (!sg_page(sg)) {
-			ret = rds_page_remainder_alloc(sg, total_len,
+			ret = rds_page_remainder_alloc(sg, iov_iter_count(from),
 						       GFP_HIGHUSER);
 			if (ret)
-				goto out;
+				return ret;
 			rm->data.op_nents++;
 			sg_off = 0;
 		}
 
-		while (iov_off == iov->iov_len) {
-			iov_off = 0;
-			iov++;
-		}
-
-		to_copy = min(iov->iov_len - iov_off, sg->length - sg_off);
-		to_copy = min_t(size_t, to_copy, total_len);
-
-		rdsdebug("copying %lu bytes from user iov [%p, %zu] + %lu to "
-			 "sg [%p, %u, %u] + %lu\n",
-			 to_copy, iov->iov_base, iov->iov_len, iov_off,
-			 (void *)sg_page(sg), sg->offset, sg->length, sg_off);
+		to_copy = min_t(unsigned long, iov_iter_count(from),
+				sg->length - sg_off);
 
-		ret = rds_page_copy_from_user(sg_page(sg), sg->offset + sg_off,
-					      iov->iov_base + iov_off,
-					      to_copy);
-		if (ret)
-			goto out;
+		rds_stats_add(s_copy_from_user, to_copy);
+		ret = copy_page_from_iter(sg_page(sg), sg->offset + sg_off,
+					  to_copy, from);
+		if (ret != to_copy)
+			return -EFAULT;
 
-		iov_off += to_copy;
-		total_len -= to_copy;
 		sg_off += to_copy;
 
 		if (sg_off == sg->length)
 			sg++;
 	}
 
-out:
 	return ret;
 }
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index b22dad9..c2a5eef 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -656,8 +656,7 @@ rds_conn_connecting(struct rds_connection *conn)
 /* message.c */
 struct rds_message *rds_message_alloc(unsigned int nents, gfp_t gfp);
 struct scatterlist *rds_message_alloc_sgs(struct rds_message *rm, int nents);
-int rds_message_copy_from_user(struct rds_message *rm, struct iovec *first_iov,
-					       size_t total_len);
+int rds_message_copy_from_user(struct rds_message *rm, struct iov_iter *from);
 struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned int total_len);
 void rds_message_populate_header(struct rds_header *hdr, __be16 sport,
 				 __be16 dport, u64 seq);
diff --git a/net/rds/send.c b/net/rds/send.c
index 0a64541..4de62ea 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -934,7 +934,9 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int queued = 0, allocated_mr = 0;
 	int nonblock = msg->msg_flags & MSG_DONTWAIT;
 	long timeo = sock_sndtimeo(sk, nonblock);
+	struct iov_iter from;
 
+	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, payload_len);
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_CMSG_COMPAT)) {
@@ -982,7 +984,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 			ret = -ENOMEM;
 			goto out;
 		}
-		ret = rds_message_copy_from_user(rm, msg->msg_iov, payload_len);
+		ret = rds_message_copy_from_user(rm, &from);
 		if (ret)
 			goto out;
 	}
-- 
1.7.10.4
