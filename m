From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: RFC: [1/2] PPP MPPE module
Date: Mon, 21 Jun 2004 11:39:20 -0500
Sender: linux-ppp-owner@vger.kernel.org
Message-ID: <20040621163920.GB29472@lists.us.dell.com>
References: <20040618161001.GE19269@lists.us.dell.com> <20040618161242.GG19269@lists.us.dell.com> <20040618161558.GA22913@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XOIedfhf+7KOe/yw"
Cc: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net,
	paulus@samba.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>, linux-ppp@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20040618161558.GA22913@infradead.org>
List-Id: netdev.vger.kernel.org


--XOIedfhf+7KOe/yw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 18, 2004 at 05:15:58PM +0100, Christoph Hellwig wrote:
> Last time I talked to Paul on MPPE he didn't like those hacks in
> the ppp core.

Adding the linux-ppp list to the discussion.

Rather than have code in ppp_generic.c testing for CI_MPPE and doing
code conditionally (which I agree was ugly), how about adding two new
fields to struct compressor:

+	/* Extra skb space needed by the compressor algorithm */
+	unsigned int comp_skb_extra_space;
+	/* Extra skb space needed by the decompressor algorithm */
+	unsigned int decomp_skb_extra_space;

which the compressor modules can fill in if needed?  Presently,
bsd_comp.c and ppp_deflate.c don't need these, so they will be filled
with zeros automatically at struct compressor instantiation.

This hunk may still be contriversial though.  It adds a negative
return value to the compress() method, which is only (presently) used
by ppp_mppe (bsd_comp.c and ppp_deflate.c always return 0 if they
couldn't compress), to indicate the frame should be dropped.

-		} else {
+                } else if (len =3D=3D 0) {
 			/* didn't compress, or CCP not up yet */
 			kfree_skb(new_skb);
+                } else {
+                        /*
+                         * (len < 0)
+                         * MPPE requires that we do not send unencrypted
+                         * frames.  The compressor will return -1 if we
+                         * should drop the frame.  We cannot simply test
+                         * the compress_proto because MPPE and MPPC share
+                         * the same number.
+                         */
+                        printk(KERN_ERR "ppp: compressor dropped pkt\n");
+                        kfree_skb(new_skb);
+                        goto drop;

Thoughts?

Patch below against 2.6.7-bk ppp_generic.c and ppp-comp.h to add such,
for comment only.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

=3D=3D=3D=3D=3D drivers/net/ppp_generic.c 1.45 vs edited =3D=3D=3D=3D=3D
--- 1.45/drivers/net/ppp_generic.c	2004-04-09 18:21:06 -05:00
+++ edited/drivers/net/ppp_generic.c	2004-06-21 10:56:34 -05:00
@@ -1066,8 +1066,9 @@
 	/* try to do packet compression */
 	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state !=3D 0
 	    && proto !=3D PPP_LCP && proto !=3D PPP_CCP) {
-		new_skb =3D alloc_skb(ppp->dev->mtu + ppp->dev->hard_header_len,
-				    GFP_ATOMIC);
+                int new_skb_size =3D ppp->dev->mtu + ppp->xcomp->comp_skb_=
extra_space + ppp->dev->hard_header_len;
+                int compressor_skb_size =3D ppp->dev->mtu + ppp->xcomp->co=
mp_skb_extra_space + PPP_HDRLEN;
+                new_skb =3D alloc_skb(new_skb_size, GFP_ATOMIC);
 		if (new_skb =3D=3D 0) {
 			printk(KERN_ERR "PPP: no memory (comp pkt)\n");
 			goto drop;
@@ -1079,15 +1080,27 @@
 		/* compressor still expects A/C bytes in hdr */
 		len =3D ppp->xcomp->compress(ppp->xc_state, skb->data - 2,
 					   new_skb->data, skb->len + 2,
-					   ppp->dev->mtu + PPP_HDRLEN);
+                                           compressor_skb_size);
 		if (len > 0 && (ppp->flags & SC_CCP_UP)) {
 			kfree_skb(skb);
 			skb =3D new_skb;
 			skb_put(skb, len);
 			skb_pull(skb, 2);	/* pull off A/C bytes */
-		} else {
+                } else if (len =3D=3D 0) {
 			/* didn't compress, or CCP not up yet */
 			kfree_skb(new_skb);
+                } else {
+                        /*
+                         * (len < 0)
+                         * MPPE requires that we do not send unencrypted
+                         * frames.  The compressor will return -1 if we
+                         * should drop the frame.  We cannot simply test
+                         * the compress_proto because MPPE and MPPC share
+                         * the same number.
+                         */
+                        printk(KERN_ERR "ppp: compressor dropped pkt\n");
+                        kfree_skb(new_skb);
+                        goto drop;
 		}
 	}
=20
@@ -1596,7 +1609,7 @@
 		goto err;
=20
 	if (proto =3D=3D PPP_COMP) {
-		ns =3D dev_alloc_skb(ppp->mru + PPP_HDRLEN);
+		ns =3D dev_alloc_skb(ppp->mru + ppp->rcomp->decomp_skb_extra_space + PPP=
_HDRLEN);
 		if (ns =3D=3D 0) {
 			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
 			goto err;


=3D=3D=3D=3D=3D include/linux/ppp-comp.h 1.4 vs edited =3D=3D=3D=3D=3D
--- 1.4/include/linux/ppp-comp.h	2003-08-07 18:57:19 -05:00
+++ edited/include/linux/ppp-comp.h	2004-06-21 10:59:44 -05:00
@@ -111,6 +111,10 @@
=20
 	/* Used in locking compressor modules */
 	struct module *owner;
+	/* Extra skb space needed by the compressor algorithm */
+	unsigned int comp_skb_extra_space;
+	/* Extra skb space needed by the decompressor algorithm */
+	unsigned int decomp_skb_extra_space;
 };
=20
 /*

--XOIedfhf+7KOe/yw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFA1w84Iavu95Lw/AkRAr1mAJ4u3/jwEeEaNuNzjNPTa2hDyGi3EgCglS9E
WvLLynOS2WwhGYha+5ysAA0=
=0xay
-----END PGP SIGNATURE-----

--XOIedfhf+7KOe/yw--
