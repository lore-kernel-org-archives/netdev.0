From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Lock policy in policy timer
Date: Sat, 22 May 2004 22:16:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040522121617.GA11649@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

In light of the xfrm_state timer bug, I reviewed the policy timer as
well.  In doing so I found that the policy timer didn't take a lock
on the policy.

Although this won't lead to a panic, it does mean that a policy might
potentially take a long time to be freed.

So here is a patch to take a read_lock on the policy in the timer
so that it does not die on us.  Since the timer doesn't occur very
often, this shouldn't have much of an impact.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== xfrm_policy.c 1.49 vs edited =====
--- 1.49/net/xfrm/xfrm_policy.c	2004-03-20 14:35:32 +11:00
+++ edited/xfrm_policy.c	2004-05-22 22:11:51 +10:00
@@ -148,6 +148,8 @@
 	int warn = 0;
 	int dir;
 
+	read_lock(&xp->lock);
+
 	if (xp->dead)
 		goto out;
 
@@ -197,6 +199,7 @@
 		xfrm_pol_hold(xp);
 
 out:
+	read_unlock(&xp->lock);
 	xfrm_pol_put(xp);
 	return;
 

--T4sUOijqQbZv57TR--
