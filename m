From: David Miller <davem@davemloft.net>
Subject: [PATCH] net+crypto: Use vmalloc for zlib inflate buffers.
Date: Mon, 27 Jun 2011 21:26:18 -0700 (PDT)
Message-ID: <20110627.212618.657750275676567934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, herbert@gondor.hengli.com.au,
	mjackson220.list@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab1F1E00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:26:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are 64K and result in order-4 allocations, even with SLUB.

Therefore, just like we always have for the deflate buffers, use
vmalloc.

Reported-by: Martin Jackson <mjackson220.list@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

diff --git a/crypto/deflate.c b/crypto/deflate.c
index b5ccae2..b0165ec 100644
--- a/crypto/deflate.c
+++ b/crypto/deflate.c
@@ -32,7 +32,6 @@
 #include <linux/interrupt.h>
 #include <linux/mm.h>
 #include <linux/net.h>
-#include <linux/slab.h>
 
 #define DEFLATE_DEF_LEVEL		Z_DEFAULT_COMPRESSION
 #define DEFLATE_DEF_WINBITS		11
@@ -73,7 +72,7 @@ static int deflate_decomp_init(struct deflate_ctx *ctx)
 	int ret = 0;
 	struct z_stream_s *stream = &ctx->decomp_stream;
 
-	stream->workspace = kzalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	stream->workspace = vzalloc(zlib_inflate_workspacesize());
 	if (!stream->workspace) {
 		ret = -ENOMEM;
 		goto out;
@@ -86,7 +85,7 @@ static int deflate_decomp_init(struct deflate_ctx *ctx)
 out:
 	return ret;
 out_free:
-	kfree(stream->workspace);
+	vfree(stream->workspace);
 	goto out;
 }
 
@@ -99,7 +98,7 @@ static void deflate_comp_exit(struct deflate_ctx *ctx)
 static void deflate_decomp_exit(struct deflate_ctx *ctx)
 {
 	zlib_inflateEnd(&ctx->decomp_stream);
-	kfree(ctx->decomp_stream.workspace);
+	vfree(ctx->decomp_stream.workspace);
 }
 
 static int deflate_init(struct crypto_tfm *tfm)
diff --git a/crypto/zlib.c b/crypto/zlib.c
index d11d761..06b62e5 100644
--- a/crypto/zlib.c
+++ b/crypto/zlib.c
@@ -29,7 +29,6 @@
 #include <linux/interrupt.h>
 #include <linux/mm.h>
 #include <linux/net.h>
-#include <linux/slab.h>
 
 #include <crypto/internal/compress.h>
 
@@ -60,7 +59,7 @@ static void zlib_decomp_exit(struct zlib_ctx *ctx)
 
 	if (stream->workspace) {
 		zlib_inflateEnd(stream);
-		kfree(stream->workspace);
+		vfree(stream->workspace);
 		stream->workspace = NULL;
 	}
 }
@@ -228,13 +227,13 @@ static int zlib_decompress_setup(struct crypto_pcomp *tfm, void *params,
 				 ? nla_get_u32(tb[ZLIB_DECOMP_WINDOWBITS])
 				 : DEF_WBITS;
 
-	stream->workspace = kzalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	stream->workspace = vzalloc(zlib_inflate_workspacesize());
 	if (!stream->workspace)
 		return -ENOMEM;
 
 	ret = zlib_inflateInit2(stream, ctx->decomp_windowBits);
 	if (ret != Z_OK) {
-		kfree(stream->workspace);
+		vfree(stream->workspace);
 		stream->workspace = NULL;
 		return -EINVAL;
 	}
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 4b70311..74be989 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -49,6 +49,7 @@
 #include <linux/zlib.h>
 #include <linux/io.h>
 #include <linux/stringify.h>
+#include <linux/vmalloc.h>
 
 #define BNX2X_MAIN
 #include "bnx2x.h"
@@ -4537,8 +4538,7 @@ static int bnx2x_gunzip_init(struct bnx2x *bp)
 	if (bp->strm  == NULL)
 		goto gunzip_nomem2;
 
-	bp->strm->workspace = kmalloc(zlib_inflate_workspacesize(),
-				      GFP_KERNEL);
+	bp->strm->workspace = vmalloc(zlib_inflate_workspacesize());
 	if (bp->strm->workspace == NULL)
 		goto gunzip_nomem3;
 
@@ -4562,7 +4562,7 @@ gunzip_nomem1:
 static void bnx2x_gunzip_end(struct bnx2x *bp)
 {
 	if (bp->strm) {
-		kfree(bp->strm->workspace);
+		vfree(bp->strm->workspace);
 		kfree(bp->strm);
 		bp->strm = NULL;
 	}
diff --git a/drivers/net/ppp_deflate.c b/drivers/net/ppp_deflate.c
index 31e9407..1dbdf82 100644
--- a/drivers/net/ppp_deflate.c
+++ b/drivers/net/ppp_deflate.c
@@ -305,7 +305,7 @@ static void z_decomp_free(void *arg)
 
 	if (state) {
 		zlib_inflateEnd(&state->strm);
-		kfree(state->strm.workspace);
+		vfree(state->strm.workspace);
 		kfree(state);
 	}
 }
@@ -345,8 +345,7 @@ static void *z_decomp_alloc(unsigned char *options, int opt_len)
 
 	state->w_size         = w_size;
 	state->strm.next_out  = NULL;
-	state->strm.workspace = kmalloc(zlib_inflate_workspacesize(),
-					GFP_KERNEL|__GFP_REPEAT);
+	state->strm.workspace = vmalloc(zlib_inflate_workspacesize());
 	if (state->strm.workspace == NULL)
 		goto out_free;
 
