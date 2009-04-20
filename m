From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/3] net: skb_copy_datagram_const_iovec()
Date: Mon, 20 Apr 2009 14:25:46 +0300
Message-ID: <20090420112546.GA6712@dhcp-1-124.tlv.redhat.com>
References: <cover.1240125603.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60295 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754418AbZDTL04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 07:26:56 -0400
Content-Disposition: inline
In-Reply-To: <cover.1240125603.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's an skb_copy_datagram_iovec() to copy out of a paged skb,
but it modifies the iovec, and does not support starting
at an offset in the destination. We want both in tun.c, so let's
add the function.

It's a carbon copy of skb_copy_datagram_iovec() with enough changes to
be annoying.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/skbuff.h |    5 +++
 include/linux/socket.h |    2 +
 net/core/datagram.c    |   92 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/iovec.c       |   26 +++++++++++++
 4 files changed, 125 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5fd3891..af2b21b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1717,6 +1717,11 @@ extern int	       skb_copy_datagram_from_iovec(struct sk_buff *skb,
 						    int offset,
 						    struct iovec *from,
 						    int len);
+extern int	       skb_copy_datagram_const_iovec(const struct sk_buff *from,
+						     int offset,
+						     const struct iovec *to,
+						     int to_offset,
+						     int size);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *skb,
 					 unsigned int flags);
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..171b08d 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -318,6 +318,8 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
 
 extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
+extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
+			     int offset, int len);
 extern int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uaddr, int __user *ulen);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index d0de644..4dbb05c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -339,6 +339,98 @@ fault:
 }
 
 /**
+ *	skb_copy_datagram_const_iovec - Copy a datagram to an iovec.
+ *	@skb: buffer to copy
+ *	@offset: offset in the buffer to start copying from
+ *	@to: io vector to copy to
+ *	@to_offset: offset in the io vector to start copying to
+ *	@len: amount of data to copy from buffer to iovec
+ *
+ *	Returns 0 or -EFAULT.
+ *	Note: the iovec is not modified during the copy.
+ */
+int skb_copy_datagram_const_iovec(const struct sk_buff *skb, int offset,
+				  const struct iovec *to, int to_offset,
+				  int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		if (memcpy_toiovecend(to, skb->data + offset, to_offset, copy))
+			goto fault;
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
+		to_offset += copy;
+	}
+
+	/* Copy paged appendix. Hmm... why does this look so complicated? */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		WARN_ON(start > offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		if ((copy = end - offset) > 0) {
+			int err;
+			u8  *vaddr;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			struct page *page = frag->page;
+
+			if (copy > len)
+				copy = len;
+			vaddr = kmap(page);
+			err = memcpy_toiovecend(to, vaddr + frag->page_offset +
+						offset - start, to_offset, copy);
+			kunmap(page);
+			if (err)
+				goto fault;
+			if (!(len -= copy))
+				return 0;
+			offset += copy;
+			to_offset += copy;
+		}
+		start = end;
+	}
+
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list; list = list->next) {
+			int end;
+
+			WARN_ON(start > offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				if (skb_copy_datagram_const_iovec(list,
+							    offset - start,
+							    to, to_offset,
+							    copy))
+					goto fault;
+				if ((len -= copy) == 0)
+					return 0;
+				offset += copy;
+				to_offset += copy;
+			}
+			start = end;
+		}
+	}
+	if (!len)
+		return 0;
+
+fault:
+	return -EFAULT;
+}
+EXPORT_SYMBOL(skb_copy_datagram_const_iovec);
+
+/**
  *	skb_copy_datagram_from_iovec - Copy a datagram from an iovec.
  *	@skb: buffer to copy
  *	@offset: offset in the buffer to start copying to
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 4c9c012..a215545 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -98,6 +98,31 @@ int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len)
 }
 
 /*
+ *	Copy kernel to iovec. Returns -EFAULT on error.
+ */
+
+int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
+		      int offset, int len)
+{
+	int copy;
+	for (; len > 0; ++iov) {
+		/* Skip over the finished iovecs */
+		if (unlikely(offset >= iov->iov_len)) {
+			offset -= iov->iov_len;
+			continue;
+		}
+		copy = min_t(unsigned int, iov->iov_len - offset, len);
+		offset = 0;
+		if (copy_to_user(iov->iov_base, kdata, copy))
+			return -EFAULT;
+		kdata += copy;
+		len -= copy;
+	}
+
+	return 0;
+}
+
+/*
  *	Copy iovec to kernel. Returns -EFAULT on error.
  *
  *	Note: this modifies the original iovec.
@@ -236,3 +261,4 @@ EXPORT_SYMBOL(csum_partial_copy_fromiovecend);
 EXPORT_SYMBOL(memcpy_fromiovec);
 EXPORT_SYMBOL(memcpy_fromiovecend);
 EXPORT_SYMBOL(memcpy_toiovec);
+EXPORT_SYMBOL(memcpy_toiovecend);
-- 
1.6.0.6

