From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] [PATCH] TCP read/write ignore (was TCP receive splice performance)
Date: Wed, 14 May 2008 12:01:23 +0300
Message-ID: <200805141201.23926.opurdila@ixiacom.com>
References: <200805121545.50390.opurdila@ixiacom.com> <412e6f7f0805120601h1121deaewd69ecebc744f258d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Changli Gao" <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4244 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753907AbYENJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 05:02:23 -0400
In-Reply-To: <412e6f7f0805120601h1121deaewd69ecebc744f258d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 May 2008, Changli Gao wrote:
> On Mon, May 12, 2008 at 8:45 PM, Octavian Purdila <opurdila@ixiacom.com> wrote:
> > In the second test case the same test was performed, only this time with
> > some modification in the network stack to disable the copying from/to
> > userspace. Throughput was 122-123MB which is practically line-rate.
>
> It is interesting. Could you show us your modification?

Hi,

Here are the patches, they are based on Linux 2.6.7, but seems to work fine
on 2.6.25 as well.

The patch allows one to ignore part of the receive or send data, by skipping 
the copy to/from the user buffer. It adds two new members to the tcp socket
structure which will count how much of the data should be ignore. These 
members are set with two new setsockopts by the user.

Being in the networking testing bussines, most of the time we do not care 
about the payload, and with this approach we can easily parse the protocol
headers and then skip the payload. But I think it can be usefull as well as a 
way of exploring performance limits, as user-kernel copying still has a 
significant performance impact.

Regards,
tavi


--- ./net/core/datagram.c.orig	2004-06-28 16:21:18.124222369 -0700
+++ ./net/core/datagram.c	2004-06-28 16:27:56.355360196 -0700
@@ -296,6 +296,30 @@
 	return -EFAULT;
 }
 
+/*
+ * Copy a datagram to an iovec, ignoring the first *readignore bytes.
+ * also, subtract the number of bytes we copy from *readignore.
+ */ 
+int skb_copy_datagram_iovec_readignore(const struct sk_buff *skb, int offset, struct iovec *to,
+							int len, int *readignore)
+{
+	int ret;
+	int ri = *readignore;
+
+	if(ri < len) {
+		/* no read ignore, or a read ignore less than what's in this copy */
+		ret = skb_copy_datagram_iovec(skb, offset + ri, to, len - ri);
+		if(ri != 0)
+			*readignore = 0;
+	} else {
+		/* read ignore bigger than this copy. subtract off the size of this copy and skip it */
+		*readignore = ri - len;
+		ret = 0;
+	}
+
+	return ret;
+}
+
 int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 			       u8 __user *to, int len, unsigned int *csump)
 {
@@ -435,6 +459,67 @@
 	return -EFAULT;
 }
 
+/* Copy and checkum skb to user iovec. Caller _must_ check that
+   skb will fit to this iovec.
+
+   Returns: 0       - success.
+            -EINVAL - checksum failure.
+	    -EFAULT - fault during copy. Beware, in this case iovec can be
+	              modified!
+ */
+int skb_copy_and_csum_datagram_iovec_readignore(const struct sk_buff *skb, int hlen, struct iovec *iov, int *readignore)
+{
+	unsigned int csum;
+	int chunk = skb->len - hlen;
+
+	int ri = *readignore;
+
+	/* Skip filled elements. */
+	while (iov->iov_len == 0)
+		iov++;
+
+	if(ri >= chunk) {
+		/* we want to ignore all or more than this chunk. still have to csum however. */
+		if ((unsigned short)csum_fold(skb_checksum(skb, 0, chunk+hlen, skb->csum)))
+			goto csum_error;
+		/* fake like we copied all of it */
+		/* FIXME THIS IS BROKEN SINCE WE HAVENT CHECKED iov->iov_len! */
+		/* we don't touch iov if we skip in skb_copy_datagram_iovec_readignore. seems
+		   like it doesnt matter, read still returns the right thing. probably messes
+		   up offets however if we start to care about bytes in the middle of a user read
+		   buffer... hmm... */
+		//iov->iov_len -= chunk;
+		//iov->iov_base += chunk;
+		/* and update readignore */
+		*readignore = ri - chunk;
+		return 0;
+	} else if((iov->iov_len < chunk) || (ri != 0)) {
+		/* we may want to ignore some of this chunk. checksum all of it and let readignore sort the copy out... */
+		/* also hit if we don't have enough room to copy_and_csum */
+		if ((unsigned short)csum_fold(skb_checksum(skb, 0, chunk+hlen, skb->csum)))
+			goto csum_error;
+		/* this will update readignore so we dont have to do it here */
+		if (skb_copy_datagram_iovec_readignore(skb, hlen, iov, chunk, readignore))
+			goto fault;
+	} else {
+		/* ri must be zero (off) so go back to the pre-readignore optimized behavior of copy_and_csum */
+		csum = csum_partial(skb->data, hlen, skb->csum);
+		if (skb_copy_and_csum_datagram(skb, hlen, iov->iov_base, chunk, &csum))
+			goto fault;
+		if ((unsigned short)csum_fold(csum))
+			goto csum_error;
+		iov->iov_len -= chunk;
+		iov->iov_base += chunk;
+	}
+	return 0;
+
+csum_error:
+	return -EINVAL;
+
+fault:
+	return -EFAULT;
+}
+
 /**
  * 	datagram_poll - generic datagram poll
  *	@file - file struct
--- ./net/ipv4/tcp_input.c.orig	2004-06-28 16:32:43.103777008 -0700
+++ ./net/ipv4/tcp_input.c	2004-06-28 16:35:30.288362880 -0700
@@ -3444,7 +3444,8 @@
 			__set_current_state(TASK_RUNNING);
 
 			local_bh_enable();
-			if (!skb_copy_datagram_iovec(skb, 0, tp->ucopy.iov, chunk)) {
+			if (!skb_copy_datagram_iovec_readignore(skb, 0,
+					tp->ucopy.iov, chunk, &tp->readignore)) {
 				tp->ucopy.len -= chunk;
 				tp->copied_seq += chunk;
 				eaten = (chunk == skb->len && !th->fin);
@@ -4041,10 +4042,11 @@
 
 	local_bh_enable();
 	if (skb->ip_summed==CHECKSUM_UNNECESSARY)
-		err = skb_copy_datagram_iovec(skb, hlen, tp->ucopy.iov, chunk);
+		err = skb_copy_datagram_iovec_readignore(skb, hlen, tp->ucopy.iov,
+							 chunk, &tp->readignore);
 	else
-		err = skb_copy_and_csum_datagram_iovec(skb, hlen,
-						       tp->ucopy.iov);
+		err = skb_copy_and_csum_datagram_iovec_readignore(skb, hlen,
+			tp->ucopy.iov, &tp->readignore);
 
 	if (!err) {
 		tp->ucopy.len -= chunk;
--- ./net/ipv4/tcp.c.orig	2004-06-28 16:28:34.229188678 -0700
+++ ./net/ipv4/tcp.c	2004-06-28 16:32:27.633480945 -0700
@@ -1693,8 +1693,8 @@
 		}
 
 		if (!(flags & MSG_TRUNC)) {
-			err = skb_copy_datagram_iovec(skb, offset,
-						      msg->msg_iov, used);
+			err = skb_copy_datagram_iovec_readignore(skb, offset,
+					msg->msg_iov, used, &tp->readignore);
 			if (err) {
 				/* Exception. Bailout! */
 				if (!copied)
@@ -2396,6 +2396,14 @@
 		}
 		break;
 
+	/* racy wrt recv... its locked against that already tho */
+	case TCP_READIGNORE:
+		if(val < 0)
+			tp->readignore = 0;
+		else
+			tp->readignore = val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2476,6 +2484,9 @@
 	case TCP_QUICKACK:
 		val = !tp->ack.pingpong;
 		break;
+	case TCP_READIGNORE:
+		val = tp->readignore;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	};
--- ./include/linux/tcp.h.orig	2004-06-28 16:16:01.795063654 -0700
+++ ./include/linux/tcp.h	2004-06-28 16:21:01.707030600 -0700
@@ -127,6 +127,7 @@
 #define TCP_WINDOW_CLAMP	10	/* Bound advertised window */
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
+#define TCP_READIGNORE		20	/* ignore read sockopt */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -379,6 +380,8 @@
 
 	unsigned long last_synq_overflow; 
 
+	int readignore; /* number of bytes to "fake" copy to user space on recv */
+
 /* Receiver side RTT estimation */
 	struct {
 		__u32	rtt;
--- ./include/linux/skbuff.h.orig	2004-06-28 16:09:06.351821612 -0700
+++ ./include/linux/skbuff.h	2004-06-28 16:13:08.022203432 -0700
@@ -1019,6 +1019,9 @@
 extern int	       skb_copy_datagram_iovec(const struct sk_buff *from,
 					       int offset, struct iovec *to,
 					       int size);
+extern int	       skb_copy_datagram_iovec_readignore(const struct sk_buff *from,
+					       int offset, struct iovec *to,
+					       int size, int *readignore);
 extern int	       skb_copy_and_csum_datagram(const struct sk_buff *skb,
 						  int offset, u8 __user *to,
 						  int len, unsigned int *csump);
@@ -1026,6 +1029,11 @@
 							struct sk_buff *skb,
 							int hlen,
 							struct iovec *iov);
+extern int	       skb_copy_and_csum_datagram_iovec_readignore(const
+							struct sk_buff *skb,
+							int hlen,
+							struct iovec *iov,
+							int *readignore);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 extern unsigned int    skb_checksum(const struct sk_buff *skb, int offset,
 				    int len, unsigned int csum);
--- ./net/ipv4/tcp.c.orig	2004-06-28 16:50:27.284565474 -0700
+++ ./net/ipv4/tcp.c	2004-06-28 17:05:47.832174058 -0700
@@ -968,19 +968,25 @@
 
 static inline int tcp_copy_to_page(struct sock *sk, char __user *from,
 				   struct sk_buff *skb, struct page *page,
-				   int off, int copy)
+				   int off, int copy, int *writeignore)
 {
 	int err = 0;
 	unsigned int csum;
 
-	if (skb->ip_summed == CHECKSUM_NONE) {
-		csum = csum_and_copy_from_user(from, page_address(page) + off,
-				       copy, 0, &err);
-		if (err) return err;
-		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+	if (*writeignore < copy) {
+		*writeignore = 0;
+
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			csum = csum_and_copy_from_user(from, page_address(page) + off,
+					       copy, 0, &err);
+			if (err) return err;
+			skb->csum = csum_block_add(skb->csum, csum, skb->len);
+		} else {
+			if (copy_from_user(page_address(page) + off, from, copy))
+				return -EFAULT;
+		}
 	} else {
-		if (copy_from_user(page_address(page) + off, from, copy))
-			return -EFAULT;
+		*writeignore = *writeignore - copy;
 	}
 
 	skb->len += copy;
@@ -991,26 +997,41 @@
 	return 0;
 }
 
-static inline int skb_add_data(struct sk_buff *skb, char __user *from, int copy)
+static inline int skb_add_data(struct sk_buff *skb, char __user *from, int copy,
+			       int *writeignore)
 {
 	int err = 0;
 	unsigned int csum;
 	int off = skb->len;
 
-	if (skb->ip_summed == CHECKSUM_NONE) {
-		csum = csum_and_copy_from_user(from, skb_put(skb, copy),
-				       copy, 0, &err);
-		if (!err) {
-			skb->csum = csum_block_add(skb->csum, csum, off);
-			return 0;
+	if (*writeignore < copy) {
+		*writeignore = 0;
+
+		/* need to keep writeignore ahead of the granularity of
+		   this function. in other words, we may not ignore the
+		   full request, but we do ignore a statistically significant
+		   part of it.
+		*/
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			csum = csum_and_copy_from_user(from, skb_put(skb, copy),
+					       copy, 0, &err);
+			if (!err) {
+				skb->csum = csum_block_add(skb->csum, csum, off);
+				return 0;
+			}
+		} else {
+			if (!copy_from_user(skb_put(skb, copy), from, copy))
+				return 0;
 		}
+
+		__skb_trim(skb, off);
+		return -EFAULT;
 	} else {
-		if (!copy_from_user(skb_put(skb, copy), from, copy))
-			return 0;
+		/* still need to increase the length of skb */
+		skb_put(skb, copy);
+		*writeignore = *writeignore - copy;
+		return 0;
 	}
-
-	__skb_trim(skb, off);
-	return -EFAULT;
 }
 
 static inline int select_size(struct sock *sk, struct tcp_opt *tp)
@@ -1110,7 +1131,8 @@
 				/* We have some space in skb head. Superb! */
 				if (copy > skb_tailroom(skb))
 					copy = skb_tailroom(skb);
-				if ((err = skb_add_data(skb, from, copy)) != 0)
+				if ((err = skb_add_data(skb, from, copy,
+							&tp->writeignore)) != 0)
 					goto do_fault;
 			} else {
 				int merge = 0;
@@ -1157,7 +1179,7 @@
 				/* Time to copy data. We are close to
 				 * the end! */
 				err = tcp_copy_to_page(sk, from, skb, page,
-						       off, copy);
+						       off, copy, &tp->writeignore);
 				if (err) {
 					/* If this page was new, give it to the
 					 * socket so it does not get leaked.
@@ -2404,6 +2426,13 @@
 			tp->readignore = val;
 		break;
 
+	case TCP_WRITEIGNORE:
+		if(val < 0)
+			tp->writeignore = 0;
+		else
+			tp->writeignore = val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2487,6 +2516,9 @@
 	case TCP_READIGNORE:
 		val = tp->readignore;
 		break;
+	case TCP_WRITEIGNORE:
+		val = tp->writeignore;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	};
--- include/linux/tcp.h.orig	2004-06-28 17:16:10.783560634 -0700
+++ include/linux/tcp.h	2004-06-28 17:16:47.333534929 -0700
@@ -128,6 +128,7 @@
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_READIGNORE		20	/* ignore read sockopt */
+#define TCP_WRITEIGNORE		22
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -381,6 +382,7 @@
 	unsigned long last_synq_overflow; 
 
 	int readignore; /* number of bytes to "fake" copy to user space on recv */
+	int writeignore; /* number of bytes to "fake" transmit */
 
 /* Receiver side RTT estimation */
 	struct {
