From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: [PATCH 1/26] block: cryptoloop - Use new skcipher interface
Date: Sun, 24 Jan 2016 21:16:06 +0800
Message-ID: <E1aNKWU-0008A9-Dx@gondolin.me.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch replaces uses of blkcipher with the new skcipher
interface.

Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
---

 drivers/block/cryptoloop.c |   48 +++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/block/cryptoloop.c b/drivers/block/cryptoloop.c
index 99e773c..3d31761 100644
--- a/drivers/block/cryptoloop.c
+++ b/drivers/block/cryptoloop.c
@@ -21,9 +21,9 @@
 
 #include <linux/module.h>
 
+#include <crypto/skcipher.h>
 #include <linux/init.h>
 #include <linux/string.h>
-#include <linux/crypto.h>
 #include <linux/blkdev.h>
 #include <linux/scatterlist.h>
 #include <asm/uaccess.h>
@@ -46,7 +46,7 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	char *cipher;
 	char *mode;
 	char *cmsp = cms;			/* c-m string pointer */
-	struct crypto_blkcipher *tfm;
+	struct crypto_skcipher *tfm;
 
 	/* encryption breaks for non sector aligned offsets */
 
@@ -82,12 +82,12 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	*cmsp++ = ')';
 	*cmsp = 0;
 
-	tfm = crypto_alloc_blkcipher(cms, 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_skcipher(cms, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
 		return PTR_ERR(tfm);
 
-	err = crypto_blkcipher_setkey(tfm, info->lo_encrypt_key,
-				      info->lo_encrypt_key_size);
+	err = crypto_skcipher_setkey(tfm, info->lo_encrypt_key,
+				     info->lo_encrypt_key_size);
 	
 	if (err != 0)
 		goto out_free_tfm;
@@ -96,17 +96,14 @@ cryptoloop_init(struct loop_device *lo, const struct loop_info64 *info)
 	return 0;
 
  out_free_tfm:
-	crypto_free_blkcipher(tfm);
+	crypto_free_skcipher(tfm);
 
  out:
 	return err;
 }
 
 
-typedef int (*encdec_cbc_t)(struct blkcipher_desc *desc,
-			struct scatterlist *sg_out,
-			struct scatterlist *sg_in,
-			unsigned int nsg);
+typedef int (*encdec_cbc_t)(struct skcipher_request *req);
 
 static int
 cryptoloop_transfer(struct loop_device *lo, int cmd,
@@ -114,11 +111,8 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		    struct page *loop_page, unsigned loop_off,
 		    int size, sector_t IV)
 {
-	struct crypto_blkcipher *tfm = lo->key_data;
-	struct blkcipher_desc desc = {
-		.tfm = tfm,
-		.flags = CRYPTO_TFM_REQ_MAY_SLEEP,
-	};
+	struct crypto_skcipher *tfm = lo->key_data;
+	SKCIPHER_REQUEST_ON_STACK(req, tfm);
 	struct scatterlist sg_out;
 	struct scatterlist sg_in;
 
@@ -127,6 +121,10 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 	unsigned in_offs, out_offs;
 	int err;
 
+	skcipher_request_set_tfm(req, tfm);
+	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
+				      NULL, NULL);
+
 	sg_init_table(&sg_out, 1);
 	sg_init_table(&sg_in, 1);
 
@@ -135,13 +133,13 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		in_offs = raw_off;
 		out_page = loop_page;
 		out_offs = loop_off;
-		encdecfunc = crypto_blkcipher_crt(tfm)->decrypt;
+		encdecfunc = crypto_skcipher_decrypt;
 	} else {
 		in_page = loop_page;
 		in_offs = loop_off;
 		out_page = raw_page;
 		out_offs = raw_off;
-		encdecfunc = crypto_blkcipher_crt(tfm)->encrypt;
+		encdecfunc = crypto_skcipher_encrypt;
 	}
 
 	while (size > 0) {
@@ -152,10 +150,10 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		sg_set_page(&sg_in, in_page, sz, in_offs);
 		sg_set_page(&sg_out, out_page, sz, out_offs);
 
-		desc.info = iv;
-		err = encdecfunc(&desc, &sg_out, &sg_in, sz);
+		skcipher_request_set_crypt(req, &sg_in, &sg_out, sz, iv);
+		err = encdecfunc(req);
 		if (err)
-			return err;
+			goto out;
 
 		IV++;
 		size -= sz;
@@ -163,7 +161,11 @@ cryptoloop_transfer(struct loop_device *lo, int cmd,
 		out_offs += sz;
 	}
 
-	return 0;
+	err = 0;
+
+out:
+	skcipher_request_zero(req);
+	return err;
 }
 
 static int
@@ -175,9 +177,9 @@ cryptoloop_ioctl(struct loop_device *lo, int cmd, unsigned long arg)
 static int
 cryptoloop_release(struct loop_device *lo)
 {
-	struct crypto_blkcipher *tfm = lo->key_data;
+	struct crypto_skcipher *tfm = lo->key_data;
 	if (tfm != NULL) {
-		crypto_free_blkcipher(tfm);
+		crypto_free_skcipher(tfm);
 		lo->key_data = NULL;
 		return 0;
 	}
