From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Sun, 03 Apr 2005 18:48:17 +0200
Message-ID: <42501E51.3000401@trash.net>
References: <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net> <20050402004956.GA24339@gondor.apana.org.au> <20050401172007.7296eced.davem@davemloft.net> <20050402020947.GA24998@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070809070105060803010504"
Cc: "David S. Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402020947.GA24998@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070809070105060803010504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> It's still a valid clean-up patch though.

Agreed. There is also a bug in my patch, tmpl->daddr can be 0 in which
case the daddr passed as an argument to xfrm_state_find() will be used.
My patch only checked tmpl->daddr, this patch fixes it. It also uses
afinfo->init_tempsel directly, but I didn't kill xfrm_init_tempsel() yet
because I need it for xfrm resolution.

> There is another reason why it won't dead lock.  We don't actually
> ever hold the write lock on afinfo :) Is there any reason why we
> dont't just use xfrm_state_afinfo_lock instead of afinfo->lock?

I don't think so. I also don't see a reason why the lock needs to be
held between xfrm_state_get_afinfo() and xfrm_state_put_afinfo(),
a reference count should be enough.

Regards
Patrick

--------------070809070105060803010504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/03 18:41:22+02:00 kaber@coreworks.de 
#   [IPSEC]: Use correct daddr for duplicate state check
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_state.c
#   2005/04/03 18:41:14+02:00 kaber@coreworks.de +9 -9
#   [IPSEC]: Use correct daddr for duplicate state check
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c	2005-04-03 18:41:41 +02:00
+++ b/net/xfrm/xfrm_state.c	2005-04-03 18:41:41 +02:00
@@ -357,12 +357,6 @@
 
 	x = best;
 	if (!x && !error && !acquire_in_progress) {
-		x0 = afinfo->state_lookup(&tmpl->id.daddr, tmpl->id.spi, tmpl->id.proto);
-		if (x0 != NULL) {
-			xfrm_state_put(x0);
-			error = -EEXIST;
-			goto out;
-		}
 		x = xfrm_state_alloc();
 		if (x == NULL) {
 			error = -ENOMEM;
@@ -370,9 +364,11 @@
 		}
 		/* Initialize temporary selector matching only
 		 * to current session. */
-		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
+		afinfo->init_tempsel(x, fl, tmpl, daddr, saddr);
+
+		x0 = afinfo->state_lookup(&x->id.daddr, x->id.spi, x->id.proto);
 
-		if (km_query(x, tmpl, pol) == 0) {
+		if (!x0 && km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;
 			list_add_tail(&x->bydst, xfrm_state_bydst+h);
 			xfrm_state_hold(x);
@@ -386,10 +382,14 @@
 			x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
 			add_timer(&x->timer);
 		} else {
+			error = -ESRCH;
+			if (x0) {
+				xfrm_state_put(x0);
+				error = -EEXIST;
+			}
 			x->km.state = XFRM_STATE_DEAD;
 			xfrm_state_put(x);
 			x = NULL;
-			error = -ESRCH;
 		}
 	}
 out:

--------------070809070105060803010504--
