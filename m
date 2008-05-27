From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 21:28:49 +0400
Message-ID: <20080527172849.GA14746@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527151259.GA11862@2ka.mipt.ru> <20080527152234.GA16419@2ka.mipt.ru> <200805271833.55880.opurdila@ixiacom.com> <20080527154710.GA6305@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35368 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbYE0R3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 13:29:20 -0400
Content-Disposition: inline
In-Reply-To: <20080527154710.GA6305@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 07:47:10PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Well, providing some flags to ->sendpage() callbacks to say that they
> should not grab locks is a bit ugly to me, I think we can fix splice
> code not to do wrong things.

And actually this will lead to data corruption, since different process
can enter and change socket values under us. Without temporal lock drop
we can deadlock (first process locked socket and then waiting for
i_mutex, while another one grabbed i_mutex and waiting for socket lock
in sendfile()).

> > I don't think we can drop the socket lock, it will introduce at least on type 
> > of races: since the skb we are processing is still on the socket queue, any 
> > entity accessing the socket queue will possible collide with us. 
> 
> Each access is being done under socket lock, so it should be safe. But
> socket release path drops skb from the list before dropping its
> reference counter, so we are not allowed to unlink it again, but we can
> check if skb is linked or not and make a decision based on that.

Please try attached patch on top of vanilla tree.
It does not use skb after socket was dropped, but instead search it
again when socket is locked, so if socket is alive, it will find it and
clean otherwise it will exit.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6087013..d285817 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1349,6 +1349,7 @@ done:
 
 	if (spd.nr_pages) {
 		int ret;
+		struct sock *sk = __skb->sk;
 
 		/*
 		 * Drop the socket lock, otherwise we have reverse
@@ -1359,9 +1360,9 @@ done:
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
index 39b629a..217dc59 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1200,15 +1200,17 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 seq = tp->copied_seq;
 	u32 offset;
-	int copied = 0;
+	int copied = 0, fin;
+	size_t used, len, skb_len;
 
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
 	while ((skb = tcp_recv_skb(sk, seq, &offset)) != NULL) {
+		used = 0;
 		if (offset < skb->len) {
-			size_t used, len;
 
-			len = skb->len - offset;
+			skb_len = skb->len;
+			len = skb_len - offset;
 			/* Stop reading if we hit a patch of urgent data */
 			if (tp->urg_data) {
 				u32 urg_offset = tp->urg_seq - seq;
@@ -1217,6 +1219,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				if (!len)
 					break;
 			}
+
 			used = recv_actor(desc, skb, offset, len);
 			if (used < 0) {
 				if (!copied)
@@ -1227,15 +1230,22 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				copied += used;
 				offset += used;
 			}
-			if (offset != skb->len)
+			if (offset != skb_len)
 				break;
 		}
-		if (tcp_hdr(skb)->fin) {
-			sk_eat_skb(sk, skb, 0);
-			++seq;
+		skb = tcp_recv_skb(sk, seq-used, &offset);
+		if (!skb) {
+			if (!copied)
+				copied = -EINVAL;
 			break;
 		}
+		fin = tcp_hdr(skb)->fin;
 		sk_eat_skb(sk, skb, 0);
+
+		if (fin) {
+			++seq;
+			break;
+		}
 		if (!desc->count)
 			break;
 	}

-- 
	Evgeniy Polyakov
