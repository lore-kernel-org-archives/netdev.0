From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 19:09:31 +0400
Message-ID: <20080527150931.GA23415@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527132148.GA7368@2ka.mipt.ru> <20080527140318.GA6963@2ka.mipt.ru> <200805271739.11612.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47513 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110AbYE0PJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 11:09:43 -0400
Content-Disposition: inline
In-Reply-To: <200805271739.11612.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 05:39:11PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> On my system it still crashes, if I interrupt the program before splice 
> blocks:

Yes, that was somewhat stupid patch.
Since I can not reproduce it anymore, let's try to upload this task to you :)
Please test this one assuming there are no other patches applied before.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6087013..e2a99a6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1295,7 +1295,7 @@ err:
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
-int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
+int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
 		    unsigned int flags)
 {
@@ -1308,16 +1308,6 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 		.ops = &sock_pipe_buf_ops,
 		.spd_release = sock_spd_release,
 	};
-	struct sk_buff *skb;
-
-	/*
-	 * I'd love to avoid the clone here, but tcp_read_sock()
-	 * ignores reference counts and unconditonally kills the sk_buff
-	 * on return from the actor.
-	 */
-	skb = skb_clone(__skb, GFP_KERNEL);
-	if (unlikely(!skb))
-		return -ENOMEM;
 
 	/*
 	 * __skb_splice_bits() only fails if the output has no room left,
@@ -1341,14 +1331,9 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 	}
 
 done:
-	/*
-	 * drop our reference to the clone, the pipe consumption will
-	 * drop the rest.
-	 */
-	kfree_skb(skb);
-
 	if (spd.nr_pages) {
 		int ret;
+		struct sock *sk = __skb->sk;
 
 		/*
 		 * Drop the socket lock, otherwise we have reverse
@@ -1359,9 +1344,9 @@ done:
 		 * we call into ->sendpage() with the i_mutex lock held
 		 * and networking will grab the socket lock.
 		 */
-		release_sock(__skb->sk);
+		release_sock(sk);
 		ret = splice_to_pipe(pipe, &spd);
-		lock_sock(__skb->sk);
+		lock_sock(sk);
 		return ret;
 	}
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39b629a..54bb460 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1196,7 +1196,7 @@ static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		  sk_read_actor_t recv_actor)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *__skb;
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 seq = tp->copied_seq;
 	u32 offset;
@@ -1204,10 +1204,14 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
-	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
+	while ((__skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
 		if (offset < skb->len) {
 			size_t used, len;
 
+			skb = skb_clone(__skb, GFP_KERNEL);
+			if (unlikely(!skb))
+				break;
+
 			len = skb->len - offset;
 			/* Stop reading if we hit a patch of urgent data */
 			if (tp->urg_data) {
@@ -1215,29 +1219,35 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				if (urg_offset < len)
 					len = urg_offset;
 				if (!len)
-					break;
+					goto out_break;
 			}
 			used = recv_actor(desc, skb, offset, len);
 			if (used < 0) {
 				if (!copied)
 					copied = used;
-				break;
+				goto out_break;
 			} else if (used <= len) {
 				seq += used;
 				copied += used;
 				offset += used;
 			}
 			if (offset != skb->len)
-				break;
+				goto out_break;
 		}
 		if (tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, 0);
 			++seq;
-			break;
+			goto out_break;
 		}
 		sk_eat_skb(sk, skb, 0);
+out:
+		kfree_skb(skb);
 		if (!desc->count)
-			break;
+			goto out_break;
+		continue;
+out_break:
+		kfree_skb(skb);
+		break;
 	}
 	tp->copied_seq = seq;
 


-- 
	Evgeniy Polyakov
