From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] Re: [Openswan Users] Invalid argument NULL
Date: Sun, 15 Aug 2004 21:25:48 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040815112548.GA2864@gondor.apana.org.au>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Cc: users@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: Jiva DeVoe <jiva@ixiacom.com>
Content-Disposition: inline
In-Reply-To: <E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
Cc: dev@lists.openswan.org
Cc: "David S. Miller" <davem@redhat.com>
Cc: netdev@oss.sgi.com
Cc: kuznet@ms2.inr.ac.ru
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 15, 2004 at 08:36:59PM +1000, Herbert Xu wrote:
> Jiva DeVoe <jiva@ixiacom.com> wrote:
> > Am trying to set up a couple of crypto_NULL tunnels... (I know, insecure,
> > that's ok... )  I have the module loaded, but I'm getting the following
> > error in pluto's logs:
> > 
> > ERROR: netlink response for Add SA esp.ff31fffb@<ip obscured> included errno
> > 22: Invalid argument
> > 
> > I presume this is something to do with setkey... Any suggestions on what I'm
> > doing wrong?
> 
> You aren't doing anything wrong.  The IPsec stack is :)

It turns out that xfrm_user isn't filling in x->props.ealgo or any of
the other algo values! I guess no one ever noticed because we rely on
the reqid to pick the right SA rather than the values in props.

Unfortunately ESP's init_state function looks at x->props.ealgo to
decide whether it's a NULL transform or not.

That may be something that we want to fix in itself.  However,
for the moment we should probably fill in x->props.*algo since it
is used elsewhere in the IPsec stack.  For example, the user may
create a template that has ealgos set which will require x->props.ealgo
to be set properly.

Come to think of it again, we only check/use aalgo anyway.  Maybe I should
forget about setting these values and just fix esp_init_state?

In any case, here is a really ugly patch to fill in those values for
xfrm_user.  Please let me know of any clean-ups or better ways of doing
this.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_user.c 1.48 vs edited =====
--- 1.48/net/xfrm/xfrm_user.c	2004-08-12 19:59:52 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-08-15 21:07:03 +10:00
@@ -155,15 +155,24 @@
 	return err;
 }
 
-static int attach_one_algo(struct xfrm_algo **algpp, struct rtattr *u_arg)
+static int attach_one_algo(struct xfrm_algo **algpp, u8 *props,
+			   struct xfrm_algo_desc *(*get_byname)(char *),
+			   struct rtattr *u_arg)
 {
 	struct rtattr *rta = u_arg;
 	struct xfrm_algo *p, *ualg;
+	struct xfrm_algo_desc *algo;
 
 	if (!rta)
 		return 0;
 
 	ualg = RTA_DATA(rta);
+
+	algo = get_byname(ualg->alg_name);
+	if (!algo)
+		return -ENOSYS;
+	*props = algo->desc.sadb_alg_id;
+
 	p = kmalloc(sizeof(*ualg) + ualg->alg_key_len, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
@@ -216,11 +225,17 @@
 
 	copy_from_user_state(x, p);
 
-	if ((err = attach_one_algo(&x->aalg, xfrma[XFRMA_ALG_AUTH-1])))
+	if ((err = attach_one_algo(&x->aalg, &x->props.aalgo,
+				   xfrm_aalg_get_byname,
+				   xfrma[XFRMA_ALG_AUTH-1])))
 		goto error;
-	if ((err = attach_one_algo(&x->ealg, xfrma[XFRMA_ALG_CRYPT-1])))
+	if ((err = attach_one_algo(&x->ealg, &x->props.ealgo,
+				   xfrm_ealg_get_byname,
+				   xfrma[XFRMA_ALG_CRYPT-1])))
 		goto error;
-	if ((err = attach_one_algo(&x->calg, xfrma[XFRMA_ALG_COMP-1])))
+	if ((err = attach_one_algo(&x->calg, &x->props.calgo,
+				   xfrm_calg_get_byname,
+				   xfrma[XFRMA_ALG_COMP-1])))
 		goto error;
 	if ((err = attach_encap_tmpl(&x->encap, xfrma[XFRMA_ENCAP-1])))
 		goto error;

--ibTvN161/egqYuK8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Dev mailing list
Dev@lists.openswan.org
http://lists.openswan.org/mailman/listinfo/dev

--ibTvN161/egqYuK8--
