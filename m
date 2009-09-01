From: "Brad Bosch" <bradbosch@comcast.net>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Tue, 1 Sep 2009 10:42:44 -0500
Message-ID: <19101.16628.347039.619378@waldo.imnotcreative.homeip.net>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net>
	<20090829104606.GA13141@gondor.apana.org.au>
	<19099.63038.425414.514063@waldo.imnotcreative.homeip.net>
	<20090831220459.GA15713@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20090831220459.GA15713@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:
 > On Mon, Aug 31, 2009 at 11:11:42AM -0500, Brad Bosch wrote:
 > >
 > > OK.  I was looking for something subtle because the crash takes a long
 > > time to happen.  But do you agree that the race I described above also
 > > a real bug?
 > 
 > No I don't think it is.  CHAINV_STATE_INUSE guarantees that only
 > one entity can use ctx->err at any time.

I don't see how you are protecting ctx->err with the INUSE flag.  For
example:

If two threads enter async_chainiv_givencrypt at the same time, one
thread will call async_chainiv_postpone_request (INUSE will be clear
until set by async_chainiv_postpone_request) and the other thread will
call async_chainiv_givencrypt_tail (INUSE may or may not be set yet).

Now, ctx-err may be used by both async_chainiv_postpone_request to
store the return value from skcipher_enqueue_givcrypt and by
async_chainiv_givencrypt_tail to store the return value from
crypto_ablkcipher_encrypt at the same time.  This can cause the
calling function to think async_chainiv_givencrypt has completed it's
work, when in fact, the work was defered.

The patch I proposed earlier (included again below) avoids this and
also makes the error handling simpler and more direct without
requiring ctx->err at all.  I still don't understand why ctx->err was
required in the first place.

Did I miss something with regard to the use of ctx->err?

Now, as to the other bug...

 > 
 > Where we subtract the offset the pointer can never be NULL.  Please
 > try my patch.

OK.  I see now that your offset patch should indeed solve that
problem.  But why did you choose to fix it in a complex way?  My
suggestion just adds a single test while yours adds new parameters, a
new function and an extra function call.

Thanks for your help.

--Brad

Index: chainiv.c
===================================================================
RCS file: /share/cvs/sdg/kernels/kernel.wms/kernel_2_6_27/src/crypto/chainiv.c,v
retrieving revision 1.1.1.1.4.2
diff -u -r1.1.1.1.4.2 chainiv.c
--- chainiv.c	10 Mar 2009 05:16:24 -0000	1.1.1.1.4.2
+++ chainiv.c	27 Aug 2009 19:40:27 -0000
@@ -36,7 +36,6 @@
 	unsigned long state;
 
 	spinlock_t lock;
-	int err;
 
 	struct crypto_queue queue;
 	struct work_struct postponed;
@@ -114,10 +113,9 @@
 	return chainiv_init_common(tfm);
 }
 
-static int async_chainiv_schedule_work(struct async_chainiv_ctx *ctx)
+static void async_chainiv_schedule_work(struct async_chainiv_ctx *ctx)
 {
 	int queued;
-	int err = ctx->err;
 
 	if (!ctx->queue.qlen) {
 		smp_mb__before_clear_bit();
@@ -125,14 +123,11 @@
 
 		if (!ctx->queue.qlen ||
 		    test_and_set_bit(CHAINIV_STATE_INUSE, &ctx->state))
-			goto out;
+			return;
 	}
 
 	queued = schedule_work(&ctx->postponed);
 	BUG_ON(!queued);
-
-out:
-	return err;
 }
 
 static int async_chainiv_postpone_request(struct skcipher_givcrypt_request *req)
@@ -148,8 +143,8 @@
 	if (test_and_set_bit(CHAINIV_STATE_INUSE, &ctx->state))
 		return err;
 
-	ctx->err = err;
-	return async_chainiv_schedule_work(ctx);
+	async_chainiv_schedule_work(ctx);
+	return err;
 }
 
 static int async_chainiv_givencrypt_tail(struct skcipher_givcrypt_request *req)
@@ -158,18 +153,20 @@
 	struct async_chainiv_ctx *ctx = crypto_ablkcipher_ctx(geniv);
 	struct ablkcipher_request *subreq = skcipher_givcrypt_reqctx(req);
 	unsigned int ivsize = crypto_ablkcipher_ivsize(geniv);
+	int err;
 
 	memcpy(req->giv, ctx->iv, ivsize);
 	memcpy(subreq->info, ctx->iv, ivsize);
 
-	ctx->err = crypto_ablkcipher_encrypt(subreq);
-	if (ctx->err)
+	err = crypto_ablkcipher_encrypt(subreq);
+	if (err)
 		goto out;
 
 	memcpy(ctx->iv, subreq->info, ivsize);
 
 out:
-	return async_chainiv_schedule_work(ctx);
+	async_chainiv_schedule_work(ctx);
+	return err;
 }
 
 static int async_chainiv_givencrypt(struct skcipher_givcrypt_request *req)
@@ -236,7 +233,7 @@
 	spin_unlock_bh(&ctx->lock);
 
 	if (!req) {
-		async_chainiv_schedule_work(ctx);
+	    async_chainiv_schedule_work(ctx);
 		return;
 	}
 
