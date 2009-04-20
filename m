From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/3] tun: fix tun_chr_aio_write so that aio works
Date: Mon, 20 Apr 2009 14:26:11 +0300
Message-ID: <20090420112611.GA6718@dhcp-1-124.tlv.redhat.com>
References: <cover.1240125603.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60314 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838AbZDTL1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 07:27:19 -0400
Content-Disposition: inline
In-Reply-To: <cover.1240125603.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aio_write gets const struct iovec * but tun_chr_aio_write casts this to struct
iovec * and modifies the iovec. As a result, attempts to use io_submit
to send packets to a tun device fail with weird errors such as EINVAL.

Since tun is the only user of skb_copy_datagram_from_iovec, we can
fix this simply by changing the later so that it does not
touch the iovec passed to it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c      |   13 ++++++++-----
 include/linux/skbuff.h |    3 ++-
 include/linux/socket.h |    4 ++--
 net/core/datagram.c    |   20 ++++++++++++++------
 net/core/iovec.c       |    7 ++++---
 5 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 24c19c2..c55be81 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -536,31 +536,34 @@ static inline struct sk_buff *tun_alloc_skb(struct tun_struct *tun,
 
 /* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
-				       struct iovec *iv, size_t count,
+				       const struct iovec *iv, size_t count,
 				       int noblock)
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
 	size_t len = count, align = 0;
 	struct virtio_net_hdr gso = { 0 };
+	int offset = 0;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) > count)
 			return -EINVAL;
 
-		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
+		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
 			return -EFAULT;
+		offset += sizeof(pi);
 	}
 
 	if (tun->flags & TUN_VNET_HDR) {
 		if ((len -= sizeof(gso)) > count)
 			return -EINVAL;
 
-		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
+		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
 			return -EFAULT;
 
 		if (gso.hdr_len > len)
 			return -EINVAL;
+		offset += sizeof(pi);
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
@@ -577,7 +580,7 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		return PTR_ERR(skb);
 	}
 
-	if (skb_copy_datagram_from_iovec(skb, 0, iv, len)) {
+	if (skb_copy_datagram_from_iovec(skb, 0, iv, offset, len)) {
 		tun->dev->stats.rx_dropped++;
 		kfree_skb(skb);
 		return -EFAULT;
@@ -669,7 +672,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	result = tun_get_user(tun, (struct iovec *)iv, iov_length(iv, count),
+	result = tun_get_user(tun, iv, iov_length(iv, count),
 			      file->f_flags & O_NONBLOCK);
 
 	tun_put(tun);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index af2b21b..1b5c3d2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1715,7 +1715,8 @@ extern int	       skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
 							struct iovec *iov);
 extern int	       skb_copy_datagram_from_iovec(struct sk_buff *skb,
 						    int offset,
-						    struct iovec *from,
+						    const struct iovec *from,
+						    int from_offset,
 						    int len);
 extern int	       skb_copy_datagram_const_iovec(const struct sk_buff *from,
 						     int offset,
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 171b08d..42a0396 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -309,8 +309,8 @@ struct ucred {
 
 #ifdef __KERNEL__
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
-extern int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, 
-				int offset, int len);
+extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
+			       int offset, int len);
 extern int csum_partial_copy_fromiovecend(unsigned char *kdata, 
 					  struct iovec *iov, 
 					  int offset, 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 4dbb05c..914d5fa 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -435,13 +435,15 @@ EXPORT_SYMBOL(skb_copy_datagram_const_iovec);
  *	@skb: buffer to copy
  *	@offset: offset in the buffer to start copying to
  *	@from: io vector to copy to
+ *	@from_offset: offset in the io vector to start copying from
  *	@len: amount of data to copy to buffer from iovec
  *
  *	Returns 0 or -EFAULT.
- *	Note: the iovec is modified during the copy.
+ *	Note: the iovec is not modified during the copy.
  */
 int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
-				 struct iovec *from, int len)
+				 const struct iovec *from, int from_offset,
+				 int len)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
@@ -450,11 +452,12 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 	if (copy > 0) {
 		if (copy > len)
 			copy = len;
-		if (memcpy_fromiovec(skb->data + offset, from, copy))
+		if (memcpy_fromiovecend(skb->data + offset, from, 0, copy))
 			goto fault;
 		if ((len -= copy) == 0)
 			return 0;
 		offset += copy;
+		from_offset += copy;
 	}
 
 	/* Copy paged appendix. Hmm... why does this look so complicated? */
@@ -473,8 +476,9 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 			if (copy > len)
 				copy = len;
 			vaddr = kmap(page);
-			err = memcpy_fromiovec(vaddr + frag->page_offset +
-					       offset - start, from, copy);
+			err = memcpy_fromiovecend(vaddr + frag->page_offset +
+						  offset - start,
+						  from, from_offset, copy);
 			kunmap(page);
 			if (err)
 				goto fault;
@@ -482,6 +486,7 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 			if (!(len -= copy))
 				return 0;
 			offset += copy;
+			from_offset += copy;
 		}
 		start = end;
 	}
@@ -500,11 +505,14 @@ int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
 					copy = len;
 				if (skb_copy_datagram_from_iovec(list,
 								 offset - start,
-								 from, copy))
+								 from,
+								 from_offset,
+								 copy))
 					goto fault;
 				if ((len -= copy) == 0)
 					return 0;
 				offset += copy;
+				from_offset += copy;
 			}
 			start = end;
 		}
diff --git a/net/core/iovec.c b/net/core/iovec.c
index a215545..40a76ce 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -147,10 +147,11 @@ int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
 }
 
 /*
- *	For use with ip_build_xmit
+ *	Copy iovec from kernel. Returns -EFAULT on error.
  */
-int memcpy_fromiovecend(unsigned char *kdata, struct iovec *iov, int offset,
-			int len)
+
+int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
+			int offset, int len)
 {
 	/* Skip over the finished iovecs */
 	while (offset >= iov->iov_len) {
-- 
1.6.0.6
