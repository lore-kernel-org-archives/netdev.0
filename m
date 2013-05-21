From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [RFC PATCH v2 3/4] ppp_mppe: cleanup kernel log messages
Date: Tue, 21 May 2013 20:18:23 +0200
Message-ID: <1369160304-31967-3-git-send-email-jorge@dti2.net>
References: <1369160304-31967-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369160304-31967-1-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

- Consolidate log messages, print PPP unit number where available.
- Changes error or warning messages to correct log level.
- Use _ratelimited() functions for messages triggered by network packets.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 drivers/net/ppp/ppp_mppe.c |   78 +++++++++++++++++++++++---------------------
 1 file changed, 41 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 97f4804..54c64cf 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -178,7 +178,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 		setup_sg(sg_out, state->session_key, state->keylen);
 		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
 					     state->keylen) != 0) {
-    		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
+			net_warn_ratelimited("%s[%d]: crypto_blkcipher_encrypt "
+					     "failed\n", __func__, state->unit);
 		}
 	} else {
 		memcpy(state->session_key, state->sha1_digest, state->keylen);
@@ -291,8 +292,7 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 	else if (mppe_opts & MPPE_OPT_40)
 		state->keylen = 8;
 	else {
-		printk(KERN_WARNING "%s[%d]: unknown key length\n", debugstr,
-		       unit);
+		pr_warn("%s[%d]: unknown key length\n", debugstr, unit);
 		return 0;
 	}
 	if (mppe_opts & MPPE_OPT_STATEFUL)
@@ -314,8 +314,7 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 			sprintf(mkey + i * 2, "%02x", state->master_key[i]);
 		for (i = 0; i < sizeof(state->session_key); i++)
 			sprintf(skey + i * 2, "%02x", state->session_key[i]);
-		printk(KERN_DEBUG
-		       "%s[%d]: keys: master: %s initial session: %s\n",
+		printk(KERN_DEBUG "%s[%d]: keys: master: %s initial session: %s\n",
 		       debugstr, unit, mkey, skey);
 	}
 
@@ -387,9 +386,9 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	/* Make sure we have enough room to generate an encrypted packet. */
 	if (osize < isize + MPPE_OVHD + 2) {
 		/* Drop the packet if we should encrypt it, but can't. */
-		printk(KERN_DEBUG "mppe_compress[%d]: osize too small! "
-		       "(have: %d need: %d)\n", state->unit,
-		       osize, osize + MPPE_OVHD + 2);
+		net_err_ratelimited("%s[%d]: osize too small! "
+				    "(have: %d need: %d)\n", __func__,
+				    state->unit, osize, isize + MPPE_OVHD + 2);
 		return -1;
 	}
 
@@ -405,7 +404,7 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 
 	state->ccount = (state->ccount + 1) % MPPE_CCOUNT_SPACE;
 	if (state->debug >= 7)
-		printk(KERN_DEBUG "mppe_compress[%d]: ccount %d\n", state->unit,
+		printk(KERN_DEBUG "%s[%d]: ccount %d\n", __func__, state->unit,
 		       state->ccount);
 	put_unaligned_be16(state->ccount, obuf);
 
@@ -414,7 +413,7 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	    (state->bits & MPPE_BIT_FLUSHED)) {	/* CCP Reset-Request  */
 		/* We must rekey */
 		if (state->debug && state->stateful)
-			printk(KERN_DEBUG "mppe_compress[%d]: rekeying\n",
+			printk(KERN_DEBUG "%s[%d]: rekeying\n", __func__,
 			       state->unit);
 		mppe_rekey(state, 0);
 		state->bits |= MPPE_BIT_FLUSHED;
@@ -432,7 +431,8 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	setup_sg(sg_in, ibuf, isize);
 	setup_sg(sg_out, obuf, osize);
 	if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in, isize) != 0) {
-		printk(KERN_DEBUG "crypto_cypher_encrypt failed\n");
+		net_err_ratelimited("%s[%d]: crypto_blkcipher_encrypt failed\n",
+				    __func__, state->unit);
 		return -1;
 	}
 
@@ -496,9 +496,8 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 
 	if (isize <= PPP_HDRLEN + MPPE_OVHD) {
 		if (state->debug)
-			printk(KERN_DEBUG
-			       "mppe_decompress[%d]: short pkt (%d)\n",
-			       state->unit, isize);
+			printk(KERN_DEBUG "%s[%d]: short pkt (%d)\n",
+			       __func__, state->unit, isize);
 		return DECOMP_ERROR;
 	}
 
@@ -509,35 +508,36 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	 * this is to account for possible PFC.
 	 */
 	if (osize < isize - MPPE_OVHD - 1) {
-		printk(KERN_DEBUG "mppe_decompress[%d]: osize too small! "
-		       "(have: %d need: %d)\n", state->unit,
-		       osize, isize - MPPE_OVHD - 1);
+		net_warn_ratelimited("%s[%d]: osize too small! "
+				     "(have: %d need: %d)\n", __func__,
+				     state->unit, osize, isize - MPPE_OVHD - 1);
 		return DECOMP_ERROR;
 	}
 	osize = isize - MPPE_OVHD - 2;	/* assume no PFC */
 
 	ccount = MPPE_CCOUNT(ibuf);
 	if (state->debug >= 7)
-		printk(KERN_DEBUG "mppe_decompress[%d]: ccount %d\n",
-		       state->unit, ccount);
+		printk(KERN_DEBUG "%s[%d]: ccount %d\n", __func__, state->unit,
+		       ccount);
 
 	/* sanity checks -- terminate with extreme prejudice */
 	if (!(MPPE_BITS(ibuf) & MPPE_BIT_ENCRYPTED)) {
-		printk(KERN_DEBUG
-		       "mppe_decompress[%d]: ENCRYPTED bit not set!\n",
-		       state->unit);
+		net_warn_ratelimited("%s[%d]: ENCRYPTED bit not set!\n",
+				     __func__, state->unit);
 		state->sanity_errors += 100;
 		sanity = 1;
 	}
 	if (!state->stateful && !flushed) {
-		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set in "
-		       "stateless mode!\n", state->unit);
+		net_warn_ratelimited("%s[%d]: FLUSHED bit not set "
+				     "in stateless mode!\n", __func__,
+				     state->unit);
 		state->sanity_errors += 100;
 		sanity = 1;
 	}
 	if (state->stateful && ((ccount & 0xff) == 0xff) && !flushed) {
-		printk(KERN_DEBUG "mppe_decompress[%d]: FLUSHED bit not set on "
-		       "flag packet!\n", state->unit);
+		net_warn_ratelimited("%s[%d]: FLUSHED bit not set "
+				     "on flag packet!\n", __func__,
+				     state->unit);
 		state->sanity_errors += 100;
 		sanity = 1;
 	}
@@ -560,11 +560,11 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 
 	if (!state->stateful) {
 		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "%s[%d]: Dropping out-of-order "
-				       "packet with ccount %u, "
-				       "expecting %u!\n", __func__,
-				       state->unit, ccount, state->ccount);
+			net_warn_ratelimited("%s[%d]: Dropping out-of-order "
+					     "packet with ccount %u, "
+					     "expecting %u!\n", __func__,
+					     state->unit, ccount,
+					     state->ccount);
 			return DECOMP_DROPERROR;
 		}
 
@@ -638,7 +638,9 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	setup_sg(sg_in, ibuf, 1);
 	setup_sg(sg_out, obuf, 1);
 	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, 1) != 0) {
-		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
+		net_warn_ratelimited
+		    ("%s[%d]: crypto_blkcipher_decrypt failed\n", __func__,
+		     state->unit);
 		return DECOMP_ERROR;
 	}
 
@@ -658,7 +660,9 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	setup_sg(sg_in, ibuf + 1, isize - 1);
 	setup_sg(sg_out, obuf + 1, osize - 1);
 	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, isize - 1)) {
-		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
+		net_warn_ratelimited
+		    ("%s[%d]: crypto_blkcipher_decrypt failed\n", __func__,
+		     state->unit);
 		return DECOMP_ERROR;
 	}
 
@@ -685,9 +689,9 @@ static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
 
 	if (state->debug &&
 	    (PPP_PROTOCOL(ibuf) >= 0x0021 && PPP_PROTOCOL(ibuf) <= 0x00fa))
-		printk(KERN_DEBUG
-		       "mppe_incomp[%d]: incompressible (unencrypted) data! "
-		       "(proto %04x)\n", state->unit, PPP_PROTOCOL(ibuf));
+		printk(KERN_DEBUG "%s[%d]: incompressible (unencrypted) data! "
+		       "(proto %04x)\n", __func__, state->unit,
+		       PPP_PROTOCOL(ibuf));
 
 	state->stats.inc_bytes += icnt;
 	state->stats.inc_packets++;
@@ -744,7 +748,7 @@ static int __init ppp_mppe_init(void)
 	answer = ppp_register_compressor(&ppp_mppe);
 
 	if (answer == 0)
-		printk(KERN_INFO "PPP MPPE Compression module registered\n");
+		pr_info("PPP MPPE Compression module registered\n");
 	else
 		kfree(sha_pad);
 
-- 
1.7.10.4


