From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/7] [IPSEC] Fix xfrm to pfkey SA state conversion
Date: Sat, 7 May 2005 17:19:30 +1000
Message-ID: <20050507071930.GC5753@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="1ccMZA6j1vT5UqiK"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050507071824.GA5753@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--1ccMZA6j1vT5UqiK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch adjusts the SA state conversion in af_key such that
XFRM_STATE_ERROR/XFRM_STATE_DEAD will be converted to SADB_STATE_DEAD
instead of SADB_STATE_DYING.

According to RFC 2367, SADB_STATE_DYING SAs can be turned into
mature ones through updating their lifetime settings.  Since SAs
which are in the states XFRM_STATE_ERROR/XFRM_STATE_DEAD cannot
be resurrected, this value is unsuitable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--1ccMZA6j1vT5UqiK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-2

--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -656,13 +656,18 @@ static struct sk_buff * pfkey_xfrm_state
 	sa->sadb_sa_exttype = SADB_EXT_SA;
 	sa->sadb_sa_spi = x->id.spi;
 	sa->sadb_sa_replay = x->props.replay_window;
-	sa->sadb_sa_state = SADB_SASTATE_DYING;
-	if (x->km.state == XFRM_STATE_VALID && !x->km.dying)
-		sa->sadb_sa_state = SADB_SASTATE_MATURE;
-	else if (x->km.state == XFRM_STATE_ACQ)
+	switch (x->km.state) {
+	case XFRM_STATE_VALID:
+		sa->sadb_sa_state = x->km.dying ?
+			SADB_SASTATE_DYING : SADB_SASTATE_MATURE;
+		break;
+	case XFRM_STATE_ACQ:
 		sa->sadb_sa_state = SADB_SASTATE_LARVAL;
-	else if (x->km.state == XFRM_STATE_EXPIRED)
+		break;
+	default:
 		sa->sadb_sa_state = SADB_SASTATE_DEAD;
+		break;
+	}
 	sa->sadb_sa_auth = 0;
 	if (x->aalg) {
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byname(x->aalg->alg_name, 0);

--1ccMZA6j1vT5UqiK--
