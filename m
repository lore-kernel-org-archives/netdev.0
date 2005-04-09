From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/4] [IPSEC] Kill spurious hard expire messages
Date: Sat, 9 Apr 2005 21:12:44 +1000
Message-ID: <20050409111244.GB7171@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XF85m9dhOBO43t/C"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050409105452.GA7171@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XF85m9dhOBO43t/C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch ensures that the hard state/policy expire notifications are
only sent when the state/policy is successfully removed from their
respective tables.

As it is, it's possible for a state/policy to both expire through
reaching a hard limit, as well as being deleted by the user.

Note that this behaviour isn't actually forbidden by RFC 2367.
However, it is a quality of implementation issue.

As an added bonus, the restructuring in this patch will help
eventually in moving the expire notifications from softirq
context into process context, thus improving their reliability.

One important side-effect from this change is that SAs reaching
their hard byte/packet limits are now deleted immediately, just
like SAs that have reached their hard time limits.

Previously they were announced immediately but only deleted after
30 seconds.

This is bad because it prevents the system from issuing an ACQUIRE
command until the existing state was deleted by the user or expires
after the time is up.

In the scenario where the expire notification was lost this introduces
a 30 second delay into the system for no good reason.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

 include/net/xfrm.h     |    2 +-
 net/xfrm/xfrm_policy.c |    8 +++++---
 net/xfrm/xfrm_state.c  |   16 +++++++---------
 3 files changed, 13 insertions(+), 13 deletions(-)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--XF85m9dhOBO43t/C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-2

===== include/net/xfrm.h 1.80 vs edited =====
--- 1.80/include/net/xfrm.h	2005-04-08 23:08:26 +10:00
+++ edited/include/net/xfrm.h	2005-04-09 17:55:24 +10:00
@@ -669,7 +669,7 @@
 	return 0;
 }
 
-extern void xfrm_policy_delete(struct xfrm_policy *pol, int dir);
+extern int xfrm_policy_delete(struct xfrm_policy *pol, int dir);
 
 static inline void xfrm_sk_free_policy(struct sock *sk)
 {
===== net/xfrm/xfrm_policy.c 1.75 vs edited =====
--- 1.75/net/xfrm/xfrm_policy.c	2005-04-01 16:24:20 +10:00
+++ edited/net/xfrm/xfrm_policy.c	2005-04-09 18:02:53 +10:00
@@ -216,8 +216,8 @@
 
 expired:
 	read_unlock(&xp->lock);
-	km_policy_expired(xp, dir, 1);
-	xfrm_policy_delete(xp, dir);
+	if (!xfrm_policy_delete(xp, dir))
+		km_policy_expired(xp, dir, 1);
 	xfrm_pol_put(xp);
 }
 
@@ -555,7 +555,7 @@
 	return NULL;
 }
 
-void xfrm_policy_delete(struct xfrm_policy *pol, int dir)
+int xfrm_policy_delete(struct xfrm_policy *pol, int dir)
 {
 	write_lock_bh(&xfrm_policy_lock);
 	pol = __xfrm_policy_unlink(pol, dir);
@@ -564,7 +564,9 @@
 		if (dir < XFRM_POLICY_MAX)
 			atomic_inc(&flow_cache_genid);
 		xfrm_policy_kill(pol);
+		return 0;
 	}
+	return -ENOENT;
 }
 
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
===== net/xfrm/xfrm_state.c 1.61 vs edited =====
--- 1.61/net/xfrm/xfrm_state.c	2005-04-08 23:08:26 +10:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-09 19:55:48 +10:00
@@ -154,6 +154,7 @@
 			next = tmo;
 	}
 
+	x->km.dying = warn;
 	if (warn)
 		km_state_expired(x, 0);
 resched:
@@ -169,9 +170,8 @@
 		next = 2;
 		goto resched;
 	}
-	if (x->id.spi != 0)
+	if (!__xfrm_state_delete(x) && x->id.spi)
 		km_state_expired(x, 1);
-	__xfrm_state_delete(x);
 
 out:
 	spin_unlock(&x->lock);
@@ -566,16 +566,18 @@
 
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
-		km_state_expired(x, 1);
-		if (!mod_timer(&x->timer, jiffies + XFRM_ACQ_EXPIRES*HZ))
+		x->km.state = XFRM_STATE_EXPIRED;
+		if (!mod_timer(&x->timer, jiffies))
 			xfrm_state_hold(x);
 		return -EINVAL;
 	}
 
 	if (!x->km.dying &&
 	    (x->curlft.bytes >= x->lft.soft_byte_limit ||
-	     x->curlft.packets >= x->lft.soft_packet_limit))
+	     x->curlft.packets >= x->lft.soft_packet_limit)) {
+		x->km.dying = 1;
 		km_state_expired(x, 0);
+	}
 	return 0;
 }
 EXPORT_SYMBOL(xfrm_state_check_expire);
@@ -833,10 +835,6 @@
 {
 	struct km_event c;
 
-	if (hard)
-		x->km.state = XFRM_STATE_EXPIRED;
-	else
-		x->km.dying = 1;
 	c.data = hard;
 	c.event = XFRM_SAP_EXPIRED;
 	km_state_notify(x, &c);

--XF85m9dhOBO43t/C--
