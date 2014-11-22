From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: PATCH 11/17] switch sctp_user_addto_chunk() and
 sctp_datamsg_from_user() to passing iov_iter
Date: Sat, 22 Nov 2014 04:36:04 +0000
Message-ID: <20141122043604.GK30478@ZenIV.linux.org.uk>
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

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/sctp/structs.h |    6 +++---
 net/sctp/chunk.c           |    9 ++++-----
 net/sctp/sm_make_chunk.c   |   16 ++++++++--------
 net/sctp/socket.c          |    5 ++++-
 4 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 806e3b5..2bb2fcf 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -531,7 +531,7 @@ struct sctp_datamsg {
 
 struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
 					    struct sctp_sndrcvinfo *,
-					    struct msghdr *, int len);
+					    struct iov_iter *);
 void sctp_datamsg_free(struct sctp_datamsg *);
 void sctp_datamsg_put(struct sctp_datamsg *);
 void sctp_chunk_fail(struct sctp_chunk *, int error);
@@ -647,8 +647,8 @@ struct sctp_chunk {
 
 void sctp_chunk_hold(struct sctp_chunk *);
 void sctp_chunk_put(struct sctp_chunk *);
-int sctp_user_addto_chunk(struct sctp_chunk *chunk, int off, int len,
-			  struct iovec *data);
+int sctp_user_addto_chunk(struct sctp_chunk *chunk, int len,
+			  struct iov_iter *from);
 void sctp_chunk_free(struct sctp_chunk *);
 void  *sctp_addto_chunk(struct sctp_chunk *, int len, const void *data);
 struct sctp_chunk *sctp_chunkify(struct sk_buff *,
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 158701d..a338091 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -164,7 +164,7 @@ static void sctp_datamsg_assign(struct sctp_datamsg *msg, struct sctp_chunk *chu
  */
 struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 					    struct sctp_sndrcvinfo *sinfo,
-					    struct msghdr *msgh, int msg_len)
+					    struct iov_iter *from)
 {
 	int max, whole, i, offset, over, err;
 	int len, first_len;
@@ -172,6 +172,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	struct sctp_chunk *chunk;
 	struct sctp_datamsg *msg;
 	struct list_head *pos, *temp;
+	size_t msg_len = iov_iter_count(from);
 	__u8 frag;
 
 	msg = sctp_datamsg_new(GFP_KERNEL);
@@ -279,12 +280,10 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			goto errout;
 		}
 
-		err = sctp_user_addto_chunk(chunk, offset, len, msgh->msg_iov);
+		err = sctp_user_addto_chunk(chunk, len, from);
 		if (err < 0)
 			goto errout_chunk_free;
 
-		offset += len;
-
 		/* Put the chunk->skb back into the form expected by send.  */
 		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
 			   - (__u8 *)chunk->skb->data);
@@ -317,7 +316,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			goto errout;
 		}
 
-		err = sctp_user_addto_chunk(chunk, offset, over, msgh->msg_iov);
+		err = sctp_user_addto_chunk(chunk, over, from);
 
 		/* Put the chunk->skb back into the form expected by send.  */
 		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index e49bcce..e49e231 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1491,26 +1491,26 @@ static void *sctp_addto_chunk_fixed(struct sctp_chunk *chunk,
  * chunk is not big enough.
  * Returns a kernel err value.
  */
-int sctp_user_addto_chunk(struct sctp_chunk *chunk, int off, int len,
-			  struct iovec *data)
+int sctp_user_addto_chunk(struct sctp_chunk *chunk, int len,
+			  struct iov_iter *from)
 {
-	__u8 *target;
-	int err = 0;
+	void *target;
+	ssize_t copied;
 
 	/* Make room in chunk for data.  */
 	target = skb_put(chunk->skb, len);
 
 	/* Copy data (whole iovec) into chunk */
-	if ((err = memcpy_fromiovecend(target, data, off, len)))
-		goto out;
+	copied = copy_from_iter(target, len, from);
+	if (copied != len)
+		return -EFAULT;
 
 	/* Adjust the chunk length field.  */
 	chunk->chunk_hdr->length =
 		htons(ntohs(chunk->chunk_hdr->length) + len);
 	chunk->chunk_end = skb_tail_pointer(chunk->skb);
 
-out:
-	return err;
+	return 0;
 }
 
 /* Helper function to assign a TSN if needed.  This assumes that both
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2120292..7e866b7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1609,6 +1609,9 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	__u16 sinfo_flags = 0;
 	long timeo;
 	int err;
+	struct iov_iter from;
+
+	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, msg_len);
 
 	err = 0;
 	sp = sctp_sk(sk);
@@ -1947,7 +1950,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	/* Break the message into multiple chunks of maximum size. */
-	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
+	datamsg = sctp_datamsg_from_user(asoc, sinfo, &from);
 	if (IS_ERR(datamsg)) {
 		err = PTR_ERR(datamsg);
 		goto out_free;
-- 
1.7.10.4
