From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec Oops when deleting an ip address
Date: Mon, 24 May 2004 21:47:51 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040524114751.GA28571@gondor.apana.org.au>
References: <20040510134958.13691.qmail@mason.oriente.labs.it> <20040521131950.GA20040@gondor.apana.org.au> <20040521144346.7887dbf0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040521144346.7887dbf0.davem@redhat.com>
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 21, 2004 at 02:43:46PM -0700, David S. Miller wrote:
> On Fri, 21 May 2004 23:19:50 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > doing a mod_timer on a live state without holding a lock or for that
> > matter not even checking whether the state is dead is definitely a bad
> > idea
> 
> Applied, thanks Herbert.

Looks like I was too hasty in blaming myself :) Although my patch does
fix a real bug, it cannot have been responsible for the crash that the OP
reported.  The reason is that the state timer always keeps a reference to
the state so even if it is incorrectly re-added the reference will prevent
the crash.

Hence the problem is still a bug in the ref counting.  I think I've found
the real culprit now.  __xfrm?_find_acq() is missing an xfrm_state_hold
on the create path.  This also explains why I never see it myself since
Openswan never creates states through that code-path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== xfrm4_state.c 1.6 vs edited =====
--- 1.6/net/ipv4/xfrm4_state.c	2003-07-21 21:49:43 +10:00
+++ edited/xfrm4_state.c	2004-05-24 21:41:29 +10:00
@@ -83,9 +83,7 @@
 			    break;
 		    }
 	}
-	if (x0) {
-		xfrm_state_hold(x0);
-	} else if (create && (x0 = xfrm_state_alloc()) != NULL) {
+	if (!x0 && create && (x0 = xfrm_state_alloc()) != NULL) {
 		x0->sel.daddr.a4 = daddr->a4;
 		x0->sel.saddr.a4 = saddr->a4;
 		x0->sel.prefixlen_d = 32;
@@ -105,6 +103,8 @@
 		list_add_tail(&x0->bydst, xfrm4_state_afinfo.state_bydst+h);
 		wake_up(&km_waitq);
 	}
+	if (x0)
+		xfrm_state_hold(x0);
 	return x0;
 }
 
===== xfrm6_state.c 1.8 vs edited =====
--- 1.8/net/ipv6/xfrm6_state.c	2003-07-21 21:49:43 +10:00
+++ edited/xfrm6_state.c	2004-05-24 21:44:06 +10:00
@@ -90,9 +90,7 @@
 			    break;
 		    }
 	}
-	if (x0) {
-		xfrm_state_hold(x0);
-	} else if (create && (x0 = xfrm_state_alloc()) != NULL) {
+	if (!x0 && create && (x0 = xfrm_state_alloc()) != NULL) {
 		ipv6_addr_copy((struct in6_addr *)x0->sel.daddr.a6,
 			       (struct in6_addr *)daddr);
 		ipv6_addr_copy((struct in6_addr *)x0->sel.saddr.a6,
@@ -115,6 +113,8 @@
 		list_add_tail(&x0->bydst, xfrm6_state_afinfo.state_bydst+h);
 		wake_up(&km_waitq);
 	}
+	if (x0)
+		xfrm_state_hold(x0);
 	return x0;
 }
 

--HlL+5n6rz5pIUxbD--
