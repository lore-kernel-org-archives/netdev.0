From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/2] net: skb_copy_datagram_from_iovec()
Date: Tue, 12 Aug 2008 16:24:56 +1000
Message-ID: <200808121624.56948.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56446 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbYHLGZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 02:25:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's an skb_copy_datagram_iovec() to copy out of a paged skb, but
nothing the other way around (because we don't do that).

We want to allocate big skbs in tun.c, so let's add the function.
It's a carbon copy of skb_copy_datagram_iovec() with enough changes to
be annoying.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/skbuff.h |    4 ++
 net/core/datagram.c    |   87 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 91 insertions(+)

diff -r fcbf6d08c910 include/linux/skbuff.h
--- a/include/linux/skbuff.h	Wed Aug 06 11:30:36 2008 +1000
+++ b/include/linux/skbuff.h	Wed Aug 06 16:13:41 2008 +1000
@@ -1452,6 +1452,10 @@ extern int	       skb_copy_and_csum_data
 extern int	       skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
 							int hlen,
 							struct iovec *iov);
+extern int	       skb_copy_datagram_from_iovec(struct sk_buff *skb,
+						    int offset,
+						    struct iovec *from,
+						    int len);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *skb,
 					 unsigned int flags);
diff -r fcbf6d08c910 net/core/datagram.c
--- a/net/core/datagram.c	Wed Aug 06 11:30:36 2008 +1000
+++ b/net/core/datagram.c	Wed Aug 06 16:13:41 2008 +1000
@@ -339,6 +339,93 @@ fault:
 	return -EFAULT;
 }
 
+/**
+ *	skb_copy_datagram_from_iovec - Copy a datagram from an iovec.
+ *	@skb: buffer to copy
+ *	@offset: offset in the buffer to start copying to
+ *	@from: io vector to copy to
+ *	@len: amount of data to copy to buffer from iovec
+ *
+ *	Returns 0 or -EFAULT.
+ *	Note: the iovec is modified during the copy.
+ */
+int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
+				 struct iovec *from, int len)
+{
+	int start = skb_headlen(skb);
+	int i, copy = start - offset;
+
+	/* Copy header. */
+	if (copy > 0) {
+		if (copy > len)
+			copy = len;
+		if (memcpy_fromiovec(skb->data + offset, from, copy))
+			goto fault;
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
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
+			err = memcpy_fromiovec(vaddr + frag->page_offset +
+					       offset - start, from, copy);
+			kunmap(page);
+			if (err)
+				goto fault;
+
+			if (!(len -= copy))
+				return 0;
+			offset += copy;
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
+				if (skb_copy_datagram_from_iovec(list,
+								 offset - start,
+								 from, copy))
+					goto fault;
+				if ((len -= copy) == 0)
+					return 0;
+				offset += copy;
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
+EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
+
 static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 				      u8 __user *to, int len,
 				      __wsum *csump)
