From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Wed, 13 Nov 2002 04:04:15 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211130104.EAA09992@sex.inr.ac.ru>
References: <20021112.143636.55033627.davem@redhat.com>
Mime-Version: 1.0
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20021112.143636.55033627.davem@redhat.com> from "David S. Miller" at Nov 12, 2 02:36:36 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Applied, thanks.
>    
>    Another fix for wrongly formatted ICV for ESP will follow
>    tonight after test for interoperability with freebsd.

So, this piece is by Maxim. Bert, beware, it is required to talk
to another stacks but breaks communication with linuxes before this patch.

For log: authentication signature for MD5/SHA was not truncated to conform RFC.

Side note: well, my fault, but damn common sense requires not to break
nice good MD5 digest to some absolutely unmotivated length.

Alexey


===== net/ipv4/esp.c 1.4 vs edited =====
--- 1.4/net/ipv4/esp.c	Fri Nov  8 11:34:37 2002
+++ edited/net/ipv4/esp.c	Wed Nov 13 03:00:52 2002
@@ -190,11 +190,10 @@
 	struct crypto_tfm *tfm = esp->auth.tfm;
 	char *digest = esp->auth.work_digest;
 
-	memset(auth_data, 0, esp->auth.authlen);
  	crypto_hmac_init(tfm, esp->auth.key, &esp->auth.key_len);
 	skb_digest_walk(skb, tfm, offset, len);
 	crypto_hmac_final(tfm, esp->auth.key, &esp->auth.key_len, digest);
-	memcpy(auth_data, digest, crypto_tfm_alg_digestsize(tfm));
+	memcpy(auth_data, digest, esp->auth.authlen);
 }
 
 /* Check that skb data bits are writable. If they are not, copy data
@@ -463,16 +462,16 @@
 
 	/* If integrity check is required, do this. */
 	if (esp->auth.authlen) {
-		int icvsize = crypto_tfm_alg_digestsize(esp->auth.tfm);
-		u8 sum[icvsize];
-		u8 sum1[icvsize];
+		u8 sum[esp->auth.authlen];
+		u8 sum1[esp->auth.authlen];
 
 		esp->auth.digest(esp, skb, 0, skb->len-esp->auth.authlen, sum);
 
-		if (skb_copy_bits(skb, skb->len-esp->auth.authlen, sum1, icvsize))
+		if (skb_copy_bits(skb, skb->len-esp->auth.authlen, sum1, 
+				esp->auth.authlen))
 			BUG();
 
-		if (unlikely(memcmp(sum, sum1, icvsize))) {
+		if (unlikely(memcmp(sum, sum1, esp->auth.authlen))) {
 			x->stats.integrity_failed++;
 			goto out;
 		}
@@ -605,14 +604,20 @@
 	memset(esp, 0, sizeof(*esp));
 
 	if (x->aalg) {
+		int digestsize;
+
 		esp->auth.key = x->aalg->alg_key;
 		esp->auth.key_len = (x->aalg->alg_key_len+7)/8;
 		esp->auth.tfm = crypto_alloc_tfm(x->aalg->alg_name, 0);
 		if (esp->auth.tfm == NULL)
 			goto error;
 		esp->auth.digest = esp_hmac_digest;
-		esp->auth.authlen = crypto_tfm_alg_digestsize(esp->auth.tfm);
-		esp->auth.work_digest = kmalloc(esp->auth.authlen, GFP_KERNEL);
+		digestsize = crypto_tfm_alg_digestsize(esp->auth.tfm);
+		/* XXX RFC2403 and RFC 2404 truncate auth to 96 bit */
+		esp->auth.authlen = 12;
+		if (esp->auth.authlen > digestsize) /* XXX */
+			BUG();
+		esp->auth.work_digest = kmalloc(digestsize, GFP_KERNEL);
 		if (!esp->auth.work_digest)
 			goto error;
 	}
