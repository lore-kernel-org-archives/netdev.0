From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSEC in 2.6.25 causes stalled connections
Date: Thu, 10 Jul 2008 17:43:45 +0800
Message-ID: <20080710094345.GA24162@gondor.apana.org.au>
References: <20080608010858.GA8877@swan.nt.tuwien.ac.at> <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au> <20080618004544.GA25439@swan.nt.tuwien.ac.at> <20080708080742.GA25027@gondor.apana.org.au> <20080708213302.GA28842@swan.nt.tuwien.ac.at> <20080709084334.GA12484@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54558 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751731AbYGJJnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 05:43:49 -0400
Content-Disposition: inline
In-Reply-To: <20080709084334.GA12484@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 04:43:34PM +0800, Herbert Xu wrote:
> 
> Thanks! I've reproduced the problem.  Now we just need to figure
> out what it is :)

OK, found it: chainiv never called the completion function!

commit 066068afee313b7746e7a3de05b57dcd4149a2fe
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Jul 10 17:42:36 2008 +0800

    crypto: chainiv - Invoke completion function
    
    When chainiv postpones requests it never calls their completion functions.
    This causes symptoms such as memory leaks when IPsec is in use.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/chainiv.c b/crypto/chainiv.c
index 6da3f57..9affade 100644
--- a/crypto/chainiv.c
+++ b/crypto/chainiv.c
@@ -117,6 +117,7 @@ static int chainiv_init(struct crypto_tfm *tfm)
 static int async_chainiv_schedule_work(struct async_chainiv_ctx *ctx)
 {
 	int queued;
+	int err = ctx->err;
 
 	if (!ctx->queue.qlen) {
 		smp_mb__before_clear_bit();
@@ -131,7 +132,7 @@ static int async_chainiv_schedule_work(struct async_chainiv_ctx *ctx)
 	BUG_ON(!queued);
 
 out:
-	return ctx->err;
+	return err;
 }
 
 static int async_chainiv_postpone_request(struct skcipher_givcrypt_request *req)
@@ -227,6 +228,7 @@ static void async_chainiv_do_postponed(struct work_struct *work)
 						     postponed);
 	struct skcipher_givcrypt_request *req;
 	struct ablkcipher_request *subreq;
+	int err;
 
 	/* Only handle one request at a time to avoid hogging keventd. */
 	spin_lock_bh(&ctx->lock);
@@ -241,7 +243,11 @@ static void async_chainiv_do_postponed(struct work_struct *work)
 	subreq = skcipher_givcrypt_reqctx(req);
 	subreq->base.flags |= CRYPTO_TFM_REQ_MAY_SLEEP;
 
-	async_chainiv_givencrypt_tail(req);
+	err = async_chainiv_givencrypt_tail(req);
+
+	local_bh_disable();
+	skcipher_givcrypt_complete(req, err);
+	local_bh_enable();
 }
 
 static int async_chainiv_init(struct crypto_tfm *tfm)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
