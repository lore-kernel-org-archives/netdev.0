From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Kill nested read lock by deleting xfrm_init_tempsel
Date: Sat, 2 Apr 2005 10:49:56 +1000
Message-ID: <20050402004956.GA24339@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au> <20050331212325.5e996432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050331212325.5e996432.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

On Thu, Mar 31, 2005 at 09:23:25PM -0800, David S. Miller wrote:
> On Thu, 31 Mar 2005 10:46:58 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > # This is a BitKeeper generated diff -Nru style patch.
> > > #
> > > # ChangeSet
> > > #   2005/03/30 06:02:45+02:00 kaber@coreworks.de 
> > > #   [IPSEC]: Check SPI in xfrm_state_find()
> > > #   
> > > #   Signed-off-by: Patrick McHardy <kaber@trash.net>
> > 
> > Looks good.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> To me too, both patches applied, thanks Patrick.

Actually I only signed off on the first patch :)

The second patch creates a dead lock since it does a nested read
lock.  The solution is simply to get rid of xfrm_init_tempsel
and call the afinfo version directly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW I'd like to start cleaning up the locking in net/xfrm.
I don't want these changes to go into 2.6.12.  However, I'd
like to have them sit in mm for a while so that they get some
testing coverage.

What's the best way to do this? Could you create a tree slated
for 2.6.13?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.60 vs edited =====
--- 1.60/net/xfrm/xfrm_state.c	2005-04-01 15:19:54 +10:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-02 10:35:06 +10:00
@@ -283,20 +283,6 @@
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
-static int
-xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		  struct xfrm_tmpl *tmpl,
-		  xfrm_address_t *daddr, xfrm_address_t *saddr,
-		  unsigned short family)
-{
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
-	if (!afinfo)
-		return -1;
-	afinfo->init_tempsel(x, fl, tmpl, daddr, saddr);
-	xfrm_state_put_afinfo(afinfo);
-	return 0;
-}
-
 struct xfrm_state *
 xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
 		struct flowi *fl, struct xfrm_tmpl *tmpl,
@@ -370,7 +356,7 @@
 		}
 		/* Initialize temporary selector matching only
 		 * to current session. */
-		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
+		afinfo->init_tempsel(x, fl, tmpl, daddr, saddr);
 
 		if (km_query(x, tmpl, pol) == 0) {
 			x->km.state = XFRM_STATE_ACQ;

--YiEDa0DAkWCtVeE4--
