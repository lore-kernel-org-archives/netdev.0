From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Fri, 4 Feb 2005 12:55:39 +1100
Message-ID: <20050204015539.GA9727@gondor.apana.org.au>
References: <20050131102920.GC4170@suse.de> <E1CvZo6-0001Bz-00@gondolin.me.apana.org.au> <20050203142705.GA11318@krispykreme.ozlabs.ibm.com> <20050203203010.GA7081@gondor.apana.org.au> <20050203141901.5ce04c92.davem@davemloft.net> <20050203235044.GA8422@gondor.apana.org.au> <20050203164922.2627a112.davem@davemloft.net> <20050204012053.GA8949@gondor.apana.org.au> <20050203172357.670c3402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050203172357.670c3402.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Feb 03, 2005 at 05:23:57PM -0800, David S. Miller wrote:
> 
> You're absolutely right.  Ok, so we do need to change kfree_skb().
> I believe even with the memory barrier, the atomic_read() optimization
> is still worth it.  atomic ops on sparc64 take a minimum of 40 some odd
> cycles on UltraSPARC-III and later, whereas the memory barrier will
> take up a single cycle most of the time.

OK, here is the patch to do that.  Let's get rid of kfree_skb_fast
while we're at it since it's no longer used.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/skbuff.h 1.59 vs edited =====
--- 1.59/include/linux/skbuff.h	2005-01-11 07:23:55 +11:00
+++ edited/include/linux/skbuff.h	2005-02-04 12:46:15 +11:00
@@ -353,15 +353,11 @@
  */
 static inline void kfree_skb(struct sk_buff *skb)
 {
-	if (atomic_read(&skb->users) == 1 || atomic_dec_and_test(&skb->users))
-		__kfree_skb(skb);
-}
-
-/* Use this if you didn't touch the skb state [for fast switching] */
-static inline void kfree_skb_fast(struct sk_buff *skb)
-{
-	if (atomic_read(&skb->users) == 1 || atomic_dec_and_test(&skb->users))
-		kfree_skbmem(skb);
+	if (likely(atomic_read(&skb->users) == 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return;
+	__kfree_skb(skb);
 }
 
 /**

--YiEDa0DAkWCtVeE4--
