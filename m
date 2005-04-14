From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Thu, 14 Apr 2005 22:26:13 +1000
Message-ID: <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
References: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
Cc: davem@davemloft.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com (David Stevens)
In-Reply-To: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> wrote:
>
> I don't know if it is possible, after the fix for the second problem, to 
> get an
> skb with nonzero nr_frags in rawv6_push_pending_frames() (maybe with
> corking? or maybe via MSG_MORE?), but this patch includes support for
> non-linear skbs as well as the missing flush on error that caused the 
> problem
> to begin with.

Yes it is possible to get nr_frags != 0.

We also need to handle the case where there are multiple packets on
sk_write_queue.

So here is a patch that introduces skb_store_bits -- the opposite of
skb_copy_bits, and uses them to read/write the csum field in rawv6.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== include/linux/skbuff.h 1.65 vs edited =====
--- 1.65/include/linux/skbuff.h	2005-03-12 07:32:26 +11:00
+++ edited/include/linux/skbuff.h	2005-04-14 22:04:30 +10:00
@@ -1183,6 +1183,8 @@
 				    int len, unsigned int csum);
 extern int	       skb_copy_bits(const struct sk_buff *skb, int offset,
 				     void *to, int len);
+extern int	       skb_store_bits(const struct sk_buff *skb, int offset,
+				      void *from, int len);
 extern unsigned int    skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      unsigned int csum);
===== net/core/skbuff.c 1.44 vs edited =====
--- 1.44/net/core/skbuff.c	2005-03-12 07:32:26 +11:00
+++ edited/net/core/skbuff.c	2005-04-14 22:22:21 +10:00
@@ -985,6 +985,94 @@
 	return -EFAULT;
 }
 
+/**
+ *	skb_store_bits - store bits from kernel buffer to skb
+ *	@skb: destination buffer
+ *	@offset: offset in destination
+ *	@from: source buffer
+ *	@len: number of bytes to copy
+ *
+ *	Copy the specified number of bytes from the source buffer to the
+ *	destination skb.  This function handles all the messy bits of
+ *	traversing fragment lists and such.
+ */
+
+int skb_store_bits(const struct sk_buff *skb, int offset, void *from, int len)
+{
+	int i, copy;
+	int start = skb_headlen(skb);
+
+	if (offset > (int)skb->len - len)
+		goto fault;
+
+	if ((copy = start - offset) > 0) {
+		if (copy > len)
+			copy = len;
+		memcpy(skb->data + offset, from, copy);
+		if ((len -= copy) == 0)
+			return 0;
+		offset += copy;
+		from += copy;
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		int end;
+
+		BUG_TRAP(start <= offset + len);
+
+		end = start + frag->size;
+		if ((copy = end - offset) > 0) {
+			u8 *vaddr;
+
+			if (copy > len)
+				copy = len;
+
+			vaddr = kmap_skb_frag(frag);
+			memcpy(vaddr + frag->page_offset + offset - start,
+			       from, copy);
+			kunmap_skb_frag(vaddr);
+
+			if ((len -= copy) == 0)
+				return 0;
+			offset += copy;
+			from += copy;
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
+			BUG_TRAP(start <= offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				if (skb_store_bits(list, offset - start,
+						   from, copy))
+					goto fault;
+				if ((len -= copy) == 0)
+					return 0;
+				offset += copy;
+				from += copy;
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
+
+EXPORT_SYMBOL(skb_store_bits);
+
 /* Checksum skb data. */
 
 unsigned int skb_checksum(const struct sk_buff *skb, int offset,
===== net/ipv6/raw.c 1.80 vs edited =====
--- 1.80/net/ipv6/raw.c	2005-03-27 09:04:35 +10:00
+++ edited/net/ipv6/raw.c	2005-04-14 22:10:51 +10:00
@@ -34,6 +34,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <asm/bug.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
@@ -452,12 +453,15 @@
 }
 
 static int rawv6_push_pending_frames(struct sock *sk, struct flowi *fl,
-				     struct raw6_sock *rp, int len)
+				     struct raw6_sock *rp)
 {
+	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 	int err = 0;
-	u16 *csum;
+	int offset;
+	int len;
 	u32 tmp_csum;
+	u16 csum;
 
 	if (!rp->checksum)
 		goto send;
@@ -465,10 +469,10 @@
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
 		goto out;
 
-	if (rp->offset + 1 < len)
-		csum = (u16 *)(skb->h.raw + rp->offset);
-	else {
+	offset = rp->offset;
+	if (offset >= inet->cork.length - 1) {
 		err = -EINVAL;
+		ip6_flush_pending_frames(sk);
 		goto out;
 	}
 
@@ -479,23 +483,46 @@
 		 */
 		tmp_csum = skb->csum;
 	} else {
+		struct sk_buff *csum_skb = NULL;
 		tmp_csum = 0;
 
 		skb_queue_walk(&sk->sk_write_queue, skb) {
 			tmp_csum = csum_add(tmp_csum, skb->csum);
+
+			if (csum_skb)
+				continue;
+
+			len = skb->len - (skb->h.raw - skb->data);
+			if (offset >= len) {
+				offset -= len;
+				continue;
+			}
+
+			csum_skb = skb;
 		}
+
+		skb = csum_skb;
 	}
 
+	offset += skb->h.raw - skb->data;
+	if (skb_copy_bits(skb, offset, &csum, 2))
+		BUG();
+
 	/* in case cksum was not initialized */
-	if (unlikely(*csum))
-		tmp_csum = csum_sub(tmp_csum, *csum);
+	if (unlikely(csum))
+		tmp_csum = csum_sub(tmp_csum, csum);
 
-	*csum = csum_ipv6_magic(&fl->fl6_src,
-				&fl->fl6_dst,
-				len, fl->proto, tmp_csum);
+	tmp_csum = csum_ipv6_magic(&fl->fl6_src,
+				   &fl->fl6_dst,
+				   inet->cork.length, fl->proto, tmp_csum);
+
+	if (tmp_csum == 0)
+		tmp_csum = -1;
+
+	csum = tmp_csum;
+	if (skb_store_bits(skb, offset, &csum, 2))
+		BUG();
 
-	if (*csum == 0)
-		*csum = -1;
 send:
 	err = ip6_push_pending_frames(sk);
 out:
@@ -774,7 +801,7 @@
 		if (err)
 			ip6_flush_pending_frames(sk);
 		else if (!(msg->msg_flags & MSG_MORE))
-			err = rawv6_push_pending_frames(sk, &fl, rp, len);
+			err = rawv6_push_pending_frames(sk, &fl, rp);
 	}
 done:
 	ip6_dst_store(sk, dst,
