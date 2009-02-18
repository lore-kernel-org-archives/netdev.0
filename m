From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Wed, 18 Feb 2009 01:13:18 -0800 (PST)
Message-ID: <20090218.011318.76843157.davem@davemloft.net>
References: <4995CD0F.8020307@hp.com>
	<20090213200014.GB2929@ami.dom.local>
	<20090213.182426.175113018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, ole@ans.pl, pupilla@hotmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751494AbZBRJNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:13:34 -0500
In-Reply-To: <20090213.182426.175113018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 13 Feb 2009 18:24:26 -0800 (PST)

> Anyways, Herbert and I have talked about %100 removing the
> warning.

I've committed the following to net-2.6 and will queue
this up for -stable as well.

net: Kill skb_truesize_check(), it only catches false-positives.

A long time ago we had bugs, primarily in TCP, where we would modify
skb->truesize (for TSO queue collapsing) in ways which would corrupt
the socket memory accounting.

skb_truesize_check() was added in order to try and catch this error
more systematically.

However this debugging check has morphed into a Frankenstein of sorts
and these days it does nothing other than catch false-positives.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    9 ---------
 include/net/sock.h     |    1 -
 net/core/skbuff.c      |    8 --------
 net/core/sock.c        |    1 -
 4 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf2cb50..9dcf956 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -416,15 +416,6 @@ extern void	      skb_over_panic(struct sk_buff *skb, int len,
 				     void *here);
 extern void	      skb_under_panic(struct sk_buff *skb, int len,
 				      void *here);
-extern void	      skb_truesize_bug(struct sk_buff *skb);
-
-static inline void skb_truesize_check(struct sk_buff *skb)
-{
-	int len = sizeof(struct sk_buff) + skb->len;
-
-	if (unlikely((int)skb->truesize < len))
-		skb_truesize_bug(skb);
-}
 
 extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
 			int getfrag(void *from, char *to, int offset,
diff --git a/include/net/sock.h b/include/net/sock.h
index ce3b5b6..eefeeaf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -860,7 +860,6 @@ static inline void sk_mem_uncharge(struct sock *sk, int size)
 
 static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
 {
-	skb_truesize_check(skb);
 	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
 	sk->sk_wmem_queued -= skb->truesize;
 	sk_mem_uncharge(sk, skb->truesize);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da74b84..c6a6b16 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -143,14 +143,6 @@ void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 	BUG();
 }
 
-void skb_truesize_bug(struct sk_buff *skb)
-{
-	WARN(net_ratelimit(), KERN_ERR "SKB BUG: Invalid truesize (%u) "
-	       "len=%u, sizeof(sk_buff)=%Zd\n",
-	       skb->truesize, skb->len, sizeof(struct sk_buff));
-}
-EXPORT_SYMBOL(skb_truesize_bug);
-
 /* 	Allocate a new skbuff. We do this ourselves so we can fill in a few
  *	'private' fields and also do memory statistics to find all the
  *	[BEEP] leaks.
diff --git a/net/core/sock.c b/net/core/sock.c
index 6f2e133..6e4f14d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1137,7 +1137,6 @@ void sock_rfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
-	skb_truesize_check(skb);
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_uncharge(skb->sk, skb->truesize);
 }
-- 
1.6.1.2.253.ga34a

