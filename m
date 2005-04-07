From: pravin b shelar <pravins@calsoftinc.com>
Subject: Re: Fwd: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 07 Apr 2005 18:00:16 +0530
Message-ID: <425527D8.4030408@calsoftinc.com>
References: <E1DJV6r-0002Nu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040604060301020209000207"
Cc: christoph@lameter.com, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJV6r-0002Nu-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040604060301020209000207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

>pravin b shelar <pravins@calsoftinc.com> wrote:
>  
>
>>This patch  will remove the need for atomic_dec_and_test for this 
>>particular case.
>>Now we can break down the atomic_dec_and_test to atomic_dec & atomic_read.
>>    
>>
>
>Sorry I overlooked your patch.  Otherwise we could have solved this
>one day earlier :)
>  
>
ah ... I was just waiting :)

>  
>
>>Please comment.
>>    
>>
>
>There is just one problem.  We need an extra barrier before or after
>the goto since we no longer have the implicit barrier given by
>atomic_dec_and_test.
>  
>
I am attaching updated patch with barrier.

Regards,
Pravin.



--------------040604060301020209000207
Content-Type: text/x-patch;
 name="dst-atomic_dec_and_test-removed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst-atomic_dec_and_test-removed.patch"

This patch removes atomic_dec_and_test from dst_destroy, used to test child dst __refcnt.

Signed-off by: Pravin B. Shelar <pravins@calsoftinc.com>

Index: linux-2.6.11-dsta/net/core/dst.c
===================================================================
--- linux-2.6.11-dsta.orig/net/core/dst.c	2005-04-06 00:18:32.000000000 -0700
+++ linux-2.6.11-dsta/net/core/dst.c	2005-04-07 04:53:28.000000000 -0700
@@ -198,17 +198,21 @@
 
 	dst = child;
 	if (dst) {
-		if (atomic_dec_and_test(&dst->__refcnt)) {
-			/* We were real parent of this dst, so kill child. */
-			if (dst->flags&DST_NOHASH)
-				goto again;
-		} else {
-			/* Child is still referenced, return it for freeing. */
-			if (dst->flags&DST_NOHASH)
-				return dst;
-			/* Child is still in his hash table */
+		if (dst->flags&DST_NOHASH) {
+			atomic_dec(&dst->__refcnt);
+			smp_mb__after_atomic_dec();
+
+			if (atomic_read(&dst->__refcnt))
+				/*-- Child is still referenced, return it for freeing. */
+				return dst;	
+
+			/*We were real parent of this dst, so kill child. */
+			goto again;
 		}
+		else /* Child is still in his hash table */
+			atomic_dec(&dst->__refcnt);
 	}
+
 	return NULL;
 }
 

--------------040604060301020209000207--
