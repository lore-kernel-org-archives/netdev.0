From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Move xfrm_flush_bundles into xfrm_state GC
Date: Tue, 29 Mar 2005 09:30:32 +1000
Message-ID: <20050328233032.GA15369@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <424864CE.5060802@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Patrick:

On Mon, Mar 28, 2005 at 10:10:54PM +0200, Patrick McHardy wrote:
> 
> I haven't though of a way to avoid this yet. It would be nice though
> if we could keep the rule that xfrm_policy_lock and policy->lock nest
> with x->lock.

Thanks for catching this.

The locking in xfrm_state/xfrm_policy has always struck me as being
an overkill.  A lot of the locks should be replaced by rules that
ensure the validity of most operations while a ref count is held.
Now I have an excuse to do just that :)

For 2.6.12 let's go for a simpler fix that breaks the dead lock.

__xfrm_state_delete does not need to flush the bundles immediately.
In fact, it is more efficient if we delay the flush to the GC worker
since the flush is not dependent on any particular xfrm state.  By
delaying it we can do one single flush even when you're deleteing
the entire xfrm state list.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.56 vs edited =====
--- 1.56/net/xfrm/xfrm_state.c	2005-03-11 13:39:54 +11:00
+++ edited/net/xfrm/xfrm_state.c	2005-03-29 09:16:13 +10:00
@@ -48,6 +48,8 @@
 static struct list_head xfrm_state_gc_list = LIST_HEAD_INIT(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
+static int xfrm_state_gc_flush_bundles;
+
 static void __xfrm_state_delete(struct xfrm_state *x);
 
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
@@ -81,6 +83,11 @@
 	struct list_head *entry, *tmp;
 	struct list_head gc_list = LIST_HEAD_INIT(gc_list);
 
+	if (xfrm_state_gc_flush_bundles) {
+		xfrm_state_gc_flush_bundles = 0;
+		xfrm_flush_bundles();
+	}
+
 	spin_lock_bh(&xfrm_state_gc_lock);
 	list_splice_init(&xfrm_state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
@@ -228,8 +235,10 @@
 		 * our caller holds.  A larger value means that
 		 * there are DSTs attached to this xfrm_state.
 		 */
-		if (atomic_read(&x->refcnt) > 2)
-			xfrm_flush_bundles();
+		if (atomic_read(&x->refcnt) > 2) {
+			xfrm_state_gc_flush_bundles = 1;
+			schedule_work(&xfrm_state_gc_work);
+		}
 
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that

--zYM0uCDKw75PZbzx--
