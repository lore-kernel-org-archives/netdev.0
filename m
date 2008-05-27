From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 18:03:18 +0400
Message-ID: <20080527140318.GA6963@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527115206.GA30353@2ka.mipt.ru> <20080527115638.GB30353@2ka.mipt.ru> <200805271553.50001.opurdila@ixiacom.com> <20080527132148.GA7368@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54831 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756834AbYE0ODg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 10:03:36 -0400
Content-Disposition: inline
In-Reply-To: <20080527132148.GA7368@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 05:21:48PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, May 27, 2008 at 03:53:49PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> > When you interrupt the program, the system will crash.
> 
> Cool!
> 
> I've reproduced the problem and will try to work it out, thank you.

Attached patch fixes the crash for me, Octavian could you please test
it.

David, is __kfree_skb() usage in tcp_read_sock() an optimisation only?
With this patch I do not see any leaks, but I did not investigate it
deep enough. If approach seems correct, I will clean things up.

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
index 39b629a..b8318e9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1182,6 +1182,23 @@ static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 	return NULL;
 }
 
+#ifdef CONFIG_NET_DMA
+static inline void __sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
+{
+	__skb_unlink(skb, &sk->sk_receive_queue);
+	if (!copied_early)
+		kfree_skb(skb);
+	else
+		__skb_queue_tail(&sk->sk_async_wait_queue, skb);
+}
+#else
+static inline void __sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
+{
+	__skb_unlink(skb, &sk->sk_receive_queue);
+	kfree_skb(skb);
+}
+#endif
+
 /*
  * This routine provides an alternative to tcp_recvmsg() for routines
  * that would like to handle copying from skbuffs directly in 'sendfile'
@@ -1231,11 +1248,11 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				break;
 		}
 		if (tcp_hdr(skb)->fin) {
-			sk_eat_skb(sk, skb, 0);
+			__sk_eat_skb(sk, skb, 0);
 			++seq;
 			break;
 		}
-		sk_eat_skb(sk, skb, 0);
+		__sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
 			break;
 	}

-- 
	Evgeniy Polyakov
