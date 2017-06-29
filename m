From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/2] skbuff: Function to send an skbuf on a socket
Date: Thu, 29 Jun 2017 11:27:04 -0700
Message-ID: <1498760825-8516-2-git-send-email-tom@herbertland.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33077 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdF2S1x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:27:53 -0400
Received: by mail-pg0-f68.google.com with SMTP id u62so12824746pgb.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 11:27:53 -0700 (PDT)
In-Reply-To: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_send_sock to send an skbuff on a socket within the kernel.
Arguments include and offset so that an skbuf might be sent in mulitple
calls (e.g.  send buffer limit is hit).
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a17e235..83849e3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3115,6 +3115,8 @@ __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
 int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
 		    unsigned int flags);
+int skb_send_sock(struct sk_buff *skb, struct socket *sock,
+				  unsigned int offset);
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
 int skb_zerocopy(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f75897a..ff9f88d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2005,6 +2005,72 @@ int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 }
 EXPORT_SYMBOL_GPL(skb_splice_bits);
 
+/* Send skb data on a socket. */
+int skb_send_sock(struct sk_buff *skb, struct socket *sock, unsigned int offset)
+{
+	unsigned int sent = 0;
+	unsigned int ret;
+	unsigned short fragidx;
+
+	/* Deal with head data */
+	while (offset < skb_headlen(skb)) {
+		size_t len = skb_headlen(skb) - offset;
+		struct kvec kv;
+		struct msghdr msg;
+
+		kv.iov_base = skb->data + offset;
+		kv.iov_len = len;
+		memset(&msg, 0, sizeof(msg));
+
+		ret = kernel_sendmsg(sock, &msg, &kv, 1, len);
+		if (ret < 0)
+			goto error;
+
+		offset += ret;
+		sent += ret;
+	}
+
+	offset -= skb_headlen(skb);
+
+	/* Are there frags? */
+	if (!skb_shinfo(skb)->nr_frags)
+		goto out;
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
+	for (; fragidx < skb_shinfo(skb)->nr_frags; fragidx++) {
+		skb_frag_t *frag  = &skb_shinfo(skb)->frags[fragidx];
+
+		ret = kernel_sendpage(sock, frag->page.p,
+				      frag->page_offset + offset,
+				      frag->size - offset,
+				      MSG_DONTWAIT);
+		if (ret < 0)
+			goto error;
+
+		sent += ret;
+		offset = 0;
+	}
+
+out:
+	return sent;
+
+error:
+	if (sent)
+		return sent;
+	else
+		return ret;
+}
+EXPORT_SYMBOL_GPL(skb_send_sock);
+
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
  *	@skb: destination buffer
-- 
2.7.4
