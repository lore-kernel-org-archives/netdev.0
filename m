From: Christoph Lameter <christoph@lameter.com>
Subject: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 11:55:45 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504051155260.13697@server.graphe.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It seems that the atomic_dec_and_test for the child dst in net/core/dst.c
is really not needed since dst_destroy cannot be called simultanously for
the same dst (frees dst unconditionally via kmem_cache_free). If a dst can
only have one child then the dst may only be deleted from its parent dst.

The refcnt is also incremented via dst_hold and decremented via
dst_release elsewhere (seems that they may race with dst_destroy?) but
there is no provisions to do something special if __refcnt would reach
zero in dst_release. __refcnt is always expected to be always
greater than zero there.

However, it is checked without dec_and_test for zero in various other
locations (dst_free, dst_run_gc, dn_dst_check_expire).

Is the atomic_dec_and_test in dst_destroy just there to join two atomic
operations into one without being necessary for the correctness of freeing
dsts?

Then we really would not need atomic_dec_and_test in dst_destroy() and the
following patch would be safe (There are some ideas for optimizations that
would not be able to preserve the atomic_dec_and_test).

Index: linux-2.6.11/net/core/dst.c
===================================================================
--- linux-2.6.11.orig/net/core/dst.c	2005-03-01 23:38:12.000000000 -0800
+++ linux-2.6.11/net/core/dst.c	2005-04-05 11:04:41.000000000 -0700
@@ -198,7 +198,8 @@ again:

 	dst = child;
 	if (dst) {
-		if (atomic_dec_and_test(&dst->__refcnt)) {
+		atomic_dec(&dst->__refcnt);
+		if (!atomic_read(&dst->__refcnt)) {
 			/* We were real parent of this dst, so kill child. */
 			if (dst->flags&DST_NOHASH)
 				goto again;
