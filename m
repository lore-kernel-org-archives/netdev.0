From: Matt Domsch <Matt_Domsch@dell.com>
Subject: RFC: [1/3] PPP MPPE module
Date: Fri, 18 Jun 2004 11:10:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618161052.GF19269@lists.us.dell.com>
References: <20040618161001.GE19269@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NGIwU0kFl1Z1A3An"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, pptpclient-devel@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <20040618161001.GE19269@lists.us.dell.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NGIwU0kFl1Z1A3An
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 18, 2004 at 11:10:01AM -0500, Matt Domsch wrote:
> 1) Add ppp_mppe.c file to drivers/net

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--- /dev/null	Thu Apr 11 09:25:15 2002
+++ linux-2.6-mppe/drivers/net/ppp_mppe.c	Fri Jun 18 10:42:11 2004
@@ -0,0 +1,695 @@
+/*
+ * ppp_mppe_compress.c - interface MPPE to the PPP code.
+ * This version is for use with Linux kernel 2.2.19+, 2.4.18+ and 2.6.2+.
+ *
+ * By Frank Cusack <frank@google.com>.
+ * Copyright (c) 2002,2003,2004 Google, Inc.
+ * All rights reserved.
+ *
+ * License:
+ * Permission to use, copy, modify, and distribute this software and its
+ * documentation is hereby granted, provided that the above copyright
+ * notice appears in all copies.  This software is provided without any
+ * warranty, express or implied.
+ *
+ * ALTERNATIVELY, provided that this notice is retained in full, this prod=
uct
+ * may be distributed under the terms of the GNU General Public License (G=
PL),
+ * in which case the provisions of the GPL apply INSTEAD OF those given ab=
ove.
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   along with this program; if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 =
 USA
+ *
+ *
+ * Changelog:
+ *      06/18/04 - Matt Domsch <Matt_Domsch@dell.com>
+ *                 Use Linux kernel 2.6 arc4 and sha1 routines rather than
+ *                 providing our own.
+ *      2/15/04 - TS: added #include <version.h> and testing for Kernel
+ *                    version before using=20
+ *                    MOD_DEC_USAGE_COUNT/MOD_INC_USAGE_COUNT which are
+ *                    deprecated in 2.6
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/crypto.h>
+#include <linux/mm.h>
+#include <asm/scatterlist.h>
+
+#include <linux/ppp_defs.h>
+#include <linux/ppp-comp.h>
+
+static void
+setup_sg(struct scatterlist *sg, const void *address, unsigned int length)
+{
+	sg[0].page =3D virt_to_page(address);
+	sg[0].offset =3D offset_in_page(address);
+
+	if (sg[0].offset + length <=3D PAGE_SIZE) {
+		sg[0].length =3D length;
+		sg[1].page =3D 0;
+		sg[1].offset =3D 0;
+		sg[1].length =3D 0;
+	} else {
+		sg[0].length =3D PAGE_SIZE - sg[0].offset;
+		sg[1].length =3D length - sg[0].length;
+		sg[1].page =3D virt_to_page(address + sg[0].length);
+		sg[1].offset =3D offset_in_page(address + sg[0].length);	/* 0 */
+	}
+}
+
+/*
+ * State for an MPPE (de)compressor.
+ */
+typedef struct ppp_mppe_state {
+	struct crypto_tfm *arc4;
+	struct crypto_tfm *sha1;
+	unsigned char *sha1_digest;
+	unsigned char master_key[MPPE_MAX_KEY_LEN];
+	unsigned char session_key[MPPE_MAX_KEY_LEN];
+	unsigned keylen;	/* key length in bytes             */
+	/* NB: 128-bit =3D=3D 16, 40-bit =3D=3D 8! */
+	/* If we want to support 56-bit,   */
+	/* the unit has to change to bits  */
+	unsigned char bits;	/* MPPE control bits */
+	unsigned ccount;	/* 12-bit coherency count (seqno)  */
+	unsigned stateful;	/* stateful mode flag */
+	int discard;		/* stateful mode packet loss flag */
+	int sanity_errors;	/* take down LCP if too many */
+	int unit;
+	int debug;
+	struct compstat stats;
+} ppp_mppe_state;
+
+/* ppp_mppe_state.bits definitions */
+#define MPPE_BIT_A	0x80	/* Encryption table were (re)inititalized */
+#define MPPE_BIT_B	0x40	/* MPPC only (not implemented) */
+#define MPPE_BIT_C	0x20	/* MPPC only (not implemented) */
+#define MPPE_BIT_D	0x10	/* This is an encrypted frame */
+
+#define MPPE_BIT_FLUSHED	MPPE_BIT_A
+#define MPPE_BIT_ENCRYPTED	MPPE_BIT_D
+
+#define MPPE_BITS(p) ((p)[4] & 0xf0)
+#define MPPE_CCOUNT(p) ((((p)[4] & 0x0f) << 8) + (p)[5])
+#define MPPE_CCOUNT_SPACE 0x1000	/* The size of the ccount space */
+
+#define MPPE_OVHD	2	/* MPPE overhead/packet */
+#define SANITY_MAX	1600	/* Max bogon factor we will tolerate */
+
+#define SHA1_PAD_SIZE 40
+/*
+ * Key Derivation, from RFC 3078, RFC 3079.
+ * Equivalent to Get_Key() for MS-CHAP as described in RFC 3079.
+ */
+static void GetNewKeyFromSHA(ppp_mppe_state * state, unsigned char *Interi=
mKey)
+{
+	static const unsigned char SHApad1[SHA1_PAD_SIZE] =3D
+	    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
+	};
+	static const unsigned char SHApad2[SHA1_PAD_SIZE] =3D
+	    { 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2,
+		0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2,
+		0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2,
+		0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2
+	};
+	struct scatterlist sg[2];
+
+	crypto_digest_init(state->sha1);
+	setup_sg(sg, state->master_key, state->keylen);
+	crypto_digest_update(state->sha1, sg, state->keylen);
+	setup_sg(sg, SHApad1, sizeof(SHApad1));
+	crypto_digest_update(state->sha1, sg, sizeof(SHApad1));
+	setup_sg(sg, state->session_key, state->keylen);
+	crypto_digest_update(state->sha1, sg, state->keylen);
+	setup_sg(sg, SHApad2, sizeof(SHApad2));
+	crypto_digest_update(state->sha1, sg, sizeof(SHApad2));
+	crypto_digest_final(state->sha1, state->sha1_digest);
+	memcpy(InterimKey, state->sha1_digest, state->keylen);
+}
+
+/*
+ * Perform the MPPE rekey algorithm, from RFC 3078, sec. 7.3.
+ * Well, not what's written there, but rather what they meant.
+ */
+static void mppe_rekey(ppp_mppe_state * state, int initial_key)
+{
+	unsigned char InterimKey[MPPE_MAX_KEY_LEN];
+	struct scatterlist sg_in[2], sg_out[2];
+
+	GetNewKeyFromSHA(state, InterimKey);
+	if (!initial_key) {
+		crypto_cipher_setkey(state->arc4, InterimKey, state->keylen);
+		setup_sg(sg_in, InterimKey, state->keylen);
+		setup_sg(sg_out, state->session_key, state->keylen);
+		crypto_cipher_encrypt(state->arc4, sg_out, sg_in,
+				      state->keylen);
+	} else {
+		memcpy(state->session_key, InterimKey, state->keylen);
+	}
+	if (state->keylen =3D=3D 8) {
+		/* See RFC 3078 */
+		state->session_key[0] =3D 0xd1;
+		state->session_key[1] =3D 0x26;
+		state->session_key[2] =3D 0x9e;
+	}
+	crypto_cipher_setkey(state->arc4, state->session_key, state->keylen);
+}
+
+/*
+ * Allocate space for a (de)compressor.
+ */
+static void *mppe_alloc(unsigned char *options, int optlen)
+{
+	ppp_mppe_state *state;
+	unsigned int digestsize;
+
+	if (optlen !=3D CILEN_MPPE + sizeof(state->master_key)
+	    || options[0] !=3D CI_MPPE || options[1] !=3D CILEN_MPPE)
+		goto out;
+
+	state =3D (ppp_mppe_state *) kmalloc(sizeof(*state), GFP_KERNEL);
+	if (state =3D=3D NULL)
+		goto out;
+
+	memset(state, 0, sizeof(*state));
+
+	state->arc4 =3D crypto_alloc_tfm("arc4", 0);
+	if (!state->arc4)
+		goto out_free;
+	state->sha1 =3D crypto_alloc_tfm("sha1", 0);
+	if (!state->sha1)
+		goto out_arc4;
+	digestsize =3D crypto_tfm_alg_digestsize(state->sha1);
+	if (digestsize < MPPE_MAX_KEY_LEN)
+		goto out_sha1;
+	state->sha1_digest =3D kmalloc(digestsize, GFP_KERNEL);
+	if (!state->sha1_digest)
+		goto out_sha1;
+
+	/* Save keys. */
+	memcpy(state->master_key, &options[CILEN_MPPE],
+	       sizeof(state->master_key));
+	memcpy(state->session_key, state->master_key,
+	       sizeof(state->master_key));
+	/*
+	 * We defer initial key generation until mppe_init(), as mppe_alloc()
+	 * is called frequently during negotiation.
+	 */
+
+	return (void *)state;
+
+      out_sha1:
+	crypto_free_tfm(state->sha1);
+      out_arc4:
+	crypto_free_tfm(state->arc4);
+      out_free:
+	kfree(state);
+      out:
+	return NULL;
+}
+
+/*
+ * Deallocate space for a (de)compressor.
+ */
+static void mppe_free(void *arg)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+
+	if (state) {
+		if (state->arc4)
+			crypto_free_tfm(state->arc4);
+		if (state->sha1)
+			crypto_free_tfm(state->sha1);
+		if (state->sha1_digest)
+			kfree(state->sha1_digest);
+		kfree(state);
+	}
+}
+
+/*=20
+ * Initialize (de)compressor state.
+ */
+static int
+mppe_init(void *arg, unsigned char *options, int optlen, int unit, int deb=
ug,
+	  const char *debugstr)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+	unsigned char mppe_opts;
+
+	if (optlen !=3D CILEN_MPPE
+	    || options[0] !=3D CI_MPPE || options[1] !=3D CILEN_MPPE)
+		return 0;
+
+	MPPE_CI_TO_OPTS(&options[2], mppe_opts);
+	if (mppe_opts & MPPE_OPT_128)
+		state->keylen =3D 16;
+	else if (mppe_opts & MPPE_OPT_40)
+		state->keylen =3D 8;
+	else {
+		printk(KERN_WARNING "%s[%d]: unknown key length\n", debugstr,
+		       unit);
+		return 0;
+	}
+	if (mppe_opts & MPPE_OPT_STATEFUL)
+		state->stateful =3D 1;
+
+	/* Generate the initial session key. */
+	mppe_rekey(state, 1);
+
+	if (debug) {
+		int i;
+		char mkey[sizeof(state->master_key) * 2 + 1];
+		char skey[sizeof(state->session_key) * 2 + 1];
+
+		printk(KERN_DEBUG "%s[%d]: initialized with %d-bit %s mode\n",
+		       debugstr, unit, (state->keylen =3D=3D 16) ? 128 : 40,
+		       (state->stateful) ? "stateful" : "stateless");
+
+		for (i =3D 0; i < sizeof(state->master_key); i++)
+			sprintf(mkey + i * 2, "%.2x", state->master_key[i]);
+		for (i =3D 0; i < sizeof(state->session_key); i++)
+			sprintf(skey + i * 2, "%.2x", state->session_key[i]);
+		printk(KERN_DEBUG
+		       "%s[%d]: keys: master: %s initial session: %s\n",
+		       debugstr, unit, mkey, skey);
+	}
+
+	/*
+	 * Initialize the coherency count.  The initial value is not specified
+	 * in RFC 3078, but we can make a reasonable assumption that it will
+	 * start at 0.  Setting it to the max here makes the comp/decomp code
+	 * do the right thing (determined through experiment).
+	 */
+	state->ccount =3D MPPE_CCOUNT_SPACE - 1;
+
+	/*
+	 * Note that even though we have initialized the key table, we don't
+	 * set the FLUSHED bit.  This is contrary to RFC 3078, sec. 3.1.
+	 */
+	state->bits =3D MPPE_BIT_ENCRYPTED;
+
+	state->unit =3D unit;
+	state->debug =3D debug;
+
+	return 1;
+}
+
+static int
+mppe_comp_init(void *arg, unsigned char *options, int optlen, int unit,
+	       int hdrlen, int debug)
+{
+	/* ARGSUSED */
+	return mppe_init(arg, options, optlen, unit, debug, "mppe_comp_init");
+}
+
+/*
+ * We received a CCP Reset-Request (actually, we are sending a Reset-Ack),
+ * tell the compressor to rekey.  Note that we MUST NOT rekey for
+ * every CCP Reset-Request; we only rekey on the next xmit packet.
+ * We might get multiple CCP Reset-Requests if our CCP Reset-Ack is lost.
+ * So, rekeying for every CCP Reset-Request is broken as the peer will not
+ * know how many times we've rekeyed.  (If we rekey and THEN get another
+ * CCP Reset-Request, we must rekey again.)
+ */
+static void mppe_comp_reset(void *arg)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+
+	state->bits |=3D MPPE_BIT_FLUSHED;
+}
+
+/*
+ * Compress (encrypt) a packet.
+ * It's strange to call this a compressor, since the output is always
+ * MPPE_OVHD + 2 bytes larger than the input.
+ */
+int
+mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
+	      int isize, int osize)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+	int proto;
+	struct scatterlist sg_in[2], sg_out[2];
+
+	/*
+	 * Check that the protocol is in the range we handle.
+	 */
+	proto =3D PPP_PROTOCOL(ibuf);
+	if (proto < 0x0021 || proto > 0x00fa)
+		return 0;
+
+	/* Make sure we have enough room to generate an encrypted packet. */
+	if (osize < isize + MPPE_OVHD + 2) {
+		/* Drop the packet if we should encrypt it, but can't. */
+		printk(KERN_DEBUG "mppe_compress[%d]: osize too small! "
+		       "(have: %d need: %d)\n", state->unit,
+		       osize, osize + MPPE_OVHD + 2);
+		return -1;
+	}
+
+	osize =3D isize + MPPE_OVHD + 2;
+
+	/*
+	 * Copy over the PPP header and set control bits.
+	 */
+	obuf[0] =3D PPP_ADDRESS(ibuf);
+	obuf[1] =3D PPP_CONTROL(ibuf);
+	obuf[2] =3D PPP_COMP >> 8;	/* isize + MPPE_OVHD + 1 */
+	obuf[3] =3D PPP_COMP;	/* isize + MPPE_OVHD + 2 */
+	obuf +=3D PPP_HDRLEN;
+
+	state->ccount =3D (state->ccount + 1) % MPPE_CCOUNT_SPACE;
+	if (state->debug >=3D 7)
+		printk(KERN_DEBUG "mppe_compress[%d]: ccount %d\n", state->unit,
+		       state->ccount);
+	obuf[0] =3D state->ccount >> 8;
+	obuf[1] =3D state->ccount & 0xff;
+
+	if (!state->stateful ||	/* stateless mode     */
+	    ((state->ccount & 0xff) =3D=3D 0xff) ||	/* "flag" packet      */
+	    (state->bits & MPPE_BIT_FLUSHED)) {	/* CCP Reset-Request  */
+		/* We must rekey */
+		if (state->debug && state->stateful)
+			printk(KERN_DEBUG "mppe_compress[%d]: rekeying\n",
+			       state->unit);
+		mppe_rekey(state, 0);
+		state->bits |=3D MPPE_BIT_FLUSHED;
+	}
+	obuf[0] |=3D state->bits;
+	state->bits &=3D ~MPPE_BIT_FLUSHED;	/* reset for next xmit */
+
+	obuf +=3D MPPE_OVHD;
+	ibuf +=3D 2;		/* skip to proto field */
+	isize -=3D 2;
+
+	/* Encrypt packet */
+	setup_sg(sg_in, ibuf, isize);
+	setup_sg(sg_out, obuf, osize);
+	crypto_cipher_encrypt(state->arc4, sg_out, sg_in, isize);
+
+	state->stats.unc_bytes +=3D isize;
+	state->stats.unc_packets++;
+	state->stats.comp_bytes +=3D osize;
+	state->stats.comp_packets++;
+
+	return osize;
+}
+
+/*
+ * Since every frame grows by MPPE_OVHD + 2 bytes, this is always going
+ * to look bad ... and the longer the link is up the worse it will get.
+ */
+static void mppe_comp_stats(void *arg, struct compstat *stats)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+
+	*stats =3D state->stats;
+}
+
+static int
+mppe_decomp_init(void *arg, unsigned char *options, int optlen, int unit,
+		 int hdrlen, int mru, int debug)
+{
+	/* ARGSUSED */
+	return mppe_init(arg, options, optlen, unit, debug, "mppe_decomp_init");
+}
+
+/*
+ * We received a CCP Reset-Ack.  Just ignore it.
+ */
+static void mppe_decomp_reset(void *arg)
+{
+	/* ARGSUSED */
+	return;
+}
+
+/*
+ * Decompress (decrypt) an MPPE packet.
+ */
+int
+mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *=
obuf,
+		int osize)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+	unsigned ccount;
+	int flushed =3D MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
+	int sanity =3D 0;
+	struct scatterlist sg_in[2], sg_out[2];
+
+	if (isize <=3D PPP_HDRLEN + MPPE_OVHD) {
+		if (state->debug)
+			printk(KERN_DEBUG
+			       "mppe_decompress[%d]: short pkt (%d)\n",
+			       state->unit, isize);
+		return DECOMP_ERROR;
+	}
+
+	/*
+	 * Make sure we have enough room to decrypt the packet.
+	 * Note that for our test we only subtract 1 byte whereas in
+	 * mppe_compress() we added 2 bytes (+MPPE_OVHD);
+	 * this is to account for possible PFC.
+	 */
+	if (osize < isize - MPPE_OVHD - 1) {
+		printk(KERN_DEBUG "mppe_decompress[%d]: osize too small! "
+		       "(have: %d need: %d)\n", state->unit,
+		       osize, isize - MPPE_OVHD - 1);
+		return DECOMP_ERROR;
+	}
+	osize =3D isize - MPPE_OVHD - 2;	/* assume no PFC */
+
+	ccount =3D MPPE_CCOUNT(ibuf);
+	if (state->debug >=3D 7)
+		printk(KERN_DEBUG "mppe_decompress[%d]: ccount %d\n",
+		       state->unit, ccount);
+
+	/* sanity checks -- terminate with extreme prejudice */
+	if (!(MPPE_BITS(ibuf) & MPPE_BIT_ENCRYPTED)) {
+		printk(KERN_DEBUG
+		       "mppe_decompress[%d]: ENCRYPTED bit not set!\n",
+		       state->unit);
+		state->sanity_errors +=3D 100;
+		sanity =3D 1;
+	}
+	if (!state->stateful && !flushed) {
+		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set in "
+		       "stateless mode!\n", state->unit);
+		state->sanity_errors +=3D 100;
+		sanity =3D 1;
+	}
+	if (state->stateful && ((ccount & 0xff) =3D=3D 0xff) && !flushed) {
+		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set on "
+		       "flag packet!\n", state->unit);
+		state->sanity_errors +=3D 100;
+		sanity =3D 1;
+	}
+
+	if (sanity) {
+		if (state->sanity_errors < SANITY_MAX)
+			return DECOMP_ERROR;
+		else
+			/*
+			 * Take LCP down if the peer is sending too many bogons.
+			 * We don't want to do this for a single or just a few
+			 * instances since it could just be due to packet corruption.
+			 */
+			return DECOMP_FATALERROR;
+	}
+
+	/*
+	 * Check the coherency count.
+	 */
+
+	if (!state->stateful) {
+		/* RFC 3078, sec 8.1.  Rekey for every packet. */
+		while (state->ccount !=3D ccount) {
+			mppe_rekey(state, 0);
+			state->ccount =3D (state->ccount + 1) % MPPE_CCOUNT_SPACE;
+		}
+	} else {
+		/* RFC 3078, sec 8.2. */
+		if (!state->discard) {
+			/* normal state */
+			state->ccount =3D (state->ccount + 1) % MPPE_CCOUNT_SPACE;
+			if (ccount !=3D state->ccount) {
+				/*
+				 * (ccount > state->ccount)
+				 * Packet loss detected, enter the discard state.
+				 * Signal the peer to rekey (by sending a CCP Reset-Request).
+				 */
+				state->discard =3D 1;
+				return DECOMP_ERROR;
+			}
+		} else {
+			/* discard state */
+			if (!flushed) {
+				/* ccp.c will be silent (no additional CCP Reset-Requests). */
+				return DECOMP_ERROR;
+			} else {
+				/* Rekey for every missed "flag" packet. */
+				while ((ccount & ~0xff) !=3D
+				       (state->ccount & ~0xff)) {
+					mppe_rekey(state, 0);
+					state->ccount =3D
+					    (state->ccount +
+					     256) % MPPE_CCOUNT_SPACE;
+				}
+
+				/* reset */
+				state->discard =3D 0;
+				state->ccount =3D ccount;
+				/*
+				 * Another problem with RFC 3078 here.  It implies that the
+				 * peer need not send a Reset-Ack packet.  But RFC 1962
+				 * requires it.  Hopefully, M$ does send a Reset-Ack; even
+				 * though it isn't required for MPPE synchronization, it is
+				 * required to reset CCP state.
+				 */
+			}
+		}
+		if (flushed)
+			mppe_rekey(state, 0);
+	}
+
+	/*
+	 * Fill in the first part of the PPP header.  The protocol field
+	 * comes from the decrypted data.
+	 */
+	obuf[0] =3D PPP_ADDRESS(ibuf);	/* +1 */
+	obuf[1] =3D PPP_CONTROL(ibuf);	/* +1 */
+	obuf +=3D 2;
+	ibuf +=3D PPP_HDRLEN + MPPE_OVHD;
+	isize -=3D PPP_HDRLEN + MPPE_OVHD;	/* -6 */
+	/* net osize: isize-4 */
+
+	/*
+	 * Decrypt the first byte in order to check if it is
+	 * a compressed or uncompressed protocol field.
+	 */
+	setup_sg(sg_in, ibuf, 1);
+	setup_sg(sg_out, obuf, 1);
+	crypto_cipher_decrypt(state->arc4, sg_out, sg_in, 1);
+
+	/*
+	 * Do PFC decompression.
+	 * This would be nicer if we were given the actual sk_buff
+	 * instead of a char *.
+	 */
+	if ((obuf[0] & 0x01) !=3D 0) {
+		obuf[1] =3D obuf[0];
+		obuf[0] =3D 0;
+		obuf++;
+		osize++;
+	}
+
+	/* And finally, decrypt the rest of the packet. */
+	setup_sg(sg_in, ibuf + 1, isize - 1);
+	setup_sg(sg_out, obuf + 1, osize - 1);
+	crypto_cipher_decrypt(state->arc4, sg_out, sg_in, isize - 1);
+
+	state->stats.unc_bytes +=3D osize;
+	state->stats.unc_packets++;
+	state->stats.comp_bytes +=3D isize;
+	state->stats.comp_packets++;
+
+	/* good packet credit */
+	state->sanity_errors >>=3D 1;
+
+	return osize;
+}
+
+/*
+ * Incompressible data has arrived (this should never happen!).
+ * We should probably drop the link if the protocol is in the range
+ * of what should be encrypted.  At the least, we should drop this
+ * packet.  (How to do this?)
+ */
+static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
+{
+	ppp_mppe_state *state =3D (ppp_mppe_state *) arg;
+
+	if (state->debug &&
+	    (PPP_PROTOCOL(ibuf) >=3D 0x0021 && PPP_PROTOCOL(ibuf) <=3D 0x00fa))
+		printk(KERN_DEBUG
+		       "mppe_incomp[%d]: incompressible (unencrypted) data! "
+		       "(proto %04x)\n", state->unit, PPP_PROTOCOL(ibuf));
+
+	state->stats.inc_bytes +=3D icnt;
+	state->stats.inc_packets++;
+	state->stats.unc_bytes +=3D icnt;
+	state->stats.unc_packets++;
+}
+
+/*************************************************************
+ * Module interface table
+ *************************************************************/
+
+/*
+ * Procedures exported to if_ppp.c.
+ */
+struct compressor ppp_mppe =3D {
+	CI_MPPE,		/* compress_proto */
+	mppe_alloc,		/* comp_alloc */
+	mppe_free,		/* comp_free */
+	mppe_comp_init,		/* comp_init */
+	mppe_comp_reset,	/* comp_reset */
+	mppe_compress,		/* compress */
+	mppe_comp_stats,	/* comp_stat */
+	mppe_alloc,		/* decomp_alloc */
+	mppe_free,		/* decomp_free */
+	mppe_decomp_init,	/* decomp_init */
+	mppe_decomp_reset,	/* decomp_reset */
+	mppe_decompress,	/* decompress */
+	mppe_incomp,		/* incomp */
+	mppe_comp_stats,	/* decomp_stat */
+};
+
+/*
+ * ppp_mppe_init()
+ *
+ * Prior to allowing load, try to load the arc4 and sha1 crypto
+ * libraries.  The actual use will be allocated later, but
+ * this way the module will fail to insmod if they aren't available.
+ */
+
+int __init ppp_mppe_init(void)
+{
+	if (!(crypto_alg_available("arc4", 0) &&
+	      crypto_alg_available("sha1", 0)))
+		return -ENODEV;
+
+	int answer =3D ppp_register_compressor(&ppp_mppe);
+
+	if (answer =3D=3D 0)
+		printk(KERN_INFO "PPP MPPE Compression module registered\n");
+	return answer;
+}
+
+void __exit ppp_mppe_cleanup(void)
+{
+	ppp_unregister_compressor(&ppp_mppe);
+}
+
+module_init(ppp_mppe_init);
+module_exit(ppp_mppe_cleanup);
+MODULE_LICENSE("Dual BSD/GPL");

--NGIwU0kFl1Z1A3An
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFA0xQMIavu95Lw/AkRApzJAJ9tGLqCIY1ZUGU09OVlWdCVi/trxQCfe/y5
pW0liK7Ato42siXYqxVwn7o=
=U9j0
-----END PGP SIGNATURE-----

--NGIwU0kFl1Z1A3An--
