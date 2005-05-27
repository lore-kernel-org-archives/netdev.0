From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [7/10] [IPSEC] Fix xfrm_state leaks in error path
Date: Fri, 27 May 2005 21:14:58 +1000
Message-ID: <20050527111458.GG4545@gondor.apana.org.au>
References: <20050527110730.GA4424@gondor.apana.org.au> <20050527110816.GA4545@gondor.apana.org.au> <20050527110852.GB4545@gondor.apana.org.au> <20050527110929.GC4545@gondor.apana.org.au> <20050527111007.GD4545@gondor.apana.org.au> <20050527111037.GE4545@gondor.apana.org.au> <20050527111140.GF4545@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9Iq5ULCa7nGtWwZS"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527111140.GF4545@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9Iq5ULCa7nGtWwZS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Herbert Xu wrote:
> @@ -1254,6 +1326,7 @@ static int pfkey_add(struct sock *sk, st
>       if (IS_ERR(x))
>               return PTR_ERR(x);
>
> +     xfrm_state_hold(x);

This introduces a leak when xfrm_state_add()/xfrm_state_update()
fail. We hold two references (one from xfrm_state_alloc(), one
from xfrm_state_hold()), but only drop one. We need to take the
reference because the reference from xfrm_state_alloc() can
be dropped by __xfrm_state_delete(), so the fix is to drop both
references on error. Same problem in xfrm_user.c.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--9Iq5ULCa7nGtWwZS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p9.patch"

diff --git a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1333,7 +1333,7 @@ static int pfkey_add(struct sock *sk, st
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
-		return err;
+		goto out;
 	}
 
 	if (hdr->sadb_msg_type == SADB_ADD)
@@ -1343,8 +1343,8 @@ static int pfkey_add(struct sock *sk, st
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	km_state_notify(x, &c);
+out:
 	xfrm_state_put(x);
-
 	return err;
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -287,7 +287,7 @@ static int xfrm_add_sa(struct sk_buff *s
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
 		xfrm_state_put(x);
-		return err;
+		goto out;
 	}
 
 	c.seq = nlh->nlmsg_seq;
@@ -295,8 +295,8 @@ static int xfrm_add_sa(struct sk_buff *s
 	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
+out:
 	xfrm_state_put(x);
-
 	return err;
 }
 

--9Iq5ULCa7nGtWwZS--
