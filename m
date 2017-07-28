From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 2/3] skbuff: Function to send an skbuf on a socket
Date: Fri, 28 Jul 2017 16:22:42 -0700
Message-ID: <20170728232243.3040-3-tom@quantonium.net>
References: <20170728232243.3040-1-tom@quantonium.net>
Cc: rohit@quantonium.net, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35940 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753049AbdG1XXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 19:23:24 -0400
Received: by mail-pf0-f171.google.com with SMTP id z129so61340944pfb.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 16:23:24 -0700 (PDT)
In-Reply-To: <20170728232243.3040-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_send_sock to send an skbuff on a socket within the kernel.
Arguments include an offset so that an skbuf might be sent in mulitple
calls (e.g. send buffer limit is hit).

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/skbuff.h |   3 ++
 net/core/skbuff.c      | 101 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4093552be1de..18e76bf9574e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3113,6 +3113,9 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
 int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
 		    unsigned int flags);
+int skb_send_sock_locked(struct sock *sk, struct sk_buff *skb, int offset,
+			 int len);
+int skb_send_sock(struct sock *sk, struct sk_buff *skb, int offset, int len);
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
 int skb_zerocopy(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c27da51d14e4..9c0e015ff3fe 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1982,6 +1982,107 @@ int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 }
 EXPORT_SYMBOL_GPL(skb_splice_bits);
 
+/* Send skb data on a socket. Socket must be locked. */
+int skb_send_sock_locked(struct sock *sk, struct sk_buff *skb, int offset,
+			 int len)
+{
+	unsigned int orig_len = len;
+	struct sk_buff *head = skb;
+	unsigned short fragidx;
+	int slen, ret;
+
+do_frag_list:
+
+	/* Deal with head data */
+	while (offset < skb_headlen(skb) && len) {
+		struct kvec kv;
+		struct msghdr msg;
+
+		slen = min_t(int, len, skb_headlen(skb) - offset);
+		kv.iov_base = skb->data + offset;
+		kv.iov_len = len;
+		memset(&msg, 0, sizeof(msg));
+
+		ret = kernel_sendmsg_locked(sk, &msg, &kv, 1, slen);
+		if (ret <= 0)
+			goto error;
+
+		offset += ret;
+		len -= ret;
+	}
+
+	/* All the data was skb head? */
+	if (!len)
+		goto out;
+
+	/* Make offset relative to start of frags */
+	offset -= skb_headlen(skb);
+
+	/* Find where we are in frag list */
+	for (fragidx = 0; fragidx < skb_shinfo(skb)->nr_frags; fragidx++) {
+		skb_frag_t *frag  = &skb_shinfo(skb)->frags[fragidx];
+
+		if (offset < frag->size)
+			break;
+
+		offset -= frag->size;
+	}
+
+	for (; len && fragidx < skb_shinfo(skb)->nr_frags; fragidx++) {
+		skb_frag_t *frag  = &skb_shinfo(skb)->frags[fragidx];
+
+		slen = min_t(size_t, len, frag->size - offset);
+
+		while (slen) {
+			ret = kernel_sendpage_locked(sk, frag->page.p,
+						     frag->page_offset + offset,
+						     slen, MSG_DONTWAIT);
+			if (ret <= 0)
+				goto error;
+
+			len -= ret;
+			offset += ret;
+			slen -= ret;
+		}
+
+		offset = 0;
+	}
+
+	if (len) {
+		/* Process any frag lists */
+
+		if (skb == head) {
+			if (skb_has_frag_list(skb)) {
+				skb = skb_shinfo(skb)->frag_list;
+				goto do_frag_list;
+			}
+		} else if (skb->next) {
+			skb = skb->next;
+			goto do_frag_list;
+		}
+	}
+
+out:
+	return orig_len - len;
+
+error:
+	return orig_len == len ? ret : orig_len - len;
+}
+EXPORT_SYMBOL_GPL(skb_send_sock_locked);
+
+/* Send skb data on a socket. */
+int skb_send_sock(struct sock *sk, struct sk_buff *skb, int offset, int len)
+{
+	int ret = 0;
+
+	lock_sock(sk);
+	ret = skb_send_sock_locked(sk, skb, offset, len);
+	release_sock(sk);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(skb_send_sock);
+
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
  *	@skb: destination buffer
-- 
2.11.0
