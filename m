From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 10/17] switch AF_PACKET and AF_UNIX to
 skb_copy_datagram_from_iter()
Date: Sat, 22 Nov 2014 04:35:02 +0000
Message-ID: <20141122043502.GJ30478@ZenIV.linux.org.uk>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34277 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbaKVEfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 23:35:03 -0500
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... and kill skb_copy_datagram_iovec()

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |    3 --
 net/core/datagram.c    |   88 ++----------------------------------------------
 net/packet/af_packet.c |   11 ++++--
 net/unix/af_unix.c     |   11 ++++--
 4 files changed, 18 insertions(+), 95 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fa11bbd..67f659e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2656,9 +2656,6 @@ static inline int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
 {
 	return skb_copy_and_csum_datagram_iovec(skb, hlen, msg->msg_iov);
 }
-int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
-				 const struct iovec *from, int from_offset,
-				 int len);
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from, int len);
 int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 5f8b90d..836f76c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -480,98 +480,14 @@ short_copy:
 EXPORT_SYMBOL(skb_copy_datagram_iter);
 
 /**
- *	skb_copy_datagram_from_iovec - Copy a datagram from an iovec.
+ *	skb_copy_datagram_from_iter - Copy a datagram from an iov_iter.
  *	@skb: buffer to copy
  *	@offset: offset in the buffer to start copying to
- *	@from: io vector to copy to
- *	@from_offset: offset in the io vector to start copying from
+ *	@from: the copy source
  *	@len: amount of data to copy to buffer from iovec
  *
  *	Returns 0 or -EFAULT.
- *	Note: the iovec is not modified during the copy.
  */
-int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
-				 const struct iovec *from, int from_offset,
-				 int len)
-{
-	int start = skb_headlen(skb);
-	int i, copy = start - offset;
-	struct sk_buff *frag_iter;
-
-	/* Copy header. */
-	if (copy > 0) {
-		if (copy > len)
-			copy = len;
-		if (memcpy_fromiovecend(skb->data + offset, from, from_offset,
-					copy))
-			goto fault;
-		if ((len -= copy) == 0)
-			return 0;
-		offset += copy;
-		from_offset += copy;
-	}
-
-	/* Copy paged appendix. Hmm... why does this look so complicated? */
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		int end;
-		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-		WARN_ON(start > offset + len);
-
-		end = start + skb_frag_size(frag);
-		if ((copy = end - offset) > 0) {
-			int err;
-			u8  *vaddr;
-			struct page *page = skb_frag_page(frag);
-
-			if (copy > len)
-				copy = len;
-			vaddr = kmap(page);
-			err = memcpy_fromiovecend(vaddr + frag->page_offset +
-						  offset - start,
-						  from, from_offset, copy);
-			kunmap(page);
-			if (err)
-				goto fault;
-
-			if (!(len -= copy))
-				return 0;
-			offset += copy;
-			from_offset += copy;
-		}
-		start = end;
-	}
-
-	skb_walk_frags(skb, frag_iter) {
-		int end;
-
-		WARN_ON(start > offset + len);
-
-		end = start + frag_iter->len;
-		if ((copy = end - offset) > 0) {
-			if (copy > len)
-				copy = len;
-			if (skb_copy_datagram_from_iovec(frag_iter,
-							 offset - start,
-							 from,
-							 from_offset,
-							 copy))
-				goto fault;
-			if ((len -= copy) == 0)
-				return 0;
-			offset += copy;
-			from_offset += copy;
-		}
-		start = end;
-	}
-	if (!len)
-		return 0;
-
-fault:
-	return -EFAULT;
-}
-EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
-
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from,
 				 int len)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 692f049..83bae39 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2400,6 +2400,10 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	unsigned short gso_type = 0;
 	int hlen, tlen;
 	int extra_len = 0;
+	struct iov_iter from;
+	ssize_t n;
+
+	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
 
 	/*
 	 *	Get and verify the address.
@@ -2438,8 +2442,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 
 		len -= vnet_hdr_len;
 
-		err = memcpy_from_msg((void *)&vnet_hdr, msg, vnet_hdr_len);
-		if (err < 0)
+		err = -EFAULT;
+		n = copy_from_iter(&vnet_hdr, vnet_hdr_len, &from);
+		if (n != vnet_hdr_len)
 			goto out_unlock;
 
 		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
@@ -2504,7 +2509,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		goto out_free;
 
 	/* Returns -EFAULT on error */
-	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
+	err = skb_copy_datagram_from_iter(skb, offset, &from, len);
 	if (err)
 		goto out_free;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5eee625..4450d62 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1459,6 +1459,9 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	int max_level;
 	int data_len = 0;
+	struct iov_iter from;
+
+	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1516,7 +1519,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	skb_put(skb, len - data_len);
 	skb->data_len = data_len;
 	skb->len = len;
-	err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, len);
+	err = skb_copy_datagram_from_iter(skb, 0, &from, len);
 	if (err)
 		goto out_free;
 
@@ -1638,6 +1641,9 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	bool fds_sent = false;
 	int max_level;
 	int data_len;
+	struct iov_iter from;
+
+	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1694,8 +1700,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		skb_put(skb, size - data_len);
 		skb->data_len = data_len;
 		skb->len = size;
-		err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov,
-						   sent, size);
+		err = skb_copy_datagram_from_iter(skb, 0, &from, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
-- 
1.7.10.4
