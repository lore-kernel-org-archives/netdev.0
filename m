From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/4] net: make skb_splice_bits more configureable
Date: Wed, 20 May 2015 17:35:07 +0200
Message-ID: <a464064d180a10d904409aa21388288d1faf7a4d.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37836 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbbETPmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:42:25 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id BF8AF20A7A
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:17 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 56BD76801D6
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:17 -0400 (EDT)
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare skb_splice_bits to be able to deal with AF_UNIX sockets.

AF_UNIX sockets don't use lock_sock/release_sock and thus we have to
use a callback to make the locking and unlocking configureable.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/skbuff.h | 11 +++++++++--
 net/core/skbuff.c      | 45 ++++++++++++++++++++++++++++-----------------
 net/ipv4/tcp.c         |  5 +++--
 3 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b9d267b..895435c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -35,6 +35,7 @@
 #include <linux/netdev_features.h>
 #include <linux/sched.h>
 #include <net/flow_dissector.h>
+#include <linux/splice.h>
 
 /* A. Checksumming of received packets by device.
  *
@@ -2698,9 +2699,15 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
 			      int len, __wsum csum);
-int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
+ssize_t skb_socket_splice(struct sock *sk,
+			  struct pipe_inode_info *pipe,
+			  struct splice_pipe_desc *spd);
+int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
-		    unsigned int flags);
+		    unsigned int flags,
+		    ssize_t (*splice_cb)(struct sock *,
+					 struct pipe_inode_info *,
+					 struct splice_pipe_desc *));
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
 int skb_zerocopy(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1d3f88a..1fc76a9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1870,15 +1870,39 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 	return false;
 }
 
+ssize_t skb_socket_splice(struct sock *sk,
+			  struct pipe_inode_info *pipe,
+			  struct splice_pipe_desc *spd)
+{
+	int ret;
+
+	/* Drop the socket lock, otherwise we have reverse
+	 * locking dependencies between sk_lock and i_mutex
+	 * here as compared to sendfile(). We enter here
+	 * with the socket lock held, and splice_to_pipe() will
+	 * grab the pipe inode lock. For sendfile() emulation,
+	 * we call into ->sendpage() with the i_mutex lock held
+	 * and networking will grab the socket lock.
+	 */
+	release_sock(sk);
+	ret = splice_to_pipe(pipe, spd);
+	lock_sock(sk);
+
+	return ret;
+}
+
 /*
  * Map data from the skb to a pipe. Should handle both the linear part,
  * the fragments, and the frag list. It does NOT handle frag lists within
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
-int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
+int skb_splice_bits(struct sk_buff *skb, struct sock *sk, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
-		    unsigned int flags)
+		    unsigned int flags,
+		    ssize_t (*splice_cb)(struct sock *,
+					 struct pipe_inode_info *,
+					 struct splice_pipe_desc *))
 {
 	struct partial_page partial[MAX_SKB_FRAGS];
 	struct page *pages[MAX_SKB_FRAGS];
@@ -1891,7 +1915,6 @@ int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		.spd_release = sock_spd_release,
 	};
 	struct sk_buff *frag_iter;
-	struct sock *sk = skb->sk;
 	int ret = 0;
 
 	/*
@@ -1914,20 +1937,8 @@ int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 	}
 
 done:
-	if (spd.nr_pages) {
-		/*
-		 * Drop the socket lock, otherwise we have reverse
-		 * locking dependencies between sk_lock and i_mutex
-		 * here as compared to sendfile(). We enter here
-		 * with the socket lock held, and splice_to_pipe() will
-		 * grab the pipe inode lock. For sendfile() emulation,
-		 * we call into ->sendpage() with the i_mutex lock held
-		 * and networking will grab the socket lock.
-		 */
-		release_sock(sk);
-		ret = splice_to_pipe(pipe, &spd);
-		lock_sock(sk);
-	}
+	if (spd.nr_pages)
+		ret = splice_cb(sk, pipe, &spd);
 
 	return ret;
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb9bb84..67f0a80 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -694,8 +694,9 @@ static int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 	struct tcp_splice_state *tss = rd_desc->arg.data;
 	int ret;
 
-	ret = skb_splice_bits(skb, offset, tss->pipe, min(rd_desc->count, len),
-			      tss->flags);
+	ret = skb_splice_bits(skb, skb->sk, offset, tss->pipe,
+			      min(rd_desc->count, len), tss->flags,
+			      skb_socket_splice);
 	if (ret > 0)
 		rd_desc->count -= ret;
 	return ret;
-- 
2.1.0
