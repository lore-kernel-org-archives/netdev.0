From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] ppp, slip: Validate VJ compression slot parameters
 completely
Date: Wed, 14 Oct 2015 18:53:30 +0100
Message-ID: <1444845210.31451.23.camel@decadent.org.uk>
References: <1444845074.31451.21.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eZzlr/htYWPtrTuS5PAs"
Cc: Karsten Keil <isdn@linux-pingi.de>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?=E9=83=AD=E6=B0=B8=E5=88=9A?= <guoyonggang@360.cn>
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1444845074.31451.21.camel@decadent.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eZzlr/htYWPtrTuS5PAs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Currently slhc_init() treats out-of-range values of rslots and tslots
as equivalent to 0, except that if tslots is too large it will
dereference a null pointer (CVE-2015-7799).

Add a range-check at the top of the function and make it return an
ERR_PTR() on error instead of NULL.=C2=A0=C2=A0Change the callers according=
ly.

Compile-tested only.

Reported-by: =E9=83=AD=E6=B0=B8=E5=88=9A <guoyonggang@360.cn>
References: http://article.gmane.org/gmane.comp.security.oss.general/17908
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
=C2=A0drivers/isdn/i4l/isdn_ppp.c=C2=A0=C2=A0=C2=A0| 10 ++++------
=C2=A0drivers/net/ppp/ppp_generic.c |=C2=A0=C2=A06 ++----
=C2=A0drivers/net/slip/slhc.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 12=
 ++++++++----
=C2=A0drivers/net/slip/slip.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=
=A0=C2=A02 +-
=C2=A04 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 86f9abe..9c1e8ad 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -322,9 +322,9 @@ isdn_ppp_open(int min, struct file *file)
=C2=A0	=C2=A0* VJ header compression init
=C2=A0	=C2=A0*/
=C2=A0	is->slcomp =3D slhc_init(16, 16);	/* not necessary for 2. link in bu=
ndle */
-	if (!is->slcomp) {
+	if (IS_ERR(is->slcomp)) {
=C2=A0		isdn_ppp_ccp_reset_free(is);
-		return -ENOMEM;
+		return PTR_ERR(is->slcomp);
=C2=A0	}
=C2=A0#endif
=C2=A0#ifdef CONFIG_IPPP_FILTER
@@ -573,10 +573,8 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned in=
t cmd, unsigned long arg)
=C2=A0			is->maxcid =3D val;
=C2=A0#ifdef CONFIG_ISDN_PPP_VJ
=C2=A0			sltmp =3D slhc_init(16, val);
-			if (!sltmp) {
-				printk(KERN_ERR "ippp, can't realloc slhc struct\n");
-				return -ENOMEM;
-			}
+			if (IS_ERR(sltmp))
+				return PTR_ERR(sltmp);
=C2=A0			if (is->slcomp)
=C2=A0				slhc_free(is->slcomp);
=C2=A0			is->slcomp =3D sltmp;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index ed00446..9a863c6 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -721,10 +721,8 @@ static long ppp_ioctl(struct file *file, unsigned int =
cmd, unsigned long arg)
=C2=A0			val &=3D 0xffff;
=C2=A0		}
=C2=A0		vj =3D slhc_init(val2+1, val+1);
-		if (!vj) {
-			netdev_err(ppp->dev,
-				=C2=A0=C2=A0=C2=A0"PPP: no memory (VJ compressor)\n");
-			err =3D -ENOMEM;
+		if (IS_ERR(vj)) {
+			err =3D PTR_ERR(vj);
=C2=A0			break;
=C2=A0		}
=C2=A0		ppp_lock(ppp);
diff --git a/drivers/net/slip/slhc.c b/drivers/net/slip/slhc.c
index 079f7ad..27ed252 100644
--- a/drivers/net/slip/slhc.c
+++ b/drivers/net/slip/slhc.c
@@ -84,8 +84,9 @@ static long decode(unsigned char **cpp);
=C2=A0static unsigned char * put16(unsigned char *cp, unsigned short x);
=C2=A0static unsigned short pull16(unsigned char **cpp);
=C2=A0
-/* Initialize compression data structure
+/* Allocate compression data structure
=C2=A0 *	slots must be in range 0 to 255 (zero meaning no compression)
+ * Returns pointer to structure or ERR_PTR() on error.
=C2=A0 */
=C2=A0struct slcompress *
=C2=A0slhc_init(int rslots, int tslots)
@@ -94,11 +95,14 @@ slhc_init(int rslots, int tslots)
=C2=A0	register struct cstate *ts;
=C2=A0	struct slcompress *comp;
=C2=A0
+	if (rslots < 0 || rslots > 255 || tslots < 0 || tslots > 255)
+		return ERR_PTR(-EINVAL);
+
=C2=A0	comp =3D kzalloc(sizeof(struct slcompress), GFP_KERNEL);
=C2=A0	if (! comp)
=C2=A0		goto out_fail;
=C2=A0
-	if ( rslots > 0=C2=A0=C2=A0&&=C2=A0=C2=A0rslots < 256 ) {
+	if (rslots > 0) {
=C2=A0		size_t rsize =3D rslots * sizeof(struct cstate);
=C2=A0		comp->rstate =3D kzalloc(rsize, GFP_KERNEL);
=C2=A0		if (! comp->rstate)
@@ -106,7 +110,7 @@ slhc_init(int rslots, int tslots)
=C2=A0		comp->rslot_limit =3D rslots - 1;
=C2=A0	}
=C2=A0
-	if ( tslots > 0=C2=A0=C2=A0&&=C2=A0=C2=A0tslots < 256 ) {
+	if (tslots > 0) {
=C2=A0		size_t tsize =3D tslots * sizeof(struct cstate);
=C2=A0		comp->tstate =3D kzalloc(tsize, GFP_KERNEL);
=C2=A0		if (! comp->tstate)
@@ -141,7 +145,7 @@ out_free2:
=C2=A0out_free:
=C2=A0	kfree(comp);
=C2=A0out_fail:
-	return NULL;
+	return ERR_PTR(-ENOMEM);
=C2=A0}
=C2=A0
=C2=A0
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 05387b1..a17d86a 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -164,7 +164,7 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
=C2=A0	if (cbuff =3D=3D NULL)
=C2=A0		goto err_exit;
=C2=A0	slcomp =3D slhc_init(16, 16);
-	if (slcomp =3D=3D NULL)
+	if (IS_ERR(slcomp))
=C2=A0		goto err_exit;
=C2=A0#endif
=C2=A0	spin_lock_bh(&sl->lock);
--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949
--=-eZzlr/htYWPtrTuS5PAs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVh6Wmue/yOyVhhEJAQpVLRAAgaA3Dr3FwCJOYck0U/vpVUtinstNZrG4
JqTfOw4wEebkf+11LTQrsp2P/fSIBADwGGYElfkTqjwQJ5Ps6mmZNp41c/4JkG7M
eQMvN//Qf8oCT5YISlegqTT0RZI4huR5vj16TnipWPQbfcxhTiuIPVJ7af2aYaoD
spQAWUxzxASpvLV+9c09YT2+ziuHh3+zwFS2anhHvxIh77odS7+YWE1TjjmAH7hs
2PgKM8WgOvTe3D8QxSwibI14E+XW37e+gNa33nlh/MvTtm9lkaYjpiL5WHv5cxfU
zAkKPr0UpKM8oAFZMrE8h01h5WyN5S+YUGu/37zKSUM2dvqkTb6i12TsAK52mJAm
F1BlTZe9hHkLluZ4JN6ah8wKkcf6HfXbF4iegp4zpvkteENjErQlZPoSxfd5LTPc
qCjvqSaNKTbwDRp8t9VEDYzJQCfYaPvOgcILjAOmXFMofsKVhaUliwQ1nc4KQHtM
fzFdgOZvHHQLKoZ8HKJewWFZwJ86E+k3cZCNcYejyMn2BcU6Z6uJ4I8xkCAm7deU
iB5O8B2qNqRj3Ky+sng0inbQ3eC4c5fExPacFZRbA+RZJjZwMFBY9xYtB1NfG3Qa
BGmTyxy3zYLHGmCv20/bHWApBOVoKgGIXKjt9bwLEm+/k6HZ4xEb5nvA626XrnKs
Uyd3uC4zWYk=
=EVPe
-----END PGP SIGNATURE-----

--=-eZzlr/htYWPtrTuS5PAs--
