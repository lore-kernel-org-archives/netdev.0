From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Fri, 10 Feb 2017 21:45:13 +0000
Message-ID: <20170210214513.GA8937@ZenIV.linux.org.uk>
References: <20160728012253.GT2356@ZenIV.linux.org.uk>
 <201608030349.u733nRPn000595@sdf.org>
 <20160803054118.GG2356@ZenIV.linux.org.uk>
 <2363167.YiBS7sFNO2@debian64>
 <20160809145836.GQ2356@ZenIV.linux.org.uk>
 <20170210081126.GA14157@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Alan Curry <rlwinm@sdf.org>,
        alexmcwhirter@triadic.us, David Miller <davem@davemloft.net>,
        Christian Lamparter <chunkeey@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34102 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdBJVpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 16:45:21 -0500
Content-Disposition: inline
In-Reply-To: <20170210081126.GA14157@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[repost with netdev added - hadn't realized it wasn't in Cc]

On Tue, Aug 09, 2016 at 03:58:36PM +0100, Al Viro wrote:

> Actually returning to the original behaviour would be "restore ->msg_iter
> if we tried skb_copy_and_csum_datagram() and failed for any reason".  Which
> would be bloody inconsistent wrt EFAULT, since the other branch (chunk
> large enough to cover the entire recvmsg()) will copy as much as it can
> and (in old kernel) drain iovec or (on the current one) leave iov_iter
> advance unreverted.

To resurrect the old thread: the problem is still there.  Namely, csum
mismatch on packet should leave the iterator as it had been.  That much
is clear; the question is what should be done on EFAULT halfway through.

Semantics of both csum and non-csum skb_copy_datagram_msg() variants in
EFAULT case is an interesting question.  None of that family report
partial copy; it's full or -EFAULT.  So for the sake of basic sanity
it would be better to leave iterator in the original state when that
kind of thing happens.  On the other hand, quite a few callers don't
care about the state of iterator after that and I wonder if the overhead
would be sensitive.  OTTH, the overhead in question is "save 5 words into
local variable and don't use it in the normal case" - in the code that
copies an skb worth of data.

AFAICS, the following gives consistent (and minimally surprising) semantics,
as well as fixing the outright bug with iov_iter left advanced in case of csum
errors.  Comments?

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index c27011bbe30c..14ae17e77603 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -848,7 +848,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 		total += VLAN_HLEN;
 
-		ret = skb_copy_datagram_iter(skb, 0, iter, vlan_offset);
+		ret = __skb_copy_datagram_iter(skb, 0, iter, vlan_offset);
 		if (ret || !iov_iter_count(iter))
 			goto done;
 
@@ -857,7 +857,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 			goto done;
 	}
 
-	ret = skb_copy_datagram_iter(skb, vlan_offset, iter,
+	ret = __skb_copy_datagram_iter(skb, vlan_offset, iter,
 				     skb->len - vlan_offset);
 
 done:
@@ -899,11 +899,14 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 		finish_wait(sk_sleep(&q->sk), &wait);
 
 	if (skb) {
+		struct iov_iter saved = *to;
 		ret = macvtap_put_user(q, skb, to);
-		if (unlikely(ret < 0))
+		if (unlikely(ret < 0)) {
+			*to = saved;
 			kfree_skb(skb);
-		else
+		} else {
 			consume_skb(skb);
+		}
 	}
 	return ret;
 }
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index a411b43a69eb..0d8badc3c4e9 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -480,7 +480,7 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
 	iov.iov_base = buf;
 	iov.iov_len = count;
 	iov_iter_init(&to, READ, &iov, 1, count);
-	if (skb_copy_datagram_iter(skb, 0, &to, skb->len))
+	if (__skb_copy_datagram_iter(skb, 0, &to, skb->len))
 		goto outf;
 	ret = skb->len;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 30863e378925..2003b8c9970e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1430,7 +1430,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
 
-		ret = skb_copy_datagram_iter(skb, 0, iter, vlan_offset);
+		ret = __skb_copy_datagram_iter(skb, 0, iter, vlan_offset);
 		if (ret || !iov_iter_count(iter))
 			goto done;
 
@@ -1439,7 +1439,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 			goto done;
 	}
 
-	skb_copy_datagram_iter(skb, vlan_offset, iter, skb->len - vlan_offset);
+	/* XXX: no error check? */
+	__skb_copy_datagram_iter(skb, vlan_offset, iter, skb->len - vlan_offset);
 
 done:
 	/* caller is in process context, */
@@ -1501,6 +1502,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 {
 	struct sk_buff *skb;
 	ssize_t ret;
+	struct iov_iter saved;
 	int err;
 
 	tun_debug(KERN_INFO, tun, "tun_do_read\n");
@@ -1513,11 +1515,14 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	if (!skb)
 		return err;
 
+	saved = *to;
 	ret = tun_put_user(tun, tfile, skb, to);
-	if (unlikely(ret < 0))
+	if (unlikely(ret < 0)) {
+		*to = saved;
 		kfree_skb(skb);
-	else
+	} else {
 		consume_skb(skb);
+	}
 
 	return ret;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f1adddc1c5ac..ee8d962373af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3060,8 +3060,17 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
 				  int *err);
 unsigned int datagram_poll(struct file *file, struct socket *sock,
 			   struct poll_table_struct *wait);
-int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
+int __skb_copy_datagram_iter(const struct sk_buff *from, int offset,
 			   struct iov_iter *to, int size);
+static inline int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
+					struct iov_iter *to, int size)
+{
+	struct iov_iter saved = *to;
+	int res = __skb_copy_datagram_iter(from, offset, to, size);
+	if (unlikely(res))
+		*to = saved;
+	return res;
+}
 static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
 					struct msghdr *msg, int size)
 {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index ea633342ab0d..33ff2046dda1 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -394,7 +394,7 @@ EXPORT_SYMBOL(skb_kill_datagram);
  *	@to: iovec iterator to copy to
  *	@len: amount of data to copy from buffer to iovec
  */
-int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
+int __skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 			   struct iov_iter *to, int len)
 {
 	int start = skb_headlen(skb);
@@ -445,7 +445,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 		if ((copy = end - offset) > 0) {
 			if (copy > len)
 				copy = len;
-			if (skb_copy_datagram_iter(frag_iter, offset - start,
+			if (__skb_copy_datagram_iter(frag_iter, offset - start,
 						   to, copy))
 				goto fault;
 			if ((len -= copy) == 0)
@@ -471,7 +471,7 @@ int skb_copy_datagram_iter(const struct sk_buff *skb, int offset,
 
 	return 0;
 }
-EXPORT_SYMBOL(skb_copy_datagram_iter);
+EXPORT_SYMBOL(__skb_copy_datagram_iter);
 
 /**
  *	skb_copy_datagram_from_iter - Copy a datagram from an iov_iter.
@@ -750,14 +750,16 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 {
 	__wsum csum;
 	int chunk = skb->len - hlen;
+	struct iov_iter saved;
 
 	if (!chunk)
 		return 0;
 
+	saved = msg->msg_iter;
 	if (msg_data_left(msg) < chunk) {
 		if (__skb_checksum_complete(skb))
 			goto csum_error;
-		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
+		if (__skb_copy_datagram_iter(skb, hlen, &msg->msg_iter, chunk))
 			goto fault;
 	} else {
 		csum = csum_partial(skb->data, hlen, skb->csum);
@@ -771,8 +773,10 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 	}
 	return 0;
 csum_error:
+	msg->msg_iter = saved;
 	return -EINVAL;
 fault:
+	msg->msg_iter = saved;
 	return -EFAULT;
 }
 EXPORT_SYMBOL(skb_copy_and_csum_datagram_msg);
