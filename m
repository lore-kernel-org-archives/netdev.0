From: Patrick McHardy <kaber@trash.net>
Subject: Re: Checking SPI in xfrm_state_find
Date: Thu, 31 Mar 2005 02:13:54 +0200
Message-ID: <424B40C2.90304@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010407060603020003010206"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050328233917.GB15369@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010407060603020003010206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Mon, Mar 28, 2005 at 10:10:54PM +0200, Patrick McHardy wrote:
> 
>>Something unrelated I was also wondering about, from xfrm_find_state():
>>
>>        list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
>>                if (x->props.family == family &&
>>                    x->props.reqid == tmpl->reqid &&
>>                    xfrm_state_addr_check(x, daddr, saddr, family) &&
>>                    tmpl->mode == x->props.mode &&
>>                    tmpl->id.proto == x->id.proto) {
>>
>>Shouldn't we check for (tmpl->id.spi == x->id.spi || !tmpl->id.spi) ?
> 
> 
> Absolutely.  We should also fix the larval state generation in that
> same function to fail the operation if that SPI already exists.

Thanks, both done by these two patches.

Regards
Patrick

--------------010407060603020003010206
Content-Type: text/plain;
 name="x1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x1"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/30 06:02:45+02:00 kaber@coreworks.de 
#   [IPSEC]: Check SPI in xfrm_state_find()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_state.c
#   2005/03/30 06:02:36+02:00 kaber@coreworks.de +2 -1
#   [IPSEC]: Check SPI in xfrm_state_find()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-03-31 02:12:12 +02:00
+++ b/net/xfrm/xfrm_state.c	2005-03-31 02:12:12 +02:00
@@ -306,7 +306,8 @@
 		    x->props.reqid == tmpl->reqid &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
-		    tmpl->id.proto == x->id.proto) {
+		    tmpl->id.proto == x->id.proto &&
+		    (tmpl->id.spi == x->id.spi || !tmpl->id.spi)) {
 			/* Resolution logic:
 			   1. There is a valid state with matching selector.
 			      Done.

--------------010407060603020003010206
Content-Type: text/plain;
 name="x2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x2"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/31 02:07:54+02:00 kaber@coreworks.de 
#   [IPSEC]: Check if SPI exists before creating acquire state
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_state.c
#   2005/03/31 02:07:42+02:00 kaber@coreworks.de +25 -7
#   [IPSEC]: Check if SPI exists before creating acquire state
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-03-31 02:12:57 +02:00
+++ b/net/xfrm/xfrm_state.c	2005-03-31 02:12:57 +02:00
@@ -295,10 +295,17 @@
 		unsigned short family)
 {
 	unsigned h = xfrm_dst_hash(daddr, family);
-	struct xfrm_state *x;
+	struct xfrm_state *x, *x0;
 	int acquire_in_progress = 0;
 	int error = 0;
 	struct xfrm_state *best = NULL;
+	struct xfrm_state_afinfo *afinfo;
+	
+	afinfo = xfrm_state_get_afinfo(family);
+	if (afinfo == NULL) {
+		*err = -EAFNOSUPPORT;
+		return NULL;
+	}
 
 	spin_lock_bh(&xfrm_state_lock);
 	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
@@ -334,14 +341,24 @@
 			} else if (x->km.state == XFRM_STATE_ERROR ||
 				   x->km.state == XFRM_STATE_EXPIRED) {
 				if (xfrm_selector_match(&x->sel, fl, family))
-					error = 1;
+					error = -ESRCH;
 			}
 		}
 	}
 
 	x = best;
-	if (!x && !error && !acquire_in_progress &&
-	    ((x = xfrm_state_alloc()) != NULL)) {
+	if (!x && !error && !acquire_in_progress) {
+		x0 = afinfo->state_lookup(&tmpl->id.daddr, tmpl->id.spi, tmpl->id.proto);
+		if (x0 != NULL) {
+			xfrm_state_put(x0);
+			error = -EEXIST;
+			goto out;
+		}
+		x = xfrm_state_alloc();
+		if (x == NULL) {
+			error = -ENOMEM;
+			goto out;
+		}
 		/* Initialize temporary selector matching only
 		 * to current session. */
 		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
@@ -363,15 +380,16 @@
 			x->km.state = XFRM_STATE_DEAD;
 			xfrm_state_put(x);
 			x = NULL;
-			error = 1;
+			error = -ESRCH;
 		}
 	}
+out:
 	if (x)
 		xfrm_state_hold(x);
 	else
-		*err = acquire_in_progress ? -EAGAIN :
-			(error ? -ESRCH : -ENOMEM);
+		*err = acquire_in_progress ? -EAGAIN : error;
 	spin_unlock_bh(&xfrm_state_lock);
+	xfrm_state_put_afinfo(afinfo);
 	return x;
 }
 

--------------010407060603020003010206--
