From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Wed, 2 Feb 2005 16:20:23 -0800
Message-ID: <20050202162023.075015d4.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 22:33:26 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> We're using atomic integers to signal that we're done with an object.
> The object is usually represented by a piece of memory.
> 
> The problem is that in most of the places where we do this (and that's
> not just in the networking systems), there are no memory barriers between
> the last reference to that object and the decrease on the atomic counter.

I agree.

> 	if (atomic_read(&skb->users) != 1) {
> 		smp_mb__before_atomic_dec();
> 		if (!atomic_dec_and_test(&skb->users))
> 			return;
> 	}
> 	__kfree_skb(skb);

This looks good.  Olaf can you possibly ask the reproducer if
this patch makes the ARP problem go away?

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/02 15:53:55-08:00 herbert@gondor.apana.org.au 
#   [NET]: Add missing memory barrier to SKB release.
#   
#   Here, we are using atomic counters to signal that we are done
#   with an object.  The object is usually represented by a piece
#   of memory.
#   
#   The problem is that in most of the places we do this, there are
#   no memory barriers between the last reference to that object
#   and the decrease on the atomic counter.
#   
#   Based upon a race spotted in arp_queue handling by Olaf Kirch.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/linux/skbuff.h
#   2005/02/02 15:51:57-08:00 herbert@gondor.apana.org.au +6 -2
#   [NET]: Add missing memory barrier to SKB release.
# 
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2005-02-02 15:54:13 -08:00
+++ b/include/linux/skbuff.h	2005-02-02 15:54:13 -08:00
@@ -353,8 +353,12 @@
  */
 static inline void kfree_skb(struct sk_buff *skb)
 {
-	if (atomic_read(&skb->users) == 1 || atomic_dec_and_test(&skb->users))
-		__kfree_skb(skb);
+	if (atomic_read(&skb->users) != 1) {
+		smp_mb__before_atomic_dec();
+		if (!atomic_dec_and_test(&skb->users))
+			return;
+	}
+	__kfree_skb(skb);
 }
 
 /* Use this if you didn't touch the skb state [for fast switching] */
