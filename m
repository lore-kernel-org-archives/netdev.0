From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net 2/2] ppp, slip: Validate VJ compression slot
 parameters completely
Date: Sun, 1 Nov 2015 16:22:53 +0000
Message-ID: <20151101162253.GB9478@decadent.org.uk>
References: <20151101162123.GA9478@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="l76fUT7nc3MelDdI"
Cc: Karsten Keil <isdn@linux-pingi.de>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151101162123.GA9478@decadent.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Currently slhc_init() treats out-of-range values of rslots and tslots
as equivalent to 0, except that if tslots is too large it will
dereference a null pointer (CVE-2015-7799).

Add a range-check at the top of the function and make it return an
ERR_PTR() on error instead of NULL.  Change the callers accordingly.

Compile-tested only.

Reported-by: =E9=83=AD=E6=B0=B8=E5=88=9A <guoyonggang@360.cn>
References: http://article.gmane.org/gmane.comp.security.oss.general/17908
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Re-sent using mutt since Evolution 3.18 mangles patches.

Ben.

 drivers/isdn/i4l/isdn_ppp.c   | 10 ++++------
 drivers/net/ppp/ppp_generic.c |  6 ++----
 drivers/net/slip/slhc.c       | 12 ++++++++----
 drivers/net/slip/slip.c       |  2 +-
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 86f9abe..9c1e8ad 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -322,9 +322,9 @@ isdn_ppp_open(int min, struct file *file)
 	 * VJ header compression init
 	 */
 	is->slcomp =3D slhc_init(16, 16);	/* not necessary for 2. link in bundle =
*/
-	if (!is->slcomp) {
+	if (IS_ERR(is->slcomp)) {
 		isdn_ppp_ccp_reset_free(is);
-		return -ENOMEM;
+		return PTR_ERR(is->slcomp);
 	}
 #endif
 #ifdef CONFIG_IPPP_FILTER
@@ -573,10 +573,8 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned in=
t cmd, unsigned long arg)
 			is->maxcid =3D val;
 #ifdef CONFIG_ISDN_PPP_VJ
 			sltmp =3D slhc_init(16, val);
-			if (!sltmp) {
-				printk(KERN_ERR "ippp, can't realloc slhc struct\n");
-				return -ENOMEM;
-			}
+			if (IS_ERR(sltmp))
+				return PTR_ERR(sltmp);
 			if (is->slcomp)
 				slhc_free(is->slcomp);
 			is->slcomp =3D sltmp;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index ed00446..9a863c6 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -721,10 +721,8 @@ static long ppp_ioctl(struct file *file, unsigned int =
cmd, unsigned long arg)
 			val &=3D 0xffff;
 		}
 		vj =3D slhc_init(val2+1, val+1);
-		if (!vj) {
-			netdev_err(ppp->dev,
-				   "PPP: no memory (VJ compressor)\n");
-			err =3D -ENOMEM;
+		if (IS_ERR(vj)) {
+			err =3D PTR_ERR(vj);
 			break;
 		}
 		ppp_lock(ppp);
diff --git a/drivers/net/slip/slhc.c b/drivers/net/slip/slhc.c
index 079f7ad..27ed252 100644
--- a/drivers/net/slip/slhc.c
+++ b/drivers/net/slip/slhc.c
@@ -84,8 +84,9 @@ static long decode(unsigned char **cpp);
 static unsigned char * put16(unsigned char *cp, unsigned short x);
 static unsigned short pull16(unsigned char **cpp);
=20
-/* Initialize compression data structure
+/* Allocate compression data structure
  *	slots must be in range 0 to 255 (zero meaning no compression)
+ * Returns pointer to structure or ERR_PTR() on error.
  */
 struct slcompress *
 slhc_init(int rslots, int tslots)
@@ -94,11 +95,14 @@ slhc_init(int rslots, int tslots)
 	register struct cstate *ts;
 	struct slcompress *comp;
=20
+	if (rslots < 0 || rslots > 255 || tslots < 0 || tslots > 255)
+		return ERR_PTR(-EINVAL);
+
 	comp =3D kzalloc(sizeof(struct slcompress), GFP_KERNEL);
 	if (! comp)
 		goto out_fail;
=20
-	if ( rslots > 0  &&  rslots < 256 ) {
+	if (rslots > 0) {
 		size_t rsize =3D rslots * sizeof(struct cstate);
 		comp->rstate =3D kzalloc(rsize, GFP_KERNEL);
 		if (! comp->rstate)
@@ -106,7 +110,7 @@ slhc_init(int rslots, int tslots)
 		comp->rslot_limit =3D rslots - 1;
 	}
=20
-	if ( tslots > 0  &&  tslots < 256 ) {
+	if (tslots > 0) {
 		size_t tsize =3D tslots * sizeof(struct cstate);
 		comp->tstate =3D kzalloc(tsize, GFP_KERNEL);
 		if (! comp->tstate)
@@ -141,7 +145,7 @@ out_free2:
 out_free:
 	kfree(comp);
 out_fail:
-	return NULL;
+	return ERR_PTR(-ENOMEM);
 }
=20
=20
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 05387b1..a17d86a 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -164,7 +164,7 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
 	if (cbuff =3D=3D NULL)
 		goto err_exit;
 	slcomp =3D slhc_init(16, 16);
-	if (slcomp =3D=3D NULL)
+	if (IS_ERR(slcomp))
 		goto err_exit;
 #endif
 	spin_lock_bh(&sl->lock);

--l76fUT7nc3MelDdI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVjY8XOe/yOyVhhEJAQqQow//cOiEYcEgQhAjit6FLF8vP0pl98fV6v7M
iKA7DNHO6E+9DrgerRIGVA3Ms6btYcqT2VduY0Fjl4QvFAFx1RB0D04OzS0JJIjb
i3/L/S0rxaNsVnIzqBUmqSkj5LN8ZY8bfN/9O742dI5rN5Rs8bOg5Od5d0YLn9lX
3Nmbfx74374DNCPBAntayjYL0M+QTbOjVv0vnD2fRLfQX5w5osAZ7XXe1za9sRzl
gpcHzrF2vQ0mdNQJBvp2IDRIRkQK6dKI582nzcRYudaD/PdNMArOB/hoQcuibr3T
jNsFZW3WoZ2u59fVSbXbFptGWLsRNMMQQH/FuqCabQq2gwCnLq1vNGp8ptI3G1Pr
omljHsRoRJ6rz6xeL5WZ/Hhbld9Kn/NiDzinkxkrp81pM2otstd1aDDM/iij5xRm
OFCm82/4aOeADSrmjGfBmNpLVuNSKLFkLCmKp2qr3A1zzj1fLWgO8WyWexGCwoS6
rsZuVv/UVqO7vQMaIyF3Rk2rsqdA3Dxq3nZZBNmyBanQk+OP+S1pRD1jXAdlQ0jd
0pQZAJGlvK+L7G46dA1m+Z73AjGrX8zr+JPdob1qs/nolQvhfmMjysBwob4aK4c8
bpl3ITTO2axBBVQrBKtLyO1CPcDpjp4budBUN6H3AM9aXl8gWulRKrn8r4RivtKP
vgPLkej0wVg=
=XdnA
-----END PGP SIGNATURE-----

--l76fUT7nc3MelDdI--
