From: "David S. Miller" <davem@davemloft.net>
Subject: skb->truesize assertion checking for TCP
Date: Wed, 19 Apr 2006 21:55:13 -0700 (PDT)
Message-ID: <20060419.215513.13034269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61351
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750877AbWDTEzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 00:55:36 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Herbert what do you think of this?

I know it might be better to check this right where we
make the manipulations, but this catch-all trap at the
end points seems to make sense and will catch other kinds
of errors.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c4619a4..60a7c5a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -344,6 +344,13 @@ extern void	      skb_over_panic(struct 
 				     void *here);
 extern void	      skb_under_panic(struct sk_buff *skb, int len,
 				      void *here);
+extern void	      skb_truesize_bug(struct sk_buff *skb);
+
+static inline void skb_truesize_check(struct sk_buff *skb)
+{
+	if (unlikely((int)skb->truesize < sizeof(struct sk_buff)))
+		skb_truesize_bug(skb);
+}
 
 extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			int getfrag(void *from, char *to, int offset,
diff --git a/include/net/sock.h b/include/net/sock.h
index af2b054..ff8b0da 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -454,6 +454,7 @@ static inline void sk_stream_set_owner_r
 
 static inline void sk_stream_free_skb(struct sock *sk, struct sk_buff *skb)
 {
+	skb_truesize_check(skb);
 	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
 	sk->sk_wmem_queued   -= skb->truesize;
 	sk->sk_forward_alloc += skb->truesize;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 09464fa..f2b4238 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -112,6 +112,12 @@ void skb_under_panic(struct sk_buff *skb
 	BUG();
 }
 
+void skb_truesize_bug(struct sk_buff *skb)
+{
+	printk("SKB BUG: Invalid truesize (%u) sizeof(sk_buff)=%Zd\n",
+	       skb->truesize, sizeof(struct sk_buff));
+}
+
 /* 	Allocate a new skbuff. We do this ourselves so we can fill in a few
  *	'private' fields and also do memory statistics to find all the
  *	[BEEP] leaks.
diff --git a/net/core/stream.c b/net/core/stream.c
index 35e2525..e948969 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -176,6 +176,7 @@ void sk_stream_rfree(struct sk_buff *skb
 {
 	struct sock *sk = skb->sk;
 
+	skb_truesize_check(skb);
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 	sk->sk_forward_alloc += skb->truesize;
 }
