From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec Oops when deleting an ip address
Date: Tue, 25 May 2004 21:52:20 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040525115220.GA15236@gondor.apana.org.au>
References: <20040510134958.13691.qmail@mason.oriente.labs.it> <20040521131950.GA20040@gondor.apana.org.au> <20040521144346.7887dbf0.davem@redhat.com> <20040524114751.GA28571@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040524114751.GA28571@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 24, 2004 at 09:47:51PM +1000, herbert wrote:
> 
> Hence the problem is still a bug in the ref counting.  I think I've found
> the real culprit now.  __xfrm?_find_acq() is missing an xfrm_state_hold
> on the create path.  This also explains why I never see it myself since
> Openswan never creates states through that code-path.

The same bug exists in xfrm_state_find.  This is actually used by
Openswan.  However, the larval state never actually matures with
Openswan so it only ever gets deleted by the timer which means that
the timer crash can't happen :) It becomes a (possible) memory leak
instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.39 vs edited =====
--- 1.39/net/xfrm/xfrm_state.c	2004-05-22 17:32:10 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-05-25 21:42:43 +10:00
@@ -331,14 +331,8 @@
 		}
 	}
 
-	if (best) {
-		xfrm_state_hold(best);
-		spin_unlock_bh(&xfrm_state_lock);
-		return best;
-	}
-
-	x = NULL;
-	if (!error && !acquire_in_progress &&
+	x = best;
+	if (!x && !error && !acquire_in_progress &&
 	    ((x = xfrm_state_alloc()) != NULL)) {
 		/* Initialize temporary selector matching only
 		 * to current session. */
@@ -363,10 +357,12 @@
 			error = 1;
 		}
 	}
-	spin_unlock_bh(&xfrm_state_lock);
-	if (!x)
+	if (x)
+		xfrm_state_hold(x);
+	else
 		*err = acquire_in_progress ? -EAGAIN :
 			(error ? -ESRCH : -ENOMEM);
+	spin_unlock_bh(&xfrm_state_lock);
 	return x;
 }
 

--a8Wt8u1KmwUX3Y2C--
