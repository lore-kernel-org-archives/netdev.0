From: Matt Domsch <Matt_Domsch@dell.com>
Subject: RFC: [1/2] PPP MPPE module
Date: Fri, 18 Jun 2004 11:12:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618161242.GG19269@lists.us.dell.com>
References: <20040618161001.GE19269@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NPukt5Otb9an/u20"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <20040618161001.GE19269@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NPukt5Otb9an/u20
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 18, 2004 at 11:10:01AM -0500, Matt Domsch wrote:
> Following two emails each contain patches.

Of course, that subject should have been [0,1,2/2], not of 3.

> 2) minimal touches to Makefile, KConfig, ppp_generic.c, and
> include/linux/ppp-comp.h

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

=3D=3D=3D=3D=3D drivers/net/Kconfig 1.75 vs edited =3D=3D=3D=3D=3D
--- 1.75/drivers/net/Kconfig	2004-06-02 15:04:38 -05:00
+++ edited/drivers/net/Kconfig	2004-06-18 09:48:16 -05:00
@@ -2410,6 +2410,12 @@
 	  module; it is called bsd_comp and will show up in the directory
 	  modules once you have said "make modules". If unsure, say N.
=20
+config PPP_MPPE
+       tristate "PPP MPPE compression (encryption)"
+       depends on PPP
+       ---help---
+         Support for the MPPE Encryption protocol.
+
 config PPPOE
 	tristate "PPP over Ethernet (EXPERIMENTAL)"
 	depends on EXPERIMENTAL && PPP
=3D=3D=3D=3D=3D drivers/net/Makefile 1.79 vs edited =3D=3D=3D=3D=3D
--- 1.79/drivers/net/Makefile	2004-05-22 12:13:08 -05:00
+++ edited/drivers/net/Makefile	2004-06-18 10:22:41 -05:00
@@ -100,6 +100,7 @@
 obj-$(CONFIG_PPP_SYNC_TTY) +=3D ppp_synctty.o
 obj-$(CONFIG_PPP_DEFLATE) +=3D ppp_deflate.o
 obj-$(CONFIG_PPP_BSDCOMP) +=3D bsd_comp.o
+obj-$(CONFIG_PPP_MPPE) +=3D ppp_mppe.o
 obj-$(CONFIG_PPPOE) +=3D pppox.o pppoe.o
=20
 obj-$(CONFIG_SLIP) +=3D slip.o
=3D=3D=3D=3D=3D drivers/net/ppp_generic.c 1.45 vs edited =3D=3D=3D=3D=3D
--- 1.45/drivers/net/ppp_generic.c	2004-04-09 18:21:06 -05:00
+++ edited/drivers/net/ppp_generic.c	2004-06-18 09:47:10 -05:00
@@ -1066,8 +1066,15 @@
 	/* try to do packet compression */
 	if ((ppp->xstate & SC_COMP_RUN) && ppp->xc_state !=3D 0
 	    && proto !=3D PPP_LCP && proto !=3D PPP_CCP) {
-		new_skb =3D alloc_skb(ppp->dev->mtu + ppp->dev->hard_header_len,
-				    GFP_ATOMIC);
+                int new_skb_size =3D ppp->dev->mtu + ppp->dev->hard_header=
_len;
+                int compressor_skb_size =3D ppp->dev->mtu + PPP_HDRLEN;
+
+                if (ppp->xcomp->compress_proto =3D=3D CI_MPPE) {
+                        /* CCP [must have] reduced MTU by MPPE_PAD. */
+                        new_skb_size +=3D MPPE_PAD;
+                        compressor_skb_size +=3D MPPE_PAD;
+                }
+                new_skb =3D alloc_skb(new_skb_size, GFP_ATOMIC);
 		if (new_skb =3D=3D 0) {
 			printk(KERN_ERR "PPP: no memory (comp pkt)\n");
 			goto drop;
@@ -1079,15 +1086,27 @@
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
@@ -1596,7 +1615,7 @@
 		goto err;
=20
 	if (proto =3D=3D PPP_COMP) {
-		ns =3D dev_alloc_skb(ppp->mru + PPP_HDRLEN);
+		ns =3D dev_alloc_skb(ppp->mru + 128 + PPP_HDRLEN);
 		if (ns =3D=3D 0) {
 			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
 			goto err;
=3D=3D=3D=3D=3D include/linux/ppp-comp.h 1.4 vs edited =3D=3D=3D=3D=3D
--- 1.4/include/linux/ppp-comp.h	2003-08-07 18:57:19 -05:00
+++ edited/include/linux/ppp-comp.h	2004-06-18 09:46:32 -05:00
@@ -191,6 +191,100 @@
 #define DEFLATE_CHK_SEQUENCE	0
=20
 /*
+ * Definitions for MPPE.
+ */
+
+#define CI_MPPE                        18      /* config option for MPPE */
+#define CILEN_MPPE             6       /* length of config option */
+
+#define MPPE_PAD               8       /* MPPE growth per frame */
+#define MPPE_MAX_KEY_LEN       16      /* largest key length (128-bit) */
+
+/* option bits for ccp_options.mppe */
+#define MPPE_OPT_40            0x01    /* 40 bit */
+#define MPPE_OPT_128           0x02    /* 128 bit */
+#define MPPE_OPT_STATEFUL      0x04    /* stateful mode */
+/* unsupported opts */
+#define MPPE_OPT_56            0x08    /* 56 bit */
+#define MPPE_OPT_MPPC          0x10    /* MPPC compression */
+#define MPPE_OPT_D             0x20    /* Unknown */
+#define MPPE_OPT_UNSUPPORTED (MPPE_OPT_56|MPPE_OPT_MPPC|MPPE_OPT_D)
+#define MPPE_OPT_UNKNOWN       0x40    /* Bits !defined in RFC 3078 were s=
et */
+
+/*
+ * This is not nice ... the alternative is a bitfield struct though.
+ * And unfortunately, we cannot share the same bits for the option
+ * names above since C and H are the same bit.  We could do a u_int32
+ * but then we have to do a htonl() all the time and/or we still need
+ * to know which octet is which.
+ */
+#define MPPE_C_BIT             0x01    /* MPPC */
+#define MPPE_D_BIT             0x10    /* Obsolete, usage unknown */
+#define MPPE_L_BIT             0x20    /* 40-bit */
+#define MPPE_S_BIT             0x40    /* 128-bit */
+#define MPPE_M_BIT             0x80    /* 56-bit, not supported */
+#define MPPE_H_BIT             0x01    /* Stateless (in a different byte) =
*/
+
+/* Does not include H bit; used for least significant octet only. */
+#define MPPE_ALL_BITS (MPPE_D_BIT|MPPE_L_BIT|MPPE_S_BIT|MPPE_M_BIT|MPPE_H_=
BIT)
+
+/* Build a CI from mppe opts (see RFC 3078) */
+#define MPPE_OPTS_TO_CI(opts, ci)              \
+    do {                                       \
+       u_char *ptr =3D ci; /* u_char[4] */       \
+                                               \
+       /* H bit */                             \
+       if (opts & MPPE_OPT_STATEFUL)           \
+           *ptr++ =3D 0x0;                       \
+       else                                    \
+           *ptr++ =3D MPPE_H_BIT;                \
+       *ptr++ =3D 0;                             \
+       *ptr++ =3D 0;                             \
+                                               \
+       /* S,L bits */                          \
+       *ptr =3D 0;                               \
+       if (opts & MPPE_OPT_128)                \
+           *ptr |=3D MPPE_S_BIT;                 \
+       if (opts & MPPE_OPT_40)                 \
+           *ptr |=3D MPPE_L_BIT;                 \
+       /* M,D,C bits not supported */          \
+    } while (/* CONSTCOND */ 0)
+
+/* The reverse of the above */
+#define MPPE_CI_TO_OPTS(ci, opts)              \
+    do {                                       \
+       u_char *ptr =3D ci; /* u_char[4] */       \
+                                               \
+       opts =3D 0;                               \
+                                               \
+       /* H bit */                             \
+       if (!(ptr[0] & MPPE_H_BIT))             \
+           opts |=3D MPPE_OPT_STATEFUL;          \
+                                               \
+       /* S,L bits */                          \
+       if (ptr[3] & MPPE_S_BIT)                \
+           opts |=3D MPPE_OPT_128;               \
+       if (ptr[3] & MPPE_L_BIT)                \
+           opts |=3D MPPE_OPT_40;                \
+                                               \
+       /* M,D,C bits */                        \
+       if (ptr[3] & MPPE_M_BIT)                \
+           opts |=3D MPPE_OPT_56;                \
+       if (ptr[3] & MPPE_D_BIT)                \
+           opts |=3D MPPE_OPT_D;                 \
+       if (ptr[3] & MPPE_C_BIT)                \
+           opts |=3D MPPE_OPT_MPPC;              \
+                                               \
+       /* Other bits */                        \
+       if (ptr[0] & ~MPPE_H_BIT)               \
+           opts |=3D MPPE_OPT_UNKNOWN;           \
+       if (ptr[1] || ptr[2])                   \
+           opts |=3D MPPE_OPT_UNKNOWN;           \
+       if (ptr[3] & ~MPPE_ALL_BITS)            \
+           opts |=3D MPPE_OPT_UNKNOWN;           \
+    } while (/* CONSTCOND */ 0)
+
+/*
  * Definitions for other, as yet unsupported, compression methods.
  */
=20

--NPukt5Otb9an/u20
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFA0xR6Iavu95Lw/AkRAjOKAJkBJWyuu6vQLBzIaLNuprukHDOHIgCgiVv9
3l+eLzGgZl982DqgnqLz03A=
=AWiM
-----END PGP SIGNATURE-----

--NPukt5Otb9an/u20--
