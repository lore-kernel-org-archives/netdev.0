From: pravin b shelar <pravins@calsoftinc.com>
Subject: Re: Fwd: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Wed, 06 Apr 2005 14:23:52 +0530
Message-ID: <4253A3A0.800@calsoftinc.com>
References: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>	 <E1DIvr8-0002yy-00@gondolin.me.apana.org.au> <b82a8917050406002339f732ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030904020801050603070305"
Return-path: <netdev-bounce@oss.sgi.com>
To: "Christoph Lameter"@calsoftinc.com, netdev@oss.sgi.com,
        davem@davemloft.net
In-Reply-To: <b82a8917050406002339f732ca@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030904020801050603070305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


>  
>
>This is racy (albeit very unlikely) because dst may be freed by
>dst_run_gc after the atomic_dec.
>
>When we are not the real parent of the dst (e.g., when we're xfrm_dst
>and the child is an rtentry), it may already be on the GC list.
>
>In fact the current code is buggy to, we need to check dst->flags
>before the dec as dst may no longer be valid afterwards.
>
>
>  
>
This patch  will remove the need for atomic_dec_and_test for this 
particular case.
Now we can break down the atomic_dec_and_test to atomic_dec & atomic_read.

Please comment.

Regards
Pravin.



--------------030904020801050603070305
Content-Type: text/plain;
 name="dst-atomic"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst-atomic"

Index: linux-2.6.11-dsta/net/core/dst.c
===================================================================
--- linux-2.6.11-dsta.orig/net/core/dst.c	2005-04-06 00:18:32.000000000 -0700
+++ linux-2.6.11-dsta/net/core/dst.c	2005-04-06 01:31:10.000000000 -0700
@@ -198,17 +198,19 @@
 
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
+			if (atomic_read(&dst->__refcnt))
+				/* Child is still referenced, return it for freeing. */
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
 

--------------030904020801050603070305--
