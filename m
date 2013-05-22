From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH v3 4/4] ppp_mppe: formatting and style cleanup
Date: Wed, 22 May 2013 13:32:53 +0200
Message-ID: <1369222373-7701-4-git-send-email-jorge@dti2.net>
References: <1369222373-7701-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369222373-7701-1-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

- Changes format and style to comply with networking code requirements.
- Adds include guards to ppp_mppe.h.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
Changes from v2:
- Checkpatch clean.

 drivers/net/ppp/ppp_mppe.c |  252 ++++++++++++++++++--------------------------
 drivers/net/ppp/ppp_mppe.h |   38 ++++---
 2 files changed, 124 insertions(+), 166 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 97989db..25575a0 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -68,8 +68,8 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_ALIAS("ppp-compress-" __stringify(CI_MPPE));
 MODULE_VERSION("1.0.2");
 
-static unsigned int
-setup_sg(struct scatterlist *sg, const void *address, unsigned int length)
+static unsigned int setup_sg(struct scatterlist *sg, const void *address,
+			     unsigned int length)
 {
 	sg_set_buf(sg, address, length);
 	return length;
@@ -77,11 +77,9 @@ setup_sg(struct scatterlist *sg, const void *address, unsigned int length)
 
 #define SHA1_PAD_SIZE 40
 
-/*
- * kernel crypto API needs its arguments to be in kmalloc'd memory, not in the module
- * static data area.  That means sha_pad needs to be kmalloc'd.
+/* kernel crypto API needs its arguments to be in kmalloc'd memory, not in
+ * the module static data area. That means sha_pad needs to be kmalloc'd.
  */
-
 struct sha_pad {
 	unsigned char sha_pad1[SHA1_PAD_SIZE];
 	unsigned char sha_pad2[SHA1_PAD_SIZE];
@@ -94,21 +92,20 @@ static inline void sha_pad_init(struct sha_pad *shapad)
 	memset(shapad->sha_pad2, 0xF2, sizeof(shapad->sha_pad2));
 }
 
-/*
- * State for an MPPE (de)compressor.
- */
+/* State for an MPPE (de)compressor. */
 struct ppp_mppe_state {
 	struct crypto_blkcipher *arc4;
 	struct crypto_hash *sha1;
 	unsigned char *sha1_digest;
 	unsigned char master_key[MPPE_MAX_KEY_LEN];
 	unsigned char session_key[MPPE_MAX_KEY_LEN];
-	unsigned keylen;	/* key length in bytes             */
-	/* NB: 128-bit == 16, 40-bit == 8! */
-	/* If we want to support 56-bit,   */
-	/* the unit has to change to bits  */
+	unsigned keylen;	/* key length in bytes
+				 * NB: 128-bit == 16, 40-bit == 8!
+				 * If we want to support 56-bit,
+				 * the unit has to change to bits
+				 */
 	unsigned char bits;	/* MPPE control bits */
-	unsigned ccount;	/* 12-bit coherency count (seqno)  */
+	unsigned ccount;	/* 12-bit coherency count (seqno) */
 	unsigned stateful;	/* stateful mode flag */
 	int discard;		/* stateful mode packet loss flag */
 	int sanity_errors;	/* take down LCP if too many */
@@ -136,11 +133,10 @@ struct ppp_mppe_state {
 #define MPPE_OVHD	2	/* MPPE overhead/packet */
 #define SANITY_MAX	1600	/* Max bogon factor we will tolerate */
 
-/*
- * Key Derivation, from RFC 3078, RFC 3079.
+/* Key Derivation, from RFC 3078, RFC 3079.
  * Equivalent to Get_Key() for MS-CHAP as described in RFC 3079.
  */
-static void get_new_key_from_sha(struct ppp_mppe_state * state)
+static void get_new_key_from_sha(struct ppp_mppe_state *state)
 {
 	struct hash_desc desc;
 	struct scatterlist sg[4];
@@ -161,11 +157,10 @@ static void get_new_key_from_sha(struct ppp_mppe_state * state)
 	crypto_hash_digest(&desc, sg, nbytes, state->sha1_digest);
 }
 
-/*
- * Perform the MPPE rekey algorithm, from RFC 3078, sec. 7.3.
+/* Perform the MPPE rekey algorithm, from RFC 3078, sec. 7.3.
  * Well, not what's written there, but rather what they meant.
  */
-static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
+static void mppe_rekey(struct ppp_mppe_state *state, int initial_key)
 {
 	struct scatterlist sg_in[1], sg_out[1];
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
@@ -195,9 +190,7 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 	crypto_blkcipher_setkey(state->arc4, state->session_key, state->keylen);
 }
 
-/*
- * Allocate space for a (de)compressor.
- */
+/* Allocate space for a (de)compressor. */
 static void *mppe_alloc(unsigned char *options, int optlen)
 {
 	struct ppp_mppe_state *state;
@@ -211,7 +204,6 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	if (state == NULL)
 		goto out;
 
-
 	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->arc4)) {
 		state->arc4 = NULL;
@@ -238,50 +230,42 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	memcpy(state->session_key, state->master_key,
 	       sizeof(state->master_key));
 
-	/*
-	 * We defer initial key generation until mppe_init(), as mppe_alloc()
+	/* We defer initial key generation until mppe_init(), as mppe_alloc()
 	 * is called frequently during negotiation.
 	 */
 
 	return (void *)state;
 
-	out_free:
-	    if (state->sha1_digest)
-		kfree(state->sha1_digest);
-	    if (state->sha1)
+out_free:
+	kfree(state->sha1_digest);
+	if (state->sha1)
 		crypto_free_hash(state->sha1);
-	    if (state->arc4)
+	if (state->arc4)
 		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
-	out:
+	kfree(state);
+out:
 	return NULL;
 }
 
-/*
- * Deallocate space for a (de)compressor.
- */
+/* Deallocate space for a (de)compressor. */
 static void mppe_free(void *arg)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	if (state) {
-	    if (state->sha1_digest)
 		kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
+		if (state->sha1)
+			crypto_free_hash(state->sha1);
+		if (state->arc4)
+			crypto_free_blkcipher(state->arc4);
+		kfree(state);
 	}
 }
 
-/*
- * Initialize (de)compressor state.
- */
-static int
-mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
-	  const char *debugstr)
+/* Initialize (de)compressor state. */
+static int mppe_init(void *arg, unsigned char *options, int optlen, int unit,
+		     int debug, const char *debugstr)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	unsigned char mppe_opts;
 
 	if (optlen != CILEN_MPPE ||
@@ -313,16 +297,14 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 			 (int)sizeof(state->session_key), state->session_key);
 	}
 
-	/*
-	 * Initialize the coherency count.  The initial value is not specified
+	/* Initialize the coherency count.  The initial value is not specified
 	 * in RFC 3078, but we can make a reasonable assumption that it will
 	 * start at 0.  Setting it to the max here makes the comp/decomp code
 	 * do the right thing (determined through experiment).
 	 */
 	state->ccount = MPPE_CCOUNT_SPACE - 1;
 
-	/*
-	 * Note that even though we have initialized the key table, we don't
+	/* Note that even though we have initialized the key table, we don't
 	 * set the FLUSHED bit.  This is contrary to RFC 3078, sec. 3.1.
 	 */
 	state->bits = MPPE_BIT_ENCRYPTED;
@@ -333,16 +315,14 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 	return 1;
 }
 
-static int
-mppe_comp_init(void *arg, unsigned char *options, int optlen, int unit,
-	       int hdrlen, int debug)
+static int mppe_comp_init(void *arg, unsigned char *options, int optlen,
+			  int unit, int hdrlen, int debug)
 {
 	/* ARGSUSED */
 	return mppe_init(arg, options, optlen, unit, debug, "mppe_comp_init");
 }
 
-/*
- * We received a CCP Reset-Request (actually, we are sending a Reset-Ack),
+/* We received a CCP Reset-Request (actually, we are sending a Reset-Ack),
  * tell the compressor to rekey.  Note that we MUST NOT rekey for
  * every CCP Reset-Request; we only rekey on the next xmit packet.
  * We might get multiple CCP Reset-Requests if our CCP Reset-Ack is lost.
@@ -352,28 +332,24 @@ mppe_comp_init(void *arg, unsigned char *options, int optlen, int unit,
  */
 static void mppe_comp_reset(void *arg)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	state->bits |= MPPE_BIT_FLUSHED;
 }
 
-/*
- * Compress (encrypt) a packet.
+/* Compress (encrypt) a packet.
  * It's strange to call this a compressor, since the output is always
  * MPPE_OVHD + 2 bytes larger than the input.
  */
-static int
-mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
-	      int isize, int osize)
+static int mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
+			 int isize, int osize)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	int proto;
 	struct scatterlist sg_in[1], sg_out[1];
 
-	/*
-	 * Check that the protocol is in the range we handle.
-	 */
+	/* Check that the protocol is in the range we handle. */
 	proto = PPP_PROTOCOL(ibuf);
 	if (proto < 0x0021 || proto > 0x00fa)
 		return 0;
@@ -389,9 +365,7 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 
 	osize = isize + MPPE_OVHD + 2;
 
-	/*
-	 * Copy over the PPP header and set control bits.
-	 */
+	/* Copy over the PPP header and set control bits. */
 	obuf[0] = PPP_ADDRESS(ibuf);
 	obuf[1] = PPP_CONTROL(ibuf);
 	put_unaligned_be16(PPP_COMP, obuf + 2);
@@ -403,9 +377,9 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 			 state->ccount);
 	put_unaligned_be16(state->ccount, obuf);
 
-	if (!state->stateful ||	/* stateless mode     */
-	    ((state->ccount & 0xff) == 0xff) ||	/* "flag" packet      */
-	    (state->bits & MPPE_BIT_FLUSHED)) {	/* CCP Reset-Request  */
+	if (!state->stateful ||	/* stateless mode */
+	    ((state->ccount & 0xff) == 0xff) ||	/* "flag" packet */
+	    (state->bits & MPPE_BIT_FLUSHED)) {	/* CCP Reset-Request */
 		/* We must rekey */
 		if (state->debug && state->stateful)
 			pr_debug("%s[%d]: rekeying\n", __func__, state->unit);
@@ -438,28 +412,24 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	return osize;
 }
 
-/*
- * Since every frame grows by MPPE_OVHD + 2 bytes, this is always going
- * to look bad ... and the longer the link is up the worse it will get.
+/* Since every frame grows by MPPE_OVHD + 2 bytes, this is always going
+ * to look bad... and the longer the link is up the worse it will get.
  */
 static void mppe_comp_stats(void *arg, struct compstat *stats)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	*stats = state->stats;
 }
 
-static int
-mppe_decomp_init(void *arg, unsigned char *options, int optlen, int unit,
-		 int hdrlen, int mru, int debug)
+static int mppe_decomp_init(void *arg, unsigned char *options, int optlen,
+			    int unit, int hdrlen, int mru, int debug)
 {
 	/* ARGSUSED */
 	return mppe_init(arg, options, optlen, unit, debug, "mppe_decomp_init");
 }
 
-/*
- * We received a CCP Reset-Ack.  Just ignore it.
- */
+/* We received a CCP Reset-Ack. Just ignore it. */
 static void mppe_decomp_reset(void *arg)
 {
 	/* ARGSUSED */
@@ -472,14 +442,11 @@ static int mppe_cmp_ccount(unsigned int a, unsigned int b)
 	return (int)((a << MPPE_CCOUNT_SHIFT) - (b << MPPE_CCOUNT_SHIFT));
 }
 
-/*
- * Decompress (decrypt) an MPPE packet.
- */
-static int
-mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
-		int osize)
+/* Decompress (decrypt) an MPPE packet. */
+static int mppe_decompress(void *arg, unsigned char *ibuf, int isize,
+			   unsigned char *obuf, int osize)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	unsigned ccount;
 	int flushed = MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
@@ -493,8 +460,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 		return DECOMP_ERROR;
 	}
 
-	/*
-	 * Make sure we have enough room to decrypt the packet.
+	/* Make sure we have enough room to decrypt the packet.
 	 * Note that for our test we only subtract 1 byte whereas in
 	 * mppe_compress() we added 2 bytes (+MPPE_OVHD);
 	 * this is to account for possible PFC.
@@ -534,19 +500,15 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	if (sanity) {
 		if (state->sanity_errors < SANITY_MAX)
 			return DECOMP_ERROR;
-		else
-			/*
-			 * Take LCP down if the peer is sending too many bogons.
-			 * We don't want to do this for a single or just a few
-			 * instances since it could just be due to packet corruption.
-			 */
-			return DECOMP_FATALERROR;
-	}
 
-	/*
-	 * Check the coherency count.
-	 */
+		/* Take LCP down if the peer is sending too many bogons.
+		 * We don't want to do this for a single or just a few
+		 * instances since it could just be due to packet corruption.
+		 */
+		return DECOMP_FATALERROR;
+	}
 
+	/* Check the coherency count. */
 	if (!state->stateful) {
 		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
 			net_warn_ratelimited("%s[%d]: Dropping out-of-order packet with ccount %u, expecting %u!\n",
@@ -566,8 +528,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 			/* normal state */
 			state->ccount = (state->ccount + 1) % MPPE_CCOUNT_SPACE;
 			if (ccount != state->ccount) {
-				/*
-				 * (ccount > state->ccount)
+				/* (ccount > state->ccount)
 				 * Packet loss detected, enter the discard state.
 				 * Signal the peer to rekey (by sending a CCP Reset-Request).
 				 */
@@ -577,7 +538,9 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 		} else {
 			/* discard state */
 			if (!flushed) {
-				/* ccp.c will be silent (no additional CCP Reset-Requests). */
+				/* ccp.c will be silent (no additional CCP
+				 * Reset-Requests).
+				 */
 				return DECOMP_ERROR;
 			} else {
 				/* Rekey for every missed "flag" packet. */
@@ -592,12 +555,13 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 				/* reset */
 				state->discard = 0;
 				state->ccount = ccount;
-				/*
-				 * Another problem with RFC 3078 here.  It implies that the
-				 * peer need not send a Reset-Ack packet.  But RFC 1962
-				 * requires it.  Hopefully, M$ does send a Reset-Ack; even
-				 * though it isn't required for MPPE synchronization, it is
-				 * required to reset CCP state.
+				/* Another problem with RFC 3078 here. It
+				 * implies that the peer need not send a
+				 * Reset-Ack packet. But RFC 1962 requires it.
+				 * Hopefully, M$ does send a Reset-Ack; even
+				 * though it isn't required for MPPE
+				 * synchronization, it is required to reset
+				 * CCP state.
 				 */
 			}
 		}
@@ -605,8 +569,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 			mppe_rekey(state, 0);
 	}
 
-	/*
-	 * Fill in the first part of the PPP header.  The protocol field
+	/* Fill in the first part of the PPP header. The protocol field
 	 * comes from the decrypted data.
 	 */
 	obuf[0] = PPP_ADDRESS(ibuf);	/* +1 */
@@ -616,8 +579,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	isize -= PPP_HDRLEN + MPPE_OVHD;	/* -6 */
 	/* net osize: isize-4 */
 
-	/*
-	 * Decrypt the first byte in order to check if it is
+	/* Decrypt the first byte in order to check if it is
 	 * a compressed or uncompressed protocol field.
 	 */
 	sg_init_table(sg_in, 1);
@@ -630,8 +592,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 		return DECOMP_ERROR;
 	}
 
-	/*
-	 * Do PFC decompression.
+	/* Do PFC decompression.
 	 * This would be nicer if we were given the actual sk_buff
 	 * instead of a char *.
 	 */
@@ -662,15 +623,14 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	return osize;
 }
 
-/*
- * Incompressible data has arrived (this should never happen!).
+/* Incompressible data has arrived (this should never happen!).
  * We should probably drop the link if the protocol is in the range
- * of what should be encrypted.  At the least, we should drop this
- * packet.  (How to do this?)
+ * of what should be encrypted. At the least, we should drop this
+ * packet. (How to do this?)
  */
 static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	if (state->debug &&
 	    (PPP_PROTOCOL(ibuf) >= 0x0021 && PPP_PROTOCOL(ibuf) <= 0x00fa))
@@ -687,36 +647,30 @@ static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
  * Module interface table
  *************************************************************/
 
-/*
- * Procedures exported to if_ppp.c.
- */
+/* Procedures exported to ppp_generic.c. */
 static struct compressor ppp_mppe = {
 	.compress_proto = CI_MPPE,
-	.comp_alloc     = mppe_alloc,
-	.comp_free      = mppe_free,
-	.comp_init      = mppe_comp_init,
-	.comp_reset     = mppe_comp_reset,
-	.compress       = mppe_compress,
-	.comp_stat      = mppe_comp_stats,
-	.decomp_alloc   = mppe_alloc,
-	.decomp_free    = mppe_free,
-	.decomp_init    = mppe_decomp_init,
-	.decomp_reset   = mppe_decomp_reset,
-	.decompress     = mppe_decompress,
-	.incomp         = mppe_incomp,
-	.decomp_stat    = mppe_comp_stats,
-	.owner          = THIS_MODULE,
-	.comp_extra     = MPPE_PAD,
+	.comp_alloc = mppe_alloc,
+	.comp_free = mppe_free,
+	.comp_init = mppe_comp_init,
+	.comp_reset = mppe_comp_reset,
+	.compress = mppe_compress,
+	.comp_stat = mppe_comp_stats,
+	.decomp_alloc = mppe_alloc,
+	.decomp_free = mppe_free,
+	.decomp_init = mppe_decomp_init,
+	.decomp_reset = mppe_decomp_reset,
+	.decompress = mppe_decompress,
+	.incomp = mppe_incomp,
+	.decomp_stat = mppe_comp_stats,
+	.owner = THIS_MODULE,
+	.comp_extra = MPPE_PAD,
 };
 
-/*
- * ppp_mppe_init()
- *
- * Prior to allowing load, try to load the arc4 and sha1 crypto
- * libraries.  The actual use will be allocated later, but
+/* Prior to allowing load, try to load the arc4 and sha1 crypto
+ * libraries. The actual use will be allocated later, but
  * this way the module will fail to insmod if they aren't available.
  */
-
 static int __init ppp_mppe_init(void)
 {
 	int answer;
diff --git a/drivers/net/ppp/ppp_mppe.h b/drivers/net/ppp/ppp_mppe.h
index 7a14e05..68a9b93 100644
--- a/drivers/net/ppp/ppp_mppe.h
+++ b/drivers/net/ppp/ppp_mppe.h
@@ -1,30 +1,32 @@
-#define MPPE_PAD                4      /* MPPE growth per frame */
-#define MPPE_MAX_KEY_LEN       16      /* largest key length (128-bit) */
+#ifndef PPP_MPPE_H
+#define PPP_MPPE_H
+
+#define MPPE_PAD                4	/* MPPE growth per frame */
+#define MPPE_MAX_KEY_LEN       16	/* largest key length (128-bit) */
 
 /* option bits for ccp_options.mppe */
-#define MPPE_OPT_40            0x01    /* 40 bit */
-#define MPPE_OPT_128           0x02    /* 128 bit */
-#define MPPE_OPT_STATEFUL      0x04    /* stateful mode */
+#define MPPE_OPT_40            0x01	/* 40 bit */
+#define MPPE_OPT_128           0x02	/* 128 bit */
+#define MPPE_OPT_STATEFUL      0x04	/* stateful mode */
 /* unsupported opts */
-#define MPPE_OPT_56            0x08    /* 56 bit */
-#define MPPE_OPT_MPPC          0x10    /* MPPC compression */
-#define MPPE_OPT_D             0x20    /* Unknown */
+#define MPPE_OPT_56            0x08	/* 56 bit */
+#define MPPE_OPT_MPPC          0x10	/* MPPC compression */
+#define MPPE_OPT_D             0x20	/* Unknown */
 #define MPPE_OPT_UNSUPPORTED (MPPE_OPT_56|MPPE_OPT_MPPC|MPPE_OPT_D)
-#define MPPE_OPT_UNKNOWN       0x40    /* Bits !defined in RFC 3078 were set */
+#define MPPE_OPT_UNKNOWN       0x40	/* Bits !defined in RFC 3078 were set */
 
-/*
- * This is not nice ... the alternative is a bitfield struct though.
+/* This is not nice... the alternative is a bitfield struct though.
  * And unfortunately, we cannot share the same bits for the option
  * names above since C and H are the same bit.  We could do a u_int32
  * but then we have to do a htonl() all the time and/or we still need
  * to know which octet is which.
  */
-#define MPPE_C_BIT             0x01    /* MPPC */
-#define MPPE_D_BIT             0x10    /* Obsolete, usage unknown */
-#define MPPE_L_BIT             0x20    /* 40-bit */
-#define MPPE_S_BIT             0x40    /* 128-bit */
-#define MPPE_M_BIT             0x80    /* 56-bit, not supported */
-#define MPPE_H_BIT             0x01    /* Stateless (in a different byte) */
+#define MPPE_C_BIT             0x01	/* MPPC */
+#define MPPE_D_BIT             0x10	/* Obsolete, usage unknown */
+#define MPPE_L_BIT             0x20	/* 40-bit */
+#define MPPE_S_BIT             0x40	/* 128-bit */
+#define MPPE_M_BIT             0x80	/* 56-bit, not supported */
+#define MPPE_H_BIT             0x01	/* Stateless (in a different byte) */
 
 /* Does not include H bit; used for least significant octet only. */
 #define MPPE_ALL_BITS (MPPE_D_BIT|MPPE_L_BIT|MPPE_S_BIT|MPPE_M_BIT|MPPE_H_BIT)
@@ -84,3 +86,5 @@
        if (ptr[3] & ~MPPE_ALL_BITS)            \
            opts |= MPPE_OPT_UNKNOWN;           \
     } while (/* CONSTCOND */ 0)
+
+#endif /* PPP_MPPE_H */
-- 
1.7.10.4


