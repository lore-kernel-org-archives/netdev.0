From: James Morris <jmorris@redhat.com>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up IPSec
 with IPCOMP]
Date: Fri, 9 Jul 2004 00:20:56 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407090018500.2381-100000@thoron.boston.redhat.com>
References: <20040702143949.21a50b74.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, <jmorris@intercode.com.au>,
        <netdev@oss.sgi.com>, <christophe@saout.de>, <mjbligh@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040702143949.21a50b74.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2 Jul 2004, Andrew Morton wrote:

> Well no.  Those games with deflate_gfp() really need to go away. 
> in_atomic() works OK if CONFIG_PREEMPT is enabled.  But with
> CONFIG_PREEMPT=n, in_atomic() returns false inside spinlock.  And
> in_atomic()'s return value is unaffected by local_irq_disable().
> 
> This all needs to be redesigned, sorry.

Ok, fixed.  Lazy allocation is gone.

Please apply.

Signed-off-by: James Morris <jmorris@redhat.com>


diff -urN -X dontdiff linux-2.6.7-bk20.o/crypto/deflate.c linux-2.6.7-bk20.w/crypto/deflate.c
--- linux-2.6.7-bk20.o/crypto/deflate.c	2004-06-16 01:20:04.000000000 -0400
+++ linux-2.6.7-bk20.w/crypto/deflate.c	2004-07-09 00:38:43.137189624 -0400
@@ -39,44 +39,16 @@
 #define DEFLATE_DEF_MEMLEVEL		MAX_MEM_LEVEL
 
 struct deflate_ctx {
-	int comp_initialized;
-	int decomp_initialized;
 	struct z_stream_s comp_stream;
 	struct z_stream_s decomp_stream;
 };
 
-static inline int deflate_gfp(void)
-{
-	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
-}
-
-static int deflate_init(void *ctx)
-{
-	return 0;
-}
-
-static void deflate_exit(void *ctx)
-{
-	struct deflate_ctx *dctx = ctx;
-
-	if (dctx->comp_initialized)
-		vfree(dctx->comp_stream.workspace);
-	if (dctx->decomp_initialized)
-		kfree(dctx->decomp_stream.workspace);
-}
-
-/*
- * Lazy initialization to make interface simple without allocating
- * un-needed workspaces.  Thus can be called in softirq context.
- */
 static int deflate_comp_init(struct deflate_ctx *ctx)
 {
 	int ret = 0;
 	struct z_stream_s *stream = &ctx->comp_stream;
 
-	stream->workspace = __vmalloc(zlib_deflate_workspacesize(),
-	                              deflate_gfp()|__GFP_HIGHMEM,
-	                              PAGE_KERNEL);
+	stream->workspace = vmalloc(zlib_deflate_workspacesize());
 	if (!stream->workspace ) {
 		ret = -ENOMEM;
 		goto out;
@@ -89,7 +61,6 @@
 		ret = -EINVAL;
 		goto out_free;
 	}
-	ctx->comp_initialized = 1;
 out:	
 	return ret;
 out_free:
@@ -102,8 +73,7 @@
 	int ret = 0;
 	struct z_stream_s *stream = &ctx->decomp_stream;
 
-	stream->workspace = kmalloc(zlib_inflate_workspacesize(),
-	                            deflate_gfp());
+	stream->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
 	if (!stream->workspace ) {
 		ret = -ENOMEM;
 		goto out;
@@ -114,7 +84,6 @@
 		ret = -EINVAL;
 		goto out_free;
 	}
-	ctx->decomp_initialized = 1;
 out:
 	return ret;
 out_free:
@@ -122,6 +91,36 @@
 	goto out;
 }
 
+static void deflate_comp_exit(struct deflate_ctx *ctx)
+{
+	vfree(ctx->comp_stream.workspace);
+}
+
+static void deflate_decomp_exit(struct deflate_ctx *ctx)
+{
+	kfree(ctx->decomp_stream.workspace);
+}
+
+static int deflate_init(void *ctx)
+{
+	int ret;
+	
+	ret = deflate_comp_init(ctx);
+	if (ret)
+		goto out;
+	ret = deflate_decomp_init(ctx);
+	if (ret)
+		deflate_comp_exit(ctx);
+out:
+	return ret;
+}
+
+static void deflate_exit(void *ctx)
+{
+	deflate_comp_exit(ctx);
+	deflate_decomp_exit(ctx);
+}
+
 static int deflate_compress(void *ctx, const u8 *src, unsigned int slen,
 	                    u8 *dst, unsigned int *dlen)
 {
@@ -129,12 +128,6 @@
 	struct deflate_ctx *dctx = ctx;
 	struct z_stream_s *stream = &dctx->comp_stream;
 
-	if (!dctx->comp_initialized) {
-		ret = deflate_comp_init(dctx);
-		if (ret)
-			goto out;
-	}
-
 	ret = zlib_deflateReset(stream);
 	if (ret != Z_OK) {
 		ret = -EINVAL;
@@ -165,12 +158,6 @@
 	struct deflate_ctx *dctx = ctx;
 	struct z_stream_s *stream = &dctx->decomp_stream;
 
-	if (!dctx->decomp_initialized) {
-		ret = deflate_decomp_init(dctx);
-		if (ret)
-			goto out;
-	}
-
 	ret = zlib_inflateReset(stream);
 	if (ret != Z_OK) {
 		ret = -EINVAL;
