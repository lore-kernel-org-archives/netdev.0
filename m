From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Allow transport SAs even when there is no policy
Date: Tue, 19 Oct 2004 07:43:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018214326.GA6589@gondor.apana.org.au>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <417428CF.2050802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <417428CF.2050802@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 18, 2004 at 10:34:23PM +0200, Patrick McHardy wrote:
> 
> > More importantly that it'll stick out like a sore thumb in terms of
> >
> > its semantics.
> 
> __xfrm_policy_check already rejects packets without a matching policy
> and skb->sp set, but it is skipped while the policy list is empty.
> What, from a semantics point of view, would be wrong with making
> xfrm_policy_check behave the same way ?

Good catch.  That was a bug introduced by yours truly :)

What I meant to say is all packets with tunnel mode SAs should be
rejected since we don't allow optional tunnel transforms for security
reasons.

This patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_policy.c 1.54 vs edited =====
--- 1.54/net/xfrm/xfrm_policy.c	2004-09-18 08:16:56 +10:00
+++ edited/net/xfrm/xfrm_policy.c	2004-10-19 07:42:37 +10:00
@@ -893,6 +893,16 @@
 	return 0;
 }
 
+static inline int secpath_has_tunnel(struct sec_path *sp, int k)
+{
+	for (; k < sp->len; k++) {
+		if (sp->x[k].xvec->props.mode)
+			return 1;
+	}
+
+	return 0;
+}
+
 int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, 
 			unsigned short family)
 {
@@ -930,7 +940,7 @@
 					xfrm_policy_lookup);
 
 	if (!pol)
-		return !skb->sp;
+		return !skb->sp || !secpath_has_tunnel(skb->sp, 0);
 
 	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
@@ -954,10 +964,8 @@
 				goto reject;
 		}
 
-		for (; k < sp->len; k++) {
-			if (sp->x[k].xvec->props.mode)
-				goto reject;
-		}
+		if (secpath_has_tunnel(sp, k))
+			goto reject;
 
 		xfrm_pol_put(pol);
 		return 1;

--gKMricLos+KVdGMg--
