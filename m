From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 09:03:27 +0800
Message-ID: <20150416010326.GA10864@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <20150415135739.GA5534@gondor.apana.org.au>
 <552E86A6.9000101@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Morris <jmorris@namei.org>,
	linux-security-module@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552E86A6.9000101@6wind.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 05:41:26PM +0200, Nicolas Dichtel wrote:
> Le 15/04/2015 15:57, Herbert Xu a =E9crit :
> >On Wed, Apr 15, 2015 at 06:22:29PM +0800, Herbert Xu wrote:
> [snip]
> >Subject: skbuff: Do not scrub skb mark within the same name space
> >
> >The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
> Maybe add a Fixes tag?
> Fixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx pa=
th")
>=20
> >harmonize cleanup done on skb on rx path") broke anyone trying to
> >use netfilter marking across IPv4 tunnels.  While most of the
> >fields that are cleared by skb_scrub_packet don't matter, the
> >netfilter mark must be preserved.
> >
> >This patch rearranges skb_scurb_packet to preserve the mark field.
> nit: s/scurb/scrub
>=20
> Else it's fine for me.

Sure.

PS I used the wrong email for James the first time around.  So
let me repeat the question here.  Should secmark be preserved
or cleared across tunnels within the same name space? In fact,
do our security models even support name spaces?

---8<---
The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
harmonize cleanup done on skb on rx path") broke anyone trying to
use netfilter marking across IPv4 tunnels.  While most of the
fields that are cleared by skb_scrub_packet don't matter, the
netfilter mark must be preserved.

This patch rearranges skb_scrub_packet to preserve the mark field.

=46ixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx pa=
th")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3b6e583..a185427 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4124,19 +4124,22 @@ EXPORT_SYMBOL(skb_try_coalesce);
  */
 void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 {
-	if (xnet)
-		skb_orphan(skb);
 	skb->tstamp.tv64 =3D 0;
 	skb->pkt_type =3D PACKET_HOST;
 	skb->skb_iif =3D 0;
 	skb->ignore_df =3D 0;
 	skb_dst_drop(skb);
-	skb->mark =3D 0;
 	skb_sender_cpu_clear(skb);
 	skb_init_secmark(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
 	nf_reset_trace(skb);
+
+	if (!xnet)
+		return;
+
+	skb_orphan(skb);
+	skb->mark =3D 0;
 }
 EXPORT_SYMBOL_GPL(skb_scrub_packet);
=20
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
